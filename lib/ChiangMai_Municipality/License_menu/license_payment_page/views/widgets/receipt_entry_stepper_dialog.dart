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
  String? defaultMethodId,
  // ─── สำหรับ new draft: ถ้า payment.uuid ว่าง → dialog จะสร้าง payment ตอน step 1 → next ───
  String? requestUuid,
  String? debtLineUuid,
  String? payType,
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
      defaultMethodId: defaultMethodId,
      requestUuid: requestUuid,
      debtLineUuid: debtLineUuid,
      payType: payType,
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
  final String?
      defaultMethodId; // pre-select method จากประวัติ (lock ไม่ให้แก้)

  // ─── new draft fields — ถ้า payment.uuid ว่าง จะสร้าง payment ใหม่ตอน step 1 → next ───
  final String? requestUuid;
  final String? debtLineUuid;
  final String? payType;

  const ReceiptEntryStepperDialog({
    super.key,
    required this.payment,
    required this.defaultAmount,
    required this.service,
    this.initialStep = 1,
    this.paymentSystem = 'external',
    this.defaultMethodId,
    this.requestUuid,
    this.debtLineUuid,
    this.payType,
  });

  @override
  State<ReceiptEntryStepperDialog> createState() =>
      _ReceiptEntryStepperDialogState();
}

class _ReceiptEntryStepperDialogState extends State<ReceiptEntryStepperDialog> {
  late int _step;

  /// 3 steps หลัก:
  ///   1 = เลือก external/internal (ถ้า internal → เด้ง popup เลือก method แยก)
  ///   2 = อัพรูป (optional)
  ///   3 = บันทึกการรับชำระ
  static const int _kTotalSteps = 3;

  /// mutable copy ของ widget.payment — update หลัง createPayment สำเร็จ
  late PaymentDetail _payment;

  /// mutable payment_system (external/internal) — user เลือกใน step 1
  late String _paymentSystem;

  /// ช่องทางรับเงิน — internal ซ่อน receipt_no/book_no/date
  bool get _isInternal => _paymentSystem.toLowerCase() == 'internal';

  /// pay_type 'fine' (ค่าปรับ) — ใช้โชว์ chip + เปลี่ยนสี label
  bool get _isFine => (widget.payType ?? '').toLowerCase() == 'fine';

  // ─── Methods cache (ใช้ตอนเด้ง popup เลือก method) ───
  List<LicensePaymentMethod> _methods = const [];
  bool _loadingMethods = true;

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
    _payment = widget.payment;
    _paymentSystem = widget.payment.paymentSystem.isNotEmpty
        ? widget.payment.paymentSystem
        : widget.paymentSystem;
    // ─── ถ้า payment มี payment_method_id แล้ว → ข้ามไป step 2 (upload) ───
    final hasMethod = (widget.payment.paymentMethodId ?? '').trim().isNotEmpty;
    if (hasMethod) {
      _step = 2; // skip system picker (method มาจาก payment)
    } else if ((widget.requestUuid ?? '').isEmpty) {
      // ไม่ใช่ new draft — caller เปิดมาที่ step ที่ระบุ
      _step = widget.initialStep.clamp(1, _kTotalSteps);
    } else {
      // new draft — เริ่มที่ step 1 (เลือก system)
      _step = 1;
    }
    _amountCtrl = TextEditingController(
      text: widget.payment.amount > 0
          ? widget.payment.amount.toStringAsFixed(2)
          : widget.defaultAmount.toStringAsFixed(2),
    );
    // ─── ห้ามดีฟอล — ให้ user กรอกเอง ───
    _receiptCtrl = TextEditingController();
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

