// ============================================================================
// attach_batch_upload_sheet.dart
// ============================================================================
// Modal Bottom Sheet — เลือกไฟล์หลายไฟล์ + ลากมาวางบนหัวข้อเอกสาร
//
// Mobile-first layout:
//   - Header (compact)
//   - Mobile: TabBar 2 tabs (📁 ไฟล์ / 📋 หัวข้อ) — ไม่ต้องเลื่อนจอ
//   - Desktop: 2 คอลัมน์ (ไฟล์ | หัวข้อ) — drag-drop ได้สะดวก
//   - Footer: ปุ่ม "บันทึกทั้งหมด" + progress
//
// ลอจิกคัดมาจาก Make_contract_CMM/BatchUploadSheet
// ============================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/license_attach_document.dart';
import '../../services/attach_documents_service.dart';
import '../theme/license_attach_theme.dart';

class _BatchRequiredBubble extends StatelessWidget {
  const _BatchRequiredBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LaColors.statusPendingBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Text(
        'จำเป็น',
        style: TextStyle(
          fontFamily: LaText.fontBold,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: LaColors.statusPendingFg,
        ),
      ),
    );
  }
}

// =============================================================================
// Public entry point
// =============================================================================

/// เปิด Bottom Sheet สำหรับ batch upload
/// คืนค่า `Map<int, LicenseAttachAttachment>` ของ docId → uploaded attachment
Future<Map<int, LicenseAttachAttachment>?> showAttachBatchUploadSheet({
  required BuildContext context,
  required List<LicenseAttachDocument> documents,
  required String requestUuid,
}) {
  return showModalBottomSheet<Map<int, LicenseAttachAttachment>>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    // ✅ Desktop: บังคับความกว้างเต็มจอ เพื่อให้ workspace แบ่งซ้าย/ขวาจริง
    //    (Material 3 มี default max-width 640px ถ้าไม่กำหนด minWidth)
    constraints: BoxConstraints(
      minWidth: MediaQuery.sizeOf(context).width,
      maxWidth: MediaQuery.sizeOf(context).width,
    ),
    backgroundColor: Colors.transparent,
    builder: (ctx) => AttachBatchUploadSheet(
      documents: documents,
      requestUuid: requestUuid,
    ),
  );
}

// =============================================================================
// Main sheet widget
// =============================================================================

class AttachBatchUploadSheet extends StatefulWidget {
  final List<LicenseAttachDocument> documents;
  final String requestUuid;

  const AttachBatchUploadSheet({
    super.key,
    required this.documents,
    required this.requestUuid,
  });

  @override
  State<AttachBatchUploadSheet> createState() => _AttachBatchUploadSheetState();
}

class _AttachBatchUploadSheetState extends State<AttachBatchUploadSheet> {
  final List<PlatformFile> _pickedFiles = [];
  final Map<int, PlatformFile> _assignments = {};
  final Map<int, LicenseAttachAttachment> _uploaded = {};

  bool _uploading = false;
  double _progress = 0;

  static const int _kMaxBytes = 10 * 1024 * 1024;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  int _docId(LicenseAttachDocument d) =>
      d.id is int ? d.id as int : int.tryParse('${d.id}') ?? 0;

  String _docName(LicenseAttachDocument d) => (d.nameTh ?? '').toString();

  bool _hasAttachment(LicenseAttachDocument d) =>
      d.attachments != null && d.attachments!.isNotEmpty;

  int get _missingRequiredCount => widget.documents.where((doc) {
        if (!doc.isRequired || _hasAttachment(doc)) return false;
        final id = _docId(doc);
        return !_assignments.containsKey(id) && !_uploaded.containsKey(id);
      }).length;

