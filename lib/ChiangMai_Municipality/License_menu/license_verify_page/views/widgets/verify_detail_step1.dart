// ============================================================================
// verify_detail_step1.dart
// ============================================================================
// Step 1 — เลือกเอกสารที่จะแนบ
//
// UI frame (SingleChildScrollView > Center > ConstrainedBox > Column > section
// header + section card + info row) คงรูปแบบเดิมทั้งหมด
// ภายใน "section card" ใช้ตารางแสดงรายการเอกสาร + ปุ่มเรียกดูไฟล์
// (ลอจิกคัดมาจาก Make_contract_CMM Step 2 แต่เขียนใหม่ทั้งหมด standalone)
// ============================================================================

import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:chaoperty/ChiangMai_Municipality/PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/verify_documents_view_model.dart';
import '../theme/license_verify_theme.dart';
import '../../services/verify_documents_service.dart';

import '../../utils/verify_utils.dart';
import '../../models/license_verify_document.dart';
import 'verify_signature_section.dart';
import 'verify_file_preview_dialog.dart';

class VerifyDetailStep1 extends StatelessWidget {
  /// UUID ของ request ที่ต้องการแนบเอกสาร
  final String? requestUuid;

  const VerifyDetailStep1({super.key, this.requestUuid});

  @override
  Widget build(BuildContext context) {
    return _Step1Body(requestUuid: requestUuid);
  }
}

/// Breakpoint: < 600px = โทรศัพท์
const double kVerifyMobileBreakpoint = 600;

bool _isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kVerifyMobileBreakpoint;

// =============================================================================
// Body หลัก — ห่อ Provider<VerifyDocumentsViewModel>
// =============================================================================
class _Step1Body extends StatelessWidget {
  final String? requestUuid;
  const _Step1Body({required this.requestUuid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VerifyDocumentsViewModel>(
      create: (_) => VerifyDocumentsViewModel(requestUuid: requestUuid)..load(),
      child: _Step1Scaffold(requestUuid: requestUuid),
    );
  }
}

class _Step1Scaffold extends StatelessWidget {
  final String? requestUuid;
  const _Step1Scaffold({required this.requestUuid});

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? LaSpace.sm : LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Section: เลือกเอกสาร (เดิม) ───
              const _SectionHeader(),
              const SizedBox(height: LaSpace.md),
              // ─── Section: ลายเซ็นผู้แนบ (ใหม่ — ก่อนตารางเอกสาร) ───
              VerifySignatureSection(requestUuid: requestUuid),
              const SizedBox(height: LaSpace.md),
              // ─── Section: ตารางแนบเอกสาร (เดิม) ───
              const _DocumentsCard(),
              const SizedBox(height: LaSpace.lg),
              const _FooterHint(),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Section Header (เหมือนเดิม 1:1)
// =============================================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? LaSpace.sm : LaSpace.md,
        vertical: LaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: LaColors.primaryLight.withOpacity(.25),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.upload_file_rounded,
              size: mobile ? 16 : 18, color: LaColors.primaryDark),
          SizedBox(width: mobile ? 6 : 8),
          Expanded(
            child: Text(
              'เลือกเอกสารที่จะแนบ',
              style: LaText.h2.copyWith(fontSize: mobile ? 14 : 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Documents Card — เนื้อหาหลักของ Step 1
// =============================================================================
class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard();

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    return Container(
      decoration: LaDecor.card(),
      padding: EdgeInsets.all(mobile ? LaSpace.sm : LaSpace.lg),
      child: Consumer<VerifyDocumentsViewModel>(
        builder: (context, vm, _) {
          if (!vm.hasRequest) {
            return const _MissingRequestState();
          }
          if (vm.isLoading && vm.documents.isEmpty) {
            return const _LoadingState();
          }
          if (vm.documents.isEmpty) {
            return const _EmptyState();
          }
          return _DocumentsTable(documents: vm.documents);
        },
      ),
    );
  }
}

// =============================================================================
// Table — รายการเอกสาร (ใช้ LaColors token ตามธีมของหน้า)
// =============================================================================
class _DocumentsTable extends StatelessWidget {
  final List<LicenseverifyDocument> documents;
  const _DocumentsTable({required this.documents});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerifyDocumentsViewModel>();
    final mobile = _isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header bar: title + actions
        _TableHeaderBar(documents: documents),
        const SizedBox(height: LaSpace.sm),

        // เลือก layout ตามมุมมองที่ user เลือก
        if (vm.isGridView) ...[
          const Divider(height: 1, color: LaColors.border),
          _DocumentsGrid(documents: documents),
        ] else if (mobile) ...[
          const Divider(height: 1, color: LaColors.border),
          // Card layout บน mobile — ไม่ต้อง horizontal scroll
          for (int i = 0; i < documents.length; i++) ...[
            _DocumentCard(index: i, doc: documents[i]),
            if (i < documents.length - 1)
              const Divider(height: 1, color: LaColors.border),
          ],
        ] else ...[
          // Desktop + List view: ตารางแถวเดียว
          const Divider(height: 1, color: LaColors.border),
          for (int i = 0; i < documents.length; i++) ...[
            _DocumentRow(index: i, doc: documents[i]),
            if (i < documents.length - 1)
              const Divider(height: 1, color: LaColors.border),
          ],
        ],
      ],
    );
  }
}

