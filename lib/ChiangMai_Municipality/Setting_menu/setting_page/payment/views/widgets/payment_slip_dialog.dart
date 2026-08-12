// ============================================================================
// payment_slip_dialog.dart
// ============================================================================
// Dialog อัปโหลด/ลบสลิป
// - ใช้ image_picker.pickImage (ใหม่ ไม่ใช่ getImage deprecated)
// - ถ้ามีสลิปเดิม → แสดง + ให้ลบ
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../theme/payment_theme.dart';
import '../../models/payment_payment_model.dart';
import '../../viewmodels/payment_view_model.dart';

class PaymentSlipDialog extends StatefulWidget {
  final PaymentPaymentModel payment;
  final PaymentViewModel viewModel;
  const PaymentSlipDialog({
    super.key,
    required this.payment,
    required this.viewModel,
  });

  @override
  State<PaymentSlipDialog> createState() => _PaymentSlipDialogState();
}

class _PaymentSlipDialogState extends State<PaymentSlipDialog> {
  Uint8List? _pickedBytes;
  String? _fileName;
  bool _uploading = false;
  bool _deleting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1200,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final now = DateTime.now();
      final stamp = DateFormat('ddMMyyyy_HHmmss').format(now);
      setState(() {
        _pickedBytes = bytes;
        _fileName =
            'PaymentSlip_${widget.payment.ser}_$stamp${_extFromName(picked.name)}';
      });
    } catch (e) {
      _show('เลือกรูปไม่สำเร็จ: $e');
    }
  }

  String _extFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.png';
    return name.substring(dot);
  }

  Future<void> _upload() async {
    if (_pickedBytes == null || _fileName == null) {
      _show('กรุณาเลือกรูปสลิปก่อน');
      return;
    }
    setState(() => _uploading = true);
    final vm = widget.viewModel;
    final ok = await vm.uploadSlip(
      ser: widget.payment.ser,
      fileBytes: _pickedBytes!,
      fileName: _fileName!,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (ok) Navigator.of(context).pop(true);
  }

  Future<void> _deleteExisting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบสลิป'),
        content: Text('ต้องการลบสลิป "${widget.payment.slipName}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    setState(() => _deleting = true);
    final vm = widget.viewModel;
    final ok = await vm.deleteSlip(
      ser: widget.payment.ser,
      fileName: widget.payment.slipName,
    );
    if (!mounted) return;
    setState(() => _deleting = false);
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
    final hasExisting = widget.payment.slipName.isNotEmpty;

    return Dialog(
      backgroundColor: PayColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PayRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(PaySpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('จัดการสลิป', style: PayText.h1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: PaySpace.sm),
              Text(
                'ผู้ใช้: ${widget.payment.sname} (${widget.payment.ln})',
                style: PayText.bodyMuted,
              ),
              const SizedBox(height: PaySpace.md),
              if (hasExisting) ...[
                Text('สลิปปัจจุบัน', style: PayText.h2.copyWith(fontSize: 14)),
                const SizedBox(height: PaySpace.sm),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PayColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(PayRadius.sm),
                    border: Border.all(color: PayColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_rounded,
                          color: PayColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.payment.slipName,
                          style: PayText.body.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            _deleting ? null : _deleteExisting,
                        icon: _deleting
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline_rounded,
                                size: 14, color: PayColors.statusRejectedFg),
                        label: const Text('ลบ'),
                        style: TextButton.styleFrom(
                          foregroundColor: PayColors.statusRejectedFg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PaySpace.md),
                Text('อัปโหลดสลิปใหม่',
                    style: PayText.h2.copyWith(fontSize: 14)),
                const SizedBox(height: PaySpace.sm),
              ] else
                Text('อัปโหลดสลิป',
                    style: PayText.h2.copyWith(fontSize: 14)),
              const SizedBox(height: PaySpace.sm),
              _pickedBytes == null
                  ? OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined,
                          size: 18),
                      label: const Text('เลือกรูปจาก Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PayColors.primary,
                        side: const BorderSide(color: PayColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(PayRadius.sm),
                          child: Image.memory(
                            _pickedBytes!,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 160,
                              alignment: Alignment.center,
                              color: PayColors.surfaceMuted,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: PayColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _fileName ?? 'slip.png',
                                style: PayText.bodyMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.refresh_rounded, size: 14),
                              label: const Text('เปลี่ยน'),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: PaySpace.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _uploading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: (_uploading || _pickedBytes == null)
                        ? null
                        : _upload,
                    icon: _uploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('อัปโหลด'),
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
    );
  }
}