  /// Validate ก่อนบันทึก — required fields ต้องครบ
  /// - amount > 0
  /// - internal: แค่ amount
  /// - external: amount + receipt_no + book_no + date
  bool _canSubmit() {
    final raw = _amountCtrl.text.trim().replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return false;
    if (_isInternal) return true;
    return _receiptCtrl.text.trim().isNotEmpty &&
        _bookCtrl.text.trim().isNotEmpty &&
        _dateCtrl.text.trim().isNotEmpty;
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
    if (_payment.uuid.isEmpty) {
      _snack('ไม่พบ payment uuid');
      return false;
    }
    setState(() => _uploadingImage = true);
    try {
      // web: ส่ง bytes ตรงๆ (MultipartFile.fromBytes)
      // mobile: ส่ง path (MultipartFile.fromPath)
      PaymentAttachment? uploaded;
      final uploadUuid = _resolvedPaymentUuid ?? _payment.uuid;
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
        final endOfToday = DateTime(today.year, today.month, today.day, 23, 59);
        if (dt.isAfter(endOfToday)) {
          throw Exception('วันที่ต้องไม่เกินวันนี้');
        }
      }

      if (_payment.uuid.isEmpty) {
        throw Exception('ไม่พบ payment uuid');
      }
      // resolve uuid ที่จะใช้ — ถ้ามี latest_attachment.paymentUuid หรือ upload สำเร็จไปก่อนหน้า ให้ใช้อันนั้น
      final payUuid = _resolvedPaymentUuid ?? _payment.uuid;
      // 1) อัปโหลดรูปก่อน (ถ้ามี)
      if (_pickedImage != null) {
        if (kIsWeb || _pickedImage!.path.isEmpty) {
          final bytes = _pickedImageBytes ?? await _pickedImage!.readAsBytes();
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
        receiptNo:
            _receiptCtrl.text.trim().isEmpty ? null : _receiptCtrl.text.trim(),
        bookNo: _bookCtrl.text.trim().isEmpty ? null : _bookCtrl.text.trim(),
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
      // step 1: ต้องเลือก external/internal ก่อน
      return _paymentSystem.isNotEmpty;
    }
    // step 2 (image) optional — ข้ามได้
    return true;
  }

  void _next() {
    if (_step >= _kTotalSteps || !_canGoNext()) return;
    // ─── step 1: เลือก external/internal → ถ้า internal เด้ง popup เลือก method แยก ───
    if (_step == 1) {
      if (_payment.uuid.isNotEmpty) {
        // payment ถูกสร้างมาแล้ว (e.g. user back จาก step 2) → ข้ามไป step 2 เฉยๆ
        setState(() => _step = 2);
      } else if (_isInternal) {
        // new draft + internal → เด้ง popup เลือก method
        _showMethodPickerAndProceed();
      } else {
        // new draft + external → สร้าง draft ทันที
        _createDraftAndAdvance(targetStep: 2);
      }
      return;
    }
    setState(() => _step += 1);
  }

  bool _creatingDraft = false;

  /// เด้ง popup เลือก method (เฉพาะ internal) → หลังเลือกแล้ว create draft + ไป step 2
  Future<void> _showMethodPickerAndProceed() async {
    // ถ้ายังโหลด methods ไม่เสร็จ → รอก่อน
    if (_methods.isEmpty && _loadingMethods) {
      // รอสักครู่ให้ _loadMethods เสร็จ (initState เรียกไปแล้ว)
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!mounted) return;
    // เปิด popup เลือก method
    final picked = await showPaymentMethodPickerDialog(
      context: context,
      methods: _methods,
      isLoading: _loadingMethods,
      initialMethodId: widget.defaultMethodId,
    );
    if (picked == null || !mounted) return;
    // สร้าง draft พร้อม method ที่เลือก → ไป step 2
    await _createDraftAndAdvance(targetStep: 2, methodId: picked.id);
  }

  Future<void> _createDraftAndAdvance({
    required int targetStep,
    int? methodId,
  }) async {
    if (_creatingDraft) return;
    final useMethodId =
        methodId ?? (_isInternal ? null : null); // external → no method
    setState(() => _creatingDraft = true);
    try {
      final created = await widget.service.createPayment(
        requestUuid: widget.requestUuid ?? '',
        debtLineUuid: widget.debtLineUuid ?? '',
        payType: widget.payType ?? 'fee',
        amount: widget.defaultAmount,
        paymentSystem: _paymentSystem,
        paymentMethodId: useMethodId,
      );
      if (!mounted) return;
      setState(() {
        _payment = created;
        _creatingDraft = false;
        _step = targetStep;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _creatingDraft = false);
      _snack('สร้างรายการรับชำระไม่สำเร็จ: $e');
    }
  }

  void _back() {
    if (_step == 3) {
      // ✅ step 3 → step 2 (ต้องกลับไปแนบรูปได้เสมอ)
      setState(() => _step = 2);
    } else {
      // ✅ step 1 → ออก dialog (ห้ามเลือกใหม่)
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
              // ✅ Banner สรุปจากขั้นตอนที่ 1 — แยกกล่องบนสุด (เห็นทุก step ที่ >= 2)
              if (_step > 1) ...[
                _SelectedSystemBanner(isInternal: _isInternal),
                const SizedBox(height: LaSpace.md),
              ],
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
                Row(
                  children: [
                    Text('บันทึกการรับชำระ',
                        style: LaText.h2.copyWith(fontSize: 16)),
                    if ((widget.payType ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isFine
                              ? LaColors.statusRejectedFg.withOpacity(.12)
                              : LaColors.statusInfoFg.withOpacity(.12),
                          borderRadius: BorderRadius.circular(LaRadius.pill),
                        ),
                        child: Text(
                          _isFine ? 'ค่าปรับ' : 'ค่าธรรมเนียม',
                          style: LaText.caption.copyWith(
                            color: _isFine
                                ? LaColors.statusRejectedFg
                                : LaColors.statusInfoFg,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      );

  // ──────────────── step body (switch) ────────────────
  Widget _stepBody() {
    switch (_step) {
      case 1:
        return _stepSection(
          number: 1,
          title: 'เลือกประเภทการรับชำระ',
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
                  style: LaText.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          child,
        ],
      ),
    );
  }

  // ──────────────── Step 1: เลือก external/internal ────────────────
  Widget _step1Body() {
    // lock ถ้า: payment.uuid ไม่ว่าง (edit) หรือ widget.paymentSystem มาจากประวัติ
    final isLocked = _payment.uuid.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _systemPickerCard(
              value: 'external',
              icon: Icons.receipt_long_rounded,
              title: 'External',
              subtitle: 'ออกใบเสร็จเอง — ต้องระบุ receipt_no / book_no',
              selected: _paymentSystem == 'external',
              enabled: !isLocked,
            ),
            const SizedBox(width: LaSpace.sm),
            _systemPickerCard(
              value: 'internal',
              icon: Icons.account_balance_rounded,
              title: 'Internal',
              subtitle: 'ใช้ช่องทางในระบบ — ไม่ต้องออกใบเสร็จ',
              selected: _paymentSystem == 'internal',
              enabled: !isLocked,
            ),
          ],
        ),
        const SizedBox(height: LaSpace.sm),
        // ⚠️ แจ้งเตือนชัดเจน: ถูกเลือกไปแล้วห้ามเลือกใหม่
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 6),
          decoration: BoxDecoration(
            color: LaColors.statusInfoBg.withOpacity(.35),
            borderRadius: BorderRadius.circular(LaRadius.sm),
            border: Border.all(color: LaColors.statusInfoFg.withOpacity(.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: LaColors.statusInfoFg),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'เลือกแล้วห้ามเลือกใหม่ — กด "ถัดไป" เพื่อดำเนินการต่อ',
                  style: LaText.caption
                      .copyWith(color: LaColors.statusInfoFg, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _systemPickerCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required bool enabled,
  }) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? () => setState(() => _paymentSystem = value) : null,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: Container(
          padding: const EdgeInsets.all(LaSpace.md),
          decoration: BoxDecoration(
            color: selected ? LaColors.primaryLight : LaColors.cardBg,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: selected ? LaColors.primary : LaColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon,
                      size: 18,
                      color:
                          selected ? LaColors.primaryDark : LaColors.textMuted),
                  const SizedBox(width: 6),
                  Text(title,
                      style: LaText.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? LaColors.primaryDark
                            : LaColors.textPrimary,
                      )),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: LaColors.primaryDark),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: LaText.caption.copyWith(color: LaColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── Banner: แสดง system ที่เลือกใน step 1 (ใช้ใน step 2) ────────────────
  Widget _SelectedSystemBanner({required bool isInternal}) {
    final accent =
        isInternal ? LaColors.statusInfoFg : LaColors.statusApprovedFg;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: isInternal
            ? LaColors.statusInfoBg.withOpacity(.45)
            : LaColors.statusApprovedBg.withOpacity(.35),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: accent.withOpacity(.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Header row: "สรุปจากขั้นตอนที่ 1" (top, subtle) ───
          Row(
            children: [
              Icon(Icons.bookmark_rounded, size: 13, color: accent),
              const SizedBox(width: 4),
              Text(
                'สรุปจากขั้นตอนที่ 1',
                style: LaText.caption.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // ─── Detail row: icon + selection + subtitle ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isInternal
                    ? Icons.account_balance_rounded
                    : Icons.receipt_long_rounded,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'เลือก',
                          style: LaText.caption
                              .copyWith(color: LaColors.textMuted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isInternal ? 'Internal' : 'External',
                          style: LaText.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '✓ ถูกเลือกไปแล้ว',
                          style: LaText.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isInternal
                          ? 'ช่องทางในระบบ — ไม่ต้องออกใบเสร็จ'
                          : 'ช่องทางภายนอก — ต้องระบุ เลขที่ใบเสร็จ / เล่มที่ใบเสร็จ',
                      style: LaText.caption.copyWith(
                        color: LaColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
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
              border:
                  Border.all(color: LaColors.statusApprovedFg.withOpacity(.4)),
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
                        style:
                            LaText.caption.copyWith(color: LaColors.textMuted),
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
                        style:
                            LaText.caption.copyWith(color: LaColors.textMuted),
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
                onPressed: _uploadingImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
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
                onPressed: _uploadingImage
                    ? null
                    : () => _pickImage(ImageSource.camera),
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
              label:
                  Text(_uploadingImage ? 'กำลังอัปโหลด...' : 'รอบันทึกการชำระ'),
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
            border:
                Border.all(color: LaColors.statusApprovedFg.withOpacity(.5)),
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
                      style: LaText.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${_attachments.length} ไฟล์ — แนบเพิ่มได้ (สูงสุด ~15 MB/ไฟล์)',
                      style: LaText.caption.copyWith(color: LaColors.textMuted),
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
            padding:
                EdgeInsets.only(bottom: i < _attachments.length - 1 ? 6 : 0),
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
        : (a.uuid.isNotEmpty ? '${a.uuid.substring(0, 8)}…' : 'attachment');
    final sizeKb =
        a.size != null ? '${(a.size! / 1024).toStringAsFixed(1)} KB' : '';
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
          // ✅ step 1: ปุ่ม "ปิด" (ออก dialog — ห้ามเลือกใหม่)
          // ✅ step 3: ปุ่ม "กลับไปแนบรูป" (ไป step 2)
          // ✅ step 2: ซ่อน (ห้ามย้อนไป step 1)
          if (_step == 1)
            TextButton.icon(
              onPressed: _submitting ? null : _back,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('ปิด'),
            )
          else if (_step == 3)
            TextButton.icon(
              onPressed: _submitting ? null : _back,
              icon: const Icon(Icons.image_rounded, size: 16),
              label: const Text('กลับไปแนบรูป'),
            )
          else
            const SizedBox.shrink(),
          if (_step < _kTotalSteps)
            FilledButton.icon(
              onPressed: (!_canGoNext() || _submitting || _creatingDraft)
                  ? null
                  : _next,
              icon: _creatingDraft
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(_creatingDraft ? 'กำลังสร้าง...' : 'ถัดไป'),
              style: FilledButton.styleFrom(
                backgroundColor: LaColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            )
          else
            FilledButton.icon(
              onPressed: (_submitting || !_canSubmit()) ? null : _submit,
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
          onChanged: (_) => setState(() {}),
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
}

// ============================================================================
// Separate popup: เลือก method (internal)
// ============================================================================
//
// เด้งขึ้นตอน user เลือก "internal" ใน stepper → กด "ถัดไป"
// คืน LicensePaymentMethod? (null = ยกเลิก)
// ============================================================================

Future<LicensePaymentMethod?> showPaymentMethodPickerDialog({
  required BuildContext context,
  required List<LicensePaymentMethod> methods,
  bool isLoading = false,
  String? initialMethodId,
}) {
  return showDialog<LicensePaymentMethod>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _PaymentMethodPickerDialog(
      methods: methods,
      isLoading: isLoading,
      initialMethodId: initialMethodId,
    ),
  );
}

class _PaymentMethodPickerDialog extends StatefulWidget {
  final List<LicensePaymentMethod> methods;
  final bool isLoading;
  final String? initialMethodId;

  const _PaymentMethodPickerDialog({
    required this.methods,
    required this.isLoading,
    this.initialMethodId,
  });

  @override
  State<_PaymentMethodPickerDialog> createState() =>
      _PaymentMethodPickerDialogState();
}

class _PaymentMethodPickerDialogState
    extends State<_PaymentMethodPickerDialog> {
  /// เก็บ index ของ method ที่เลือก (unique ต่อ render — uuid/id อาจว่าง/ซ้ำจาก API)
  int? _pickedIndex;

  LicensePaymentMethod? get _picked =>
      _pickedIndex != null && _pickedIndex! < widget.methods.length
          ? widget.methods[_pickedIndex!]
          : null;

  @override
  void initState() {
    super.initState();
    // pre-select จาก initialMethodId (ถ้ามี)
    final want = widget.initialMethodId;
    if (want != null && want.trim().isNotEmpty) {
      for (var i = 0; i < widget.methods.length; i++) {
        final m = widget.methods[i];
        if (m.uuid.isNotEmpty && m.uuid.toLowerCase() == want.toLowerCase()) {
          _pickedIndex = i;
          break;
        }
        if (m.id.toString() == want) {
          _pickedIndex = i;
          break;
        }
      }
    }
  }

  /// หา index ของ method m ใน list (เทียบ uuid ก่อน, ไม่งั้นใช้ object identity)
  int? _indexOf(LicensePaymentMethod m) {
    for (var i = 0; i < widget.methods.length; i++) {
      final x = widget.methods[i];
      if (identical(x, m)) return i;
      if (m.uuid.isNotEmpty &&
          x.uuid.isNotEmpty &&
          m.uuid.toLowerCase() == x.uuid.toLowerCase()) {
        return i;
      }
    }
    return null;
  }

  bool get _canConfirm => _picked != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LaColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: LaSpace.md),
              _body(),
              const SizedBox(height: LaSpace.md),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LaColors.primaryDark,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.account_balance_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('เลือกช่องทางรับชำระ',
                    style: LaText.h2.copyWith(fontSize: 16)),
                Text(
                  'ช่องทางในระบบ — ต้องระบุ',
                  style: LaText.caption.copyWith(color: LaColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'ปิด',
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

  Widget _body() {
    if (widget.isLoading && widget.methods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (widget.methods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(LaSpace.md),
        decoration: BoxDecoration(
          color: LaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: LaColors.textMuted),
            SizedBox(width: 8),
            Expanded(
              child: Text('ไม่พบช่องทางรับเงิน — ลองใหม่อีกครั้ง'),
            ),
          ],
        ),
      );
    }
    // ─── แยก cash / bank methods ───
    final cashMethods = widget.methods.where((m) => m.isCash).toList();
    final bankMethods =
        widget.methods.where((m) => !m.isCash && m.hasBankAccounts).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cashMethods.isNotEmpty) ...[
          _sectionLabel('ช่องทางเงินสด'),
          const SizedBox(height: 6),
          ...cashMethods.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _methodOption(m),
              )),
        ],
        if (bankMethods.isNotEmpty) ...[
          const SizedBox(height: LaSpace.sm),
          _sectionLabel('ช่องทางเงินโอน / QR'),
          const SizedBox(height: 6),
          ...bankMethods.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _methodOption(m),
              )),
        ],
      ],
    );
  }

  Widget _sectionLabel(String s) => Text(
        s,
        style: LaText.caption.copyWith(
          color: LaColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _methodOption(LicensePaymentMethod m) {
    final selectedIndex = _indexOf(m);
    final selected = _pickedIndex != null && selectedIndex == _pickedIndex;
    final IconData icon =
        m.isCash ? Icons.payments_rounded : Icons.account_balance_rounded;
    final Color iconColor =
        m.isCash ? LaColors.statusApprovedFg : LaColors.statusInfoFg;
    final subtitle = m.banks.isNotEmpty
        ? [
            if ((m.banks.first.bankCode ?? '').isNotEmpty)
              m.banks.first.bankCode,
            if ((m.banks.first.bankAccount ?? '').isNotEmpty)
              m.banks.first.bankAccount,
            if ((m.banks.first.branch ?? '').isNotEmpty)
              'สาขา ${m.banks.first.branch}',
            if (m.banks.length > 1) '+${m.banks.length - 1} บัญชี',
          ].join(' · ')
        : m.code;

    return InkWell(
      onTap: selectedIndex == null
          ? null
          : () => setState(() {
                _pickedIndex = selectedIndex;
              }),
      borderRadius: BorderRadius.circular(LaRadius.md),
      child: Container(
        padding: const EdgeInsets.all(LaSpace.sm),
        decoration: BoxDecoration(
          color: selected
              ? LaColors.primaryLight.withOpacity(.5)
              : LaColors.cardBg,
          borderRadius: BorderRadius.circular(LaRadius.md),
          border: Border.all(
            color: selected ? LaColors.primary : LaColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.15),
                shape: BoxShape.circle,
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
                    m.nameTh.isNotEmpty ? m.nameTh : m.code,
                    style: LaText.body.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
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
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: LaColors.primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _footer() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('ยกเลิก'),
          ),
          FilledButton.icon(
            onPressed:
                _canConfirm ? () => Navigator.of(context).pop(_picked) : null,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('ยืนยัน'),
            style: FilledButton.styleFrom(
              backgroundColor: LaColors.primaryDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
}
