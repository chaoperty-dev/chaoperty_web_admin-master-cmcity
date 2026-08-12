// ============================================================================
// payment_form_dialog.dart
// ============================================================================
// Dialog เพิ่ม/แก้ Payment
// - ฟอร์ม: ln / sn / sname / sw / zone / type_id / bank_id / bank_type_id
// - validation: required + number (sw)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/payment_theme.dart';
import '../../models/payment_payment_model.dart';
import '../../viewmodels/payment_view_model.dart';

enum PaymentDialogMode { create, edit }

class PaymentFormDialog extends StatefulWidget {
  final PaymentDialogMode mode;
  final PaymentPaymentModel? initial;
  final PaymentViewModel viewModel;
  const PaymentFormDialog({
    super.key,
    required this.mode,
    this.initial,
    required this.viewModel,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ln = TextEditingController();
  final _sn = TextEditingController();
  final _sname = TextEditingController();
  final _sw = TextEditingController();

  String? _typeId;
  String? _bankId;
  String? _bankTypeId;
  String _zone = '0';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PaymentDialogMode.edit && widget.initial != null) {
      final p = widget.initial!;
      _ln.text = p.ln;
      _sn.text = p.sn;
      _sname.text = p.sname;
      _sw.text = p.sw;
      _zone = p.zone.isEmpty ? '0' : p.zone;
      _typeId = p.typeId.isEmpty ? null : p.typeId;
      _bankId = p.bankId.isEmpty ? null : p.bankId;
      _bankTypeId = p.bankTypeId.isEmpty ? null : p.bankTypeId;
    }
  }

  @override
  void dispose() {
    _ln.dispose();
    _sn.dispose();
    _sname.dispose();
    _sw.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_typeId == null) {
      _show('กรุณาเลือกประเภทการรับชำระ');
      return;
    }
    if (_bankId == null) {
      _show('กรุณาเลือกธนาคาร');
      return;
    }
    if (_bankTypeId == null) {
      _show('กรุณาเลือกประเภทบัญชี');
      return;
    }
    setState(() => _submitting = true);
    final vm = widget.viewModel;
    final ok = widget.mode == PaymentDialogMode.create
        ? await vm.addPayment(
            ln: _ln.text.trim(),
            sn: _sn.text.trim(),
            sname: _sname.text.trim(),
            sw: _sw.text.trim(),
            zone: _zone,
            typeId: _typeId!,
            bankId: _bankId!,
            bankTypeId: _bankTypeId!,
          )
        : await vm.updatePayment(
            ser: widget.initial!.ser,
            ln: _ln.text.trim(),
            sn: _sn.text.trim(),
            sname: _sname.text.trim(),
            sw: _sw.text.trim(),
            zone: _zone,
            typeId: _typeId!,
            bankId: _bankId!,
            bankTypeId: _bankTypeId!,
          );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PayColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final title = widget.mode == PaymentDialogMode.create
        ? 'เพิ่ม Payment'
        : 'แก้ไข Payment';

    return Dialog(
      backgroundColor: PayColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PayRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(PaySpace.lg),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: PayText.h1)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: PaySpace.md),
                  Row(
                    children: [
                      Expanded(child: _field(_ln, 'รหัส (ln)')),
                      const SizedBox(width: PaySpace.sm),
                      Expanded(
                        child: _field(
                          _sw,
                          'ลำดับ (sw)',
                          type: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรอกลำดับ';
                            if (int.tryParse(v) == null) return 'ตัวเลขเท่านั้น';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PaySpace.sm),
                  Row(
                    children: [
                      Expanded(child: _field(_sn, 'ชื่อย่อ (sn)')),
                      const SizedBox(width: PaySpace.sm),
                      Expanded(child: _field(_sname, 'ชื่อบัญชี (sname)')),
                    ],
                  ),
                  const SizedBox(height: PaySpace.md),
                  const Text('ประเภทการรับชำระ', style: PayText.h2),
                  const SizedBox(height: PaySpace.sm),
                  _dropdown<String?>(
                    value: _typeId,
                    hint: 'เลือก PayType',
                    items: vm.payTypes
                        .map(
                          (t) => DropdownMenuItem<String?>(
                            value: t.ser,
                            child: Text(t.tn),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _typeId = v),
                  ),
                  const SizedBox(height: PaySpace.md),
                  const Text('ธนาคาร', style: PayText.h2),
                  const SizedBox(height: PaySpace.sm),
                  _dropdown<String?>(
                    value: _bankId,
                    hint: 'เลือกธนาคาร',
                    items: vm.banks
                        .map(
                          (b) => DropdownMenuItem<String?>(
                            value: b.ser,
                            child: Text('${b.bcode.isEmpty ? "" : "${b.bcode} "}${b.bname}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _bankId = v),
                  ),
                  const SizedBox(height: PaySpace.md),
                  const Text('ประเภทบัญชี', style: PayText.h2),
                  const SizedBox(height: PaySpace.sm),
                  _dropdown<String?>(
                    value: _bankTypeId,
                    hint: 'เลือก BankType',
                    items: vm.bankTypes
                        .map(
                          (t) => DropdownMenuItem<String?>(
                            value: t.ser,
                            child: Text(t.btype),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _bankTypeId = v),
                  ),
                  const SizedBox(height: PaySpace.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _submitting ? null : _onSubmit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 16),
                        label: Text(
                          widget.mode == PaymentDialogMode.create
                              ? 'เพิ่ม Payment'
                              : 'บันทึก',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PayColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      inputFormatters: type == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอก$label' : null,
    );
  }

  Widget _dropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: PayColors.border),
        borderRadius: BorderRadius.circular(PayRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
