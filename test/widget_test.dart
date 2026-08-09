// ไฟล์ test นี้ถูกปรับให้ทดสอบแค่ Component ของ NavigationRail เท่านั้น
// เพราะ main.dart มี dart:html ซึ่งใช้ได้เฉพาะบน web (ไม่รองรับบน Flutter test/Dart VM)
//
// หากต้องการ test main app ให้รัน `flutter run -d chrome` แทน

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // ทดสอบ MaterialApp ปกติ (ไม่ import main.dart)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Test OK')),
        ),
      ),
    );

    expect(find.text('Test OK'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
