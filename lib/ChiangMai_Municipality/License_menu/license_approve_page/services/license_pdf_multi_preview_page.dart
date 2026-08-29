// ============================================================================
// license_pdf_multi_preview_page.dart
// ============================================================================
// PDF preview pager สำหรับเอกสารประกอบคำขอ (self-contained)
// - รับ docs: List<Map<String,String>> (ser / key / title) + getUrl(key) resolver
// - AppBar: back, title 'ser. title [i+1/total]', prev/next actions
// - Body: icon + title + URL + ปุ่ม "เปิด PDF" → url_launcher (external browser)
// - ไม่ import PDF_CMM/unity_pdf_cmm, ไม่ใช้ dart:html
// - ใช้ url_launcher ที่มีอยู่แล้วใน pubspec.yaml
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page สำหรับเปิด PDF preview ทีละ doc พร้อม prev/next
class LicensePdfMultiPreviewPage extends StatefulWidget {
  final List<Map<String, String>> docs;
  final String Function(String key) getUrl;
  final int initialIndex;

  const LicensePdfMultiPreviewPage({
    super.key,
    required this.docs,
    required this.getUrl,
    this.initialIndex = 0,
  });

  @override
  State<LicensePdfMultiPreviewPage> createState() =>
      _LicensePdfMultiPreviewPageState();
}

class _LicensePdfMultiPreviewPageState
    extends State<LicensePdfMultiPreviewPage> {
  late int _index;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.docs.length - 1);
  }

  void _prev() {
    if (_index <= 0) return;
    setState(() => _index--);
  }

  void _next() {
    if (_index >= widget.docs.length - 1) return;
    setState(() => _index++);
  }

  Future<void> _openInBrowser() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final doc = widget.docs[_index];
      final key = doc['key'] ?? '';
      final raw = widget.getUrl(key);
      if (raw.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบ URL เอกสารนี้')),
        );
        return;
      }
      final uri = Uri.parse(raw);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เปิดเอกสารไม่สำเร็จ')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิดเอกสารไม่สำเร็จ')),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.docs[_index];
    final ser = doc['ser'] ?? '';
    final title = doc['title'] ?? '';
    final url = widget.getUrl(doc['key'] ?? '');
    final total = widget.docs.length;
    final canPrev = _index > 0;
    final canNext = _index < total - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0.5,
        title: Text(
          '$ser. $title [${_index + 1}/$total]',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'ก่อนหน้า',
            icon: const Icon(Icons.navigate_before_rounded),
            onPressed: canPrev ? _prev : null,
          ),
          IconButton(
            tooltip: 'ถัดไป',
            icon: const Icon(Icons.navigate_next_rounded),
            onPressed: canNext ? _next : null,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 96,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$ser. $title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_index + 1} / $total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3730A3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    url,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _opening ? null : _openInBrowser,
                      icon: _opening
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.open_in_browser_rounded),
                      label: Text(_opening ? 'กำลังเปิด...' : 'เปิด PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('กลับ'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
