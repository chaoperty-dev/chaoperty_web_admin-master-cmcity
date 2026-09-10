// ============================================================================
// request_detail_zone_row.dart
// ============================================================================
// Row แสดงข้อมูลโซนแบบ read-only (3 ช่อง: โซนพื้นที่เช่า, โซน, รหัสพื้นที่)
// (ใช้ภายใน license_request_page ของตัวเอง)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_request_detail_step1_view_model.dart';

class RequestDetailZoneRow extends StatelessWidget {
  const RequestDetailZoneRow({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep1ViewModel>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          // Row 1: sub-zone + zone
          Row(
            children: [
              Expanded(
                child: _DisplayField(
                  icon: Icons.layers_outlined,
                  label: 'โซนพื้นที่เช่า',
                  value: vm.selectedSubZone ?? '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DisplayField(
                  icon: Icons.place_outlined,
                  label: 'โซน',
                  value: vm.selectedZn ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: property only
          _DisplayField(
            icon: Icons.numbers_rounded,
            label: 'รหัสพื้นที่',
            value: vm.selectedLn ?? '-',
          ),
        ],
      ),
    );
  }
}

/// Field แสดงผลแบบ read-only (icon + label + value)
class _DisplayField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DisplayField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty || value == '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF15803D)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9).withOpacity(.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isEmpty
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
