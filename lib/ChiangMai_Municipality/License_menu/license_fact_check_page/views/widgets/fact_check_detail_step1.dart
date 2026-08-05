// ============================================================================
// fact_check_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบข้อเท็จจริง
// - แสดง "ข้อมูลเบื้องต้น" ของคำขอ (uuid / ชื่อลูกค้า / lease / zone / สถานะ)
// - ปุ่ม "เพิ่มรอบตรวจ" → startNewInspection
// - ปุ่ม "อัปโหลดรูป" → file_picker / image_picker (web + ios + android)
// - รายการ "รอบตรวจ" (inspection rounds) แสดงเป็น folder cards
// ============================================================================

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../unity/FormatPhone.dart';
import '../../../../Model/Review_Model.dart';
import '../../services/license_fact_check_service.dart';
import '../theme/license_fact_check_theme.dart';
import '../../viewmodels/license_fact_check_detail_view_model.dart';

class FactCheckDetailStep1 extends StatefulWidget {
  const FactCheckDetailStep1({super.key});

  @override
  State<FactCheckDetailStep1> createState() => _FactCheckDetailStep1State();
}

class _FactCheckDetailStep1State extends State<FactCheckDetailStep1> {
  bool _roundsLoaded = false;

  @override
  void initState() {
    super.initState();
    // โหลด rounds หลัง frame แรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<LicensefactcheckDetailViewModel>();
      if (vm.requestUuid != null && vm.requestUuid!.isNotEmpty) {
        vm.loadRounds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicensefactcheckDetailViewModel>();

    // ถ้า requestUuid เปลี่ยน (เปิด detail ใหม่) → load rounds ใหม่
    final uuid = vm.requestUuid;
    if (uuid != null && uuid.isNotEmpty && !_roundsLoaded) {
      _roundsLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          context.read<LicensefactcheckDetailViewModel>().loadRounds();
      });
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(LaSpace.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header band ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: LaSpace.md, vertical: LaSpace.sm),
                    decoration: BoxDecoration(
                      color: LaColors.primaryLight.withOpacity(.25),
                      borderRadius: BorderRadius.circular(LaRadius.md),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 18, color: LaColors.primaryDark),
                        SizedBox(width: 8),
                        Text('ตรวจสอบข้อเท็จจริง', style: LaText.h2),
                      ],
                    ),
                  ),
                  const SizedBox(height: LaSpace.md),

                  // ─── Loading / Error / Data ───
                  if (vm.isLoading)
                    const _LoadingBlock()
                  else if (vm.loadError != null)
                    _ErrorBlock(message: vm.loadError!)
                  else if (vm.currentRequest == null)
                    _EmptyBlock(uuid: vm.requestUuid)
                  else
                    _RequestSummaryCard(model: vm.currentRequest!),

                  const SizedBox(height: LaSpace.lg),

                  // ─── Inspection rounds (โฟลเดอร์) ───
                  if (vm.currentRequest != null) ...[
                    _RoundsSection(vm: vm),
                    const SizedBox(height: LaSpace.lg),
                  ],

                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: LaColors.textMuted),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ตรวจสอบข้อเท็จจริงให้ครบถ้วนก่อนกด "ถัดไป"',
                          style: LaText.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Loading overlay (เริ่ม inspection ใหม่) ───
        if (vm.isStartingInspection)
          const _LoadingOverlay(message: 'กำลังเริ่มรอบตรวจใหม่...'),
      ],
    );
  }
}

// ============================================================================
// Rounds section (โฟลเดอร์)
// ============================================================================

class _RoundsSection extends StatelessWidget {
  final LicensefactcheckDetailViewModel vm;
  const _RoundsSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header + Action buttons ───
          Row(
            children: [
              const Icon(Icons.folder_open_rounded,
                  color: LaColors.primaryDark),
              const SizedBox(width: LaSpace.sm),
              const Text('รอบตรวจ (Inspection Rounds)', style: LaText.h2),
              const SizedBox(width: LaSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: LaColors.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: Text(
                  '${vm.rounds.length} รอบ',
                  style: LaText.caption.copyWith(
                    color: LaColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _StartInspectionButton(vm: vm),
            ],
          ),

          // ─── Active inspection banner ───
          if (vm.activeInspectionUuid != null) ...[
            const SizedBox(height: LaSpace.md),
            _ActiveInspectionBanner(vm: vm),
          ],

          // ─── Error ───
          if (vm.roundsError != null) ...[
            const SizedBox(height: LaSpace.md),
            _InlineError(
              message: vm.roundsError!,
              onClose: vm.clearRoundsError,
            ),
          ],

          const SizedBox(height: LaSpace.md),

          // ─── Rounds list ───
          if (vm.isLoadingRounds)
            const _RoundsLoading()
          else if (vm.rounds.isEmpty)
            const _RoundsEmpty()
          else
            _RoundsGrid(rounds: vm.rounds, vm: vm),
        ],
      ),
    );
  }
}

