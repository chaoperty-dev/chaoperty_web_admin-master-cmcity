import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'unity/API_addfile.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/SecurePrefs_helper.dart';
import 'Model/ReviewUuid_Model.dart';
import '../Constant/Myconstant.dart';
import 'unity/ReusableSignaturePad.dart';
import 'unity/Enum.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class MobileUploadGrid_CMM extends StatefulWidget {
  final String requestUuid;
  final String expiry;
  final String accessToken;

  const MobileUploadGrid_CMM({
    super.key,
    required this.requestUuid,
    required this.expiry,
    this.accessToken = '',
  });

  @override
  State<MobileUploadGrid_CMM> createState() => _MobileUploadGrid_CMMState();
}

class _MobileUploadGrid_CMMState extends State<MobileUploadGrid_CMM> {
  bool _isLoading = true;
  bool _isExpired = false;
  ReviewDetail? _reviewDetail;
  final Map<int, PlatformFile?> _selectedFiles = {};
  final Map<int, bool> _uploadingStatus = {};
  bool _isGlobalSubmitting = false;
  Timer? _countdownTimer;
  String _timeRemaining = '';
  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeMobileSession();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateTimeLabel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLabel();
    });
  }

  void _updateTimeLabel() {
    try {
      final expiryTime = int.parse(widget.expiry);
      final now = DateTime.now().millisecondsSinceEpoch;
      final remaining = expiryTime - now;

      if (remaining <= 0) {
        _countdownTimer?.cancel();
        setState(() {
          _isExpired = true;
          _timeRemaining = '00:00';
        });
        return;
      }

      final duration = Duration(milliseconds: remaining);
      final minutes =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          duration.inSeconds.remainder(60).toString().padLeft(2, '0');

      setState(() {
        _timeRemaining = '$minutes:$seconds';
      });
    } catch (e) {
      _countdownTimer?.cancel();
    }
  }

  Future<void> _initializeMobileSession() async {
    _checkExpiration();
    if (_isExpired) return;

    if (widget.accessToken.isNotEmpty) {
      await SecurePrefs.setEncrypted(
          SecurePrefsType.authAccessToken, widget.accessToken);
    }

    // Save full URL to localStorage for persistence across refreshes
    if (kIsWeb) {
      final currentHash = html.window.location.hash;
      if (currentHash.contains('mobile_upload')) {
        html.window.localStorage['last_mobile_upload_url'] = currentHash;
      }
    }

    _loadRequestData();
  }

  void _checkExpiration() {
    try {
      final expiryTime = int.parse(widget.expiry);
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiryTime) {
        setState(() {
          _isExpired = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isExpired = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRequestData() async {
    setState(() => _isLoading = true);
    final response = await read_GC_ReviewsUuid(widget.requestUuid);
    if (response != null && response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        _reviewDetail = ReviewDetail.fromJson(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile(int docId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles[docId] = result.files.first;
      });
    }
  }

  Future<void> _takePhoto(int docId) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _selectedFiles[docId] = PlatformFile(
          name: photo.name,
          size: bytes.length,
          bytes: bytes,
        );
      });
    }
  }

  Future<void> _submitBatch() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isGlobalSubmitting = true);

    int successCount = 0;
    int failCount = 0;

    for (var entry in _selectedFiles.entries) {
      final docId = entry.key;
      final file = entry.value;

      if (file == null) continue;

      setState(() => _uploadingStatus[docId] = true);

      try {
        final response = await pickAndUpload(
          widget.requestUuid,
          docId,
          selectedFile: file,
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          successCount++;
          // REMOVED: Immediate reload inside loop to save requests
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      } finally {
        setState(() => _uploadingStatus[docId] = false);
      }
    }

    setState(() => _isGlobalSubmitting = false);

    // Refresh data ONCE after all uploads are done
    await _loadRequestData();

    _showResultDialog(successCount, failCount);
  }

  void _showSignatureDialog(int docId) {
    bool isLandscape = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('เซ็นลายมือชื่อ'),
              IconButton(
                icon: Icon(isLandscape
                    ? Icons.screen_lock_portrait
                    : Icons.screen_lock_landscape),
                onPressed: () {
                  setDialogState(() {
                    isLandscape = !isLandscape;
                  });
                },
                tooltip:
                    isLandscape ? 'เปลี่ยนเป็นแนวตั้ง' : 'เปลี่ยนเป็นแนวนอน',
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          insetPadding: isLandscape
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isLandscape
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width,
              child: RotatedBox(
                quarterTurns: isLandscape ? 1 : 0,
                child: ReusableSignaturePad(
                  height: isLandscape
                      ? MediaQuery.of(context).size.width * 0.8
                      : 400,
                  width: isLandscape ? 500 : null, // ขยายความกว้างเมื่อแนวนอน
                  signatureKey: _signatureKey,
                  onClear: () {
                    _signatureKey.currentState?.clear();
                  },
                  onUp: () async {
                    setState(() => _isGlobalSubmitting = true);
                    try {
                      final response = await handleSave(
                        widget.requestUuid,
                        docId,
                        _signatureKey,
                        SignatureActionType.upload_user,
                      );

                      if (response != null &&
                          (response.statusCode == 200 ||
                              response.statusCode == 201)) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('อัปโหลดลายเซ็นสำเร็จ')),
                          );
                          _loadRequestData();
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('อัปโหลดลายเซ็นล้มเหลว')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isGlobalSubmitting = false);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      }),
    );
  }

  void _showResultDialog(int success, int fail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('อัพโหลดเรียบร้อย'),
        content: Text('สำเร็จ: $success รายการ\nล้มเหลว: $fail รายการ'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (fail == 0) {
                // Clear selected files on total success
                setState(() => _selectedFiles.clear());
                // REMOVED: Redundant reload (already handled by _submitBatch)
              }
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(RequiredDocument doc, PlatformFile? selectedFile) {
    if (selectedFile != null) {
      final ext = selectedFile.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        if (selectedFile.bytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(selectedFile.bytes!, fit: BoxFit.cover),
          );
        }
      }
      return const Center(
          child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 32));
    }

    if (doc.attachment != null) {
      final ext = doc.attachment!.fileType.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'image/jpeg', 'image/png'].contains(ext) ||
          doc.attachment!.filePath.toLowerCase().endsWith('.jpg') ||
          doc.attachment!.filePath.toLowerCase().endsWith('.jpeg') ||
          doc.attachment!.filePath.toLowerCase().endsWith('.png')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            MyConstant().domain_v3 + doc.attachment!.filePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }
      return const Center(
          child: Icon(Icons.description, color: Colors.blue, size: 32));
    }

    return const Center(
        child: Icon(Icons.add_photo_alternate_outlined,
            color: Colors.grey, size: 32));
  }

  Future<void> _closeSession() async {
    if (kIsWeb) {
      html.window.localStorage.remove('last_mobile_upload_url');
    }
    await SecurePrefs.removeEncrypted(SecurePrefsType.authAccessToken);
    if (kIsWeb) {
      html.window.location.href = 'https://www.google.com';
    }
  }

  Future<void> _showExitConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันตัวตน'),
        content: const Text(
            'คุณต้องการปิดหน้านี้และล้างข้อมูลทั้งหมดหรือไม่? (คุณจะไม่สามารถกลับมาหน้านี้ได้ถ้าไม่มี QR Code ใหม่)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ยืนยันปิด'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _closeSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('หมดเวลา'),
          centerTitle: true,
          backgroundColor: Colors.red[800],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_off, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text('QR Code นี้หมดอายุแล้ว (10 นาที)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _closeSession,
                icon: const Icon(Icons.close),
                label: const Text('ปิด'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_reviewDetail == null) {
      return const Scaffold(body: Center(child: Text('ไม่พบข้อมูลคำขอ')));
    }

    final docs = _reviewDetail!.requiredDocs;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              _reviewDetail?.client.scname ?? 'อัปโหลดเอกสาร (Guest)',
              maxLines: 1,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_timeRemaining.isNotEmpty)
              Text(
                'เหลือเวลา: $_timeRemaining',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.yellowAccent),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: _showExitConfirmation,
            tooltip: 'ปิดและล้างข้อมูล',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final docId = doc.document.id;
                final file = _selectedFiles[docId];
                final isUploading = _uploadingStatus[docId] ?? false;

                return Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: AutoSizeText(
                                  doc.document.nameTh ?? 'เอกสาร',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              flex: 4,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _buildPreview(doc, file),
                                    if (doc.attachment != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'อัปโหลดแล้ว',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'THSarabun',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isUploading)
                              const SizedBox(
                                  height: 36,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)))
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Colors.blue, size: 20),
                                    onPressed: () => _takePhoto(docId),
                                    tooltip: 'ถ่ายรูป',
                                  ),
                                  if (doc.document.code == 'users_signature')
                                    IconButton(
                                      icon: const Icon(Icons.draw,
                                          color: Colors.purple, size: 20),
                                      onPressed: () =>
                                          _showSignatureDialog(docId),
                                      tooltip: 'เซ็นชื่อ',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.file_upload,
                                        color: Colors.orange, size: 20),
                                    onPressed: () => _pickFile(docId),
                                    tooltip: 'เลือกไฟล์',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (file != null || doc.attachment != null)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedFiles.isEmpty ? Colors.grey : Colors.green[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: (_selectedFiles.isEmpty || _isGlobalSubmitting)
                    ? null
                    : _submitBatch,
                child: _isGlobalSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'บันทึกและส่งทั้งหมด (${_selectedFiles.length})',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
