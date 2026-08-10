// ============================================================================
// form_person_section.dart
// ============================================================================
// Section "ข้อมูลผู้เช่า" — modern form rows
// - ใช้ pattern: Label (icon + title) + Input (modern TextField)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class FormPersonSection extends StatelessWidget {
  const FormPersonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    return Column(
      children: [
        for (int i = 0; i < vm.dataPerson.length; i++)
          _FieldRow(
            label: vm.dataPerson[i].title,
            required: true,
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: TextFormField(
                textAlign: TextAlign.left,
                keyboardType: TextInputType.multiline,
                showCursor: !vm.readOnly,
                readOnly: vm.readOnly,
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
                style: LcText.input,
                decoration: LcDecor.inputDecor(
                  hintText: 'กรอก${vm.dataPerson[i].title}',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Row: Label (left) + Field (right)
class _FieldRow extends StatelessWidget {
  final String label;
  final bool required;
  final int flex;
  final Widget child;
  const _FieldRow({
    required this.label,
    required this.child,
    this.required = false,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: flex,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 4),
              child: Row(
                children: [
                  Flexible(
                    child: AutoSizeText(
                      required ? '$label *' : label,
                      minFontSize: 11,
                      maxFontSize: 13,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LcText.label.copyWith(
                        color: required
                            ? LcColors.textPrimary
                            : LcColors.textSecondary,
                      ),
                    ),
                  ),
                  if (required)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: LcColors.required,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(flex: 2, child: child),
        ],
      ),
    );
  }
}
