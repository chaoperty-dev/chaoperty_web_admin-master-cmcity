// ============================================================================
// registration_detail_step2.dart
// ============================================================================
// Step 2 — ที่อยู่ / สัญญา / สถานะ
// แสดง: ที่อยู่ / โซน / สถานะ / Last update / หมายเหตุ
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/registration_detail_view_model.dart';
import '../theme/registration_theme.dart';

class RegistrationDetailStep2 extends StatelessWidget {
  const RegistrationDetailStep2({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationDetailViewModel>();
    final c = vm.customer;
    if (c == null) {
      return const Center(child: Text('ไม่พบข้อมูลลูกค้า'));
    }

    final palette = StatusPalette.of(c.status);
    final address = '${c.addr1 ?? ''} ${c.addr2 ?? ''}'.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RgSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('ที่อยู่', Icons.location_on_rounded),
              const SizedBox(height: RgSpace.md),
              Container(
                decoration: RgDecor.card(),
                padding: const EdgeInsets.all(RgSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      address.isEmpty ? '-' : address,
                      minFontSize: 12,
                      maxFontSize: 15,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: RgText.body.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: RgSpace.sm),
                    _row('รหัสไปรษณีย์', c.zip ?? '-'),
                    const SizedBox(height: RgSpace.sm),
                    _row('โซน', c.zn ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: RgSpace.lg),
              _sectionTitle('สถานะ & ข้อมูลระบบ', Icons.info_rounded),
              const SizedBox(height: RgSpace.md),
              Container(
                decoration: RgDecor.card(),
                padding: const EdgeInsets.all(RgSpace.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            'สถานะ',
                            style: RgText.bodyMuted.copyWith(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: RgDecor.pill(palette.bg, palette.fg),
                            child: Text(
                              c.status ?? '-',
                              style: RgText.body.copyWith(
                                fontFamily: RgText.fontBold,
                                fontSize: 12,
                                color: palette.fg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _divider(),
                    _row('วันที่ลงทะเบียน', c.datex ?? '-'),
                    _divider(),
                    _row('เวลา', c.timex ?? '-'),
                    _divider(),
                    _row('อัปเดตล่าสุด', c.dataUpdate ?? '-'),
                    _divider(),
                    _row('หมายเหตุ', c.wnote ?? '-'),
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

  Widget _row(String label, String value) {
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
              style: RgText.body,
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
