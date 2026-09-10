// ============================================================================
// registration_detail_step1.dart
// ============================================================================
// Step 1 — ข้อมูลลูกค้า (เหมือนการ์ด Customer Card)
// แสดง: รหัสลูกค้า / ชื่อ / ประเภท / เบอร์โทร / อีเมล / เลขประจำตัวผู้เสียภาษี
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../unity/FormatPhone.dart';
import '../../viewmodels/registration_detail_view_model.dart';
import '../theme/registration_theme.dart';

class RegistrationDetailStep1 extends StatelessWidget {
  const RegistrationDetailStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationDetailViewModel>();
    final c = vm.customer;
    if (c == null) {
      return const Center(child: Text('ไม่พบข้อมูลลูกค้า'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RgSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('ข้อมูลลูกค้า', Icons.person_rounded),
              const SizedBox(height: RgSpace.md),
              Container(
                decoration: RgDecor.card(),
                padding: const EdgeInsets.all(RgSpace.lg),
                child: Column(
                  children: [
                    _row('รหัสลูกค้า', c.custno ?? '-'),
                    _divider(),
                    _row('ชื่อย่อ', c.scname ?? '-'),
                    _divider(),
                    _row('ชื่อลูกค้า', c.cname ?? '-'),
                    _divider(),
                    _row('ประเภทลูกค้า', c.type ?? '-'),
                    _divider(),
                    _row('สาขา', c.branch ?? '-'),
                    _divider(),
                    _row('ผู้ติดต่อ', c.attn ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: RgSpace.lg),
              _sectionTitle('ข้อมูลติดต่อ', Icons.contact_phone_rounded),
              const SizedBox(height: RgSpace.md),
              Container(
                decoration: RgDecor.card(),
                padding: const EdgeInsets.all(RgSpace.lg),
                child: Column(
                  children: [
                    _row('เบอร์โทร', formatPhoneNumber(c.tel ?? '')),
                    _divider(),
                    _row('อีเมล', c.email ?? '-'),
                    _divider(),
                    _row('LINE ID', c.lineid ?? '-'),
                    _divider(),
                    _row('Fax', c.fax ?? '-'),
                    _divider(),
                    _row('เลขประจำตัวผู้เสียภาษี', c.tax ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: RgSpace.lg),
              _sectionTitle('บัญชีผู้ใช้', Icons.account_circle_rounded),
              const SizedBox(height: RgSpace.md),
              Container(
                decoration: RgDecor.card(),
                padding: const EdgeInsets.all(RgSpace.lg),
                child: Column(
                  children: [
                    _row('ชื่อผู้ใช้', c.user_name ?? '-'),
                    _divider(),
                    _row('UUID', c.uuid ?? '-', isMono: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RgSpace.md, vertical: RgSpace.sm),
      decoration: BoxDecoration(
        color: RgColors.primaryLight.withOpacity(.5),
        borderRadius: BorderRadius.circular(RgRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RgColors.primaryDark),
          const SizedBox(width: 8),
          Text(text, style: RgText.h2),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: RgText.bodyMuted.copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: AutoSizeText(
              value.isEmpty ? '-' : value,
              minFontSize: 11,
              maxFontSize: 14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RgText.body.copyWith(
                fontFamily: isMono ? 'monospace' : RgText.fontRegular,
                fontFamilyFallback: const [RgText.fontRegular],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
        height: 1,
        thickness: 1,
        color: RgColors.border,
      );
}
