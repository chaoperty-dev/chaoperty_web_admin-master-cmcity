// ============================================================================
// image_viewer_dialog.dart — Zoomable image viewer (port จาก _showMyDialogImg)
// ============================================================================

import 'package:flutter/material.dart';

import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

class ImageViewerDialog extends StatelessWidget {
  final String url;
  final String title;
  const ImageViewerDialog({super.key, required this.url, required this.title});

  static Future<void> show(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageViewerDialog(url: url, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: Center(
        child: Text(
          title,
          style: LaText.h2.copyWith(
            color: LaColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: InteractiveViewer(
          child: Container(
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 64),
              ),
            ),
          ),
          minScale: 0.5,
          maxScale: 5.0,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ปิด',
              style: LaText.label.copyWith(color: LaColors.primary)),
        ),
      ],
    );
  }
}
