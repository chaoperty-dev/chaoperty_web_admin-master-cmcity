import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../Style/colors.dart';

Widget_Loading(context) {
  return SizedBox(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        StreamBuilder(
          stream: Stream.periodic(const Duration(milliseconds: 25), (i) => i),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('');
            double elapsed = double.parse(snapshot.data.toString()) * 0.05;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
                // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                style: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T
                    //fontSize: 10.0
                    ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Dia_log1(context) {
  return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext builderContext) {
        Timer(Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}

Dia_log2(context) {
  return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext builderContext) {
        // Timer(Duration(milliseconds: 150), () {
        //   Navigator.of(context).pop();
        // });

        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}

Dia_log3(context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            height: 20,
            width: 80,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset(
                "images/gif-LOGOchao.gif",
                fit: BoxFit.cover,
                height: 20,
                width: 80,
              ),
            ),
          ),
        );
      });
}

Dia_log4(context) async {
  PanaraInfoDialog.showAnimatedGrow(
    context,
    title: "Oops",
    message: "ยกเลิกการรับชำระ เสร็จสิ้น ...!!",
    buttonText: "รับทราบ",
    onTapDismiss: () async {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.warning,
    barrierDismissible: false, // optional parameter (default is true)
  );
}

Dialog_success(context, String datatex) async {
  PanaraInfoDialog.showAnimatedGrow(
    context,
    title: "Yahh",
    message: "$datatex",
    buttonText: "รับทราบ",
    onTapDismiss: () async {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.success,
    barrierDismissible: false,
  );
}

Dialog_error(context, String datatex) async {
  PanaraInfoDialog.showAnimatedGrow(
    context,
    title: "Oops",
    message: "$datatex",
    buttonText: "รับทราบ",
    onTapDismiss: () async {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.error,
    barrierDismissible: false,
  );
}
