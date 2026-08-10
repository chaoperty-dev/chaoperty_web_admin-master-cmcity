import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Style/colors.dart';

Future<DateTime?> pickThaiDate(BuildContext context) async {
  DateTime? newDate = await showDatePicker(
    locale: const Locale('th', 'TH'),
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000, 1, 1),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppBarColors.ABar_Colors,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors
                  .black, // แก้จาก primary เป็น foregroundColor ตาม Flutter 3
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  return newDate; // ✅ คืนค่า newDate กลับไป
}
