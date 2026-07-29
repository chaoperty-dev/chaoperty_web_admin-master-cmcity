// ============================================================================
// area_info_card.dart
// ============================================================================
// Card แสดงข้อมูลพื้นที่เช่าที่เลือก (แสดงเมื่อ selectedLn != null)
// - ใช้ modern card style + icon badges
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../../../../../Model/GetArea_Model.dart';
import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class AreaInfoCard extends StatelessWidget {
  const AreaInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    if (vm.selectedLn == null) return const SizedBox.shrink();

    final selectedLnOnly = vm.selectedLn!.split('|').first;
    final area = vm.filteredAreas.firstWhere(
      (a) => (a.lncode ?? '').toString() == selectedLnOnly,
      orElse: () => AreaModel(),
    );
    if (area.lncode == null || area.lncode!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: LcDecor.card(),
      padding: const EdgeInsets.all(LcSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: LcColors.primaryLight,
                  borderRadius: BorderRadius.circular(LcRadius.sm),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 18,
                  color: LcColors.primaryDark,
                ),
              ),
              const SizedBox(width: LcSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลพื้นที่เช่า',
                      style: LcText.h2.copyWith(fontSize: 14),
                    ),
                    if ((area.sname ?? '').isNotEmpty ||
                        (area.cname ?? '').isNotEmpty)
                      Text(
                        [
                          if ((area.sname ?? '').isNotEmpty) area.sname,
                          if ((area.cname ?? '').isNotEmpty) area.cname,
                        ].whereType<String>().join(' • '),
                        style: LcText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // LN badge (รหัสพื้นที่)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LcColors.primaryLight,
                  borderRadius: BorderRadius.circular(LcRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      size: 12,
                      color: LcColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      area.lncode ?? '-',
                      style: LcText.caption.copyWith(
                        color: LcColors.primaryDark,
                        fontFamily: LcText.fontBold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LcSpace.md),
          const Divider(height: 1, color: LcColors.border),
          const SizedBox(height: LcSpace.md),
          // ─── Request status (active) ───
          // แสดงเมื่อล็อกนี้มี PropertiesModel ติดอยู่ (join จาก /admin/requests/properties)
          if (area.properties.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: LcSpace.sm),
              padding: const EdgeInsets.all(LcSpace.sm),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(.08),
                borderRadius: BorderRadius.circular(LcRadius.md),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(.15),
                      borderRadius: BorderRadius.circular(LcRadius.sm),
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: LcSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สถานะคำขอ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // ดึง requestStatus จาก NewRequest ของ PropertiesModel แรก
                          // เช่น "เสนอราคา", "กำลังดำเนินการ", "อนุมัติแล้ว"
                          _requestStatusText(area),
                          style: LcText.input.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LcColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_requestStep(area) != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(LcRadius.pill),
                      ),
                      child: Text(
                        'Step ${_requestStep(area)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Info grid (2 columns)
          _row(
            icon: Icons.place_outlined,
            label: 'โซน',
            value: area.zn ?? '-',
          ),
          if ((area.area ?? '').isNotEmpty)
            _row(
              icon: Icons.straighten_outlined,
              label: 'ขนาดพื้นที่',
              value: area.area!,
            ),
          if ((area.rent ?? '').isNotEmpty)
            _row(
              icon: Icons.payments_outlined,
              label: 'ค่าเช่า',
              value: area.rent!,
            ),
          if ((area.stype ?? '').isNotEmpty)
            _row(
              icon: Icons.category_outlined,
              label: 'ประเภทสินค้า',
              value: area.stype!,
            ),
          if ((area.sdate ?? '').isNotEmpty)
            _row(
              icon: Icons.calendar_today_rounded,
              label: 'วันที่เริ่มสัญญา',
              value: formatDate(area.sdate!, type: DateFormatType.dmy),
              isMono: true,
            ),
          if ((area.ldate ?? '').isNotEmpty)
            _row(
              icon: Icons.event_busy_rounded,
              label: 'วันที่สิ้นสุดสัญญา',
              value: formatDate(area.ldate!, type: DateFormatType.dmy),
              isMono: true,
            ),
          if ((area.quantity ?? '').isNotEmpty)
            _row(
              icon: Icons.info_outline_rounded,
              label: 'สถานะ',
              value: (area.quantity ?? '') == '1' ? 'มีผู้เช่า' : 'ว่าง',
            ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
    bool isMono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 8, top: 1),
            decoration: BoxDecoration(
              color: LcColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LcRadius.sm),
            ),
            child: Icon(icon, size: 12, color: LcColors.textSecondary),
          ),
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: LcText.label.copyWith(
                fontSize: 11,
                color: LcColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: AutoSizeText(
              value,
              style: LcText.input.copyWith(
                fontSize: 12.5,
                fontFamily: isMono ? 'monospace' : LcText.fontRegular,
                fontFamilyFallback: const [LcText.fontRegular],
              ),
              maxFontSize: 13,
              minFontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Request status helpers ───
  /// ดึงข้อความสถานะ request จาก PropertiesModel (เหมือน ChaoArea_Screen บรรทัด 11726-11746)
  String _requestStatusText(AreaModel area) {
    if (area.properties.isEmpty) return 'ไม่มีคำขอ';
    final nr = area.properties.first.newRequest;
    final status = nr?.requestStatus;
    if (status == null || status.isEmpty) return 'กำลังดำเนินการ';
    return status;
  }

  /// ดึง requestStep (1-6) — ถ้ามี ให้แสดง pill "Step X"
  String? _requestStep(AreaModel area) {
    if (area.properties.isEmpty) return null;
    final nr = area.properties.first.newRequest;
    final step = nr?.requestStep;
    if (step == null || step.isEmpty) return null;
    return step;
  }
}
