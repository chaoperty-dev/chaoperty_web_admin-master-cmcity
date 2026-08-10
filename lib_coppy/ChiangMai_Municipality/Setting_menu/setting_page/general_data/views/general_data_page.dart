// ============================================================================
// general_data_page.dart
// ============================================================================
// หน้า "ข้อมูลทั่วไป" (Port จาก Status1_Web ใน lib/Setting/SettingScreen.dart)
//
// GeneralDataPage.create() — factory wrap ChangeNotifierProvider
// (เหมือน LicensefactcheckPage.create())
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/rental_general_service.dart';
import '../viewmodels/rental_general_view_model.dart';
import 'rental_general_page.dart';

// ═══════════════════════════════════════════════════════════════════════
// Public API
// ═══════════════════════════════════════════════════════════════════════
class GeneralDataPage extends StatefulWidget {
  const GeneralDataPage({super.key});

  /// Factory สร้าง Page พร้อม Provider
  static Widget create({RentalGeneralService? service}) {
    final svc = service ?? RentalGeneralService();
    return ChangeNotifierProvider<RentalGeneralViewModel>(
      create: (_) => RentalGeneralViewModel(service: svc)..load(),
      child: const GeneralDataPage(),
    );
  }

  @override
  State<GeneralDataPage> createState() => _GeneralDataPageState();
}

class _GeneralDataPageState extends State<GeneralDataPage> {
  @override
  Widget build(BuildContext context) {
    // Delegate ไปยัง RentalGeneralPage (ตัวจริง)
    return const RentalGeneralPage();
  }
}
