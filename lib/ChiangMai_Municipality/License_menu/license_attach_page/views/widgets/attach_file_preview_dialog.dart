// ============================================================================
// attach_file_preview_dialog.dart
// ============================================================================
// Popup ดูไฟล์แนบ (รูป / PDF) — โหลด bytes ผ่าน AttachDocumentsService
// (มี auth header) แล้วแสดงด้วย Image.memory + InteractiveViewer (zoom)
// ไม่ต้องออกไปหน้าใหม่ — แสดง 1 ต่อ 1 เท่านั้น
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../Model/Document_Model.dart';
import '../../services/attach_documents_service.dart';

/// Popup ดูไฟล์แนบ (รูป/PDF) — โหลดผ่าน auth แล้วแสดงเป็นรูป
///
/// รองรับ:
/// - รูป (jpg/jpeg/png/gif/webp) → แสดงด้วย Image.memory + zoom
/// - PDF/อื่นๆ → แสดง icon + meta
class AttachFilePreviewDialog extends StatelessWidget {
  final AttachmentsModel attachment;
  final String title;
  const AttachFilePreviewDialog({
    super.key,
    required this.attachment,
    required this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required AttachmentsModel attachment,
    required String title,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttachFilePreviewDialog(
        attachment: attachment,
        title: title,
      ),
    );
  }

  /// ตรวจว่าเป็นรูปหรือไม่ (จาก fileType + fileName fallback)
  bool _isImage() {
    final fileType = (attachment.fileType ?? '').toString().toLowerCase();
    final fileName = (attachment.fileName ?? attachment.filePath ?? '')
        .toString()
        .toLowerCase();
    final combined = '$fileType $fileName';
    return ['jpg', 'jpeg', 'png', 'gif', 'webp']
        .any((ext) => combined.contains(ext));
  }

  bool _isPdf() {
    final fileType = (attachment.fileType ?? '').toString().toLowerCase();
    final fileName = (attachment.fileName ?? attachment.filePath ?? '')
        .toString()
        .toLowerCase();
    return '$fileType $fileName'.contains('pdf');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isImage = _isImage();
    final isPdf = _isPdf();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 920,
          maxHeight: mq.size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ───
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    isImage
                        ? Icons.image_outlined
                        : (isPdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.insert_drive_file_outlined),
                    size: 22,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'ปิด',
                  ),
                ],
              ),
            ),

            // ─── Body ───
            Flexible(
              child: isImage
                  ? _ImageViewer(attachment: attachment)
                  : _NonImageViewer(
                      attachment: attachment,
                      isPdf: isPdf,
                    ),
            ),

            // ─── Footer ───
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ปิด'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// โหลด bytes แล้วแสดงรูป + zoom
class _ImageViewer extends StatelessWidget {
  final AttachmentsModel attachment;
  const _ImageViewer({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AttachDocumentsService().fetchAttachmentBytes(attachment),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }
        final bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined,
                    size: 64, color: Colors.black38),
                SizedBox(height: 12),
                Text('โหลดรูปไม่สำเร็จ',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined,
                          size: 64, color: Colors.black38),
                      SizedBox(height: 12),
                      Text('ไม่สามารถแสดงรูปได้',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// สำหรับ PDF / ไฟล์อื่น — แสดง meta + ปุ่ม (ตอนนี้ยังโหลดรูปไม่ได้)
class _NonImageViewer extends StatelessWidget {
  final AttachmentsModel attachment;
  final bool isPdf;
  const _NonImageViewer({required this.attachment, required this.isPdf});

  @override
  Widget build(BuildContext context) {
    final name = (attachment.fileName ?? attachment.filePath ?? '').toString();
    final type = (attachment.fileType ?? '').toString();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf
                ? Icons.picture_as_pdf_outlined
                : Icons.insert_drive_file_outlined,
            size: 72,
            color: isPdf ? Colors.red.shade400 : Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? 'ไม่ทราบชื่อไฟล์' : name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (type.isNotEmpty)
                _Chip(label: type.toUpperCase(), color: Colors.blueGrey),
              if (attachment.uploadedAt != null)
                _Chip(
                  label: attachment.uploadedAt.toString(),
                  color: Colors.blueGrey,
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'ไฟล์ประเภทนี้ยังไม่รองรับการแสดงผลแบบ inline',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
