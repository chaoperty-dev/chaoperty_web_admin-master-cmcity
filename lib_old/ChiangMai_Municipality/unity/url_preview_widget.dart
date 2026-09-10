import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;

/// Widget แสดง URL ใน iframe บน Flutter Web โดยไม่มี warning dimension
class UrlPreviewWidget extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;

  const UrlPreviewWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  @override
  State<UrlPreviewWidget> createState() => _UrlPreviewWidgetState();
}

class _UrlPreviewWidgetState extends State<UrlPreviewWidget> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
        'url-preview-${widget.url.hashCode}-${DateTime.now().microsecondsSinceEpoch}';

    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = widget.width ?? size.width;
    final h = widget.height ?? size.height;

    if (!kIsWeb) {
      return SizedBox(
        width: w,
        height: h,
        child: const Center(child: Text('Preview ไม่รองรับบน Mobile')),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
