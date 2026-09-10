import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../Style/colors.dart';

class PreviewPdfgen1_CMM extends StatefulWidget {
  final pw.Document doc;
  final dynamic renTal_name;
  final dynamic title;

  const PreviewPdfgen1_CMM({
    Key? key,
    required this.doc,
    this.renTal_name,
    this.title,
  }) : super(key: key);

  @override
  State<PreviewPdfgen1_CMM> createState() => _PreviewPdfgen1_CMMState();
}

class _PreviewPdfgen1_CMMState extends State<PreviewPdfgen1_CMM> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late final PdfViewerController _pdfViewerController;

  Uint8List? _pdfBytes;
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    // แปลง pw.Document เป็น Uint8List สำหรับ SfPdfViewer.memory
    final bytes = await widget.doc.save();
    setState(() {
      _pdfBytes = bytes;
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoomLevel += 0.25;
      if (_currentZoomLevel > 3.0) _currentZoomLevel = 3.0;
      _pdfViewerController.zoomLevel = _currentZoomLevel;
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoomLevel -= 0.25;
      if (_currentZoomLevel < 1.0) _currentZoomLevel = 1.0;
      _pdfViewerController.zoomLevel = _currentZoomLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarColors.hexColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Center(
          child: Text(
            "ตัวอย่าง : ${widget.title ?? ''}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
      ),
      body: _pdfBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SfPdfViewer.memory(_pdfBytes!,
                          key: _pdfViewerKey,
                          controller: _pdfViewerController,
                          enableTextSelection: false,
                          enableDoubleTapZooming: true),
                      const IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _WatermarkPainter('Chaoperty'),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.indigo[400],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.zoom_in,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: _zoomIn,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.zoom_out,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: _zoomOut,
                      ),
                      // const SizedBox(width: 10),
                      // Text(
                      //   'x${_currentZoomLevel.toStringAsFixed(2)}',
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontFamily: Font_.Fonts_T,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Painter ลายน้ำ: ประสิทธิภาพสูง ไม่กระพริบ
class _WatermarkPainter extends CustomPainter {
  final String text;
  const _WatermarkPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const double angle = -0.4; // ~ -22°
    canvas.save();
    canvas.rotate(angle);

    final style = const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    );

    // เว้นระยะห่างแบบคงที่ วาดให้ครอบคลุมทั้งหน้าจอ
    for (double y = -size.height; y < size.height * 2; y += 180) {
      for (double x = -size.width; x < size.width * 2; x += 260) {
        textPainter.text = TextSpan(text: text, style: style);
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
