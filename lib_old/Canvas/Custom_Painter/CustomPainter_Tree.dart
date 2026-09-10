import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

//Add this CustomPaint widget to the Widget Tree

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter_Tree extends CustomPainter {
  final color_s;

  RPSCustomPainter_Tree(this.color_s);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.4017578, size.height * 0.5472031);
    path_0.cubicTo(
        size.width * 0.3810371,
        size.height * 0.5192891,
        size.width * 0.3478320,
        size.height * 0.5011953,
        size.width * 0.3103965,
        size.height * 0.5011953);
    path_0.cubicTo(
        size.width * 0.2475898,
        size.height * 0.5011953,
        size.width * 0.1966758,
        size.height * 0.5521094,
        size.width * 0.1966758,
        size.height * 0.6149160);
    path_0.cubicTo(
        size.width * 0.1966758,
        size.height * 0.6777227,
        size.width * 0.2475898,
        size.height * 0.7286367,
        size.width * 0.3103965,
        size.height * 0.7286367);
    path_0.cubicTo(
        size.width * 0.3231543,
        size.height * 0.7286367,
        size.width * 0.3354063,
        size.height * 0.7265059,
        size.width * 0.3468555,
        size.height * 0.7226289);
    path_0.cubicTo(
        size.width * 0.3605391,
        size.height * 0.7303984,
        size.width * 0.3763457,
        size.height * 0.7348574,
        size.width * 0.3932051,
        size.height * 0.7348574);
    path_0.cubicTo(
        size.width * 0.4451367,
        size.height * 0.7348574,
        size.width * 0.4872324,
        size.height * 0.6927598,
        size.width * 0.4872324,
        size.height * 0.6408301);
    path_0.cubicTo(
        size.width * 0.4872324,
        size.height * 0.5917813,
        size.width * 0.4496758,
        size.height * 0.5515254,
        size.width * 0.4017578,
        size.height * 0.5472031);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff47821C).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.4865547, size.height * 0.9851230);
    path_1.cubicTo(
        size.width * 0.4641660,
        size.height * 0.9851230,
        size.width * 0.4460156,
        size.height * 0.9669727,
        size.width * 0.4460156,
        size.height * 0.9445840);
    path_1.lineTo(size.width * 0.4460156, size.height * 0.4393750);
    path_1.cubicTo(
        size.width * 0.4460156,
        size.height * 0.4169863,
        size.width * 0.4641660,
        size.height * 0.3988359,
        size.width * 0.4865547,
        size.height * 0.3988359);
    path_1.cubicTo(
        size.width * 0.5089434,
        size.height * 0.3988359,
        size.width * 0.5270938,
        size.height * 0.4169863,
        size.width * 0.5270938,
        size.height * 0.4393750);
    path_1.lineTo(size.width * 0.5270938, size.height * 0.9445859);
    path_1.cubicTo(
        size.width * 0.5270938,
        size.height * 0.9669727,
        size.width * 0.5089434,
        size.height * 0.9851230,
        size.width * 0.4865547,
        size.height * 0.9851230);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xffCC7400).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.4865547, size.height * 0.9445859);
    path_2.lineTo(size.width * 0.4865547, size.height * 0.4393750);
    path_2.cubicTo(
        size.width * 0.4865547,
        size.height * 0.4243789,
        size.width * 0.4947188,
        size.height * 0.4113164,
        size.width * 0.5068242,
        size.height * 0.4043047);
    path_2.cubicTo(
        size.width * 0.5008574,
        size.height * 0.4008477,
        size.width * 0.4939473,
        size.height * 0.3988379,
        size.width * 0.4865547,
        size.height * 0.3988379);
    path_2.cubicTo(
        size.width * 0.4641660,
        size.height * 0.3988379,
        size.width * 0.4460156,
        size.height * 0.4169883,
        size.width * 0.4460156,
        size.height * 0.4393770);
    path_2.lineTo(size.width * 0.4460156, size.height * 0.9445879);
    path_2.cubicTo(
        size.width * 0.4460156,
        size.height * 0.9669766,
        size.width * 0.4641660,
        size.height * 0.9851270,
        size.width * 0.4865547,
        size.height * 0.9851270);
    path_2.cubicTo(
        size.width * 0.4939473,
        size.height * 0.9851270,
        size.width * 0.5008574,
        size.height * 0.9831172,
        size.width * 0.5068242,
        size.height * 0.9796602);
    path_2.cubicTo(
        size.width * 0.4947187,
        size.height * 0.9726426,
        size.width * 0.4865547,
        size.height * 0.9595801,
        size.width * 0.4865547,
        size.height * 0.9445859);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xffAA6100).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.8342539, size.height * 0.3530059);
    path_3.cubicTo(
        size.width * 0.8393809,
        size.height * 0.3386973,
        size.width * 0.8421914,
        size.height * 0.3232910,
        size.width * 0.8421914,
        size.height * 0.3072207);
    path_3.cubicTo(
        size.width * 0.8421914,
        size.height * 0.2322520,
        size.width * 0.7814180,
        size.height * 0.1714785,
        size.width * 0.7064492,
        size.height * 0.1714785);
    path_3.cubicTo(
        size.width * 0.6314805,
        size.height * 0.1714785,
        size.width * 0.5707070,
        size.height * 0.2322520,
        size.width * 0.5707070,
        size.height * 0.3072207);
    path_3.cubicTo(
        size.width * 0.5707070,
        size.height * 0.3158398,
        size.width * 0.5715449,
        size.height * 0.3242578,
        size.width * 0.5730820,
        size.height * 0.3324316);
    path_3.cubicTo(
        size.width * 0.4958691,
        size.height * 0.3457754,
        size.width * 0.4371211,
        size.height * 0.4130371,
        size.width * 0.4371211,
        size.height * 0.4940605);
    path_3.cubicTo(
        size.width * 0.4371211,
        size.height * 0.5846797,
        size.width * 0.5105820,
        size.height * 0.6581406,
        size.width * 0.6012012,
        size.height * 0.6581406);
    path_3.cubicTo(
        size.width * 0.6819629,
        size.height * 0.6581406,
        size.width * 0.7490488,
        size.height * 0.5997734,
        size.width * 0.7626973,
        size.height * 0.5229316);
    path_3.cubicTo(
        size.width * 0.7772832,
        size.height * 0.5323184,
        size.width * 0.7946289,
        size.height * 0.5377891,
        size.width * 0.8132656,
        size.height * 0.5377891);
    path_3.cubicTo(
        size.width * 0.8649512,
        size.height * 0.5377891,
        size.width * 0.9068535,
        size.height * 0.4958887,
        size.width * 0.9068535,
        size.height * 0.4442012);
    path_3.cubicTo(
        size.width * 0.9068555,
        size.height * 0.3997344,
        size.width * 0.8758301,
        size.height * 0.3625391,
        size.width * 0.8342539,
        size.height * 0.3530059);
    path_3.close();

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = Color(0xff4E901E).withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);

    Path path_4 = Path();
    path_4.moveTo(size.width * 0.7726680, size.height * 0.3148184);
    path_4.cubicTo(
        size.width * 0.7726680,
        size.height * 0.2619121,
        size.width * 0.7543437,
        size.height * 0.2119629,
        size.width * 0.7222031,
        size.height * 0.1724199);
    path_4.cubicTo(
        size.width * 0.7170332,
        size.height * 0.1718203,
        size.width * 0.7117812,
        size.height * 0.1714805,
        size.width * 0.7064492,
        size.height * 0.1714805);
    path_4.cubicTo(
        size.width * 0.6314805,
        size.height * 0.1714805,
        size.width * 0.5707070,
        size.height * 0.2322539,
        size.width * 0.5707070,
        size.height * 0.3072227);
    path_4.cubicTo(
        size.width * 0.5707070,
        size.height * 0.3158418,
        size.width * 0.5715449,
        size.height * 0.3242598,
        size.width * 0.5730820,
        size.height * 0.3324336);
    path_4.cubicTo(
        size.width * 0.4958691,
        size.height * 0.3457773,
        size.width * 0.4371211,
        size.height * 0.4130391,
        size.width * 0.4371211,
        size.height * 0.4940625);
    path_4.cubicTo(
        size.width * 0.4371211,
        size.height * 0.5635898,
        size.width * 0.4803887,
        size.height * 0.6229746,
        size.width * 0.5414492,
        size.height * 0.6468711);
    path_4.cubicTo(
        size.width * 0.5685020,
        size.height * 0.6168789,
        size.width * 0.5865371,
        size.height * 0.5786016,
        size.width * 0.5911445,
        size.height * 0.5363301);
    path_4.cubicTo(
        size.width * 0.6945293,
        size.height * 0.5156523,
        size.width * 0.7726680,
        size.height * 0.4241914,
        size.width * 0.7726680,
        size.height * 0.3148184);
    path_4.close();

    Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    paint_4_fill.color = Color(0xff47821C).withOpacity(1.0);
    canvas.drawPath(path_4, paint_4_fill);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.6297266, size.height * 0.6096094);
    path_5.cubicTo(
        size.width * 0.6232383,
        size.height * 0.6096094,
        size.width * 0.6172734,
        size.height * 0.6053281,
        size.width * 0.6154219,
        size.height * 0.5987734);
    path_5.cubicTo(
        size.width * 0.6131934,
        size.height * 0.5908711,
        size.width * 0.6177930,
        size.height * 0.5826562,
        size.width * 0.6256973,
        size.height * 0.5804277);
    path_5.cubicTo(
        size.width * 0.6584941,
        size.height * 0.5711777,
        size.width * 0.6835371,
        size.height * 0.5435078,
        size.width * 0.6895000,
        size.height * 0.5099336);
    path_5.cubicTo(
        size.width * 0.6909375,
        size.height * 0.5018477,
        size.width * 0.6986562,
        size.height * 0.4964473,
        size.width * 0.7067402,
        size.height * 0.4978945);
    path_5.cubicTo(
        size.width * 0.7148242,
        size.height * 0.4993301,
        size.width * 0.7202148,
        size.height * 0.5070488,
        size.width * 0.7187793,
        size.height * 0.5151348);
    path_5.cubicTo(
        size.width * 0.7108340,
        size.height * 0.5598613,
        size.width * 0.6774668,
        size.height * 0.5967266,
        size.width * 0.6337695,
        size.height * 0.6090508);
    path_5.cubicTo(
        size.width * 0.6324219,
        size.height * 0.6094277,
        size.width * 0.6310605,
        size.height * 0.6096094,
        size.width * 0.6297266,
        size.height * 0.6096094);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.color = Color(0xff47821C).withOpacity(1.0);
    canvas.drawPath(path_5, paint_5_fill);

    Path path_6 = Path();
    path_6.moveTo(size.width * 0.3949160, size.height * 0.3781973);
    path_6.cubicTo(
        size.width * 0.3714121,
        size.height * 0.3781973,
        size.width * 0.3492949,
        size.height * 0.3841387,
        size.width * 0.3299805,
        size.height * 0.3945938);
    path_6.cubicTo(
        size.width * 0.3099766,
        size.height * 0.3796934,
        size.width * 0.2851777,
        size.height * 0.3708691,
        size.width * 0.2583145,
        size.height * 0.3708691);
    path_6.cubicTo(
        size.width * 0.2572988,
        size.height * 0.3708691,
        size.width * 0.2562988,
        size.height * 0.3709199,
        size.width * 0.2552891,
        size.height * 0.3709473);
    path_6.cubicTo(
        size.width * 0.2418613,
        size.height * 0.3416250,
        size.width * 0.2122813,
        size.height * 0.3212402,
        size.width * 0.1779199,
        size.height * 0.3212402);
    path_6.cubicTo(
        size.width * 0.1309355,
        size.height * 0.3212402,
        size.width * 0.09284766,
        size.height * 0.3593281,
        size.width * 0.09284766,
        size.height * 0.4063125);
    path_6.cubicTo(
        size.width * 0.09284766,
        size.height * 0.4391113,
        size.width * 0.1114199,
        size.height * 0.4675566,
        size.width * 0.1386113,
        size.height * 0.4817539);
    path_6.cubicTo(
        size.width * 0.1383809,
        size.height * 0.4847949,
        size.width * 0.1382246,
        size.height * 0.4878574,
        size.width * 0.1382246,
        size.height * 0.4909590);
    path_6.cubicTo(
        size.width * 0.1382246,
        size.height * 0.5572832,
        size.width * 0.1919902,
        size.height * 0.6110488,
        size.width * 0.2583145,
        size.height * 0.6110488);
    path_6.cubicTo(
        size.width * 0.2704336,
        size.height * 0.6110488,
        size.width * 0.2821250,
        size.height * 0.6092363,
        size.width * 0.2931523,
        size.height * 0.6058984);
    path_6.cubicTo(
        size.width * 0.3181641,
        size.height * 0.6338184,
        size.width * 0.3544805,
        size.height * 0.6514004,
        size.width * 0.3949141,
        size.height * 0.6514004);
    path_6.cubicTo(
        size.width * 0.4703555,
        size.height * 0.6514004,
        size.width * 0.5315137,
        size.height * 0.5902422,
        size.width * 0.5315137,
        size.height * 0.5148008);
    path_6.cubicTo(
        size.width * 0.5315137,
        size.height * 0.4393594,
        size.width * 0.4703594,
        size.height * 0.3781973,
        size.width * 0.3949160,
        size.height * 0.3781973);
    path_6.close();

    Paint paint_6_fill = Paint()..style = PaintingStyle.fill;
    paint_6_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawPath(path_6, paint_6_fill);

    Path path_7 = Path();
    path_7.moveTo(size.width * 0.2407988, size.height * 0.5316406);
    path_7.cubicTo(
        size.width * 0.2136074,
        size.height * 0.5174434,
        size.width * 0.1950352,
        size.height * 0.4889980,
        size.width * 0.1950352,
        size.height * 0.4561992);
    path_7.cubicTo(
        size.width * 0.1950352,
        size.height * 0.4122051,
        size.width * 0.2284297,
        size.height * 0.3760156,
        size.width * 0.2712539,
        size.height * 0.3715840);
    path_7.cubicTo(
        size.width * 0.2670020,
        size.height * 0.3711289,
        size.width * 0.2626895,
        size.height * 0.3708711,
        size.width * 0.2583145,
        size.height * 0.3708711);
    path_7.cubicTo(
        size.width * 0.2572988,
        size.height * 0.3708711,
        size.width * 0.2562988,
        size.height * 0.3709219,
        size.width * 0.2552891,
        size.height * 0.3709492);
    path_7.cubicTo(
        size.width * 0.2418633,
        size.height * 0.3416270,
        size.width * 0.2122813,
        size.height * 0.3212422,
        size.width * 0.1779199,
        size.height * 0.3212422);
    path_7.cubicTo(
        size.width * 0.1309355,
        size.height * 0.3212422,
        size.width * 0.09284766,
        size.height * 0.3593301,
        size.width * 0.09284766,
        size.height * 0.4063145);
    path_7.cubicTo(
        size.width * 0.09284766,
        size.height * 0.4391133,
        size.width * 0.1114199,
        size.height * 0.4675586,
        size.width * 0.1386133,
        size.height * 0.4817559);
    path_7.cubicTo(
        size.width * 0.1383809,
        size.height * 0.4847969,
        size.width * 0.1382266,
        size.height * 0.4878594,
        size.width * 0.1382266,
        size.height * 0.4909609);
    path_7.cubicTo(
        size.width * 0.1382266,
        size.height * 0.5572852,
        size.width * 0.1919922,
        size.height * 0.6110508,
        size.width * 0.2583164,
        size.height * 0.6110508);
    path_7.cubicTo(
        size.width * 0.2598965,
        size.height * 0.6110508,
        size.width * 0.2614688,
        size.height * 0.6110176,
        size.width * 0.2630352,
        size.height * 0.6109551);
    path_7.cubicTo(
        size.width * 0.2488184,
        size.height * 0.5912227,
        size.width * 0.2404160,
        size.height * 0.5670234,
        size.width * 0.2404160,
        size.height * 0.5408457);
    path_7.cubicTo(
        size.width * 0.2404141,
        size.height * 0.5377441,
        size.width * 0.2405703,
        size.height * 0.5346816,
        size.width * 0.2407988,
        size.height * 0.5316406);
    path_7.close();

    Paint paint_7_fill = Paint()..style = PaintingStyle.fill;
    paint_7_fill.color = Color(0xff4E901E).withOpacity(1.0);
    canvas.drawPath(path_7, paint_7_fill);

    Path path_8 = Path();
    path_8.moveTo(size.width * 0.3949160, size.height * 0.3781973);
    path_8.cubicTo(
        size.width * 0.3714121,
        size.height * 0.3781973,
        size.width * 0.3492949,
        size.height * 0.3841387,
        size.width * 0.3299805,
        size.height * 0.3945938);
    path_8.cubicTo(
        size.width * 0.3099746,
        size.height * 0.3796934,
        size.width * 0.2851777,
        size.height * 0.3708691,
        size.width * 0.2583145,
        size.height * 0.3708691);
    path_8.cubicTo(
        size.width * 0.2572988,
        size.height * 0.3708691,
        size.width * 0.2562988,
        size.height * 0.3709199,
        size.width * 0.2552891,
        size.height * 0.3709473);
    path_8.cubicTo(
        size.width * 0.2418633,
        size.height * 0.3416250,
        size.width * 0.2122813,
        size.height * 0.3212402,
        size.width * 0.1779199,
        size.height * 0.3212402);
    path_8.cubicTo(
        size.width * 0.1690254,
        size.height * 0.3212402,
        size.width * 0.1604492,
        size.height * 0.3226094,
        size.width * 0.1523906,
        size.height * 0.3251445);
    path_8.cubicTo(
        size.width * 0.1701992,
        size.height * 0.4201816,
        size.width * 0.2537793,
        size.height * 0.4923320,
        size.width * 0.3539082,
        size.height * 0.4923320);
    path_8.cubicTo(
        size.width * 0.3697949,
        size.height * 0.4923320,
        size.width * 0.3853691,
        size.height * 0.4905547,
        size.width * 0.4005215,
        size.height * 0.4870234);
    path_8.cubicTo(
        size.width * 0.4365859,
        size.height * 0.5177910,
        size.width * 0.4813379,
        size.height * 0.5363301,
        size.width * 0.5291562,
        size.height * 0.5400059);
    path_8.cubicTo(
        size.width * 0.5306816,
        size.height * 0.5318340,
        size.width * 0.5315156,
        size.height * 0.5234160,
        size.width * 0.5315156,
        size.height * 0.5148027);
    path_8.cubicTo(
        size.width * 0.5315176,
        size.height * 0.4393555,
        size.width * 0.4703594,
        size.height * 0.3781973,
        size.width * 0.3949160,
        size.height * 0.3781973);
    path_8.close();

    Paint paint_8_fill = Paint()..style = PaintingStyle.fill;
    paint_8_fill.color = Color(0xff4E901E).withOpacity(1.0);
    canvas.drawPath(path_8, paint_8_fill);

    Path path_9 = Path();
    path_9.moveTo(size.width * 0.6236445, size.height * 0.1687188);
    path_9.cubicTo(
        size.width * 0.6244570,
        size.height * 0.1627148,
        size.width * 0.6249160,
        size.height * 0.1565977,
        size.width * 0.6249160,
        size.height * 0.1503711);
    path_9.cubicTo(
        size.width * 0.6249160,
        size.height * 0.07553516,
        size.width * 0.5642500,
        size.height * 0.01486719,
        size.width * 0.4894121,
        size.height * 0.01486719);
    path_9.cubicTo(
        size.width * 0.4170234,
        size.height * 0.01486719,
        size.width * 0.3579004,
        size.height * 0.07163281,
        size.width * 0.3541094,
        size.height * 0.1430762);
    path_9.cubicTo(
        size.width * 0.3540410,
        size.height * 0.1430762,
        size.width * 0.3539766,
        size.height * 0.1430703,
        size.width * 0.3539082,
        size.height * 0.1430703);
    path_9.cubicTo(
        size.width * 0.2742559,
        size.height * 0.1430703,
        size.width * 0.2096836,
        size.height * 0.2076426,
        size.width * 0.2096836,
        size.height * 0.2872949);
    path_9.cubicTo(
        size.width * 0.2096836,
        size.height * 0.3669473,
        size.width * 0.2742559,
        size.height * 0.4315195,
        size.width * 0.3539082,
        size.height * 0.4315195);
    path_9.cubicTo(
        size.width * 0.3765801,
        size.height * 0.4315195,
        size.width * 0.3980215,
        size.height * 0.4262734,
        size.width * 0.4171094,
        size.height * 0.4169512);
    path_9.cubicTo(
        size.width * 0.4473418,
        size.height * 0.4552773,
        size.width * 0.4941641,
        size.height * 0.4799082,
        size.width * 0.5467656,
        size.height * 0.4799082);
    path_9.cubicTo(
        size.width * 0.6379453,
        size.height * 0.4799082,
        size.width * 0.7118613,
        size.height * 0.4059922,
        size.width * 0.7118613,
        size.height * 0.3148125);
    path_9.cubicTo(
        size.width * 0.7118594,
        size.height * 0.2514043,
        size.width * 0.6760898,
        size.height * 0.1963750,
        size.width * 0.6236445,
        size.height * 0.1687188);
    path_9.close();

    Paint paint_9_fill = Paint()..style = PaintingStyle.fill;
    paint_9_fill.color = Color(0xff6DC82A).withOpacity(1.0);
    canvas.drawPath(path_9, paint_9_fill);

    Path path_10 = Path();
    path_10.moveTo(size.width * 0.4246543, size.height * 0.2256641);
    path_10.cubicTo(
        size.width * 0.4247227,
        size.height * 0.2256641,
        size.width * 0.4247871,
        size.height * 0.2256680,
        size.width * 0.4248555,
        size.height * 0.2256699);
    path_10.cubicTo(
        size.width * 0.4286465,
        size.height * 0.1542266,
        size.width * 0.4877695,
        size.height * 0.09746094,
        size.width * 0.5601563,
        size.height * 0.09746094);
    path_10.cubicTo(
        size.width * 0.5812656,
        size.height * 0.09746094,
        size.width * 0.6012461,
        size.height * 0.1022930,
        size.width * 0.6190566,
        size.height * 0.1109023);
    path_10.cubicTo(
        size.width * 0.6021562,
        size.height * 0.05532031,
        size.width * 0.5505156,
        size.height * 0.01486719,
        size.width * 0.4894102,
        size.height * 0.01486719);
    path_10.cubicTo(
        size.width * 0.4170215,
        size.height * 0.01486719,
        size.width * 0.3578984,
        size.height * 0.07163281,
        size.width * 0.3541074,
        size.height * 0.1430762);
    path_10.cubicTo(
        size.width * 0.3540391,
        size.height * 0.1430762,
        size.width * 0.3539746,
        size.height * 0.1430703,
        size.width * 0.3539062,
        size.height * 0.1430703);
    path_10.cubicTo(
        size.width * 0.2742539,
        size.height * 0.1430703,
        size.width * 0.2096816,
        size.height * 0.2076426,
        size.width * 0.2096816,
        size.height * 0.2872949);
    path_10.cubicTo(
        size.width * 0.2096816,
        size.height * 0.3431250,
        size.width * 0.2414238,
        size.height * 0.3915078,
        size.width * 0.2878262,
        size.height * 0.4154785);
    path_10.cubicTo(
        size.width * 0.2830527,
        size.height * 0.4011426,
        size.width * 0.2804277,
        size.height * 0.3858262,
        size.width * 0.2804277,
        size.height * 0.3698867);
    path_10.cubicTo(
        size.width * 0.2804297,
        size.height * 0.2902363,
        size.width * 0.3450000,
        size.height * 0.2256641,
        size.width * 0.4246543,
        size.height * 0.2256641);
    path_10.close();

    Paint paint_10_fill = Paint()..style = PaintingStyle.fill;
    paint_10_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawPath(path_10, paint_10_fill);

    Path path_11 = Path();
    path_11.moveTo(size.width * 0.5467656, size.height * 0.4353066);
    path_11.cubicTo(
        size.width * 0.5385527,
        size.height * 0.4353066,
        size.width * 0.5318965,
        size.height * 0.4286484,
        size.width * 0.5318965,
        size.height * 0.4204375);
    path_11.cubicTo(
        size.width * 0.5318965,
        size.height * 0.4122266,
        size.width * 0.5385527,
        size.height * 0.4055684,
        size.width * 0.5467656,
        size.height * 0.4055684);
    path_11.cubicTo(
        size.width * 0.5968066,
        size.height * 0.4055684,
        size.width * 0.6375176,
        size.height * 0.3648574,
        size.width * 0.6375176,
        size.height * 0.3148164);
    path_11.cubicTo(
        size.width * 0.6375176,
        size.height * 0.3066055,
        size.width * 0.6441738,
        size.height * 0.2999473,
        size.width * 0.6523867,
        size.height * 0.2999473);
    path_11.cubicTo(
        size.width * 0.6605996,
        size.height * 0.2999473,
        size.width * 0.6672559,
        size.height * 0.3066055,
        size.width * 0.6672559,
        size.height * 0.3148164);
    path_11.cubicTo(
        size.width * 0.6672539,
        size.height * 0.3812559,
        size.width * 0.6132031,
        size.height * 0.4353066,
        size.width * 0.5467656,
        size.height * 0.4353066);
    path_11.close();

    Paint paint_11_fill = Paint()..style = PaintingStyle.fill;
    paint_11_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawPath(path_11, paint_11_fill);

    Paint paint_12_fill = Paint()..style = PaintingStyle.fill;
    paint_12_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.3419590, size.height * 0.3645234),
        size.width * 0.03776758, paint_12_fill);

    Paint paint_13_fill = Paint()..style = PaintingStyle.fill;
    paint_13_fill.color = Color(0xff4E901E).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.3987969, size.height * 0.5731621),
        size.width * 0.03776758, paint_13_fill);

    Paint paint_14_fill = Paint()..style = PaintingStyle.fill;
    paint_14_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.5315254, size.height * 0.2195820),
        size.width * 0.03776758, paint_14_fill);

    Paint paint_15_fill = Paint()..style = PaintingStyle.fill;
    paint_15_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.5692734, size.height * 0.3012012),
        size.width * 0.01440234, paint_15_fill);

    Paint paint_16_fill = Paint()..style = PaintingStyle.fill;
    paint_16_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.4365449, size.height * 0.3086152),
        size.width * 0.01440234, paint_16_fill);

    Paint paint_17_fill = Paint()..style = PaintingStyle.fill;
    paint_17_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.4793457, size.height * 0.3823652),
        size.width * 0.01440234, paint_17_fill);

    Paint paint_18_fill = Paint()..style = PaintingStyle.fill;
    paint_18_fill.color = Color(0xff4E901E).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.2977891, size.height * 0.5267305),
        size.width * 0.01440234, paint_18_fill);

    Path path_19 = Path();
    path_19.moveTo(size.width * 0.8945820, size.height * 0.9851230);
    path_19.cubicTo(
        size.width * 0.9011055,
        size.height * 0.9746445,
        size.width * 0.9048848,
        size.height * 0.9622832,
        size.width * 0.9048848,
        size.height * 0.9490293);
    path_19.cubicTo(
        size.width * 0.9048848,
        size.height * 0.9152559,
        size.width * 0.8803984,
        size.height * 0.8872168,
        size.width * 0.8482129,
        size.height * 0.8816543);
    path_19.cubicTo(
        size.width * 0.8418672,
        size.height * 0.8296973,
        size.width * 0.7976250,
        size.height * 0.7894434,
        size.width * 0.7439551,
        size.height * 0.7894434);
    path_19.cubicTo(
        size.width * 0.6859277,
        size.height * 0.7894434,
        size.width * 0.6388867,
        size.height * 0.8364844,
        size.width * 0.6388867,
        size.height * 0.8945117);
    path_19.cubicTo(
        size.width * 0.6388867,
        size.height * 0.8963848,
        size.width * 0.6389395,
        size.height * 0.8982441,
        size.width * 0.6390371,
        size.height * 0.9000918);
    path_19.cubicTo(
        size.width * 0.6158047,
        size.height * 0.9103184,
        size.width * 0.5995781,
        size.height * 0.9335273,
        size.width * 0.5995781,
        size.height * 0.9605410);
    path_19.cubicTo(
        size.width * 0.5995781,
        size.height * 0.9692324,
        size.width * 0.6012734,
        size.height * 0.9775215,
        size.width * 0.6043262,
        size.height * 0.9851211);
    path_19.lineTo(size.width * 0.8945820, size.height * 0.9851230);
    path_19.lineTo(size.width * 0.8945820, size.height * 0.9851230);
    path_19.close();

    Paint paint_19_fill = Paint()..style = PaintingStyle.fill;
    paint_19_fill.color = Color(0xff6DC82A).withOpacity(1.0);
    canvas.drawPath(path_19, paint_19_fill);

    Path path_20 = Path();
    path_20.moveTo(size.width * 0.7067148, size.height * 0.9318164);
    path_20.cubicTo(
        size.width * 0.7066172,
        size.height * 0.9299687,
        size.width * 0.7065645,
        size.height * 0.9281074,
        size.width * 0.7065645,
        size.height * 0.9262363);
    path_20.cubicTo(
        size.width * 0.7065645,
        size.height * 0.8682090,
        size.width * 0.7536055,
        size.height * 0.8211680,
        size.width * 0.8116328,
        size.height * 0.8211680);
    path_20.cubicTo(
        size.width * 0.8142598,
        size.height * 0.8211680,
        size.width * 0.8168555,
        size.height * 0.8212930,
        size.width * 0.8194316,
        size.height * 0.8214805);
    path_20.cubicTo(
        size.width * 0.8003379,
        size.height * 0.8017363,
        size.width * 0.7735918,
        size.height * 0.7894473,
        size.width * 0.7439512,
        size.height * 0.7894473);
    path_20.cubicTo(
        size.width * 0.6859238,
        size.height * 0.7894473,
        size.width * 0.6388828,
        size.height * 0.8364883,
        size.width * 0.6388828,
        size.height * 0.8945156);
    path_20.cubicTo(
        size.width * 0.6388828,
        size.height * 0.8963887,
        size.width * 0.6389355,
        size.height * 0.8982480,
        size.width * 0.6390332,
        size.height * 0.9000957);
    path_20.cubicTo(
        size.width * 0.6158008,
        size.height * 0.9103223,
        size.width * 0.5995742,
        size.height * 0.9335312,
        size.width * 0.5995742,
        size.height * 0.9605449);
    path_20.cubicTo(
        size.width * 0.5995742,
        size.height * 0.9692363,
        size.width * 0.6012695,
        size.height * 0.9775254,
        size.width * 0.6043223,
        size.height * 0.9851270);
    path_20.lineTo(size.width * 0.6676816, size.height * 0.9851270);
    path_20.cubicTo(
        size.width * 0.6702598,
        size.height * 0.9612148,
        size.width * 0.6855625,
        size.height * 0.9411250,
        size.width * 0.7067148,
        size.height * 0.9318164);
    path_20.close();

    Paint paint_20_fill = Paint()..style = PaintingStyle.fill;
    paint_20_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawPath(path_20, paint_20_fill);

    Paint paint_21_fill = Paint()..style = PaintingStyle.fill;
    paint_21_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.7816777, size.height * 0.9103652),
        size.width * 0.03776758, paint_21_fill);

    Paint paint_22_fill = Paint()..style = PaintingStyle.fill;
    paint_22_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.8588359, size.height * 0.9247773),
        size.width * 0.01440234, paint_22_fill);

    Path path_23 = Path();
    path_23.moveTo(size.width * 0.3699277, size.height * 0.9845195);
    path_23.cubicTo(
        size.width * 0.3727402,
        size.height * 0.9772832,
        size.width * 0.3743027,
        size.height * 0.9694199,
        size.width * 0.3743027,
        size.height * 0.9611875);
    path_23.cubicTo(
        size.width * 0.3743027,
        size.height * 0.9256113,
        size.width * 0.3454609,
        size.height * 0.8967695,
        size.width * 0.3098848,
        size.height * 0.8967695);
    path_23.cubicTo(
        size.width * 0.3067129,
        size.height * 0.8967695,
        size.width * 0.3035957,
        size.height * 0.8970098,
        size.width * 0.3005469,
        size.height * 0.8974512);
    path_23.cubicTo(
        size.width * 0.2874316,
        size.height * 0.8584668,
        size.width * 0.2506133,
        size.height * 0.8303770,
        size.width * 0.2072109,
        size.height * 0.8303770);
    path_23.cubicTo(
        size.width * 0.1528203,
        size.height * 0.8303770,
        size.width * 0.1087305,
        size.height * 0.8744668,
        size.width * 0.1087305,
        size.height * 0.9288574);
    path_23.cubicTo(
        size.width * 0.1087305,
        size.height * 0.9495176,
        size.width * 0.1151035,
        size.height * 0.9686797,
        size.width * 0.1259746,
        size.height * 0.9845156);
    path_23.lineTo(size.width * 0.3699277, size.height * 0.9845156);
    path_23.lineTo(size.width * 0.3699277, size.height * 0.9845195);
    path_23.close();

    Paint paint_23_fill = Paint()..style = PaintingStyle.fill;
    paint_23_fill.color = Color(0xff6DC82A).withOpacity(1.0);
    canvas.drawPath(path_23, paint_23_fill);

    Path path_24 = Path();
    path_24.moveTo(size.width * 0.2674023, size.height * 0.8621094);
    path_24.cubicTo(
        size.width * 0.2717930,
        size.height * 0.8621094,
        size.width * 0.2761133,
        size.height * 0.8624102,
        size.width * 0.2803516,
        size.height * 0.8629687);
    path_24.cubicTo(
        size.width * 0.2623340,
        size.height * 0.8429668,
        size.width * 0.2362520,
        size.height * 0.8303789,
        size.width * 0.2072109,
        size.height * 0.8303789);
    path_24.cubicTo(
        size.width * 0.1528203,
        size.height * 0.8303789,
        size.width * 0.1087305,
        size.height * 0.8744688,
        size.width * 0.1087305,
        size.height * 0.9288594);
    path_24.cubicTo(
        size.width * 0.1087305,
        size.height * 0.9495195,
        size.width * 0.1151035,
        size.height * 0.9686816,
        size.width * 0.1259746,
        size.height * 0.9845176);
    path_24.lineTo(size.width * 0.1718711, size.height * 0.9845176);
    path_24.cubicTo(
        size.width * 0.1699551,
        size.height * 0.9768555,
        size.width * 0.1689219,
        size.height * 0.9688457,
        size.width * 0.1689219,
        size.height * 0.9605879);
    path_24.cubicTo(
        size.width * 0.1689219,
        size.height * 0.9062012,
        size.width * 0.2130137,
        size.height * 0.8621094,
        size.width * 0.2674023,
        size.height * 0.8621094);
    path_24.close();

    Paint paint_24_fill = Paint()..style = PaintingStyle.fill;
    paint_24_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawPath(path_24, paint_24_fill);

    Paint paint_25_fill = Paint()..style = PaintingStyle.fill;
    paint_25_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.2271133, size.height * 0.9247773),
        size.width * 0.01440234, paint_25_fill);

    Paint paint_26_fill = Paint()..style = PaintingStyle.fill;
    paint_26_fill.color = Color(0xff5EAC24).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.2968574, size.height * 0.9481309),
        size.width * 0.01440234, paint_26_fill);

    Path path_27 = Path();
    path_27.moveTo(size.width * 0.6579805, size.height * 0.6321562);
    path_27.cubicTo(
        size.width * 0.6528203,
        size.height * 0.6342773,
        size.width * 0.6474746,
        size.height * 0.6361250,
        size.width * 0.6420938,
        size.height * 0.6376504);
    path_27.cubicTo(
        size.width * 0.6341934,
        size.height * 0.6398887,
        size.width * 0.6296035,
        size.height * 0.6481074,
        size.width * 0.6318418,
        size.height * 0.6560098);
    path_27.cubicTo(
        size.width * 0.6336973,
        size.height * 0.6625566,
        size.width * 0.6396543,
        size.height * 0.6668281,
        size.width * 0.6461387,
        size.height * 0.6668281);
    path_27.cubicTo(
        size.width * 0.6474805,
        size.height * 0.6668281,
        size.width * 0.6488457,
        size.height * 0.6666465,
        size.width * 0.6502012,
        size.height * 0.6662617);
    path_27.cubicTo(
        size.width * 0.6566641,
        size.height * 0.6644297,
        size.width * 0.6630859,
        size.height * 0.6622090,
        size.width * 0.6692852,
        size.height * 0.6596602);
    path_27.cubicTo(
        size.width * 0.6768809,
        size.height * 0.6565371,
        size.width * 0.6805059,
        size.height * 0.6478477,
        size.width * 0.6773828,
        size.height * 0.6402539);
    path_27.cubicTo(
        size.width * 0.6742637,
        size.height * 0.6326602,
        size.width * 0.6655703,
        size.height * 0.6290391,
        size.width * 0.6579805,
        size.height * 0.6321562);
    path_27.close();

    Paint paint_27_fill = Paint()..style = PaintingStyle.fill;
    paint_27_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_27, paint_27_fill);

    Path path_28 = Path();
    path_28.moveTo(size.width * 0.8612520, size.height * 0.8695215);
    path_28.cubicTo(
        size.width * 0.8496523,
        size.height * 0.8147129,
        size.width * 0.8009551,
        size.height * 0.7745762,
        size.width * 0.7439551,
        size.height * 0.7745762);
    path_28.cubicTo(
        size.width * 0.6789570,
        size.height * 0.7745762,
        size.width * 0.6258672,
        size.height * 0.8265547,
        size.width * 0.6240625,
        size.height * 0.8911270);
    path_28.cubicTo(
        size.width * 0.5998672,
        size.height * 0.9056094,
        size.width * 0.5847031,
        size.height * 0.9318789,
        size.width * 0.5847031,
        size.height * 0.9605430);
    path_28.cubicTo(
        size.width * 0.5847031,
        size.height * 0.9709160,
        size.width * 0.5866602,
        size.height * 0.9810508,
        size.width * 0.5905215,
        size.height * 0.9906660);
    path_28.cubicTo(
        size.width * 0.5927852,
        size.height * 0.9963008,
        size.width * 0.5982461,
        size.height * 0.9999941,
        size.width * 0.6043203,
        size.height * 0.9999941);
    path_28.lineTo(size.width * 0.8945781, size.height * 0.9999941);
    path_28.cubicTo(
        size.width * 0.8997129,
        size.height * 0.9999941,
        size.width * 0.9044844,
        size.height * 0.9973437,
        size.width * 0.9071992,
        size.height * 0.9929863);
    path_28.cubicTo(
        size.width * 0.9154102,
        size.height * 0.9798008,
        size.width * 0.9197500,
        size.height * 0.9646016,
        size.width * 0.9197500,
        size.height * 0.9490352);
    path_28.cubicTo(
        size.width * 0.9197539,
        size.height * 0.9120664,
        size.width * 0.8957148,
        size.height * 0.8801699,
        size.width * 0.8612520,
        size.height * 0.8695215);
    path_28.close();
    path_28.moveTo(size.width * 0.8856309, size.height * 0.9702539);
    path_28.lineTo(size.width * 0.6153691, size.height * 0.9702539);
    path_28.cubicTo(
        size.width * 0.6147520,
        size.height * 0.9670703,
        size.width * 0.6144434,
        size.height * 0.9638242,
        size.width * 0.6144434,
        size.height * 0.9605410);
    path_28.cubicTo(
        size.width * 0.6144434,
        size.height * 0.9402637,
        size.width * 0.6264473,
        size.height * 0.9218809,
        size.width * 0.6450254,
        size.height * 0.9137031);
    path_28.cubicTo(
        size.width * 0.6506816,
        size.height * 0.9112148,
        size.width * 0.6542070,
        size.height * 0.9054883,
        size.width * 0.6538828,
        size.height * 0.8993184);
    path_28.cubicTo(
        size.width * 0.6537969,
        size.height * 0.8976875,
        size.width * 0.6537559,
        size.height * 0.8960703,
        size.width * 0.6537559,
        size.height * 0.8945156);
    path_28.cubicTo(
        size.width * 0.6537559,
        size.height * 0.8447793,
        size.width * 0.6942188,
        size.height * 0.8043145,
        size.width * 0.7439551,
        size.height * 0.8043145);
    path_28.cubicTo(
        size.width * 0.7894668,
        size.height * 0.8043145,
        size.width * 0.8279434,
        size.height * 0.8383398,
        size.width * 0.8334551,
        size.height * 0.8834570);
    path_28.cubicTo(
        size.width * 0.8342480,
        size.height * 0.8899668,
        size.width * 0.8392168,
        size.height * 0.8951875,
        size.width * 0.8456816,
        size.height * 0.8963047);
    path_28.cubicTo(
        size.width * 0.8713711,
        size.height * 0.9007461,
        size.width * 0.8900156,
        size.height * 0.9229199,
        size.width * 0.8900156,
        size.height * 0.9490293);
    path_28.cubicTo(
        size.width * 0.8900156,
        size.height * 0.9563750,
        size.width * 0.8885156,
        size.height * 0.9635898,
        size.width * 0.8856309,
        size.height * 0.9702539);
    path_28.close();

    Paint paint_28_fill = Paint()..style = PaintingStyle.fill;
    paint_28_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_28, paint_28_fill);

    Path path_29 = Path();
    path_29.moveTo(size.width * 0.3103809, size.height * 0.8819043);
    path_29.cubicTo(
        size.width * 0.2921465,
        size.height * 0.8417578,
        size.width * 0.2520254,
        size.height * 0.8155098,
        size.width * 0.2072109,
        size.height * 0.8155098);
    path_29.cubicTo(
        size.width * 0.1989980,
        size.height * 0.8155098,
        size.width * 0.1923418,
        size.height * 0.8221680,
        size.width * 0.1923418,
        size.height * 0.8303789);
    path_29.cubicTo(
        size.width * 0.1923418,
        size.height * 0.8385898,
        size.width * 0.1989961,
        size.height * 0.8452480,
        size.width * 0.2072109,
        size.height * 0.8452480);
    path_29.cubicTo(
        size.width * 0.2431504,
        size.height * 0.8452480,
        size.width * 0.2749941,
        size.height * 0.8681328,
        size.width * 0.2864551,
        size.height * 0.9021953);
    path_29.cubicTo(
        size.width * 0.2887422,
        size.height * 0.9090059,
        size.width * 0.2955742,
        size.height * 0.9131973,
        size.width * 0.3026875,
        size.height * 0.9121680);
    path_29.cubicTo(
        size.width * 0.3050957,
        size.height * 0.9118164,
        size.width * 0.3075195,
        size.height * 0.9116406,
        size.width * 0.3098867,
        size.height * 0.9116406);
    path_29.cubicTo(
        size.width * 0.3372070,
        size.height * 0.9116406,
        size.width * 0.3594355,
        size.height * 0.9338691,
        size.width * 0.3594355,
        size.height * 0.9611895);
    path_29.cubicTo(
        size.width * 0.3594355,
        size.height * 0.9640449,
        size.width * 0.3591934,
        size.height * 0.9668711,
        size.width * 0.3587129,
        size.height * 0.9696523);
    path_29.lineTo(size.width * 0.1342187, size.height * 0.9696523);
    path_29.cubicTo(
        size.width * 0.1272520,
        size.height * 0.9572285,
        size.width * 0.1236016,
        size.height * 0.9432715,
        size.width * 0.1236016,
        size.height * 0.9288633);
    path_29.cubicTo(
        size.width * 0.1236016,
        size.height * 0.9084336,
        size.width * 0.1310469,
        size.height * 0.8887656,
        size.width * 0.1445664,
        size.height * 0.8734863);
    path_29.cubicTo(
        size.width * 0.1500059,
        size.height * 0.8673359,
        size.width * 0.1494336,
        size.height * 0.8579395,
        size.width * 0.1432832,
        size.height * 0.8524980);
    path_29.cubicTo(
        size.width * 0.1371328,
        size.height * 0.8470586,
        size.width * 0.1277363,
        size.height * 0.8476328,
        size.width * 0.1222949,
        size.height * 0.8537813);
    path_29.cubicTo(
        size.width * 0.1039609,
        size.height * 0.8745020,
        size.width * 0.09386328,
        size.height * 0.9011680,
        size.width * 0.09386328,
        size.height * 0.9288652);
    path_29.cubicTo(
        size.width * 0.09386328,
        size.height * 0.9518652,
        size.width * 0.1007285,
        size.height * 0.9740195,
        size.width * 0.1137168,
        size.height * 0.9929395);
    path_29.cubicTo(
        size.width * 0.1164902,
        size.height * 0.9969785,
        size.width * 0.1210762,
        size.height * 0.9993926,
        size.width * 0.1259766,
        size.height * 0.9993926);
    path_29.lineTo(size.width * 0.3699316, size.height * 0.9993926);
    path_29.cubicTo(
        size.width * 0.3760645,
        size.height * 0.9993926,
        size.width * 0.3815645,
        size.height * 0.9956289,
        size.width * 0.3837891,
        size.height * 0.9899141);
    path_29.cubicTo(
        size.width * 0.3873633,
        size.height * 0.9807246,
        size.width * 0.3891758,
        size.height * 0.9710605,
        size.width * 0.3891758,
        size.height * 0.9611914);
    path_29.cubicTo(
        size.width * 0.3891719,
        size.height * 0.9176348,
        size.width * 0.3538730,
        size.height * 0.8821719,
        size.width * 0.3103809,
        size.height * 0.8819043);
    path_29.close();

    Paint paint_29_fill = Paint()..style = PaintingStyle.fill;
    paint_29_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_29, paint_29_fill);

    Path path_30 = Path();
    path_30.moveTo(size.width * 0.6013516, size.height * 0.6432813);
    path_30.cubicTo(
        size.width * 0.5683867,
        size.height * 0.6432813,
        size.width * 0.5366133,
        size.height * 0.6324160,
        size.width * 0.5106641,
        size.height * 0.6125273);
    path_30.cubicTo(
        size.width * 0.5330156,
        size.height * 0.5861289,
        size.width * 0.5465332,
        size.height * 0.5520234,
        size.width * 0.5465332,
        size.height * 0.5148066);
    path_30.cubicTo(
        size.width * 0.5465332,
        size.height * 0.5080859,
        size.width * 0.5460801,
        size.height * 0.5013906,
        size.width * 0.5452031,
        size.height * 0.4947676);
    path_30.lineTo(size.width * 0.5287441, size.height * 0.4762148);
    path_30.lineTo(size.width * 0.5146445, size.height * 0.4919043);
    path_30.cubicTo(
        size.width * 0.5160723,
        size.height * 0.4994160,
        size.width * 0.5167949,
        size.height * 0.5070898,
        size.width * 0.5167949,
        size.height * 0.5148086);
    path_30.cubicTo(
        size.width * 0.5167949,
        size.height * 0.5819316,
        size.width * 0.4621875,
        size.height * 0.6365410,
        size.width * 0.3950625,
        size.height * 0.6365410);
    path_30.cubicTo(
        size.width * 0.3605156,
        size.height * 0.6365410,
        size.width * 0.3274609,
        size.height * 0.6217598,
        size.width * 0.3043770,
        size.height * 0.5959863);
    path_30.cubicTo(
        size.width * 0.3005234,
        size.height * 0.5916836,
        size.width * 0.2945273,
        size.height * 0.5900039,
        size.width * 0.2889922,
        size.height * 0.5916758);
    path_30.cubicTo(
        size.width * 0.2790977,
        size.height * 0.5946719,
        size.width * 0.2688242,
        size.height * 0.5961895,
        size.width * 0.2584609,
        size.height * 0.5961895);
    path_30.cubicTo(
        size.width * 0.2004414,
        size.height * 0.5961895,
        size.width * 0.1532422,
        size.height * 0.5489863,
        size.width * 0.1532422,
        size.height * 0.4909687);
    path_30.cubicTo(
        size.width * 0.1532422,
        size.height * 0.4885430,
        size.width * 0.1533516,
        size.height * 0.4859746,
        size.width * 0.1535859,
        size.height * 0.4828867);
    path_30.cubicTo(
        size.width * 0.1540352,
        size.height * 0.4769590,
        size.width * 0.1509102,
        size.height * 0.4713340,
        size.width * 0.1456406,
        size.height * 0.4685820);
    path_30.cubicTo(
        size.width * 0.1223398,
        size.height * 0.4564160,
        size.width * 0.1078633,
        size.height * 0.4325605,
        size.width * 0.1078633,
        size.height * 0.4063223);
    path_30.cubicTo(
        size.width * 0.1078633,
        size.height * 0.3676113,
        size.width * 0.1393574,
        size.height * 0.3361172,
        size.width * 0.1780684,
        size.height * 0.3361172);
    path_30.cubicTo(
        size.width * 0.1871973,
        size.height * 0.3361172,
        size.width * 0.1960391,
        size.height * 0.3378555,
        size.width * 0.2043926,
        size.height * 0.3412461);
    path_30.lineTo(size.width * 0.2165020, size.height * 0.3285195);
    path_30.lineTo(size.width * 0.1963633, size.height * 0.3080781);
    path_30.cubicTo(
        size.width * 0.1903730,
        size.height * 0.3069687,
        size.width * 0.1842676,
        size.height * 0.3063789,
        size.width * 0.1780684,
        size.height * 0.3063789);
    path_30.cubicTo(
        size.width * 0.1229609,
        size.height * 0.3063789,
        size.width * 0.07812695,
        size.height * 0.3512129,
        size.width * 0.07812695,
        size.height * 0.4063203);
    path_30.cubicTo(
        size.width * 0.07812695,
        size.height * 0.4404238,
        size.width * 0.09529102,
        size.height * 0.4716934,
        size.width * 0.1235098,
        size.height * 0.4900508);
    path_30.cubicTo(
        size.width * 0.1235078,
        size.height * 0.4903574,
        size.width * 0.1235059,
        size.height * 0.4906641,
        size.width * 0.1235059,
        size.height * 0.4909668);
    path_30.cubicTo(
        size.width * 0.1235059,
        size.height * 0.5371953,
        size.width * 0.1468789,
        size.height * 0.5780566,
        size.width * 0.1824180,
        size.height * 0.6023867);
    path_30.cubicTo(
        size.width * 0.1820176,
        size.height * 0.6065391,
        size.width * 0.1818105,
        size.height * 0.6107344,
        size.width * 0.1818105,
        size.height * 0.6149121);
    path_30.cubicTo(
        size.width * 0.1818105,
        size.height * 0.6858164,
        size.width * 0.2394961,
        size.height * 0.7435020,
        size.width * 0.3104004,
        size.height * 0.7435020);
    path_30.cubicTo(
        size.width * 0.3222539,
        size.height * 0.7435020,
        size.width * 0.3339902,
        size.height * 0.7418730,
        size.width * 0.3453770,
        size.height * 0.7386504);
    path_30.cubicTo(
        size.width * 0.3602168,
        size.height * 0.7459121,
        size.width * 0.3766191,
        size.height * 0.7497227,
        size.width * 0.3932070,
        size.height * 0.7497227);
    path_30.cubicTo(
        size.width * 0.4063477,
        size.height * 0.7497227,
        size.width * 0.4192070,
        size.height * 0.7473730,
        size.width * 0.4312969,
        size.height * 0.7428574);
    path_30.lineTo(size.width * 0.4312969, size.height * 0.9445918);
    path_30.cubicTo(
        size.width * 0.4312969,
        size.height * 0.9751445,
        size.width * 0.4561523,
        size.height * 1.000000,
        size.width * 0.4867031,
        size.height * 1.000000);
    path_30.cubicTo(
        size.width * 0.5172539,
        size.height * 1.000000,
        size.width * 0.5421094,
        size.height * 0.9751426,
        size.width * 0.5421094,
        size.height * 0.9445918);
    path_30.lineTo(size.width * 0.5421094, size.height * 0.6629063);
    path_30.cubicTo(
        size.width * 0.5609766,
        size.height * 0.6695215,
        size.width * 0.5809707,
        size.height * 0.6730195,
        size.width * 0.6013516,
        size.height * 0.6730195);
    path_30.cubicTo(
        size.width * 0.6095645,
        size.height * 0.6730195,
        size.width * 0.6162207,
        size.height * 0.6663613,
        size.width * 0.6162207,
        size.height * 0.6581504);
    path_30.cubicTo(
        size.width * 0.6162246,
        size.height * 0.6499395,
        size.width * 0.6095625,
        size.height * 0.6432813,
        size.width * 0.6013516,
        size.height * 0.6432813);
    path_30.close();
    path_30.moveTo(size.width * 0.4312930, size.height * 0.7101973);
    path_30.cubicTo(
        size.width * 0.4196660,
        size.height * 0.7165977,
        size.width * 0.4066465,
        size.height * 0.7199844,
        size.width * 0.3932031,
        size.height * 0.7199844);
    path_30.cubicTo(
        size.width * 0.3795371,
        size.height * 0.7199844,
        size.width * 0.3660508,
        size.height * 0.7164277,
        size.width * 0.3541953,
        size.height * 0.7096953);
    path_30.cubicTo(
        size.width * 0.3505078,
        size.height * 0.7076016,
        size.width * 0.3460996,
        size.height * 0.7071816,
        size.width * 0.3420898,
        size.height * 0.7085391);
    path_30.cubicTo(
        size.width * 0.3318477,
        size.height * 0.7120039,
        size.width * 0.3211836,
        size.height * 0.7137617,
        size.width * 0.3103984,
        size.height * 0.7137617);
    path_30.cubicTo(
        size.width * 0.2567676,
        size.height * 0.7137617,
        size.width * 0.2130078,
        size.height * 0.6708242,
        size.width * 0.2116133,
        size.height * 0.6175254);
    path_30.cubicTo(
        size.width * 0.2262148,
        size.height * 0.6229473,
        size.width * 0.2419980,
        size.height * 0.6259238,
        size.width * 0.2584629,
        size.height * 0.6259238);
    path_30.cubicTo(
        size.width * 0.2686328,
        size.height * 0.6259238,
        size.width * 0.2787363,
        size.height * 0.6247813,
        size.width * 0.2886074,
        size.height * 0.6225234);
    path_30.cubicTo(
        size.width * 0.3168672,
        size.height * 0.6504336,
        size.width * 0.3551641,
        size.height * 0.6662754,
        size.width * 0.3950645,
        size.height * 0.6662754);
    path_30.cubicTo(
        size.width * 0.4075527,
        size.height * 0.6662754,
        size.width * 0.4196797,
        size.height * 0.6647266,
        size.width * 0.4312949,
        size.height * 0.6618652);
    path_30.lineTo(size.width * 0.4312930, size.height * 0.7101973);
    path_30.lineTo(size.width * 0.4312930, size.height * 0.7101973);
    path_30.close();
    path_30.moveTo(size.width * 0.5123711, size.height * 0.9445918);
    path_30.cubicTo(
        size.width * 0.5123711,
        size.height * 0.9587461,
        size.width * 0.5008555,
        size.height * 0.9702637,
        size.width * 0.4867012,
        size.height * 0.9702637);
    path_30.cubicTo(
        size.width * 0.4725469,
        size.height * 0.9702637,
        size.width * 0.4610313,
        size.height * 0.9587480,
        size.width * 0.4610313,
        size.height * 0.9445918);
    path_30.lineTo(size.width * 0.4610313, size.height * 0.6511328);
    path_30.cubicTo(
        size.width * 0.4710605,
        size.height * 0.6462598,
        size.width * 0.4804551,
        size.height * 0.6402871,
        size.width * 0.4891055,
        size.height * 0.6334160);
    path_30.cubicTo(
        size.width * 0.4964668,
        size.height * 0.6393516,
        size.width * 0.5042539,
        size.height * 0.6446445,
        size.width * 0.5123730,
        size.height * 0.6493027);
    path_30.lineTo(size.width * 0.5123730, size.height * 0.9445918);
    path_30.lineTo(size.width * 0.5123711, size.height * 0.9445918);
    path_30.close();

    Paint paint_30_fill = Paint()..style = PaintingStyle.fill;
    paint_30_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_30, paint_30_fill);

    Path path_31 = Path();
    path_31.moveTo(size.width * 0.8528750, size.height * 0.3431582);
    path_31.cubicTo(
        size.width * 0.8557539,
        size.height * 0.3314395,
        size.width * 0.8572070,
        size.height * 0.3194102,
        size.width * 0.8572070,
        size.height * 0.3072285);
    path_31.cubicTo(
        size.width * 0.8572070,
        size.height * 0.2241816,
        size.width * 0.7896426,
        size.height * 0.1566172,
        size.width * 0.7065957,
        size.height * 0.1566172);
    path_31.cubicTo(
        size.width * 0.6871133,
        size.height * 0.1566172,
        size.width * 0.6681953,
        size.height * 0.1603184,
        size.width * 0.6502988,
        size.height * 0.1675410);
    path_31.lineTo(size.width * 0.6502910, size.height * 0.1676348);
    path_31.cubicTo(
        size.width * 0.6467676,
        size.height * 0.1651602,
        size.width * 0.6431523,
        size.height * 0.1627891,
        size.width * 0.6394277,
        size.height * 0.1605508);
    path_31.cubicTo(
        size.width * 0.6396680,
        size.height * 0.1571172,
        size.width * 0.6397891,
        size.height * 0.1537168,
        size.width * 0.6397891,
        size.height * 0.1503730);
    path_31.cubicTo(size.width * 0.6397891, size.height * 0.06745703,
        size.width * 0.5723320, 0, size.width * 0.4894160, 0);
    path_31.cubicTo(
        size.width * 0.4140352,
        0,
        size.width * 0.3511035,
        size.height * 0.05554688,
        size.width * 0.3405918,
        size.height * 0.1287559);
    path_31.cubicTo(
        size.width * 0.2590781,
        size.height * 0.1355469,
        size.width * 0.1948203,
        size.height * 0.2040586,
        size.width * 0.1948203,
        size.height * 0.2872969);
    path_31.cubicTo(
        size.width * 0.1948203,
        size.height * 0.3750234,
        size.width * 0.2661895,
        size.height * 0.4463906,
        size.width * 0.3539141,
        size.height * 0.4463906);
    path_31.cubicTo(
        size.width * 0.3743926,
        size.height * 0.4463906,
        size.width * 0.3941953,
        size.height * 0.4425879,
        size.width * 0.4129336,
        size.height * 0.4350723);
    path_31.cubicTo(
        size.width * 0.4470918,
        size.height * 0.4731602,
        size.width * 0.4952422,
        size.height * 0.4947813,
        size.width * 0.5467695,
        size.height * 0.4947813);
    path_31.cubicTo(
        size.width * 0.6460039,
        size.height * 0.4947813,
        size.width * 0.7267324,
        size.height * 0.4140488,
        size.width * 0.7267324,
        size.height * 0.3148184);
    path_31.cubicTo(
        size.width * 0.7267324,
        size.height * 0.2674453,
        size.width * 0.7082773,
        size.height * 0.2230508,
        size.width * 0.6764824,
        size.height * 0.1900508);
    path_31.lineTo(size.width * 0.6766562, size.height * 0.1900840);
    path_31.cubicTo(
        size.width * 0.6863711,
        size.height * 0.1876055,
        size.width * 0.6963887,
        size.height * 0.1863574,
        size.width * 0.7065977,
        size.height * 0.1863574);
    path_31.cubicTo(
        size.width * 0.7732480,
        size.height * 0.1863574,
        size.width * 0.8274707,
        size.height * 0.2405801,
        size.width * 0.8274707,
        size.height * 0.3072305);
    path_31.cubicTo(
        size.width * 0.8274707,
        size.height * 0.3211973,
        size.width * 0.8250937,
        size.height * 0.3349160,
        size.width * 0.8204043,
        size.height * 0.3480000);
    path_31.cubicTo(
        size.width * 0.8189707,
        size.height * 0.3520000,
        size.width * 0.8193184,
        size.height * 0.3564258,
        size.width * 0.8213574,
        size.height * 0.3601523);
    path_31.cubicTo(
        size.width * 0.8233965,
        size.height * 0.3638809,
        size.width * 0.8269336,
        size.height * 0.3665586,
        size.width * 0.8310781,
        size.height * 0.3675078);
    path_31.cubicTo(
        size.width * 0.8670273,
        size.height * 0.3757480,
        size.width * 0.8921328,
        size.height * 0.4072891,
        size.width * 0.8921328,
        size.height * 0.4442109);
    path_31.cubicTo(
        size.width * 0.8921328,
        size.height * 0.4876152,
        size.width * 0.8568184,
        size.height * 0.5229297,
        size.width * 0.8134160,
        size.height * 0.5229297);
    path_31.cubicTo(
        size.width * 0.7982930,
        size.height * 0.5229297,
        size.width * 0.7835898,
        size.height * 0.5186094,
        size.width * 0.7708926,
        size.height * 0.5104395);
    path_31.cubicTo(
        size.width * 0.7667090,
        size.height * 0.5077461,
        size.width * 0.7614531,
        size.height * 0.5073262,
        size.width * 0.7568984,
        size.height * 0.5093145);
    path_31.cubicTo(
        size.width * 0.7523379,
        size.height * 0.5113047,
        size.width * 0.7490781,
        size.height * 0.5154414,
        size.width * 0.7482051,
        size.height * 0.5203418);
    path_31.cubicTo(
        size.width * 0.7417383,
        size.height * 0.5567500,
        size.width * 0.7219844,
        size.height * 0.5893477,
        size.width * 0.6925840,
        size.height * 0.6121230);
    path_31.cubicTo(
        size.width * 0.6860937,
        size.height * 0.6171523,
        size.width * 0.6849082,
        size.height * 0.6264922,
        size.width * 0.6899375,
        size.height * 0.6329824);
    path_31.cubicTo(
        size.width * 0.6928672,
        size.height * 0.6367656,
        size.width * 0.6972598,
        size.height * 0.6387461,
        size.width * 0.7017012,
        size.height * 0.6387461);
    path_31.cubicTo(
        size.width * 0.7048809,
        size.height * 0.6387461,
        size.width * 0.7080879,
        size.height * 0.6377285,
        size.width * 0.7107988,
        size.height * 0.6356289);
    path_31.cubicTo(
        size.width * 0.7407617,
        size.height * 0.6124160,
        size.width * 0.7623730,
        size.height * 0.5806719,
        size.width * 0.7729414,
        size.height * 0.5448340);
    path_31.cubicTo(
        size.width * 0.7857344,
        size.height * 0.5499883,
        size.width * 0.7994473,
        size.height * 0.5526641,
        size.width * 0.8134141,
        size.height * 0.5526641);
    path_31.cubicTo(
        size.width * 0.8732168,
        size.height * 0.5526641,
        size.width * 0.9218691,
        size.height * 0.5040098,
        size.width * 0.9218691,
        size.height * 0.4442070);
    path_31.cubicTo(
        size.width * 0.9218691,
        size.height * 0.3987031,
        size.width * 0.8941816,
        size.height * 0.3591270,
        size.width * 0.8528750,
        size.height * 0.3431582);
    path_31.close();
    path_31.moveTo(size.width * 0.5467637, size.height * 0.4650430);
    path_31.cubicTo(
        size.width * 0.5005098,
        size.height * 0.4650430,
        size.width * 0.4575078,
        size.height * 0.4441602,
        size.width * 0.4287813,
        size.height * 0.4077461);
    path_31.cubicTo(
        size.width * 0.4258848,
        size.height * 0.4040742,
        size.width * 0.4215410,
        size.height * 0.4020859,
        size.width * 0.4170996,
        size.height * 0.4020859);
    path_31.cubicTo(
        size.width * 0.4148945,
        size.height * 0.4020859,
        size.width * 0.4126660,
        size.height * 0.4025781,
        size.width * 0.4105820,
        size.height * 0.4035938);
    path_31.cubicTo(
        size.width * 0.3928398,
        size.height * 0.4122598,
        size.width * 0.3737734,
        size.height * 0.4166523,
        size.width * 0.3539082,
        size.height * 0.4166523);
    path_31.cubicTo(
        size.width * 0.2825801,
        size.height * 0.4166523,
        size.width * 0.2245527,
        size.height * 0.3586230,
        size.width * 0.2245527,
        size.height * 0.2872969);
    path_31.cubicTo(
        size.width * 0.2245527,
        size.height * 0.2160391,
        size.width * 0.2824707,
        size.height * 0.1580527,
        size.width * 0.3537051,
        size.height * 0.1579414);
    path_31.cubicTo(
        size.width * 0.3538652,
        size.height * 0.1579453,
        size.width * 0.3539883,
        size.height * 0.1579473,
        size.width * 0.3541133,
        size.height * 0.1579473);
    path_31.cubicTo(
        size.width * 0.3620020,
        size.height * 0.1579473,
        size.width * 0.3685371,
        size.height * 0.1517715,
        size.width * 0.3689570,
        size.height * 0.1438652);
    path_31.cubicTo(
        size.width * 0.3723555,
        size.height * 0.07986719,
        size.width * 0.4252637,
        size.height * 0.02973633,
        size.width * 0.4894160,
        size.height * 0.02973633);
    path_31.cubicTo(
        size.width * 0.5559355,
        size.height * 0.02973633,
        size.width * 0.6100508,
        size.height * 0.08385352,
        size.width * 0.6100508,
        size.height * 0.1503711);
    path_31.cubicTo(
        size.width * 0.6100508,
        size.height * 0.1556602,
        size.width * 0.6096680,
        size.height * 0.1611621,
        size.width * 0.6089141,
        size.height * 0.1667188);
    path_31.cubicTo(
        size.width * 0.6080742,
        size.height * 0.1729063,
        size.width * 0.6111875,
        size.height * 0.1789590,
        size.width * 0.6167129,
        size.height * 0.1818711);
    path_31.cubicTo(
        size.width * 0.6662344,
        size.height * 0.2079824,
        size.width * 0.6969941,
        size.height * 0.2589258,
        size.width * 0.6969941,
        size.height * 0.3148164);
    path_31.cubicTo(
        size.width * 0.6969922,
        size.height * 0.3976523,
        size.width * 0.6295996,
        size.height * 0.4650430,
        size.width * 0.5467637,
        size.height * 0.4650430);
    path_31.close();

    Paint paint_31_fill = Paint()..style = PaintingStyle.fill;
    paint_31_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_31, paint_31_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
