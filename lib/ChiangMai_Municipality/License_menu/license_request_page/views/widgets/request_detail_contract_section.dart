// ============================================================================
// request_detail_contract_section.dart
// ============================================================================
// Section "ข้อมูลสัญญา" — แบบ read-only (ของตัวเอง)
// - ser 1 / 2 → แสดงวันที่ (dd-MM-yyyy)
// - ser 3 / 4 → แสดงเป็น text ธรรมดา
// ใช้ LicenseRequestDetailStep1ViewModel ของ license_request_page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../../viewmodels/license_request_detail_step1_view_model.dart';

class RequestDetailContractSection extends StatelessWidget {
  const RequestDetailContractSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep1ViewModel>();
    return Column(
      children: [
        for (final cid in vm.dataCid)
          _FieldRow(
            label: cid['title']?.toString() ?? '',
            child: _FieldWidget(cid: cid),
          ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 4),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: child),
        ],
      ),
    );
  }
}

class _FieldWidget extends StatelessWidget {
  final Map<String, dynamic> cid;
  const _FieldWidget({required this.cid});

  bool get _isDate =>
      cid['ser'].toString() == '1' || cid['ser'].toString() == '2';

  @override
  Widget build(BuildContext context) {
    final rawValue = (cid['detail'] ?? '').toString();
    final displayValue = _isDate
        ? formatDate(rawValue, type: DateFormatType.dmy)
        : rawValue;
    final isEmpty = displayValue.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              _isDate ? Icons.event_rounded : Icons.info_outline_rounded,
              size: 16,
              color: isEmpty
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEmpty ? '-' : displayValue,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
