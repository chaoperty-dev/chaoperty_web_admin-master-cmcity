// ============================================================================
// step2_pdf_preview.dart
// ============================================================================
// Section พรีวิวเอกสาร PDF 3 อัน (ใบคำร้อง / ใบพิจารณา / ใบอนุญาต)
// - โหลด PDF จาก domain_v3 preview API
// - แสดง thumbnail + คลิกดูเต็มจอ
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:chaoperty/Constant/Myconstant.dart';

import '../../../viewmodels/license_approve_detail_step2_view_model.dart';
import '../../theme/license_approve_theme.dart';

/// รายการ PDF 3 อันที่จะแสดงพรีวิว
class LaPdfDoc {
  final int ser;
  final String title;
  const LaPdfDoc({required this.ser, required this.title});
}

const List<LaPdfDoc> kLaPdfDocs = [
  LaPdfDoc(ser: 1, title: 'ใบคำร้องขอต่อใบอนุญาต'),
  LaPdfDoc(ser: 2, title: 'ใบพิจารณาคำขอต่อใบอนุญาต'),
  LaPdfDoc(ser: 3, title: 'ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ'),
];

/// Section พรีวิวเอกสาร PDF
class Step2PdfPreviewSection extends StatelessWidget {
  const Step2PdfPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseApproveDetailStep2ViewModel>();
    final uuid = vm.reviewDetail?.uuid ?? '';

    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LaColors.statusInfoBg,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    size: 18, color: LaColors.statusInfoFg),
              ),
              const SizedBox(width: LaSpace.sm),
              const Text('พรีวิวเอกสาร', style: LaText.h2),
            ],
          ),
          const SizedBox(height: LaSpace.md),
          LayoutBuilder(
            builder: (context, c) {
              final crossAxisCount =
                  c.maxWidth >= 900 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: LaSpace.sm,
                  crossAxisSpacing: LaSpace.sm,
                  childAspectRatio: 0.85,
                ),
                itemCount: kLaPdfDocs.length,
                itemBuilder: (context, i) {
                  final doc = kLaPdfDocs[i];
                  return _PdfTile(
                    title: doc.title,
                    onTap: uuid.isEmpty
                        ? null
                        : () => _openPdf(context, uuid, doc),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _openPdf(BuildContext context, String uuid, LaPdfDoc doc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _PdfViewerDialog(uuid: uuid, title: doc.title),
    );
  }
}

class _PdfTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _PdfTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        decoration: LaDecor.softCard(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: LaColors.surfaceMuted,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded,
                        size: 48, color: LaColors.statusRejectedFg),
                    SizedBox(height: 4),
                    Text('PDF', style: LaText.caption),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LaSpace.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: LaText.body.copyWith(fontFamily: LaText.fontBold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.visibility_rounded,
                      size: 16, color: LaColors.primaryDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfViewerDialog extends StatelessWidget {
  final String uuid;
  final String title;
  const _PdfViewerDialog({required this.uuid, required this.title});

  @override
  Widget build(BuildContext context) {
    final url = '${MyConstant().domain_v3}/api/preview/vendor-license-2/$uuid';

    return Dialog(
      backgroundColor: LaColors.cardBg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LaRadius.lg)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                  LaSpace.md, LaSpace.md, LaSpace.sm, LaSpace.sm),
              decoration: BoxDecoration(
                color: LaColors.surfaceMuted,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(LaRadius.lg)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: LaText.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'ปิด',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _PdfLoader(url: url),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfLoader extends StatefulWidget {
  final String url;
  const _PdfLoader({required this.url});

  @override
  State<_PdfLoader> createState() => _PdfLoaderState();
}

class _PdfLoaderState extends State<_PdfLoader> {
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final headers = await _buildHeaders();
    try {
      _future = http.get(Uri.parse(widget.url), headers: headers).then((r) {
        if (r.statusCode == 200) return r.bodyBytes;
        return null;
      });
    } catch (_) {
      _future = Future.value(null);
    }
    if (mounted) setState(() {});
  }

  Future<Map<String, String>> _buildHeaders() async {
    // ใช้ helper จาก viewmodel (delegate เพื่อให้ auth header ตรงกัน)
    final vm = context.read<LicenseApproveDetailStep2ViewModel>();
    return await vm.buildAuthHeaders();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_rounded,
                    size: 48, color: LaColors.textMuted),
                SizedBox(height: LaSpace.sm),
                Text('ไม่สามารถโหลด PDF ได้',
                    style: LaText.bodyMuted),
              ],
            ),
          );
        }
        return SfPdfViewer.memory(bytes);
      },
    );
  }
}
