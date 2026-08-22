// ============================================================================
// receipt_entry_stepper_dialog.dart
// ============================================================================
// Dialog "บันทึกการรับชำระ" — popup 3 สเตป:
//   Step 1 — เลือกรูปแบบการชำระ  (dropdown ช่องทาง + บัญชี)
//   Step 2 — อัพหลักฐาน          (image picker — รูปสลิป)
//   Step 3 — บันทึกการชำระ      (amount + receipt_no + book_no + date)
//
// ใช้:
//   - POST /v2/payments/{uuid}/pay        (บันทึก)
//   - POST /v2/payments/{uuid}/attachments (อัปโหลดรูป — ถ้ามี)
// ============================================================================

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/license_payment_attachment.dart';
import '../../models/license_payment_detail_model.dart';
import '../../models/license_payment_method.dart';
import '../../services/license_payment_detail_service.dart';
import '../theme/license_payment_theme.dart';

// ============================================================================
// Public API
// ============================================================================

/// เปิด popup → คืน PaymentDetail? (เมื่อบันทึกสำเร็จ) / null (ยกเลิก)
///
/// [paymentSystem]: 'internal' (default จาก payment) → ซ่อน receipt_no/book_no/date
///                  'external' → แสดงครบ
/// [initialStep]:
///   1 = เลือกรูปแบบรับเงิน (default — กรณีสร้าง draft ใหม่)
///   3 = บันทึกการชำระ (กรณี payment มีอยู่แล้ว — ข้ามไป step ที่เหลือ)
Future<PaymentDetail?> showReceiptEntryStepperDialog({
  required BuildContext context,
  required PaymentDetail payment,
  double defaultAmount = 0,
  LicensePaymentDetailService? service,
  int initialStep = 1,
  String? paymentSystem,
}) {
  return showDialog<PaymentDetail>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ReceiptEntryStepperDialog(
      payment: payment,
      defaultAmount: defaultAmount,
      service: service ?? LicensePaymentDetailService(),
      initialStep: initialStep,
      paymentSystem: paymentSystem ?? payment.paymentSystem,
    ),
  );
}

// ============================================================================
// Dialog root
// ============================================================================

class ReceiptEntryStepperDialog extends StatefulWidget {
  final PaymentDetail payment;
  final double defaultAmount;
  final LicensePaymentDetailService service;
  final int initialStep;
  final String paymentSystem; // internal | external

  const ReceiptEntryStepperDialog({
    super.key,
    required this.payment,
    required this.defaultAmount,
    required this.service,
    this.initialStep = 1,
    this.paymentSystem = 'external',
  });

  @override
  State<ReceiptEntryStepperDialog> createState() =>
      _ReceiptEntryStepperDialogState();
}

class _ReceiptEntryStepperDialogState extends State<ReceiptEntryStepperDialog> {
  late int _step;
  static const int _kTotalSteps = 3;

  /// ช่องทางรับเงิน — internal ซ่อน receipt_no/book_no/date
  bool get _isInternal =>
      widget.paymentSystem.toLowerCase() == 'internal';

  // ─── Step 1 state ───
  List<LicensePaymentMethod> _methods = const [];
  bool _loadingMethods = true;
  LicensePaymentMethod? _selectedMethod;
  LicensePaymentBank? _selectedBank;

  // ─── Step 2 state (image upload) ───
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _uploadingImage = false;
  List<PaymentAttachment> _attachments = const [];
  bool _loadingAttachments = true;
  // uuid ของ payment ที่ resolve จากการแนบหลักฐานล่าสุด (ใช้แทน widget.payment.uuid)
  String? _resolvedPaymentUuid;

  // ─── Step 3 state ───
  late final TextEditingController _amountCtrl;
  late final TextEditingController _receiptCtrl;
  late final TextEditingController _bookCtrl;
  late final TextEditingController _dateCtrl;

