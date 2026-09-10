import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart'; // สำหรับพิมพ์/บันทึก PDF
import 'package:share_plus/share_plus.dart'; // สำหรับแชร์ไฟล์

class LoadedDoc {
  final Uint8List bytes;
  final bool isPdf;
  final String mimeType;
  LoadedDoc(this.bytes, this.isPdf, this.mimeType);
}

class FullScreenDocViewer extends StatefulWidget {
  const FullScreenDocViewer({
    super.key,
    required this.title,
    required this.subTitle,
    required this.future,
    required this.fileTypeHint, // จาก first.fileType
    required this.watermark,
    this.appBarColor,
    this.downloadFileName = 'downloaded_document', // ชื่อไฟล์ตอนแชร์/ดาวน์โหลด
  });

  final String title;
  final String subTitle;
  final Future<http.Response?> future;
  final String fileTypeHint;
  final Widget watermark;
  final Color? appBarColor;
  final String downloadFileName;

  @override
  State<FullScreenDocViewer> createState() => _FullScreenDocViewerState();
}

class _FullScreenDocViewerState extends State<FullScreenDocViewer> {
  Uint8List? _bytes;
  bool _isPdf = false;
  String _mimeType = 'application/octet-stream';
  late Future<LoadedDoc> _load;
  double _currentZoomLevel = 1.0;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  @override
  void initState() {
    super.initState();
    _load = _prepareDoc(widget.future, widget.fileTypeHint);
  }

  Future<LoadedDoc> _prepareDoc(
      Future<http.Response?> future, String fileTypeHint) async {
    final res = await future;
    if (res == null || res.statusCode != 200) {
      throw Exception('โหลดไฟล์ไม่สำเร็จ');
    }
    final ct =
        (res.headers['content-type'] ?? res.headers['Content-Type'] ?? '')
            .toLowerCase();
    final hint = fileTypeHint.toLowerCase();
    final isPdf = hint.contains('pdf') || ct.contains('application/pdf');
    final mime = ct.isNotEmpty
        ? ct
        : (isPdf ? 'application/pdf' : 'application/octet-stream');
    return LoadedDoc(res.bodyBytes, isPdf, mime);
  }

  void _setLoadedBytes(http.Response res) {
    // เก็บ bytes + วิเคราะห์ content-type
    final headers = res.headers;
    final ct = (headers['content-type'] ?? headers['Content-Type'] ?? '')
        .toLowerCase();

    final fileType = widget.fileTypeHint.toLowerCase();
    final isPdf = fileType.contains('pdf') || ct.contains('application/pdf');

    setState(() {
      _bytes = res.bodyBytes;
      _isPdf = isPdf;
      _mimeType = ct.isNotEmpty
          ? ct
          : (isPdf ? 'application/pdf' : 'application/octet-stream');
    });
  }

  Future<void> _printPDF() async {
    if (_bytes == null || !_isPdf) {
      _showSnack('ไฟล์ยังไม่พร้อมหรือไม่ใช่ PDF');
      return;
    }
    await Printing.layoutPdf(onLayout: (format) async => _bytes!);
  }

  Future<void> _shareFile() async {
    if (_bytes == null) {
      _showSnack('ไฟล์ยังไม่พร้อม');
      return;
    }
    final name = '${widget.downloadFileName}${_isPdf ? '.pdf' : ''}';
    // ใช้ share_plus แชร์ไฟล์จากหน่วยความจำ
    final xfile = XFile.fromData(
      _bytes!,
      name: name,
      mimeType: _mimeType,
    );
    await Share.shareXFiles([xfile], text: widget.title);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildBottomBar(canUse, doc) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.indigo[400],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0)),
      ),
      // color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(
                    Icons.print,
                    size: 30,
                  ),
                  onPressed: (canUse && doc!.isPdf)
                      ? () async {
                          await Printing.layoutPdf(
                              onLayout: (format) async => doc.bytes);
                        }
                      : null,
                  tooltip: 'Print PDF',
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.save_alt,
                    size: 30,
                  ),
                  onPressed: canUse
                      ? () async {
                          if (doc!.bytes == null) return;
                          await Printing.sharePdf(
                            bytes: doc.bytes!,
                            filename: widget.title ?? 'downloaded_document.pdf',
                          );
                          // final name =
                          //     '${widget.downloadFileName}${doc!.isPdf ? '.pdf' : ''}';
                          // final x = XFile.fromData(doc.bytes,
                          //     name: name, mimeType: doc.mimeType);
                          // await Share.shareXFiles([x], text: widget.title);
                        }
                      : null,
                  tooltip: 'Save PDF',
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.zoom_in,
                    size: 30,
                  ),
                  onPressed: () {
                    _currentZoomLevel += 0.25;
                    if (_currentZoomLevel > 3.0) _currentZoomLevel = 3.0;
                    _pdfViewerController.zoomLevel = _currentZoomLevel;
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.zoom_out,
                    size: 30,
                  ),
                  onPressed: () {
                    _currentZoomLevel -= 0.25;
                    if (_currentZoomLevel < 1.0) _currentZoomLevel = 1.0;
                    _pdfViewerController.zoomLevel = _currentZoomLevel;
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoadedDoc>(
      future: _load,
      builder: (context, snap) {
        final canUse =
            snap.connectionState == ConnectionState.done && snap.hasData;
        final doc = canUse ? snap.data! : null;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: widget.appBarColor ?? Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(widget.title,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis),
                Text(widget.subTitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: () {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!canUse) {
                          return const Center(
                              child: Icon(Icons.broken_image,
                                  size: 64, color: Colors.white));
                        }
                        return doc!.isPdf
                            ? SfPdfViewer.memory(
                                controller: _pdfViewerController, doc.bytes)
                            : InteractiveViewer(
                                child: Image.memory(doc.bytes,
                                    fit: BoxFit.contain));
                      }(),
                    ),
                    Positioned.fill(
                        child: IgnorePointer(child: widget.watermark)),
                  ],
                ),
              ),
              _buildBottomBar(canUse, doc)
            ],
          ),
        );
      },
    );
  }
}
