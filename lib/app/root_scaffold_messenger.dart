// ============================================================================
// root_scaffold_messenger.dart
// ============================================================================
// Global ScaffoldMessenger key — ใช้แสดง SnackBar จากทุกที่ในแอป
// bypass ปัญหา context ของ InheritedWidget ที่อาจ invalidate ระหว่าง route transition
//
// Setup:
//   - MaterialApp.router(scaffoldMessengerKey: rootScaffoldMessengerKey, ...)
//   - เรียก rootScaffoldMessengerKey.currentState?.showSnackBar(...)
// ============================================================================

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