class _TableHeaderBar extends StatelessWidget {
  final List<LicenseverifyDocument> documents;
  const _TableHeaderBar({required this.documents});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerifyDocumentsViewModel>();
    final hasAny = documents.isNotEmpty;
    final mobile = _isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      child: Row(
        children: [
          Icon(Icons.folder_open_rounded,
              size: mobile ? 16 : 18, color: LaColors.primaryDark),
          SizedBox(width: mobile ? 4 : 6),
          Expanded(
            child: Text(
              'เอกสารที่ต้องแนบ (${documents.length} รายการ)',
              style: LaText.h2.copyWith(fontSize: mobile ? 13 : 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Toggle: List / Grid view
          _ViewModeToggle(
            isGrid: vm.isGridView,
            onTap: vm.toggleViewMode,
          ),
          IconButton(
            tooltip: 'รีเฟรช',
            visualDensity:
                mobile ? VisualDensity.compact : VisualDensity.standard,
            onPressed: vm.isLoading ? null : vm.refresh,
            icon: const Icon(Icons.refresh_rounded, color: LaColors.primary),
          ),
          SizedBox(width: mobile ? 0 : 4),
        ],
      ),
    );
  }
}

// =============================================================================
// Row — เอกสาร 1 รายการ
// =============================================================================
class _DocumentRow extends StatelessWidget {
  final int index;
  final LicenseverifyDocument doc;
  const _DocumentRow({required this.index, required this.doc});

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerifyDocumentsViewModel>();
    const fields = kVerifyDocDisplayFields;
    final mobile = _isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LaSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── คอลัมน์ตาม data_title_doc ───
          for (final titleDoc in fields)
            Expanded(
              flex: titleDoc['title'] == 'ชื่อเอกสาร' ? 3 : 1,
              child: _buildCell(context, vm, titleDoc),
            ),
          const SizedBox(width: LaSpace.sm),
          SizedBox(
            width: 140,
            child: _ReviewActions(
              doc: doc,
              docId: _docId,
              enabled: _hasFile &&
                  !_statusLabel(doc).contains('อนุมัติ') &&
                  !_statusLabel(doc).contains('ปฏิเสธ'),
              onApprove: () => _onApprove(context, doc),
              onReject: () => _onReject(context, doc),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cell builder (ตาม data_title_doc)
  // ---------------------------------------------------------------------------
  Widget _buildCell(
    BuildContext context,
    VerifyDocumentsViewModel vm,
    Map<String, String> titleDoc,
  ) {
    final isName = titleDoc['title'] == 'ชื่อเอกสาร';
    final isFile = titleDoc['title'] == 'ไฟล์เอกสาร';
    final isStatus = titleDoc['title'] == 'สถานะ';

    if (isFile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _FileButton(doc: doc, enabled: _hasFile),
      );
    }

    if (isStatus) {
      final label = _statusLabel(doc);
      final palette = _statusPalette(doc);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 4),
          decoration: LaDecor.pill(palette.bg, palette.fg),
          child: AutoSizeText(
            label,
            minFontSize: 11,
            maxFontSize: 13,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.fg,
              fontFamily: LaText.fontBold,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    final rawText = _displayText(titleDoc['ser'] ?? '');
    final displayText = isName ? '${index + 1}. $rawText' : rawText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AutoSizeText(
        displayText,
        minFontSize: 11,
        maxFontSize: 13,
        maxLines: 1,
        textAlign: isName ? TextAlign.left : TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: LaText.tableCell,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Display text helpers
  // ---------------------------------------------------------------------------
  String _displayText(String ser) {
    if (ser == '1') {
      // ชื่อเอกสาร — ใช้ nameTh จาก doc
      return (doc.nameTh ?? '').toString();
    }
    if (!_hasFile) return '-';
    final att = doc.attachments!.first;
    switch (ser) {
      case '2': // วันที่ทำรายการ
        return _fmtDate(att.uploadedAt);
      case '4': // สถานะ
        return _statusLabel(doc);
      case '5': // วันที่ตรวจสอบ
        return _fmtDate(att.reviewAt);
      default:
        return '-';
    }
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd-$mm-${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  String _statusLabel(LicenseverifyDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  StatusPalette _statusPalette(LicenseverifyDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  Future<void> _onApprove(BuildContext context, LicenseverifyDocument doc) async {
    final vm = context.read<VerifyDocumentsViewModel>();
    // ignore: avoid_print
    print('🔵 [_DocumentRow] อนุมัติ docId=$_docId name=${doc.nameTh}');
    final ok = await vm.approveDocument(documentId: _docId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'อนุมัติสำเร็จ' : 'อนุมัติไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }

  Future<void> _onReject(BuildContext context, LicenseverifyDocument doc) async {
    final vm = context.read<VerifyDocumentsViewModel>();
    // ignore: avoid_print
    print('🔴 [_DocumentRow] ปฏิเสธ docId=$_docId name=${doc.nameTh}');
    final ok = await vm.rejectDocument(documentId: _docId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ปฏิเสธสำเร็จ' : 'ปฏิเสธไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }
}

// =============================================================================
// ReviewActions — ปุ่ม อนุมัติ/ปฏิเสธ วางหลังสุด
// =============================================================================
class _ReviewActions extends StatelessWidget {
  final LicenseverifyDocument doc;
  final int docId;
  final bool enabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ReviewActions({
    required this.doc,
    required this.docId,
    required this.enabled,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: enabled ? onApprove : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: LaColors.statusApprovedBg,
            foregroundColor: LaColors.statusApprovedFg,
            disabledBackgroundColor: LaColors.surfaceMuted,
            disabledForegroundColor: LaColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('อนุมัติ'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: enabled ? onReject : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: LaColors.statusRejectedBg,
            foregroundColor: LaColors.statusRejectedFg,
            disabledBackgroundColor: LaColors.surfaceMuted,
            disabledForegroundColor: LaColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('ปฏิเสธ'),
        ),
      ],
    );
  }
}

// =============================================================================
// DocumentCard — layout สำหรับ mobile (stack แนวตั้ง)
// =============================================================================
class _DocumentCard extends StatelessWidget {
  final int index;
  final LicenseverifyDocument doc;
  const _DocumentCard({required this.index, required this.doc});

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerifyDocumentsViewModel>();
    final palette = _statusPalette(doc);
    final statusLabel = _statusLabel(doc);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: LaSpace.xs),
      padding: const EdgeInsets.all(LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Row 1: ลำดับ + ชื่อเอกสาร ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: Text(
                  '${index + 1}',
                  style: LaText.label.copyWith(
                    color: LaColors.primaryDark,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              Expanded(
                child: Text(
                  (doc.nameTh ?? '-').toString(),
                  style: LaText.tableCell.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.xs),

          // ─── Row 2: Status pill ───
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 12, color: LaColors.textSecondary),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.sm, vertical: 2),
                decoration: LaDecor.pill(palette.bg, palette.fg),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: palette.fg,
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              if (_hasFile)
                Text(
                  'อัปโหลด: ${_fmtDateShort(doc.attachments!.first.uploadedAt)}',
                  style: LaText.caption.copyWith(fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: LaSpace.sm),

          // ─── Row 3: ปุ่ม actions ───
          Row(
            children: [
              // เรียกดูไฟล์ (เต็มพื้นที่ที่เหลือ)
              Expanded(
                child: _FileButton(doc: doc, enabled: _hasFile),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 140,
                child: _ReviewActions(
                  doc: doc,
                  docId: _docId,
                  enabled: _hasFile &&
                      !_statusLabel(doc).contains('อนุมัติ') &&
                      !_statusLabel(doc).contains('ปฏิเสธ'),
                  onApprove: () => _onApprove(context, doc),
                  onReject: () => _onReject(context, doc),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- shared helpers (ซ้ำกับ row เพื่อไม่ผูกกัน) --------
  StatusPalette _statusPalette(LicenseverifyDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  String _statusLabel(LicenseverifyDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  String _fmtDateShort(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd/$mm/${dt.year % 100}';
    } catch (_) {
      return '-';
    }
  }

  Future<void> _onApprove(BuildContext context, LicenseverifyDocument doc) async {
    final vm = context.read<VerifyDocumentsViewModel>();
    // ignore: avoid_print
    print('🔵 [_DocumentCard] อนุมัติ docId=$_docId name=${doc.nameTh}');
    final ok = await vm.approveDocument(documentId: _docId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'อนุมัติสำเร็จ' : 'อนุมัติไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }

  Future<void> _onReject(BuildContext context, LicenseverifyDocument doc) async {
    final vm = context.read<VerifyDocumentsViewModel>();
    // ignore: avoid_print
    print('🔴 [_DocumentCard] ปฏิเสธ docId=$_docId name=${doc.nameTh}');
    final ok = await vm.rejectDocument(documentId: _docId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'ปฏิเสธสำเร็จ' : 'ปฏิเสธไม่สำเร็จ'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
      ),
    );
  }
}

// =============================================================================
// ปุ่ม "เรียกดูไฟล์" (เปิด preview)
// =============================================================================
// ปุ่ม "เรียกดูไฟล์" (เปิด preview)
// =============================================================================
class _FileButton extends StatelessWidget {
  final LicenseverifyDocument doc;
  final bool enabled;
  const _FileButton({required this.doc, required this.enabled});

  /// เปิด preview ไฟล์แนบ (PDF / รูป) — popup gallery รองรับ Next/Prev
  void _openPreview(BuildContext context) {
    if (!enabled) return;

    // หา attachment ที่ตรงกับ docId ของ row นี้
    final docId =
        doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;
    final matched = findAttachmentByDocId(
      doc.attachments ?? <LicenseverifyAttachment>[],
      docId,
    );
    final att = matched ?? doc.attachments!.first;

    // รวบรวม attachments ทั้งหมดจากทุก docs ใน VM เพื่อให้ Next/Prev ทำงาน
    final vm = context.read<VerifyDocumentsViewModel>();
    final allAttachments = <LicenseverifyAttachment>[];
    final allTitles = <String?>[];
    for (final d in vm.documents) {
      if (d.attachments != null) {
        for (final a in d.attachments!) {
          allAttachments.add(a);
          // ใช้ doc.nameTh เป็น title สำหรับแต่ละ attachment
          allTitles.add(d.nameTh?.toString());
        }
      }
    }

    // หา index ของ attachment ปัจจุบัน
    final initialIndex = allAttachments
        .indexWhere((a) => a.uuid == att.uuid && a.filePath == att.filePath);

    final onApprove = () async {
      final ok = await vm.approveDocument(documentId: docId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'อนุมัติสำเร็จ' : 'อนุมัติไม่สำเร็จ'),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
        ),
      );
    };

    final onReject = () async {
      final ok = await vm.rejectDocument(documentId: docId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'ปฏิเสธสำเร็จ' : 'ปฏิเสธไม่สำเร็จ'),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              ok ? LaColors.statusApprovedFg : LaColors.statusRejectedFg,
        ),
      );
    };

    if (allAttachments.length <= 1) {
      // ถ้ามีแค่ 1 ไฟล์ → ใช้ .show() ปกติ
      VerifyFilePreviewDialog.show(
        context,
        attachment: att,
        title: doc.nameTh ?? 'ไฟล์แนบ',
        onApprove: onApprove,
        onReject: onReject,
      );
    } else {
      // ถ้ามีหลายไฟล์ → ใช้ .showGallery() รองรับ Next/Prev + ส่ง titles list
      VerifyFilePreviewDialog.showGallery(
        context,
        attachments: allAttachments,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        title: doc.nameTh ?? 'ไฟล์แนบ',
        titles: allTitles,
        onApprove: onApprove,
        onReject: onReject,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? LaColors.statusApprovedBg : LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(LaRadius.sm),
          onTap: enabled ? () => _openPreview(context) : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: LaSpace.sm, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  enabled
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 14,
                  color:
                      enabled ? LaColors.statusApprovedFg : LaColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'เรียกดู',
                  style: LaText.label.copyWith(
                    color: enabled
                        ? LaColors.statusApprovedFg
                        : LaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// States (Loading / Empty / MissingRequest)
// =============================================================================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(LaColors.primary),
              ),
            ),
            SizedBox(height: LaSpace.md),
            Text('กำลังโหลดรายการเอกสาร…', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: LaColors.textMuted),
            SizedBox(height: LaSpace.md),
            Text('ไม่พบรายการเอกสารที่ต้องแนบ', style: LaText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

class _MissingRequestState extends StatelessWidget {
  const _MissingRequestState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: LaSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded,
                size: 48, color: LaColors.statusRejectedFg),
            SizedBox(height: LaSpace.md),
            Text('ไม่พบรหัสคำขอ', style: LaText.h2),
            SizedBox(height: 4),
            Text(
              'กรุณาเปิดหน้านี้จากรายการ "คำขอต่อสัญญา"',
              style: LaText.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Footer Hint (เหมือนเดิม 1:1)
// =============================================================================
class _FooterHint extends StatelessWidget {
  const _FooterHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: LaColors.textMuted),
        SizedBox(width: 6),
        Expanded(
          child: Text('เลือกเอกสารให้ครบถ้วนก่อนกด "ถัดไป"',
              style: LaText.caption),
        ),
      ],
    );
  }
}

// =============================================================================
// View Mode Toggle — สลับระหว่าง List / Grid
// =============================================================================
class _ViewModeToggle extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onTap;

  const _ViewModeToggle({required this.isGrid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LaRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_list_rounded,
                  size: 14,
                  color: isGrid ? LaColors.textMuted : LaColors.primaryDark,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.view_module_rounded,
                  size: 14,
                  color: isGrid ? LaColors.primaryDark : LaColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Documents Grid — Grid view สูงสุด 4 คอลัมน์ + preview รูป/PDF
// =============================================================================
class _DocumentsGrid extends StatelessWidget {
  final List<LicenseverifyDocument> documents;
  const _DocumentsGrid({required this.documents});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // Responsive: 1-4 คอลัมน์ ตามความกว้าง
        int columns = 1;
        if (constraints.maxWidth >= 1200) {
          columns = 4;
        } else if (constraints.maxWidth >= 800) {
          columns = 3;
        } else if (constraints.maxWidth >= 500) {
          columns = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78, // card ค่อนข้างสูง (รูป + ชื่อ + status)
          ),
          itemCount: documents.length,
          itemBuilder: (ctx, i) {
            return _DocumentGridCard(
              index: i,
              doc: documents[i],
              columns: columns,
            );
          },
        );
      },
    );
  }
}

class _DocumentGridCard extends StatelessWidget {
  final int index;
  final LicenseverifyDocument doc;
  final int columns;
  const _DocumentGridCard({
    required this.index,
    required this.doc,
    required this.columns,
  });

  bool get _hasFile => doc.attachments != null && doc.attachments!.isNotEmpty;

  int get _docId =>
      doc.id is int ? doc.id as int : int.tryParse('${doc.id}') ?? 0;

  String _fmtDateShort(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.isEmpty || s == 'null') return '-';
    try {
      final dt = DateTime.parse(s);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd/$mm/${dt.year % 100}';
    } catch (_) {
      return '-';
    }
  }

  String _statusLabel(LicenseverifyDocument doc) {
    if (!_hasFile) return 'ยังไม่แนบ';
    final s = doc.attachments!.first.status_label?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return 'รอตรวจสอบ';
    return s;
  }

  StatusPalette _statusPalette(LicenseverifyDocument doc) {
    final raw =
        (_hasFile ? doc.attachments!.first.status : null)?.toString() ?? '';
    final label = _statusLabel(doc);
    if (raw.contains('อนุมัติ') ||
        label.contains('อนุมัติ') ||
        label.contains('ผ่าน') ||
        label.contains('เสร็จ')) {
      return const StatusPalette(
          LaColors.statusApprovedBg, LaColors.statusApprovedFg);
    }
    if (raw.contains('ปฏิเสธ') ||
        label.contains('ปฏิเสธ') ||
        label.contains('ขอปรับปรุง') ||
        label.contains('ไม่ผ่าน')) {
      return const StatusPalette(
          LaColors.statusRejectedBg, LaColors.statusRejectedFg);
    }
    return const StatusPalette(
        LaColors.statusPendingBg, LaColors.statusPendingFg);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerifyDocumentsViewModel>();
    final palette = _statusPalette(doc);
    final statusLabel = _statusLabel(doc);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Preview area ───
            Expanded(
              child: _DocumentPreview(
                doc: doc,
                hasFile: _hasFile,
              ),
            ),

            // ─── Body ───
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ลำดับ + ชื่อ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: LaColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: LaText.label.copyWith(
                            color: LaColors.primaryDark,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (doc.nameTh ?? '-').toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Status pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: LaDecor.pill(palette.bg, palette.fg),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: palette.fg,
                        fontFamily: LaText.fontBold,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (_hasFile) ...[
                    const SizedBox(height: 4),
                    Text(
                      _fmtDateShort(doc.attachments!.first.uploadedAt),
                      style: LaText.caption.copyWith(fontSize: 9),
                    ),
                  ],

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Document Preview — โหลด thumbnail รูป/PDF (ใช้ service + auth header)
// =============================================================================
class _DocumentPreview extends StatelessWidget {
  final LicenseverifyDocument doc;
  final bool hasFile;
  const _DocumentPreview({required this.doc, required this.hasFile});

  @override
  Widget build(BuildContext context) {
    if (!hasFile) {
      return _emptyState();
    }

    final att = doc.attachments!.first;

    // ตรวจนามสกุลไฟล์
    final fileType = (att.fileType ?? '').toString().toLowerCase();
    final fileName =
        (att.fileName ?? att.filePath ?? '').toString().toLowerCase();
    final combined = '$fileType $fileName';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp']
        .any((ext) => combined.contains(ext));
    final isPdf = combined.contains('pdf');

    if (isImage) {
      // โหลดผ่าน service (มี auth header) แล้วแสดงด้วย Image.memory
      return FutureBuilder<Uint8List?>(
        future: VerifyDocumentsService().fetchAttachmentBytes(att),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _loadingState();
          }
          final bytes = snap.data;
          if (bytes == null || bytes.isEmpty) {
            return GestureDetector(
              onTap: () => _openPreview(context),
              child: _placeholder(
                Icons.broken_image_rounded,
                'โหลดไม่สำเร็จ',
              ),
            );
          }
          return GestureDetector(
            onTap: () => _openPreview(context),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _placeholder(
                Icons.broken_image_rounded,
                'แสดงไม่ได้',
              ),
            ),
          );
        },
      );
    }

    // PDF / อื่นๆ → แสดง icon + คลิกเปิด preview เต็มจอ
    return GestureDetector(
      onTap: () {
        // ignore: avoid_print
        print(
            '🔍 [_DocumentPreview] คลิก PDF/ไฟล์: "${att.fileName}" (uuid=${att.uuid})');
        _openPreview(context);
      },
      child: _placeholder(
        isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
        isPdf ? 'PDF' : (fileType.isNotEmpty ? fileType.toUpperCase() : 'FILE'),
        pdfColor: isPdf ? Colors.red.shade400 : null,
      ),
    );
  }

  /// Empty state: ยังไม่มีไฟล์แนบ
  Widget _emptyState() {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.upload_file_rounded, size: 32, color: LaColors.textMuted),
          SizedBox(height: 4),
          Text(
            'ยังไม่มีไฟล์',
            style: TextStyle(
              color: LaColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading state: กำลังโหลดรูป
  Widget _loadingState() {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Placeholder: PDF / ไฟล์อื่น / โหลดไม่สำเร็จ
  Widget _placeholder(IconData icon, String label, {Color? pdfColor}) {
    return Container(
      color: LaColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: pdfColor ?? LaColors.textMuted),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: pdfColor ?? LaColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'คลิกเพื่อดู',
            style: TextStyle(
              color: LaColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// เปิด preview ไฟล์แนบ — popup gallery รองรับ Next/Prev + ส่ง titles list
  void _openPreview(BuildContext context) {
    if (!hasFile) return;

    // หา attachment ที่ตรงกับ docId
    final raw = doc.id;
    final docId = raw is int
        ? raw
        : (raw is num
            ? raw.toInt()
            : (raw is String ? int.tryParse(raw) ?? 0 : 0));
    final matched = findAttachmentByDocId(
      doc.attachments ?? <LicenseverifyAttachment>[],
      docId,
    );
    final att = matched ?? doc.attachments!.first;

    // รวบรวม attachments + titles ทั้งหมดจากทุก docs ใน VM
    final vm = context.read<VerifyDocumentsViewModel>();
    final allAttachments = <LicenseverifyAttachment>[];
    final allTitles = <String?>[];
    for (final d in vm.documents) {
      if (d.attachments != null) {
        for (final a in d.attachments!) {
          allAttachments.add(a);
          // ใช้ doc.nameTh เป็น title สำหรับแต่ละ attachment
          allTitles.add(d.nameTh?.toString());
        }
      }
    }

    // หา index ของ attachment ปัจจุบัน
    final initialIndex = allAttachments
        .indexWhere((a) => a.uuid == att.uuid && a.filePath == att.filePath);

    if (allAttachments.length <= 1) {
      // ถ้ามีแค่ 1 ไฟล์ → ใช้ .show() ปกติ
      VerifyFilePreviewDialog.show(
        context,
        attachment: att,
        title: doc.nameTh ?? 'ไฟล์แนบ',
      );
    } else {
      // ถ้ามีหลายไฟล์ → ใช้ .showGallery() + ส่ง titles list เพื่อให้ title เปลี่ยนตามไฟล์
      VerifyFilePreviewDialog.showGallery(
        context,
        attachments: allAttachments,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        title: doc.nameTh ?? 'ไฟล์แนบ',
        titles: allTitles,
      );
    }
  }
}