  // ---------------------------------------------------------------------------
  // File picker
  // ---------------------------------------------------------------------------
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null) return;

    final rejected = <PlatformFile>[];
    setState(() {
      final existing = _pickedFiles.map((f) => '${f.name}:${f.size}').toSet();
      for (final f in result.files) {
        if (f.size > _kMaxBytes) {
          rejected.add(f);
          continue;
        }
        final key = '${f.name}:${f.size}';
        if (!existing.contains(key)) {
          _pickedFiles.add(f);
          existing.add(key);
        }
      }
    });

    if (rejected.isNotEmpty && mounted) {
      final lines =
          rejected.map((f) => '• ${f.name} (${_fmtBytes(f.size)})').join('\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไฟล์ใหญ่เกินกำหนด (${_fmtBytes(_kMaxBytes)})\n$lines'),
          backgroundColor: LaColors.statusRejectedFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Drag handlers
  // ---------------------------------------------------------------------------
  void _onAssign(int docId, PlatformFile file) {
    setState(() {
      _assignments[docId] = file;
    });
  }

  void _onUnassign(int docId) {
    setState(() => _assignments.remove(docId));
  }

  void _removePickedAt(int index) {
    setState(() {
      final removed = _pickedFiles[index];
      for (final id in _assignments.keys.toList()) {
        if (_assignments[id] == removed) _assignments.remove(id);
      }
      _pickedFiles.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _pickedFiles.clear();
      _assignments.clear();
    });
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------
  Future<void> _uploadAll() async {
    if (_assignments.isEmpty) return;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    final service = AttachDocumentsService();
    final total = _assignments.length;
    int done = 0;

    for (final entry in _assignments.entries) {
      final docId = entry.key;
      final file = entry.value;

      try {
        final result = await service.uploadAttachment(
          requestUuid: widget.requestUuid,
          documentId: docId,
          bytes: file.bytes,
          filename: file.name,
          file: !kIsWeb && file.path != null ? File(file.path!) : null,
        );

        if (result.ok && result.body?['data'] is Map<String, dynamic>) {
          final updated = LicenseAttachAttachment.fromJson(
            result.body!['data'] as Map<String, dynamic>,
          );
          _uploaded[docId] = updated;
        }
      } catch (_) {}

      done++;
      if (mounted) {
        setState(() => _progress = done / total);
      }
    }

    if (!mounted) return;
    setState(() {
      _uploading = false;
      _progress = 0;
    });

    final success = _uploaded.length;
    final failed = total - success;

    if (failed == 0) {
      Navigator.of(context).pop(_uploaded);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อัปโหลดสำเร็จ $success / $total รายการ'),
          backgroundColor: LaColors.statusPendingFg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      // ยก sheet ขึ้นเหนือ keyboard
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) {
          // ใช้ LayoutBuilder ตรวจสอบขนาด sheet จริง (ไม่ใช่หน้าจอทั้งหมด)
          // → หน้าเดียวทุกขนาด: mobile เรียงแนวตั้ง / desktop 2 แผง
          return LayoutBuilder(
            builder: (layoutCtx, constraints) {
              final isMobile = constraints.maxWidth < 700;

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    _buildHeader(isMobile),
                    Expanded(
                      child: isMobile
                          ? _buildMobileWorkspace(scrollController)
                          : _buildDesktopBody(scrollController),
                    ),
                    _buildFooter(isMobile),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 8 : 12,
        isMobile ? 4 : 8,
        isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LaColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: LaColors.primaryLight,
              borderRadius: BorderRadius.circular(LaRadius.md),
            ),
            child: Icon(
              Icons.library_add_rounded,
              color: LaColors.primaryDark,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'เพิ่มหลายรายการ',
                  style: TextStyle(
                    fontFamily: LaText.fontBold,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                if (!isMobile)
                  const Text(
                    'ลากไฟล์มาวางบนหัวข้อเอกสารที่ต้องการ',
                    style: TextStyle(
                      color: LaColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'ปิด',
            visualDensity: isMobile ? VisualDensity.compact : null,
            onPressed: _uploading ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Mobile workspace — หน้าเดียว: ไฟล์ด้านบน + หัวข้อเอกสารด้านล่าง
  Widget _buildMobileWorkspace(ScrollController scrollController) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: _buildFilePanel(scrollController, isMobile: true),
        ),
        Container(height: 1, color: LaColors.border),
        Expanded(child: _buildDocsPanel(0, isMobile: true)),
      ],
    );
  }

  /// Desktop body — แบ่ง workspace ซ้าย/ขวาชัดเจน (ไฟล์ 25% | เอกสาร 75%)
  /// - แผงซ้าย: รายการไฟล์ที่เลือก + drag source
  /// - แผงขวา: หัวข้อเอกสาร 2 คอลัมน์คงที่ + drop target
  Widget _buildDesktopBody(ScrollController scrollController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildFilePanel(scrollController, isMobile: false),
        ),
        Container(width: 1, color: LaColors.border),
        Expanded(
          flex: 3,
          child: _buildDocsPanel(
            0,
            isMobile: false,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePanel(ScrollController controller,
      {required bool isMobile}) {
    return Container(
      color: LaColors.surfaceMuted.withOpacity(.3),
      child: Column(
        children: [
          // Header + pick button
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 10 : 12,
              isMobile ? 8 : 12,
              isMobile ? 10 : 12,
              isMobile ? 4 : 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ไฟล์ที่เลือก (${_pickedFiles.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 12 : 13,
                    ),
                  ),
                ),
                if (_pickedFiles.isNotEmpty)
                  TextButton.icon(
                    onPressed: _uploading ? null : _clearAll,
                    style: TextButton.styleFrom(
                      visualDensity: isMobile
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.clear_all, size: 14),
                    label: Text('ล้าง',
                        style: TextStyle(fontSize: isMobile ? 11 : 12)),
                  ),
              ],
            ),
          ),
          // Pick button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: LaColors.primaryLight,
                borderRadius: BorderRadius.circular(LaRadius.md),
                child: InkWell(
                  onTap: _uploading ? null : _pickFiles,
                  borderRadius: BorderRadius.circular(LaRadius.md),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 8 : 10,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            size: isMobile ? 14 : 16,
                            color: LaColors.primaryDark),
                        SizedBox(width: isMobile ? 3 : 4),
                        Text(
                          'เลือกไฟล์',
                          style: TextStyle(
                            color: LaColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 12 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          // File list
          Expanded(
            child: _pickedFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file_rounded,
                            size: isMobile ? 28 : 36,
                            color: LaColors.textMuted),
                        SizedBox(height: isMobile ? 4 : 8),
                        Text(
                          'ยังไม่มีไฟล์ที่เลือก',
                          style: TextStyle(
                            color: LaColors.textSecondary,
                            fontSize: isMobile ? 11 : 13,
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'กดปุ่ม "เลือกไฟล์"',
                            style: TextStyle(
                              color: LaColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: controller,
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    itemCount: _pickedFiles.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: isMobile ? 4 : 6),
                    itemBuilder: (ctx, i) {
                      final file = _pickedFiles[i];
                      return Draggable<PlatformFile>(
                        data: file,
                        feedback: _dragFeedback(file),
                        childWhenDragging: Opacity(
                          opacity: .4,
                          child: _fileTile(
                            file: file,
                            onRemove: () => _removePickedAt(i),
                            isMobile: isMobile,
                          ),
                        ),
                        child: _fileTile(
                          file: file,
                          onRemove: () => _removePickedAt(i),
                          isMobile: isMobile,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocsPanel(double availableWidth, {required bool isMobile}) {
    // แสดงเอกสารครบทุกหัวข้อ รวมรายการที่มีไฟล์แนบแล้ว
    final docsToShow = widget.documents;

    // Desktop = 2 คอลัมน์คงที่ตาม workspace ref; mobile = 1 คอลัมน์
    final crossAxisCount = isMobile ? 1 : 2;
    final aspectRatio = isMobile ? 5.0 : 5.2;

    return Container(
      color: Colors.white,
      child: docsToShow.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.task_alt_rounded,
                      size: 48, color: LaColors.statusApprovedFg),
                  SizedBox(height: 8),
                  Text(
                    'ทุกหัวข้อมีไฟล์แนบแล้ว',
                    style: TextStyle(
                      color: LaColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header: หัวข้อ + จำนวน
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 16, color: LaColors.primaryDark),
                      const SizedBox(width: 6),
                      Text(
                        'หัวข้อเอกสาร (${docsToShow.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Grid (2-4 คอลัมน์) หรือ List (1 คอลัมน์)
                Expanded(
                  child: crossAxisCount > 1
                      ? GridView.builder(
                          padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: docsToShow.length,
                          itemBuilder: (ctx, i) {
                            final doc = docsToShow[i];
                            return _docDropTarget(
                              docId: _docId(doc),
                              name: _docName(doc),
                              isRequired: doc.isRequired,
                              assigned: _assignments[_docId(doc)],
                              uploaded: _uploaded[_docId(doc)] ??
                                  (_hasAttachment(doc)
                                      ? doc.attachments.first
                                      : null),
                              isMobile: false,
                            );
                          },
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 10 : 12,
                            0,
                            isMobile ? 10 : 12,
                            isMobile ? 10 : 12,
                          ),
                          itemCount: docsToShow.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (ctx, i) {
                            final doc = docsToShow[i];
                            return _docDropTarget(
                              docId: _docId(doc),
                              name: _docName(doc),
                              isRequired: doc.isRequired,
                              assigned: _assignments[_docId(doc)],
                              uploaded: _uploaded[_docId(doc)] ??
                                  (_hasAttachment(doc)
                                      ? doc.attachments.first
                                      : null),
                              isMobile: isMobile,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _docDropTarget({
    required int docId,
    required String name,
    required bool isRequired,
    required PlatformFile? assigned,
    required LicenseAttachAttachment? uploaded,
    required bool isMobile,
  }) {
    final isUploaded = uploaded != null;

    return DragTarget<PlatformFile>(
      onWillAccept: (file) => assigned == null,
      onAccept: (file) => _onAssign(docId, file),
      builder: (ctx, candidate, rejected) {
        final isHovering = candidate.isNotEmpty;
        final hasFile = assigned != null;
        final ext = hasFile ? (assigned.extension ?? '').toUpperCase() : '';
        final color = _extColor(ext.toLowerCase());

        // Tap บน mobile: เปิด FilePicker ทันที แล้วจับคู่กับ docId นี้
        final container = Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isUploaded
                ? LaColors.statusApprovedBg.withOpacity(.4)
                : isHovering
                    ? LaColors.primaryLight.withOpacity(.5)
                    : isRequired && !hasFile
                        ? LaColors.statusPendingBg.withOpacity(.45)
                        : LaColors.surfaceMuted.withOpacity(.5),
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(
              color: isUploaded
                  ? LaColors.statusApprovedFg
                  : isHovering
                      ? LaColors.primary
                      : isRequired && !hasFile
                          ? LaColors.statusPendingFg.withOpacity(.35)
                          : LaColors.border,
              width: isHovering || isUploaded ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 32 : 36,
                height: isMobile ? 32 : 36,
                decoration: BoxDecoration(
                  color: hasFile ? color.withOpacity(.15) : Colors.white,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                  border: Border.all(color: color.withOpacity(.4)),
                ),
                child: Icon(
                  isUploaded
                      ? Icons.check_circle_rounded
                      : hasFile
                          ? (ext == 'PDF'
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_rounded)
                          : Icons.upload_file_rounded,
                  color: isUploaded
                      ? LaColors.statusApprovedFg
                      : hasFile
                          ? color
                          : LaColors.textMuted,
                  size: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: 5),
                          const _BatchRequiredBubble(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (isUploaded)
                      Text(
                        '✓ อัปโหลดแล้ว',
                        style: TextStyle(
                          color: LaColors.statusApprovedFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (hasFile)
                      Text(
                        '${assigned.name} (${_fmtBytes(assigned.size)})',
                        style: const TextStyle(
                          color: LaColors.statusInfoFg,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        isMobile ? 'แตะที่นี่เพื่อเลือก' : 'ลากไฟล์มาวางที่นี่',
                        style: const TextStyle(
                          color: LaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasFile && !isUploaded)
                IconButton(
                  tooltip: 'เอาไฟล์ออก',
                  visualDensity: VisualDensity.compact,
                  onPressed: _uploading ? null : () => _onUnassign(docId),
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: LaColors.statusRejectedFg),
                ),
            ],
          ),
        );

        // Mobile: tap เพื่อเลือกไฟล์ตรงๆ (สะดวกกว่า drag-drop)
        if (isMobile && assigned == null && !isUploaded) {
          return GestureDetector(
            onTap: _uploading ? null : () => _pickForDoc(docId),
            child: container,
          );
        }

        return container;
      },
    );
  }

  /// Mobile helper: เลือกไฟล์เดียวสำหรับ docId นี้โดยตรง
  Future<void> _pickForDoc(int docId) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.size > _kMaxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไฟล์ใหญ่เกินกำหนด (${_fmtBytes(_kMaxBytes)})'),
            backgroundColor: LaColors.statusRejectedFg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      // เก็บใน _pickedFiles ด้วยเพื่อให้ list ด้านซ้าย sync
      final key = '${file.name}:${file.size}';
      final existing = _pickedFiles.map((f) => '${f.name}:${f.size}').toSet();
      if (!existing.contains(key)) {
        _pickedFiles.add(file);
      }
      _assignments[docId] = file;
    });
  }

  Widget _buildFooter(bool isMobile) {
    final canUpload =
        !_uploading && _assignments.isNotEmpty && widget.requestUuid.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 8 : 12,
        isMobile ? 12 : 16,
        isMobile ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: LaColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_uploading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(LaRadius.sm),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 5,
                  backgroundColor: LaColors.surfaceMuted,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(LaColors.primary),
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                'กำลังอัปโหลด... ${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: LaColors.textSecondary,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 8),
            ],
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'จับคู่แล้ว ${_assignments.length} ไฟล์',
                        style: TextStyle(
                          color: LaColors.textSecondary,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                      if (_missingRequiredCount > 0) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '• เอกสารจำเป็นยังขาด $_missingRequiredCount รายการ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LaColors.statusPendingFg,
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _uploading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 16,
                    ),
                    visualDensity: isMobile
                        ? VisualDensity.compact
                        : VisualDensity.standard,
                  ),
                  child: const Text('ยกเลิก'),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                FilledButton.icon(
                  onPressed: canUpload ? _uploadAll : null,
                  icon: Icon(Icons.cloud_upload_rounded,
                      size: isMobile ? 14 : 16),
                  label: Text('บันทึกทั้งหมด'),
                  style: FilledButton.styleFrom(
                    backgroundColor: LaColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                      vertical: isMobile ? 6 : 10,
                    ),
                    visualDensity: isMobile
                        ? VisualDensity.compact
                        : VisualDensity.standard,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------
  Widget _fileTile({
    required PlatformFile file,
    required VoidCallback onRemove,
    required bool isMobile,
  }) {
    final ext = (file.extension ?? '').toLowerCase();
    final color = _extColor(ext);
    final isImage = ext == 'jpg' || ext == 'jpeg' || ext == 'png';
    final tileSize = isMobile ? 28.0 : 36.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(.3)),
            ),
            child: isImage && file.bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(
                      file.bytes!,
                      fit: BoxFit.cover,
                      width: tileSize,
                      height: tileSize,
                    ),
                  )
                : Icon(
                    ext == 'pdf'
                        ? Icons.picture_as_pdf_rounded
                        : Icons.insert_drive_file_rounded,
                    color: color,
                    size: isMobile ? 14 : 20,
                  ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _fmtBytes(file.size),
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: LaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'ลบ',
            visualDensity: VisualDensity.compact,
            iconSize: isMobile ? 14 : 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: _uploading ? null : onRemove,
            icon: const Icon(Icons.close_rounded, color: LaColors.textMuted),
          ),
          Icon(Icons.drag_indicator_rounded,
              color: LaColors.textMuted, size: isMobile ? 12 : 16),
        ],
      ),
    );
  }

  Widget _dragFeedback(PlatformFile file) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator_rounded, color: LaColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Utils
  // ---------------------------------------------------------------------------
  Color _extColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red.shade700;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _fmtBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const k = 1024;
    const units = ['B', 'KB', 'MB', 'GB'];
    final i = (math.log(bytes) / math.log(k)).floor();
    final idx = i.clamp(0, units.length - 1).toInt();
    final value = bytes / math.pow(k, idx);
    return '${value.toStringAsFixed(1)} ${units[idx]}';
  }
}

