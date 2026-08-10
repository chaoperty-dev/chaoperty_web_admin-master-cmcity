// ============================================================================
// rental_general_page.dart
// ============================================================================
// หน้า "ข้อมูลทั่วไป" — Port ตรง Status1_Web() ใน lib/Setting/SettingScreen.dart
//
// ใช้ pattern 2-step (เหมือน RegistrationDetailPage):
//   - Step 1: ข้อมูลพื้นฐาน (Hero + Section 1-3 + Section 5 + รูปแผนผัง)
//   - Step 2: การตั้งค่า (Section 6 + Section 7 + Section 8)
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

import '../models/rental_general_models.dart';
import '../services/rental_general_service.dart';
import '../viewmodels/rental_general_view_model.dart';
import '../widgets/general_data_sections.dart';
import '../widgets/general_data_header.dart';
import '../widgets/general_data_footer.dart';

// ═══════════════════════════════════════════════════════════════════════
// Public API
// ═══════════════════════════════════════════════════════════════════════
class RentalGeneralPage extends StatefulWidget {
  const RentalGeneralPage({super.key});

  /// Factory — สร้าง Page พร้อม Provider (เหมือน RegistrationDetailPage.create())
  static Widget create({RentalGeneralService? service}) {
    final svc = service ?? RentalGeneralService();
    return ChangeNotifierProvider<RentalGeneralViewModel>(
      create: (_) => RentalGeneralViewModel(service: svc)..load(),
      child: const _RentalGeneralPageBody(),
    );
  }

  @override
  State<RentalGeneralPage> createState() => _RentalGeneralPageState();
}

class _RentalGeneralPageState extends State<RentalGeneralPage> {
  @override
  Widget build(BuildContext context) => RentalGeneralPage.create();
}

/// Body จริง — ต้องอยู่ใต้ Provider เสมอ
class _RentalGeneralPageBody extends StatefulWidget {
  const _RentalGeneralPageBody();

  @override
  State<_RentalGeneralPageBody> createState() => _RentalGeneralPageBodyState();
}

class _RentalGeneralPageBodyState extends State<_RentalGeneralPageBody> {
  StreamSubscription? _eventSub;
  int _currentStep = 1;

  static const int _totalSteps = 2;

  @override
  void initState() {
    super.initState();
    // Load zones หลัง build รอบแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RentalGeneralViewModel>().loadZones();
      }
    });
    // Listen events ของ Provider
    _eventSub = context.read<RentalGeneralViewModel>().events.listen((ev) {
      if (!mounted) return;
      if (ev is ErrorRentalGeneral) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ev.message),
          backgroundColor: LaColors.statusRejectedFg,
        ));
      } else if (ev is UpdatedRentalGeneral) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('อัปเดต ${ev.field} แล้ว'),
        ));
      } else if (ev is UploadedRentalGeneral) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('อัปโหลด ${ev.path} แล้ว'),
        ));
      } else if (ev is DeletedRentalGeneral) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ลบ ${ev.path} แล้ว'),
        ));
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการตั้งค่าเรียบร้อย'),
        backgroundColor: LaColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header (Back + Title + Tab bar) ───
            GeneralDataTabBar(
              title: 'ข้อมูลทั่วไป',
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onStepChanged: (s) => setState(() => _currentStep = s),
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),

            // ─── Body (Step1 หรือ Step2) ───
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _currentStep == 1
                    ? const GeneralDataStep1(key: ValueKey(1))
                    : const GeneralDataStep2(key: ValueKey(2)),
              ),
            ),

            // ─── Footer (บันทึก) ───
            GeneralDataFooter(
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}
