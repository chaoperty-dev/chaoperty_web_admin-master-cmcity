// ============================================================================
// payment_bank_dialog.dart
// ============================================================================
// Dialog เพิ่ม Bank (ธนาคาร)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/payment_theme.dart';
import '../../viewmodels/payment_view_model.dart';

class PaymentBankDialog extends StatefulWidget {
  final PaymentViewModel viewModel;
  const PaymentBankDialog({super.key, required this.viewModel});

  @override
  State<PaymentBankDialog> createState() => _PaymentBankDialogState();
}

class _PaymentBankDialogState extends State<PaymentBankDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bcode = TextEditingController();
  final _bname = TextEditingController();
  final _btype = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _bcode.dispose();
    _bname.dispose();
    _btype.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final vm = widget.viewModel;
    final ok = await vm.addBank(
      bcode: _bcode.text.trim(),
      bname: _bname.text.trim(),
      btype: _btype.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Dialog(
      backgroundColor: PayColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PayRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(PaySpace.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('เพิ่มธนาคาร', style: PayText.h1)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: PaySpace.md),
                TextFormField(
                  controller: _bcode,
                  decoration: const InputDecoration(
                    labelText: 'รหัสธนาคาร (bcode) เช่น KBANK, SCB',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรุณากรอกรหัสธนาคาร' : null,
                ),
                const SizedBox(height: PaySpace.sm),
                TextFormField(
                  controller: _bname,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อธนาคาร (bname)',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อธนาคาร' : null,
                ),
                const SizedBox(height: PaySpace.sm),
                const Text('ประเภทบัญชี (btype)',
                    style: TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: PayColors.border),
                    borderRadius: BorderRadius.circular(PayRadius.sm),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _btype.text.isEmpty
                          ? null
                          : vm.bankTypes
                              .where((t) => t.ser == _btype.text)
                              .map((t) => t.ser)
                              .firstOrNull,
                      hint: const Text('เลือกประเภทบัญชี'),
                      items: vm.bankTypes
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t.ser,
                              child: Text(t.btype),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _btype.text = v);
                        }
                      },
                    ),
                  ),
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
                      label: const Text('บันทึก'),
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
    );
  }
}
