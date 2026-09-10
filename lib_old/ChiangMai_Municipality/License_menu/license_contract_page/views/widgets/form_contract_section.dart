// ============================================================================
// form_contract_section.dart
// ============================================================================
// Section "ข้อมูลสัญญา" — Date picker rows
// - ser 1 / 2 → Date picker (แสดงด้วย InkWell + Container คล้าย input)
// - ser 3 / 4 → Text display only
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class FormContractSection extends StatelessWidget {
  const FormContractSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    return Column(
      children: [
        for (final cid in vm.dataCid)
          _FieldRow(
            label: cid['title']?.toString() ?? '',
            required:
                cid['ser'].toString() == '1' || cid['ser'].toString() == '2',
            child: _FieldWidget(cid: cid, vm: vm),
          ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  const _FieldRow({
    required this.label,
    required this.child,
    this.required = false,
  });

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

class _FieldWidget extends StatelessWidget {
  final Map<String, dynamic> cid;
  final LicenseContractViewModel vm;
  const _FieldWidget({required this.cid, required this.vm});

  bool get _isDate =>
      cid['ser'].toString() == '1' || cid['ser'].toString() == '2';

  @override
  Widget build(BuildContext context) {
    final isReadonly = vm.readOnly || !_isDate;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _DatePickerField(
        value: _isDate
            ? formatDate('${cid['detail']}', type: DateFormatType.dmy)
            : '${cid['detail']}',
        placeholder: _isDate ? 'เลือกวันที่' : cid['detail']?.toString() ?? '-',
        icon: _isDate ? Icons.event_rounded : Icons.info_outline_rounded,
        enabled: !isReadonly,
        onTap: _isDate ? () => _pickDate(context) : null,
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(const Duration(days: -100)),
      lastDate: DateTime.now().add(const Duration(days: 400)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LcColors.primary,
              onPrimary: Colors.white,
              onSurface: LcColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: LcColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (newDate == null) return;
    final formatted = DateFormat('yyyy-MM-dd').format(newDate);
    vm.updateCidDate(int.parse(cid['ser'].toString()), formatted);
  }
}

/// Pill-style date picker field (looks like InputField)
class _DatePickerField extends StatefulWidget {
  final String value;
  final String placeholder;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _DatePickerField({
    required this.value,
    required this.placeholder,
    required this.icon,
    this.enabled = true,
    this.onTap,
  });

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.value.isEmpty || widget.value == '-';
    return MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: LcAnimations.fast,
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                _hover ? Colors.white : LcColors.surfaceMuted.withOpacity(.6),
            borderRadius: BorderRadius.circular(LcRadius.sm),
            border: Border.all(
              color: _hover ? LcColors.borderStrong : LcColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.enabled
                    ? (_hover ? LcColors.primary : LcColors.textSecondary)
                    : LcColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEmpty ? widget.placeholder : widget.value,
                  style: LcText.input.copyWith(
                    color: isEmpty ? LcColors.textMuted : LcColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.enabled && !isEmpty)
                const Icon(
                  Icons.edit_calendar_rounded,
                  size: 14,
                  color: LcColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
