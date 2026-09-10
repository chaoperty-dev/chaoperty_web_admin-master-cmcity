import 'package:flutter/material.dart';

import '../../../Style/colors.dart';
import '../../unity/url_preview_widget.dart';

class PdfMultiPreviewPage extends StatefulWidget {
  final List<Map<String, String>> docs; // [{title:'...', key:'GeneratePDF_1'}]
  final int initialIndex;

  /// getUrl(key) -> URL string ของ preview page
  final String Function(String key) getUrl;

  const PdfMultiPreviewPage({
    super.key,
    required this.docs,
    required this.getUrl,
    this.initialIndex = 0,
  });

  @override
  State<PdfMultiPreviewPage> createState() => _PdfMultiPreviewPageState();
}

class _PdfMultiPreviewPageState extends State<PdfMultiPreviewPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.docs.length - 1);
  }

  String get _currentKey => widget.docs[_index]['key'] ?? '';
  String get _currentTitle => widget.docs[_index]['title'] ?? '';
  String get _currentUrl => widget.getUrl(_currentKey);

  void _prev() {
    if (_index <= 0) return;
    setState(() => _index--);
  }

  void _next() {
    if (_index >= widget.docs.length - 1) return;
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarColors.hexColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          '${_currentTitle} [${_index + 1}/${widget.docs.length}]',
          style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_index > 0)
            IconButton(
              icon: const Icon(Icons.navigate_before, color: Colors.white),
              onPressed: _prev,
            ),
          if (_index < widget.docs.length - 1)
            IconButton(
              icon: const Icon(Icons.navigate_next, color: Colors.white),
              onPressed: _next,
            ),
        ],
      ),
      body: UrlPreviewWidget(key: ValueKey(_currentUrl), url: _currentUrl),
    );
  }
}
