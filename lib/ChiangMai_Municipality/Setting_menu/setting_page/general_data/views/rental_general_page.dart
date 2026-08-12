// ============================================================================
// rental_general_page.dart
// ============================================================================
// หน้า "ข้อมูลทั่วไป" — Port ตรง Status1_Web() ใน lib/Setting/SettingScreen.dart
// (แสดงเฉพาะส่วนข้อมูลทั่วไป)
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header (Back + Title) ───
            GeneralDataHeader(
              title: 'ข้อมูลทั่วไป',
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),

            // ─── Body (ข้อมูลทั่วไป) ───
            const Expanded(
              child: GeneralDataStep1(),
            ),
          ],
        ),
      ),
    );
  }
}


