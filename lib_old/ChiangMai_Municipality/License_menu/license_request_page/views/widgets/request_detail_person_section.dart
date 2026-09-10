// ============================================================================
// request_detail_person_section.dart
// ============================================================================
// Section "ข้อมูลผู้เช่า" — แบบ read-only (ของตัวเอง)
// ใช้ LicenseRequestDetailStep1ViewModel ของ license_request_page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_request_detail_step1_view_model.dart';

class RequestDetailPersonSection extends StatelessWidget {
  const RequestDetailPersonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep1ViewModel>();
    return Column(
      children: [
        for (int i = 0; i < vm.dataPerson.length; i++)
          _FieldRow(
            label: vm.dataPerson[i].title,
            child: TextFormField(
              textAlign: TextAlign.left,
              readOnly: true,
              controller: vm.controllersPerson[i],
              minLines: (i == 0)
                  ? 1
                  : (i + 1 == vm.dataPerson.length)
                      ? 3
                      : 1,
              maxLines: (i == 0)
                  ? 2
                  : (i + 1 == vm.dataPerson.length)
                      ? 3
                      : 1,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              decoration: _inputDecoration(),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      fillColor: const Color(0xFFF8FAFC),
      filled: true,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(width: 1, color: Color(0xFF16A34A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
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