  String? _error;
  bool _submitting = false;
  static const _kMaxImageBytes = 15 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    // ─── ถ้า payment มี payment_method_id แล้ว → ข้าม step 1 (เลือกรูปแบบการชำระ) ───
    final hasMethod =
        (widget.payment.paymentMethodId ?? '').trim().isNotEmpty;
    _step = hasMethod
        ? 2
        : widget.initialStep.clamp(1, _kTotalSteps);
    _amountCtrl = TextEditingController(
      text: widget.payment.amount > 0
          ? widget.payment.amount.toStringAsFixed(2)
          : widget.defaultAmount.toStringAsFixed(2),
    );
    _receiptCtrl = TextEditingController(text: widget.payment.paymentNo);
    _bookCtrl = TextEditingController();
    final today = DateTime.now();
    _dateCtrl = TextEditingController(
      text:
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
    );
    // seed attachments จาก payment.latestAttachment (ติดมาจาก /v2/requests/{uuid}/payments)
    final latest = widget.payment.latestAttachment;
    if (latest != null && latest.uuid.isNotEmpty) {
      _attachments = [latest];
      // ใช้ payment_uuid จาก latest_attachment เป็นค่าเริ่มต้น (ถ้ามี)
      if (latest.paymentUuid != null && latest.paymentUuid!.isNotEmpty) {
        _resolvedPaymentUuid = latest.paymentUuid;
      }
    }
    _loadingAttachments = false;
    _loadMethods();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _receiptCtrl.dispose();
    _bookCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMethods() async {
    try {
      final res = await widget.service.fetchPaymentMethods();
      if (!mounted) return;
      setState(() {
        _methods = res;
        _loadingMethods = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMethods = false);
    }
  }

  // ──────────────── Step 2: image picker ────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxHeight: 1600,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > _kMaxImageBytes) {
        _snack('รูปใหญ่เกินกำหนด (สูงสุด ~15 MB)');
        return;
      }
      setState(() {
        _pickedImage = picked;
        _pickedImageBytes = bytes;
      });
    } catch (e) {
      _snack('เลือกรูปไม่สำเร็จ: $e');
    }
  }

  /// อัปโหลดรูปที่เลือกทันที (เรียกจากปุ่ม "ยืนยัน" ใน step 2)
  /// คืน true ถ้าสำเร็จ
  Future<bool> _confirmUploadImage() async {
    if (_pickedImage == null) {
      _snack('กรุณาเลือกรูปสลิปก่อน');
      return false;
    }
    if (widget.payment.uuid.isEmpty) {
      _snack('ไม่พบ payment uuid');
      return false;
    }
    setState(() => _uploadingImage = true);
    try {
      // web: ส่ง bytes ตรงๆ (MultipartFile.fromBytes)
      // mobile: ส่ง path (MultipartFile.fromPath)
      PaymentAttachment? uploaded;
      final uploadUuid = _resolvedPaymentUuid ?? widget.payment.uuid;
      if (kIsWeb || _pickedImage!.path.isEmpty) {
        final bytes = _pickedImageBytes ?? await _pickedImage!.readAsBytes();
        uploaded = await widget.service.uploadPaymentAttachment(
          uuid: uploadUuid,
          fileBytes: bytes,
          fileName: _pickedImage!.name,
        );
      } else {
        uploaded = await widget.service.uploadPaymentAttachment(
          uuid: uploadUuid,
          filePath: _pickedImage!.path,
        );
      }
      if (!mounted) return false;
      // ใช้ response ที่ได้จาก upload ตรงๆ — เพิ่มเข้า list ทันที
      setState(() {
        _attachments = [
          ..._attachments,
          if (uploaded != null) uploaded,
        ];
        _pickedImage = null;
        _pickedImageBytes = null;
        // จำ uuid ของ payment ที่ attach สำเร็จไว้ — ใช้ตอน /pay
        if (uploaded != null &&
            uploaded.paymentUuid != null &&
            uploaded.paymentUuid!.isNotEmpty) {
          _resolvedPaymentUuid = uploaded.paymentUuid;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text('อัปโหลดหลักฐานสำเร็จ'),
            ],
          ),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
        ),
      );
      // ไป step 3 ต่อ
      _next();
      return true;
    } catch (e) {
      if (!mounted) return false;
      _snack('อัปโหลดไม่สำเร็จ: $e');
      return false;
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final raw = _amountCtrl.text.trim().replaceAll(',', '');
      final amount = double.tryParse(raw);
      if (amount == null || amount <= 0) {
        throw Exception('กรุณากรอกจำนวนเงินที่รับชำระ');
      }
      final dateStr = _dateCtrl.text.trim();
      if (dateStr.isNotEmpty) {
        final parts = dateStr.split('-');
        if (parts.length != 3) {
          throw Exception('รูปแบบวันที่ไม่ถูกต้อง (YYYY-MM-DD)');
        }
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y == null || m == null || d == null) {
          throw Exception('รูปแบบวันที่ไม่ถูกต้อง');
        }
        final dt = DateTime(y, m, d);
        final today = DateTime.now();
        final endOfToday =
            DateTime(today.year, today.month, today.day, 23, 59);
        if (dt.isAfter(endOfToday)) {
          throw Exception('วันที่ต้องไม่เกินวันนี้');
        }
      }

      if (widget.payment.uuid.isEmpty) {
        throw Exception('ไม่พบ payment uuid');
      }
      // resolve uuid ที่จะใช้ — ถ้ามี latest_attachment.paymentUuid หรือ upload สำเร็จไปก่อนหน้า ให้ใช้อันนั้น
      final payUuid = _resolvedPaymentUuid ?? widget.payment.uuid;
      // 1) อัปโหลดรูปก่อน (ถ้ามี)
      if (_pickedImage != null) {
        if (kIsWeb || _pickedImage!.path.isEmpty) {
          final bytes =
              _pickedImageBytes ?? await _pickedImage!.readAsBytes();
          await widget.service.uploadPaymentAttachment(
            uuid: payUuid,
            fileBytes: bytes,
            fileName: _pickedImage!.name,
          );
        } else {
          await widget.service.uploadPaymentAttachment(
            uuid: payUuid,
            filePath: _pickedImage!.path,
          );
        }
      }
      // 2) POST /pay — payload ต่างกันตาม paymentSystem
      final updated = await widget.service.pay(
        uuid: payUuid,
        amountReceived: amount,
        paymentSystem: widget.paymentSystem,
        receiptNo: _receiptCtrl.text.trim().isEmpty
            ? null
            : _receiptCtrl.text.trim(),
        bookNo:
            _bookCtrl.text.trim().isEmpty ? null : _bookCtrl.text.trim(),
        bookDate: dateStr.isEmpty ? null : dateStr,
      );

      if (!mounted) return;
      // caller reload เองหลัง pop
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _canGoNext() {
    if (_step == 1) {
      if (_selectedMethod != null &&
          _selectedMethod!.hasBankAccounts &&
          _selectedBank == null) {
        return false;
      }
      return true;
    }
    // step 2 (image) optional — ข้ามได้
    return true;
  }

  void _next() {
    if (_step < _kTotalSteps && _canGoNext()) {
      setState(() => _step += 1);
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LaColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: LaSpace.md),
              Flexible(child: _stepBody()),
              if (_error != null && _step == _kTotalSteps) ...[
                const SizedBox(height: LaSpace.sm),
                Text(_error!,
                    style: LaText.caption
                        .copyWith(color: LaColors.statusRejectedFg)),
              ],
              const SizedBox(height: LaSpace.md),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── header ────────────────
  Widget _header() => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LaColors.primaryDark,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('บันทึกการรับชำระ', style: LaText.h2.copyWith(fontSize: 16)),
                Text(
                  widget.payment.uuid.isEmpty
                      ? '-'
                      : 'uuid: ${widget.payment.uuid}',
                  style: LaText.caption.copyWith(
                      fontFamily: 'monospace',
                      color: LaColors.textMuted,
                      fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'ปิด',
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed:
                _submitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      );

  // ──────────────── step body (switch) ────────────────
  Widget _stepBody() {
    switch (_step) {
      case 1:
        return _stepSection(
          number: 1,
          title: 'เลือกรูปแบบการชำระ',
          child: _step1Body(),
        );
      case 2:
        return _stepSection(
          number: 2,
          title: 'อัพหลักฐาน',
          child: _step2Body(),
        );
      default:
        return _stepSection(
          number: 3,
          title: 'บันทึกการชำระ',
          child: _step3Body(),
        );
    }
  }

  // ──────────────── step section (bordered card) ────────────────
  Widget _stepSection({
    required int number,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border),
      ),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LaColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: LaText.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: LaText.body
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          child,
        ],
      ),
    );
  }

  // ──────────────── Step 1 ────────────────
  Widget _step1Body() {
    // ─── ถ้า payment มี payment_method_id แล้ว → แสดง read-only summary ───
    final lockedMethod =
        (widget.payment.paymentMethodId ?? '').trim().isNotEmpty;
    if (lockedMethod) {
      return _lockedMethodSummary();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomDropdown<LicensePaymentMethod>(
          items: _methods,
          initialItem: _selectedMethod,
          hintText: _loadingMethods
              ? 'กำลังโหลด...'
              : 'กรุงเทพมหานครมหา...',
          overlayHeight: 280,
          headerBuilder: (ctx, m, _) => _methodRow(m),
          listItemBuilder: (ctx, m, isSel, onSelect) => InkWell(
            onTap: onSelect,
            child: _methodRow(m),
          ),
          onChanged: (m) => setState(() {
            _selectedMethod = m;
            _selectedBank = null;
          }),
        ),
        if (_selectedMethod != null && _selectedMethod!.hasBankAccounts) ...[
          const SizedBox(height: LaSpace.sm),
          CustomDropdown<LicensePaymentBank>(
            items: _selectedMethod!.banks,
            initialItem: _selectedBank,
            hintText: 'เลือกบัญชี',
            overlayHeight: 220,
            headerBuilder: (ctx, b, _) => _bankRow(b),
            listItemBuilder: (ctx, b, isSel, onSelect) => InkWell(
              onTap: onSelect,
              child: _bankRow(b),
            ),
            onChanged: (b) => setState(() => _selectedBank = b),
          ),
        ],
        const SizedBox(height: LaSpace.sm),
        Text(
          'เลือกหรือข้ามได้ — กด "ถัดไป" เพื่อไปอัพหลักฐาน',
          style: LaText.caption.copyWith(color: LaColors.textMuted),
        ),
      ],
    );
  }

  /// การ์ด read-only เมื่อ payment มี payment_method_id แล้ว
  /// (ไม่ให้ผู้ใช้เปลี่ยน method — popup จะข้ามไป step 2/3 ทันที)
  ///
  /// แสดงเป็นรายการ methods + banks ทั้งหมดที่ผูกกับ payment นี้
  /// (CASH = 1 row, BANK_TRANSFER = 1 row ต่อ bank account)
  Widget _lockedMethodSummary() {
    final p = widget.payment;
    final mid = (p.paymentMethodId ?? '').trim();
    int? midInt = int.tryParse(mid);
    // match method ที่ถูกเลือก (highlight แถวนั้น)
    LicensePaymentMethod? matched;
    for (final m in _methods) {
      if (m.id == midInt || m.id.toString() == mid) {
        matched = m;
        break;
      }
    }

    final cashMethods = _methods.where((m) => m.isCash).toList();
    final bankMethods =
        _methods.where((m) => !m.isCash && m.hasBankAccounts).toList();

    final hasAnyData = cashMethods.isNotEmpty || bankMethods.isNotEmpty;
    if (!hasAnyData && matched == null) {
      // fallback — ไม่มีข้อมูล lookup เลย
      return Container(
        padding: const EdgeInsets.all(LaSpace.md),
        decoration: BoxDecoration(
          color: LaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 16, color: LaColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p.methodName.isNotEmpty
                    ? p.methodName
                    : 'ช่องทางรับเงิน (method_id=$mid)',
                style: LaText.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: LaColors.cardBg,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── header ───
          Container(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.md, LaSpace.sm, LaSpace.md, LaSpace.sm),
            decoration: BoxDecoration(
              color: LaColors.statusApprovedBg.withOpacity(.5),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(LaRadius.sm)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LaColors.statusApprovedFg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'เลือกการชำระ',
                    style: LaText.body
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: LaColors.statusApprovedFg,
                    borderRadius: BorderRadius.circular(LaRadius.pill),
                  ),
                  child: Text(
                    'เลือกแล้ว',
                    style: LaText.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── rows (cash แล้วตามด้วย banks) ───
          ..._buildLockedRows(cashMethods, bankMethods, matched),
        ],
      ),
    );
  }

  List<Widget> _buildLockedRows(
    List<LicensePaymentMethod> cashMethods,
    List<LicensePaymentMethod> bankMethods,
    LicensePaymentMethod? selectedMethod,
  ) {
    final rows = <Widget>[];
    var index = 0;
    final total =
        cashMethods.length + bankMethods.fold<int>(0, (s, m) => s + m.banks.length);

    // cash row(s)
    for (final m in cashMethods) {
      rows.add(_lockedRow(
        index: index++,
        total: total,
        icon: Icons.payments_rounded,
        iconColor: LaColors.statusApprovedFg,
        title: m.nameTh.isNotEmpty ? m.nameTh : 'เงินสด',
        subtitle: '(ช่องรับแบบเงินสด)',
        rightPrimary: m.code.isNotEmpty ? m.code : 'เงินสด',
        rightSecondary: null,
        isSelected: selectedMethod != null && m.id == selectedMethod.id,
      ));
    }

    // bank rows (one row per bank)
    for (final m in bankMethods) {
      for (final b in m.banks) {
        // ขวาบน: bank_id (ถ้ามี) ไม่งั้น bank_account
        final rightPrimary = (b.bankId != null && b.bankId! > 0)
            ? b.bankId.toString()
            : (b.bankAccount?.isNotEmpty == true
                ? b.bankAccount!
                : (b.bankCode ?? '-'));
        // ขวาล่าง: ชื่อบัญชี/ผู้ถือบัญชี
        final rightSecondary = (b.bankName ?? '').isNotEmpty
            ? b.bankName!
            : ((b.branch ?? '').isNotEmpty ? 'สาขา ${b.branch}' : null);

        rows.add(_lockedRow(
          index: index++,
          total: total,
          icon: Icons.account_balance_rounded,
          iconColor: LaColors.statusInfoFg,
          title: 'เงินโอน',
          subtitle: '(แบบเอกสาร QR แอป)',
          rightPrimary: rightPrimary,
          rightSecondary: rightSecondary,
          isSelected: selectedMethod != null && m.id == selectedMethod.id,
        ));
      }
    }

    return rows;
  }

  Widget _lockedRow({
    required int index,
    required int total,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String rightPrimary,
    required String? rightSecondary,
    required bool isSelected,
  }) {
    final showDivider = index > 0;
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? LaColors.statusApprovedBg.withOpacity(.25)
            : Colors.transparent,
        border: showDivider
            ? const Border(
                top: BorderSide(color: LaColors.border, width: 1),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── left: icon + title/subtitle ───
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(LaRadius.pill),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style:
                      LaText.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: LaText.caption
                      .copyWith(color: LaColors.textMuted),
                ),
              ],
            ),
          ),
          // ─── right: primary + secondary ───
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rightPrimary,
                style: LaText.body.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: LaColors.primaryDark,
                ),
              ),
              if (rightSecondary != null && rightSecondary.isNotEmpty) ...[
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    rightSecondary,
                    style: LaText.caption
                        .copyWith(color: LaColors.textMuted),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── Step 2 — Image upload ────────────────
  Widget _step2Body() {
    final hasImage = _pickedImage != null;

    // ─── กำลังโหลดรายการ attachments ───
    if (_loadingAttachments) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // ─── แนบหลักฐานแล้ว รอบันทึกการชำระ → แสดงรายการ + ปุ่มเพิ่ม ───
    if (_attachments.isNotEmpty && !hasImage) {
      return _alreadyUploadedView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── พื้นที่แสดงรูปที่เลือก (หรือ placeholder) ───
        if (hasImage)
          Container(
            padding: const EdgeInsets.all(LaSpace.md),
            decoration: BoxDecoration(
              color: LaColors.statusApprovedBg.withOpacity(.3),
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(
                  color: LaColors.statusApprovedFg.withOpacity(.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: LaColors.statusApprovedFg.withOpacity(.15),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: _pickedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(LaRadius.sm),
                          child: Image.memory(
                            _pickedImageBytes!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        )
                      : const Icon(Icons.image_rounded,
                          size: 26, color: LaColors.statusApprovedFg),
                ),
                const SizedBox(width: LaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pickedImage!.name,
                        style: LaText.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'รองรับ .jpg, .png (สูงสุด ~15 MB)',
                        style: LaText.caption
                            .copyWith(color: LaColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ลบ',
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => setState(() {
                    _pickedImage = null;
                    _pickedImageBytes = null;
                  }),
                  color: LaColors.statusRejectedFg,
                ),
              ],
            ),
          )
        else
          // ─── พื้นที่ว่าง + ปุ่ม Gallery/Camera ตรงนี้เลย ───
          Container(
            padding: const EdgeInsets.all(LaSpace.md),
            decoration: BoxDecoration(
              color: LaColors.surface,
              borderRadius: BorderRadius.circular(LaRadius.md),
              border: Border.all(color: LaColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: LaColors.primaryDark.withOpacity(.08),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_rounded,
                      size: 26, color: LaColors.primaryDark),
                ),
                const SizedBox(width: LaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'คลิกเพื่อแนบรูปสลิป',
                        style: LaText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: LaColors.primaryDark,
                        ),
                      ),
                      Text(
                        'รองรับ .jpg, .png (สูงสุด ~15 MB)',
                        style: LaText.caption
                            .copyWith(color: LaColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: LaSpace.sm),

        // ─── ปุ่ม Gallery / Camera (เลือกตรงนี้ได้เลย — ไม่ต้องเปิด bottom sheet) ───
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _uploadingImage ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 16),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _uploadingImage ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded, size: 16),
                label: const Text('ถ่ายรูป'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),

        // ─── ปุ่ม "ยืนยัน" — อัปโหลดรูปที่เลือกทันที (ปรากฏเมื่อมีรูป) ───
        if (hasImage) ...[
          const SizedBox(height: LaSpace.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _uploadingImage ? null : _confirmUploadImage,
              icon: _uploadingImage
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded, size: 16),
              label: Text(_uploadingImage
                  ? 'กำลังอัปโหลด...'
                  : 'รอบันทึกการชำระ'),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],

        const SizedBox(height: LaSpace.sm),
        Text(
          'รูปสลิปจะถูกอัปโหลดก่อนบันทึกการรับชำระ (หรือข้ามได้)',
          style: LaText.caption.copyWith(color: LaColors.textMuted),
        ),
      ],
    );
  }

  /// แสดงเมื่อ payment มี attachments อัปโหลดไว้แล้ว (read-only list + เพิ่มใหม่ได้)
  Widget _alreadyUploadedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── banner "เคยอัพแล้ว" ───
        Container(
          padding: const EdgeInsets.all(LaSpace.md),
          decoration: BoxDecoration(
            color: LaColors.statusApprovedBg.withOpacity(.35),
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
                color: LaColors.statusApprovedFg.withOpacity(.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.statusApprovedFg.withOpacity(.2),
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.cloud_done_rounded,
                    size: 18, color: LaColors.statusApprovedFg),
              ),
              const SizedBox(width: LaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'หลักฐานแล้ว รอชืนยัน',
                      style: LaText.body
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${_attachments.length} ไฟล์ — แนบเพิ่มได้ (สูงสุด ~15 MB/ไฟล์)',
                      style: LaText.caption
                          .copyWith(color: LaColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: LaSpace.sm),

        // ─── รายการไฟล์ที่อัปโหลดแล้ว ───
        ..._attachments.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < _attachments.length - 1 ? 6 : 0),
            child: _attachmentRow(a),
          );
        }),

        const SizedBox(height: LaSpace.sm),

        // ─── ปุ่มเพิ่มไฟล์ใหม่ ───
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _uploadingImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 16),
                label: const Text('เพิ่มรูปจาก Gallery'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: LaSpace.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _uploadingImage
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded, size: 16),
                label: const Text('ถ่ายรูปเพิ่ม'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: LaSpace.sm),
        Text(
          'อัปโหลดหลากหลายไฟล์ได้ — กด "ถัดไป" เพื่อไปบันทึกการรับชำระ',
          style: LaText.caption.copyWith(color: LaColors.textMuted),
        ),
      ],
    );
  }

  Widget _attachmentRow(PaymentAttachment a) {
    final name = a.filename?.isNotEmpty == true
        ? a.filename!
        : (a.uuid.isNotEmpty
            ? '${a.uuid.substring(0, 8)}…'
            : 'attachment');
    final sizeKb = a.size != null ? '${(a.size! / 1024).toStringAsFixed(1)} KB' : '';
    return Container(
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusApprovedBg.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.statusApprovedFg.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaColors.statusApprovedFg.withOpacity(.15),
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.image_rounded,
                size: 18, color: LaColors.statusApprovedFg),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: LaText.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (a.mimeType?.isNotEmpty == true) a.mimeType!,
                    if (sizeKb.isNotEmpty) sizeKb,
                  ].join(' • '),
                  style: LaText.caption.copyWith(
                    color: LaColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              size: 16, color: LaColors.statusApprovedFg),
        ],
      ),
    );
  }

  // ──────────────── Step 3 — Receipt form ────────────────
  Widget _step3Body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── banner system ───
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: LaSpace.md, vertical: LaSpace.sm),
          decoration: BoxDecoration(
            color: _isInternal
                ? LaColors.statusInfoBg.withOpacity(.45)
                : LaColors.statusApprovedBg.withOpacity(.35),
            borderRadius: BorderRadius.circular(LaRadius.sm),
            border: Border.all(
              color: (_isInternal
                      ? LaColors.statusInfoFg
                      : LaColors.statusApprovedFg)
                  .withOpacity(.45),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isInternal
                    ? Icons.account_balance_rounded
                    : Icons.receipt_long_rounded,
                size: 16,
                color: _isInternal
                    ? LaColors.statusInfoFg
                    : LaColors.statusApprovedFg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isInternal
                      ? 'ช่องทางในระบบ — บันทึกด้วยจำนวนเงินอย่างเดียว'
                      : 'ช่องทางภายนอก — ต้องระบุเลขที่ใบเสร็จ / เล่ม / วันที่',
                  style: LaText.caption.copyWith(
                    color: _isInternal
                        ? LaColors.statusInfoFg
                        : LaColors.statusApprovedFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LaSpace.sm),
        _field(
          label: 'จำนวนเงินที่รับชำระ *',
          icon: Icons.payments_rounded,
          controller: _amountCtrl,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (!_isInternal) ...[
          const SizedBox(height: LaSpace.sm),
          _field(
            label: 'เลขที่ใบเสร็จ',
            icon: Icons.tag_rounded,
            controller: _receiptCtrl,
            hint: widget.payment.paymentNo.isEmpty
                ? 'PAY-...'
                : widget.payment.paymentNo,
          ),
          const SizedBox(height: LaSpace.sm),
          _field(
            label: 'เลขที่หนังสือ/เล่ม',
            icon: Icons.menu_book_rounded,
            controller: _bookCtrl,
            hint: 'B-001',
          ),
          const SizedBox(height: LaSpace.sm),
          Row(
            children: [
              Expanded(
                child: _field(
                  label: 'วันที่ทำรายการ',
                  icon: Icons.calendar_today_rounded,
                  controller: _dateCtrl,
                  hint: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: OutlinedButton(
                  onPressed: _pickDate,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LaRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  child: const Icon(Icons.event_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ──────────────── footer ────────────────
  Widget _footer() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _submitting ? null : _back,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(_step == 1 ? 'ยกเลิก' : 'ย้อนกลับ'),
          ),
          if (_step < _kTotalSteps)
            FilledButton.icon(
              onPressed: (!_canGoNext() || _submitting) ? null : _next,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('ถัดไป'),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            )
          else
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: const Text('บันทึกการรับชำระ'),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      );

  // ──────────────── helpers ────────────────
  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: LaText.label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            prefixIcon: Icon(icon, size: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parts = _dateCtrl.text.split('-');
    DateTime initial = now;
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) initial = DateTime(y, m, d);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _methodRow(LicensePaymentMethod m) {
    final fg =
        m.isCash ? LaColors.statusApprovedFg : LaColors.statusInfoFg;
    final bg = m.isCash ? const Color(0x1A22C55E) : LaColors.statusInfoBg;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Icon(
            m.isCash
                ? Icons.payments_rounded
                : Icons.account_balance_rounded,
            size: 14,
            color: fg,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                m.nameTh.isNotEmpty ? m.nameTh : m.code,
                style: LaText.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${m.code}  •  id=${m.id}'
                '${m.hasBankAccounts ? '  •  ${m.banks.length} บัญชี' : ''}',
                style: LaText.caption.copyWith(
                  fontFamily: 'monospace',
                  color: LaColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankRow(LicensePaymentBank b) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: const Icon(Icons.account_balance_rounded,
              size: 12, color: LaColors.textMuted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (b.bankName ?? '-').isEmpty ? '-' : b.bankName!,
                style: LaText.tableCell,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                [
                  if ((b.bankCode ?? '').isNotEmpty) b.bankCode,
                  if ((b.bankAccount ?? '').isNotEmpty) b.bankAccount,
                  if ((b.branch ?? '').isNotEmpty) 'สาขา ${b.branch}',
                ].join(' • '),
                style: LaText.caption.copyWith(
                  fontFamily: 'monospace',
                  color: LaColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}