class _StartInspectionButton extends StatelessWidget {
  final LicensefactcheckDetailViewModel vm;
  const _StartInspectionButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: vm.isStartingInspection
            ? null
            : () async {
                final ok = await vm.startNewInspection();
                if (!context.mounted) return;
                if (ok != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'เริ่มรอบตรวจใหม่สำเร็จ (${ok.substring(0, ok.length.clamp(0, 8))})'),
                      backgroundColor: LaColors.statusApprovedFg,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: LaColors.primary,
            borderRadius: BorderRadius.circular(LaRadius.md),
            boxShadow: [
              BoxShadow(
                color: LaColors.primary.withOpacity(.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_circle_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'เพิ่มรอบตรวจ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveInspectionBanner extends StatelessWidget {
  final LicensefactcheckDetailViewModel vm;
  const _ActiveInspectionBanner({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusPendingBg.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.statusPendingFg.withOpacity(.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record,
              color: LaColors.statusPendingFg, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รอบตรวจที่กำลังดำเนินการ',
                  style: LaText.caption.copyWith(
                    color: LaColors.statusPendingFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  'uuid: ${vm.activeInspectionUuid}',
                  minFontSize: 11,
                  maxFontSize: 12,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: LaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const _UploadImageButton(vm: null),
        ],
      ),
    );
  }
}

class _UploadImageButton extends StatefulWidget {
  final LicensefactcheckDetailViewModel? vm;
  const _UploadImageButton({this.vm});

  @override
  State<_UploadImageButton> createState() => _UploadImageButtonState();
}

class _UploadImageButtonState extends State<_UploadImageButton> {
  bool _uploading = false;
  final _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onUpload(BuildContext context) async {
    final vm = context.read<LicensefactcheckDetailViewModel>();
    if (vm.activeInspectionUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณา "เพิ่มรอบตรวจ" ก่อนอัปโหลดรูป'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final List<File> pickedFiles = [];
    final List<({Uint8List bytes, String filename})> pickedBytesList = [];

    if (kIsWeb) {
      // ─── Web: file_picker → multi bytes ───
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true, // ✅ เลือกหลายไฟล์
      );
      if (result == null || result.files.isEmpty) return;
      for (final f in result.files) {
        if (f.bytes != null) {
          pickedBytesList.add((bytes: f.bytes!, filename: f.name));
        }
      }
    } else {
      // ─── Mobile/Desktop: image_picker (camera/gallery/multi) + file_picker fallback ───
      final source = await showModalBottomSheet<_ImagePickSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const _ImageSourceSheet(),
      );
      if (source == null) return;

      if (source == _ImagePickSource.camera) {
        final shot = await ImagePicker().pickImage(source: ImageSource.camera);
        if (shot != null) pickedFiles.add(File(shot.path));
      } else if (source == _ImagePickSource.galleryMulti) {
        // ✅ แกลเลอรี: เลือกหลายรูป
        final shots = await ImagePicker().pickMultiImage();
        for (final s in shots) {
          pickedFiles.add(File(s.path));
        }
      } else {
        // file_picker (multi)
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result == null || result.files.isEmpty) return;
        for (final f in result.files) {
          if (f.path != null) {
            pickedFiles.add(File(f.path!));
          } else if (f.bytes != null) {
            pickedBytesList.add((bytes: f.bytes!, filename: f.name));
          }
        }
      }
    }

    if (pickedFiles.isEmpty && pickedBytesList.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถอ่านไฟล์ที่เลือก'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final total = pickedFiles.length + pickedBytesList.length;
    setState(() => _uploading = true);

    // ✅ 1 ไฟล์ → single API (เร็วกว่า)
    // ✅ หลายไฟล์ → batch API
    if (total == 1) {
      final ok = await vm.uploadImageToActive(
        file: pickedFiles.isNotEmpty ? pickedFiles.first : null,
        bytes: pickedBytesList.isNotEmpty ? pickedBytesList.first.bytes : null,
        filename:
            pickedBytesList.isNotEmpty ? pickedBytesList.first.filename : null,
        caption: _captionCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'อัปโหลดรูปสำเร็จ' : 'อัปโหลดรูปไม่สำเร็จ'),
          backgroundColor:
              ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final result = await vm.uploadMultipleToActive(
        files: pickedFiles.isNotEmpty ? pickedFiles : null,
        bytesList: pickedBytesList.isNotEmpty ? pickedBytesList : null,
        caption: _captionCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      if (!context.mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดรูปไม่สำเร็จ'),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.allOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปโหลดสำเร็จ ${result.successCount} รูป'),
            backgroundColor: LaColors.statusApprovedFg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.allFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'อัปโหลดล้มเหลวทั้งหมด ${result.failedCount} รูป: ${result.errors.first}'),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'อัปโหลดสำเร็จ ${result.successCount}/${result.total} รูป (ล้มเหลว ${result.failedCount})'),
            backgroundColor: LaColors.statusPendingFg,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _uploading ? null : () => _onUpload(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                _uploading ? LaColors.surfaceMuted : LaColors.statusPendingFg,
            borderRadius: BorderRadius.circular(LaRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_uploading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.upload_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                _uploading ? 'กำลังอัปโหลด' : 'อัปโหลดรูป',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// enum สำหรับ source sheet — แยก gallery (single) กับ gallery multi
enum _ImagePickSource {
  camera, // กล้อง (1 รูป)
  galleryMulti, // แกลเลอรี (หลายรูป)
  filePickerMulti, // file_picker (หลายไฟล์)
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LaRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('ถ่ายรูป (กล้อง)'),
              subtitle: const Text('ทีละ 1 รูป'),
              onTap: () => Navigator.of(context).pop(_ImagePickSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('เลือกหลายรูปจากแกลเลอรี'),
              subtitle: const Text('เลือกพร้อมกันได้หลายไฟล์'),
              onTap: () =>
                  Navigator.of(context).pop(_ImagePickSource.galleryMulti),
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: const Text('เลือกไฟล์จากเครื่อง'),
              subtitle: const Text('รองรับหลายไฟล์'),
              onTap: () =>
                  Navigator.of(context).pop(_ImagePickSource.filePickerMulti),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundsGrid extends StatelessWidget {
  final List<InspectionRound> rounds;
  final LicensefactcheckDetailViewModel vm;
  const _RoundsGrid({required this.rounds, required this.vm});

  bool _isOpen(String? state) {
    final s = (state ?? '').toLowerCase();
    return s.isEmpty ||
        s.contains('pending') ||
        s.contains('in_review') ||
        s.contains('progress') ||
        s.contains('doing');
  }

  // _safe ถูก define ใน scope global ด้านล่าง — ใช้ตัวเดียวกันได้

  @override
  Widget build(BuildContext context) {
    // เรียง round มาก → น้อย (รอบล่าสุดอยู่บน)
    final sorted = [...rounds]
      ..sort((a, b) => (b.round ?? 0).compareTo(a.round ?? 0));

    // ✅ กล่องเดียว = รอบที่ยังเปิดอยู่ (pending/in_review) — ถ้ามี
    // ถ้าไม่มี → ใช้รอบล่าสุดเป็น current
    final currentIdx = sorted.indexWhere((r) => _isOpen(r.state));
    final heroIdx = currentIdx >= 0 ? currentIdx : 0;
    final hero = sorted[heroIdx];
    final history = [...sorted]
      ..removeAt(heroIdx); // รอบที่เหลือ (รวมตัวที่ปิดแล้ว)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── กล่องเดียว: รอบปัจจุบัน ───
        _CurrentRoundCard(round: hero),
        // ─── ลิงก์ไปดูประวัติ (step 2) ───
        if (history.isNotEmpty) ...[
          const SizedBox(height: LaSpace.sm),
          _HistoryLinkButton(count: history.length),
        ],
      ],
    );
  }
}

/// ปุ่มลิงก์ไป step 2 เพื่อดู timeline ประวัติ
class _HistoryLinkButton extends StatelessWidget {
  final int count;
  const _HistoryLinkButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<LicensefactcheckDetailViewModel>().nextDetailStep();
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: LaSpace.md, vertical: 10),
          decoration: BoxDecoration(
            color: LaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LaColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 16, color: LaColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'ดูประวัติการตรวจ ($count รอบ)',
                style: LaText.caption.copyWith(
                  color: LaColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: LaColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// การ์ด "รอบปัจจุบัน" — ใหญ่กว่ารอบอื่นๆ + เน้นสี
class _CurrentRoundCard extends StatelessWidget {
  final InspectionRound round;
  const _CurrentRoundCard({required this.round});

  @override
  Widget build(BuildContext context) {
    final s = (round.state ?? '').toLowerCase();
    Color bg, fg;
    IconData icon;
    String statusText = round.stateLabel ?? round.state ?? 'กำลังดำเนินการ';

    if (s.contains('passed') || s.contains('ผ่าน')) {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
      icon = Icons.check_circle_rounded;
    } else if (s.contains('failed') || s.contains('ไม่ผ่าน')) {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
      icon = Icons.cancel_rounded;
    } else {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
      icon = Icons.hourglass_top_rounded;
      statusText = 'กำลังดำเนินการ';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(LaRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LaRadius.lg),
          border: Border.all(color: LaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Accent strip ───
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: fg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(LaRadius.lg),
                  topRight: Radius.circular(LaRadius.lg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  LaSpace.lg, LaSpace.md, LaSpace.lg, LaSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: fg, size: 20),
                      ),
                      const SizedBox(width: LaSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                AutoSizeText(
                                  'รอบที่ ${round.round ?? '-'}',
                                  minFontSize: 16,
                                  maxFontSize: 20,
                                  style: LaText.h2,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius:
                                        BorderRadius.circular(LaRadius.pill),
                                  ),
                                  child: Text(
                                    'รอบปัจจุบัน',
                                    style: TextStyle(
                                      color: fg,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(statusText,
                                style: LaText.caption.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ─── Stats inline ───
                  const SizedBox(height: LaSpace.md),
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.photo_library_rounded,
                        text: '${round.imageCount ?? 0} รูป',
                      ),
                      const SizedBox(width: 12),
                      _Stat(
                        icon: Icons.schedule_rounded,
                        text: _shortDate(round.createdAt),
                      ),
                      const Spacer(),
                      Text(
                        '#${_shortUuid(round.uuid)}',
                        style: LaText.caption.copyWith(
                          color: LaColors.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if ((round.comment ?? '').isNotEmpty) ...[
                    const SizedBox(height: LaSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: LaSpace.sm, vertical: 6),
                      decoration: BoxDecoration(
                        color: LaColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(LaRadius.sm),
                      ),
                      child: AutoSizeText(
                        round.comment!,
                        minFontSize: 11,
                        maxFontSize: 12,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LaText.caption.copyWith(
                          color: LaColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // ─── Thumbnails (full-bleed, subtle bg) ───
            _compactImagesRow(context, round.uuid),
            // ─── Toolbar ───
            Container(
              decoration: const BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(LaRadius.lg),
                  bottomRight: Radius.circular(LaRadius.lg),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: LaSpace.lg, vertical: LaSpace.sm),
              child: _toolbar(context, round),
            ),
          ],
        ),
      ),
    );
  }

  /// Toolbar แถวเดียว
  /// - pending     → ปุ่ม "เริ่มทำ" (เต็มแถว) → ยิง transition(state=in_review)
  /// - in_review   → อัปโหลด + ผ่าน + ไม่ผ่าน + รีเช็ค
  /// - passed/failed/cancelled → ไม่แสดง
  Widget _toolbar(BuildContext context, InspectionRound r) {
    final s = (r.state ?? '').toLowerCase();
    final isPending = s.contains('pending') || s.isEmpty;
    final isInReview = s.contains('in_review') || s.contains('progress');

    if (r.uuid == null) return const SizedBox.shrink();

    final vm = context.read<LicensefactcheckDetailViewModel>();

    // ─── pending → เริ่มทำ ───
    if (isPending) {
      return _StartReviewButton(
        inspectionUuid: r.uuid!,
        onSuccess: (msg) => _showResultSnack(
          context,
          ok: true,
          okText: msg,
          errText: msg,
          fg: LaColors.statusApprovedFg,
        ),
        onError: (msg) => _showResultSnack(
          context,
          ok: false,
          okText: msg,
          errText: msg,
          fg: LaColors.statusRejectedFg,
        ),
      );
    }

    // ─── in_review → full toolbar ───
    if (!isInReview) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _ToolButton(
            icon: Icons.upload_rounded,
            label: 'อัปโหลด',
            color: LaColors.primary,
            bg: LaColors.primaryLight,
            onTap: () async {
              vm.setActiveInspection(r.uuid!);
              await Future<void>.delayed(const Duration(milliseconds: 80));
              if (!context.mounted) return;
              await _showUploadFlow(context, r.uuid!);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ToolButton(
            icon: Icons.check_rounded,
            label: 'ผ่าน',
            color: LaColors.statusApprovedFg,
            bg: LaColors.statusApprovedBg,
            filled: true,
            onTap: () => _showCommentDialog(
              context,
              title: 'ยืนยัน "ผ่าน"',
              confirmFg: LaColors.statusApprovedFg,
              onConfirm: (comment) async {
                final res = await vm.transitionRound(
                  r.uuid!,
                  state: 'passed',
                  comment: comment,
                );
                if (!context.mounted) return;
                _showResultSnack(
                  context,
                  ok: res?.success == true,
                  okText: 'บันทึก "ผ่าน" สำเร็จ',
                  errText: 'ไม่สำเร็จ: ${res?.message ?? '-'}',
                  fg: LaColors.statusApprovedFg,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ToolButton(
            icon: Icons.close_rounded,
            label: 'ไม่ผ่าน',
            color: LaColors.statusRejectedFg,
            bg: LaColors.statusRejectedBg,
            outlined: true,
            onTap: () => _showCommentDialog(
              context,
              title: 'ยืนยัน "ไม่ผ่าน"',
              confirmFg: LaColors.statusRejectedFg,
              onConfirm: (comment) async {
                final res = await vm.transitionRound(
                  r.uuid!,
                  state: 'failed',
                  comment: comment,
                );
                if (!context.mounted) return;
                _showResultSnack(
                  context,
                  ok: res?.success == true,
                  okText: 'บันทึก "ไม่ผ่าน" สำเร็จ',
                  errText: 'ไม่สำเร็จ: ${res?.message ?? '-'}',
                  fg: LaColors.statusRejectedFg,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        _IconAction(
          icon: Icons.refresh_rounded,
          fg: LaColors.textSecondary,
          bg: Colors.white,
          border: LaColors.border,
          tooltip: 'เปิดรอบใหม่',
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LaRadius.lg),
                ),
                title: const Text('เปิดรอบตรวจใหม่'),
                content: const Text(
                    'ปิดรอบปัจจุบันและเปิดรอบใหม่เพื่อตรวจซ้ำ — ดำเนินการต่อ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('ยกเลิก'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('ยืนยัน'),
                  ),
                ],
              ),
            );
            if (confirm != true || !context.mounted) return;
            final res = await vm.recheckRound(r.uuid!);
            if (!context.mounted) return;
            _showResultSnack(
              context,
              ok: res != null,
              okText: 'เปิดรอบใหม่สำเร็จ',
              errText: 'เปิดรอบใหม่ไม่สำเร็จ',
              fg: LaColors.statusApprovedFg,
            );
          },
        ),
      ],
    );
  }

  /// Snack helper (ลด duplication)
  void _showResultSnack(
    BuildContext context, {
    required bool ok,
    required String okText,
    required String errText,
    required Color fg,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? okText : errText),
        backgroundColor: ok ? fg : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Thumbnail row แบบกระชับ (Hero card) — full-bleed
  Widget _compactImagesRow(BuildContext context, String? uuid) {
    if (uuid == null || uuid.isEmpty) return const SizedBox.shrink();
    final vm = context.watch<LicensefactcheckDetailViewModel>();

    if (vm.isLoadingImages(uuid)) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: LaSpace.lg, vertical: LaSpace.sm),
        child: Row(
          children: const [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            SizedBox(width: 6),
            Text('กำลังโหลดรูป...', style: LaText.caption),
          ],
        ),
      );
    }

    final imgs = vm.imagesOf(uuid);
    if (imgs.isEmpty) return const SizedBox.shrink();

    final preview = imgs.length > 5 ? imgs.sublist(0, 5) : imgs;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.lg, vertical: LaSpace.sm),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: preview.length + (imgs.length > 5 ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            if (i >= preview.length) {
              return Container(
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                  border: Border.all(color: LaColors.border),
                ),
                child: Text(
                  '+${imgs.length - 5}',
                  style: LaText.caption.copyWith(
                    color: LaColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return _ImageThumb(
              inspectionUuid: uuid,
              imageUuid: preview[i].uuid,
              caption: preview[i].caption,
            );
          },
        ),
      ),
    );
  }

  /// Mini stat (icon + text inline)
  Widget _Stat({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: LaColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: LaText.caption.copyWith(color: LaColors.textSecondary)),
      ],
    );
  }

  /// เปิด source sheet + อัปโหลดรูป (single หรือ multi) → inspectionUuid
  Future<void> _showUploadFlow(
      BuildContext context, String inspectionUuid) async {
    final List<File> pickedFiles = [];
    final List<({Uint8List bytes, String filename})> pickedBytesList = [];

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;
      for (final f in result.files) {
        if (f.bytes != null) {
          pickedBytesList.add((bytes: f.bytes!, filename: f.name));
        }
      }
    } else {
      final source = await showModalBottomSheet<_ImagePickSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const _ImageSourceSheet(),
      );
      if (source == null) return;

      if (source == _ImagePickSource.camera) {
        final shot = await ImagePicker().pickImage(source: ImageSource.camera);
        if (shot != null) pickedFiles.add(File(shot.path));
      } else if (source == _ImagePickSource.galleryMulti) {
        final shots = await ImagePicker().pickMultiImage();
        for (final s in shots) {
          pickedFiles.add(File(s.path));
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result == null || result.files.isEmpty) return;
        for (final f in result.files) {
          if (f.path != null) {
            pickedFiles.add(File(f.path!));
          } else if (f.bytes != null) {
            pickedBytesList.add((bytes: f.bytes!, filename: f.name));
          }
        }
      }
    }

    if (pickedFiles.isEmpty && pickedBytesList.isEmpty) return;

    if (!context.mounted) return;
    final vm = context.read<LicensefactcheckDetailViewModel>();
    final total = pickedFiles.length + pickedBytesList.length;

    if (total == 1) {
      final ok = await vm.uploadImageToActive(
        file: pickedFiles.isNotEmpty ? pickedFiles.first : null,
        bytes: pickedBytesList.isNotEmpty ? pickedBytesList.first.bytes : null,
        filename:
            pickedBytesList.isNotEmpty ? pickedBytesList.first.filename : null,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'อัปโหลดรูปสำเร็จ' : 'อัปโหลดรูปไม่สำเร็จ'),
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      final res = await vm.uploadMultipleToActive(
        files: pickedFiles.isNotEmpty ? pickedFiles : null,
        bytesList: pickedBytesList.isNotEmpty ? pickedBytesList : null,
      );
      if (!context.mounted) return;
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('อัปโหลดรูปไม่สำเร็จ'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ));
      } else if (res.allOk) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('อัปโหลดสำเร็จ ${res.successCount} รูป'),
          backgroundColor: LaColors.statusApprovedFg,
          behavior: SnackBarBehavior.floating,
        ));
      } else if (res.allFailed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('อัปโหลดล้มเหลวทั้งหมด ${res.failedCount} รูป'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('อัปโหลดสำเร็จ ${res.successCount}/${res.total} รูป'),
          backgroundColor: LaColors.statusPendingFg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  Future<void> _showCommentDialog(
    BuildContext context, {
    required String title,
    String hint = 'คอมเมนต์ (optional)',
    String confirmLabel = 'ยืนยัน',
    required Color confirmFg,
    required Future<void> Function(String comment) onConfirm,
  }) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.lg),
        ),
        title: Text(title),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmFg),
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (result != null) {
      await onConfirm(result);
    }
  }

  String _shortDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _shortUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
    if (uuid.length <= 8) return uuid;
    return uuid.substring(0, 8);
  }
}

/// helper global — ใช้แทน null/empty ด้วย fallback (default: '-')
String _safe(String? s, [String fallback = '-']) =>
    (s == null || s.isEmpty) ? fallback : s;

/// ปุ่ม "เริ่มทำ" — ใช้กับ round ที่อยู่ในสถานะ pending
/// กดแล้ว → vm.startReview(uuid) → transition(state=in_review)
/// แสดง full-width, มี spinner ตอนกำลังยิง API
class _StartReviewButton extends StatefulWidget {
  final String inspectionUuid;
  final void Function(String message) onSuccess;
  final void Function(String message) onError;
  const _StartReviewButton({
    required this.inspectionUuid,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_StartReviewButton> createState() => _StartReviewButtonState();
}

class _StartReviewButtonState extends State<_StartReviewButton> {
  bool _busy = false;

  Future<void> _onTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    final vm = context.read<LicensefactcheckDetailViewModel>();
    try {
      final res = await vm.startReview(
        widget.inspectionUuid,
        comment: 'เริ่มตรวจ',
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (res?.success == true) {
        widget
            .onSuccess('เริ่มตรวจสำเร็จ — เปลี่ยนสถานะเป็น "กำลังเก็บข้อมูล"');
      } else {
        widget.onError(res?.message ?? 'เปลี่ยนสถานะไม่สำเร็จ');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      widget.onError('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white;
    return MouseRegion(
      cursor: _busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _busy ? null : _onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: LaColors.statusPendingFg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: LaColors.statusPendingFg.withOpacity(.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(Icons.play_arrow_rounded, color: fg, size: 18),
              const SizedBox(width: 8),
              Text(
                _busy ? 'กำลังเริ่มตรวจ...' : 'เริ่มทำ',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่มใน toolbar — full-width, มี 3 variants (filled / outlined / ghost)
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool filled;
  final bool outlined;
  final VoidCallback onTap;
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    this.filled = false,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = filled;
    final fg = isFilled ? Colors.white : color;
    final bgColor = isFilled ? color : bg;
    final borderColor = isFilled ? color : color.withOpacity(.4);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: outlined || !isFilled
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่ม pill ขนาดเล็ก — ใช้ใน toolbar (อัปโหลด / ผ่าน / ไม่ผ่าน)
class _PillAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final Color border;
  final VoidCallback onTap;
  const _PillAction({
    required this.icon,
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่ม icon กลมขนาดเล็ก (รีเฟรช / เมนู)
class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color border;
  final String tooltip;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.fg,
    required this.bg,
    required this.border,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Icon(icon, color: fg, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail เล็ก — โหลด bytes preview แล้ว cache
class _ImageThumb extends StatefulWidget {
  final String inspectionUuid;
  final String? imageUuid;
  final String? caption;
  const _ImageThumb({
    required this.inspectionUuid,
    required this.imageUuid,
    this.caption,
  });

  @override
  State<_ImageThumb> createState() => _ImageThumbState();
}

class _ImageThumbState extends State<_ImageThumb> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.imageUuid == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }
    try {
      final svc = context.read<LicensefactcheckDetailViewModel>().service;
      final bytes = await svc.previewImage(
        widget.imageUuid!,
        inspectionUuid: widget.inspectionUuid,
      );
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _bytes == null
          ? null
          : () => _showFullImage(context, widget.imageUuid, widget.caption),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: Container(
          width: 64,
          height: 64,
          color: LaColors.surfaceMuted,
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _failed || _bytes == null
                  ? const Icon(Icons.broken_image_outlined,
                      size: 20, color: LaColors.textMuted)
                  : Image.memory(
                      _bytes!,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                    ),
        ),
      ),
    );
  }

  void _showFullImage(
      BuildContext context, String? imageUuid, String? caption) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_bytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(LaRadius.md),
                child: Image.memory(_bytes!, fit: BoxFit.contain),
              ),
            if (caption != null && caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  caption,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg;
  final bool mono;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.fg,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: AutoSizeText(
              label,
              minFontSize: 10,
              maxFontSize: 11,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: mono ? 'monospace' : LaText.fontRegular,
                fontSize: 11,
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundsLoading extends StatelessWidget {
  const _RoundsLoading();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: LaSpace.sm),
          Text('กำลังโหลดรอบตรวจ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _RoundsEmpty extends StatelessWidget {
  const _RoundsEmpty();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.lg),
      child: Column(
        children: const [
          Icon(Icons.folder_off_rounded, size: 36, color: LaColors.textMuted),
          SizedBox(height: LaSpace.sm),
          Text('ยังไม่มีรอบตรวจ — กด "เพิ่มรอบตรวจ" เพื่อเริ่ม',
              style: LaText.bodyMuted, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _InlineError({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.statusRejectedBg.withOpacity(.4),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.statusRejectedFg.withOpacity(.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: LaColors.statusRejectedFg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message,
                style:
                    LaText.caption.copyWith(color: LaColors.statusRejectedFg)),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded,
                size: 14, color: LaColors.statusRejectedFg),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String message;
  const _LoadingOverlay({required this.message});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(.25),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(LaSpace.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: LaSpace.sm),
              Text(message, style: LaText.body),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Sub widgets (existing)
// ============================================================================

class _RequestSummaryCard extends StatelessWidget {
  final ReviewModel model;
  const _RequestSummaryCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final nr = model.newRequest;
    final client = model.client;

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header row: status + uuid ───
          Row(
            children: [
              _StatusBadge(label: model.statusLabel ?? model.status ?? '-'),
              const Spacer(),
              _PillIcon(
                icon: Icons.tag_rounded,
                text: 'UUID: ${_short(model.uuid)}',
                muted: true,
              ),
            ],
          ),
          const SizedBox(height: LaSpace.lg),

          // ─── Grid 2 columns ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลคำขอ',
                  items: [
                    _InfoItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'เลขที่สัญญา',
                      value: nr?.leaseNumber,
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันที่สิ้นสุด',
                      value: _formatDate(nr?.ldate),
                    ),
                    _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'บริเวณ / โซน',
                      value: _joinZones(nr),
                    ),
                    _InfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'รหัสพื้นที่',
                      value: nr?.ln,
                      mono: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LaSpace.lg),
              Expanded(
                child: _InfoColumn(
                  title: 'ข้อมูลลูกค้า',
                  items: [
                    _InfoItem(
                      icon: Icons.person_rounded,
                      label: 'ชื่อผู้ติดต่อ',
                      value: client?.cname ?? client?.scname,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทร',
                      value: formatPhoneNumber(client?.tel ?? ''),
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.confirmation_number_rounded,
                      label: 'เลขประจำตัวผู้เสียภาษี',
                      value: client?.tax,
                      mono: true,
                    ),
                    _InfoItem(
                      icon: Icons.place_rounded,
                      label: 'ที่อยู่',
                      value: client?.addr1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Footer note ───
          const SizedBox(height: LaSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: LaSpace.md, vertical: LaSpace.sm),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: LaColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: AutoSizeText(
                    'ข้อมูลด้านบนเป็น "ภาพรวมคำขอ" '
                    'สำหรับตรวจสอบเบื้องต้น — รายละเอียดเพิ่มเติมจะแสดงใน Step ถัดไป',
                    style: LaText.caption,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _short(String? uuid) {
    if (uuid == null || uuid.isEmpty) return '-';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 8)}…';
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String? _joinZones(NewRequestModel? nr) {
    if (nr == null) return null;
    final parts = <String>[
      if ((nr.subzone ?? '').isNotEmpty) nr.subzone!,
      if ((nr.zn ?? '').isNotEmpty) nr.zn!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' / ');
  }
}

// ============================================================================
// Sub widgets
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final s = label.toLowerCase();
    Color bg, fg;
    if (s.contains('อนุมัติ') || s.contains('approved') || s.contains('pass')) {
      bg = LaColors.statusApprovedBg;
      fg = LaColors.statusApprovedFg;
    } else if (s.contains('ปฏิเสธ') ||
        s.contains('reject') ||
        s.contains('cancel') ||
        s.contains('ยกเลิก')) {
      bg = LaColors.statusRejectedBg;
      fg = LaColors.statusRejectedFg;
    } else if (s.contains('รอ') ||
        s.contains('pending') ||
        s.contains('progress')) {
      bg = LaColors.statusPendingBg;
      fg = LaColors.statusPendingFg;
    } else {
      bg = LaColors.statusNeutralBg;
      fg = LaColors.statusNeutralFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: fg.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          AutoSizeText(
            label,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: TextStyle(
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;
  const _PillIcon({required this.icon, required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final fg = muted ? LaColors.textSecondary : LaColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          AutoSizeText(
            text,
            minFontSize: 11,
            maxFontSize: 12,
            maxLines: 1,
            style: LaText.caption.copyWith(
              color: fg,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _InfoColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: LaText.label.copyWith(
            color: LaColors.primaryDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: LaSpace.sm),
        for (final item in items) ...[
          item,
          const SizedBox(height: LaSpace.sm),
        ],
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool mono;
  const _InfoItem({
    required this.icon,
    required this.label,
    this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = (value ?? '').trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: LaColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(LaRadius.sm),
          ),
          child: Icon(icon, size: 16, color: LaColors.primaryDark),
        ),
        const SizedBox(width: LaSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: LaText.caption),
              const SizedBox(height: 2),
              AutoSizeText(
                v.isEmpty ? '-' : v,
                minFontSize: 12,
                maxFontSize: 14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: mono ? 'monospace' : LaText.fontRegular,
                  fontSize: 13,
                  color: v.isEmpty ? LaColors.textMuted : LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: LaSpace.md),
          Text('กำลังโหลดข้อมูลคำขอ...', style: LaText.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  const _ErrorBlock({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: LaColors.statusRejectedFg),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Text(
              message,
              style: LaText.body.copyWith(color: LaColors.statusRejectedFg),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String? uuid;
  const _EmptyBlock({this.uuid});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.xxl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LaColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.lg),
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 36, color: LaColors.primary),
          ),
          const SizedBox(height: LaSpace.md),
          Text(
            uuid != null && uuid!.isNotEmpty
                ? 'ไม่พบข้อมูลคำขอ (uuid: ${uuid!.substring(0, uuid!.length.clamp(0, 8))})'
                : 'ไม่พบข้อมูลคำขอ',
            style: LaText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LaSpace.sm),
          const Text(
            'ตรวจสอบว่า uuid ถูกต้อง หรือกด "ย้อนกลับ" เพื่อเลือกรายการใหม่',
            style: LaText.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
