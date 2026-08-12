// ============================================================================
// payment_paytype_dialog.dart
// ============================================================================
// Dialog เพิ่ม PayType (ประเภทการรับชำระ)
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/payment_theme.dart';
import '../../viewmodels/payment_view_model.dart';

class PaymentPayTypeDialog extends StatefulWidget {
  final PaymentViewModel viewModel;
  const PaymentPayTypeDialog({super.key, required this.viewModel});

  @override
  State<PaymentPayTypeDialog> createState() => _PaymentPayTypeDialogState();
}

class _PaymentPayTypeDialogState extends State<PaymentPayTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tn = TextEditingController();
  final _desc = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _tn.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final vm = widget.viewModel;
    final ok = await vm.addPayType(
      tn: _tn.text.trim(),
      desc: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PayColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PayRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
                    Expanded(
                      child: Text('เพิ่มประเภทการรับชำระ', style: PayText.h1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: PaySpace.md),
                TextFormField(
                  controller: _tn,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ PayType (tn)',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
                ),
                const SizedBox(height: PaySpace.sm),
                TextFormField(
                  controller: _desc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'คำอธิบาย (ไม่บังคับ)',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                    isDense: true,
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
