// ============================================================================
// add_custo_rg_screen.dart
// ============================================================================
// "เพิ่มทะเบียนลูกค้า" — ใช้ UI ใหม่ของเมนู "ทะเบียน" (Rg theme)
// - extends Add_Custo_Screen เพื่อ reuse business logic (save/load/validate)
// - override build() เพื่อใช้ Rg design tokens แทน UI เดิม
// - ห่อด้วย Scaffold + Header สีเขียว + form แบบ card
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../Bureau_Registration/Add_Custo_Screen.dart';
import '../theme/registration_theme.dart';

class AddCustoRgScreen extends StatefulWidget {
  final FutureOr<void> Function(String)? onSaveSuccess;

  const AddCustoRgScreen({super.key, this.onSaveSuccess});

  @override
  State<AddCustoRgScreen> createState() => _AddCustoRgScreenState();
}

/// ใช้ Composition: ห่อ Add_Custo_Screen เดิมไว้ข้างใน
/// เพื่อ reuse business logic + form state ทั้งหมด
/// โดยไม่ต้องแก้ไฟล์ต้นฉบับ
class _AddCustoRgScreenState extends State<AddCustoRgScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 700;
    final maxW =
        width >= 1200 ? 1320.0 : (width >= 700 ? 1000.0 : double.infinity);

    // Add_Custo_Screen เดิมมี SingleChildScrollView + ConstrainedBox อยู่ข้างในแล้ว
    // ไม่ต้องห่อซ้ำ — ให้ของเดิมจัดการ scroll เอง เพื่อหลีกเลี่ยง
    // "RenderBox was not laid out" assertion (nested Expanded + SingleChildScrollView)
    return Scaffold(
      backgroundColor: RgColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RgHeader(
              title: 'เพิ่มทะเบียนลูกค้า',
              subtitle: 'กรอกข้อมูลลูกค้าใหม่เพื่อลงทะเบียน',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Container(
                decoration: RgDecor.card(),
                margin: EdgeInsets.all(isCompact ? RgSpace.md : RgSpace.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Add_Custo_Screen(
                      onSaveSuccess: widget.onSaveSuccess,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Rg Header — Back button + Title + Subtitle (gradient)
// ============================================================================
class _RgHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _RgHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RgColors.headerBg, RgColors.headerAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(RgRadius.lg),
          bottomRight: Radius.circular(RgRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: RgColors.primary.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'กลับ',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded,
                color: RgColors.textInverse),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RgRadius.sm),
              ),
            ),
          ),
          const SizedBox(width: RgSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'REGISTRATION',
                  style: RgText.label.copyWith(
                    color: RgColors.primaryAccent.withOpacity(.9),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: RgText.h1.copyWith(
                    color: RgColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: RgText.caption.copyWith(
                    color: Colors.white.withOpacity(.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
