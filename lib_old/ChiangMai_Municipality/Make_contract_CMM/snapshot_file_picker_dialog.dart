import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Constant/Myconstant.dart';
import '../unity/API-Admin-Request-Snapshots/Models/snapshot_attachment_model.dart';
import '../unity/API-Admin-Request-Snapshots/API-Snapshot-Attachments.dart';
import '../unity/API-Admin-Request-Snapshots/API-List-Snapshots.dart';
import '../unity/API-Admin-Request-Snapshots/Models/snapshot_list_model.dart';

/// Dialog สำหรับเลือกไฟล์จาก Snapshot Attachments
///
/// แสดงรายการ snapshots ของ client และให้เลือกไฟล์ attachments
class SnapshotFilePickerDialog extends StatefulWidget {
  final String clientsUuid;
  final String title;

  const SnapshotFilePickerDialog({
    Key? key,
    required this.clientsUuid,
    this.title = 'เลือกไฟล์จากระบบ',
  }) : super(key: key);

  @override
  State<SnapshotFilePickerDialog> createState() =>
      _SnapshotFilePickerDialogState();
}

class _SnapshotFilePickerDialogState extends State<SnapshotFilePickerDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  List<SnapshotListItemModel> _snapshots = [];
  List<SnapshotAttachmentModel> _attachments = [];
  SnapshotListItemModel? _selectedSnapshot;
  List<SnapshotAttachmentModel> _selectedAttachments = [];

  @override
  void initState() {
    super.initState();
    _loadSnapshots();
  }

  /// โหลดรายการ snapshots ของ client
  Future<void> _loadSnapshots() async {
    print(
        '[SnapshotFilePicker] 🔄 เริ่มโหลด snapshots สำหรับ clientsUuid: ${widget.clientsUuid}');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshots =
          await APIListSnapshots.getSnapshotsList(widget.clientsUuid);
      print(
          '[SnapshotFilePicker] ✅ โหลด snapshots เสร็จสิ้น: ${snapshots.length} รายการ');
      setState(() {
        _snapshots = snapshots;
        _isLoading = false;
      });
    } catch (e) {
      print('[SnapshotFilePicker] ❌ Error loading snapshots: $e');
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดข้อมูล snapshots ได้: $e';
        _isLoading = false;
      });
    }
  }

  /// โหลด attachments ของ snapshot ที่เลือก
  Future<void> _loadAttachments(String snapshotUuid) async {
    print(
        '[SnapshotFilePicker] 🔄 เริ่มโหลด attachments สำหรับ snapshotUuid: $snapshotUuid');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attachments =
          await APISnapshotAttachments.getAttachmentsList(snapshotUuid);
      print(
          '[SnapshotFilePicker] ✅ โหลด attachments เสร็จสิ้น: ${attachments.length} รายการ');
      setState(() {
        _attachments = attachments;
        _isLoading = false;
      });
    } catch (e) {
      print('[SnapshotFilePicker] ❌ Error loading attachments: $e');
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดข้อมูลไฟล์แนบได้: $e';
        _isLoading = false;
      });
    }
  }

  /// สร้าง URL สำหรับ preview ไฟล์
  /// ใช้ API endpoint: /api/request-snapshot-attachments/{uuid}/preview
  String _buildFileUrl(String attachmentUuid) {
    if (attachmentUuid.isEmpty) return '';
    // URL: https://cmr.chaoperties.com/api/request-snapshot-attachments/{uuid}/preview
    final url =
        'https://cmr.chaoperties.com/api/request-snapshot-attachments/$attachmentUuid/preview';
    print('[SnapshotFilePicker] 🔗 Generated URL: $url');
    return url;
  }

  /// ดึงภาพ preview พร้อม Basic Auth
  Future<Uint8List?> _fetchImageWithAuth(String url) async {
    try {
      print('[SnapshotFilePicker] 📥 Fetching image from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'authorization':
              'Basic Y2hpYW5nbWFpbXVuaWNpcGFsaXR5OmNoYW9wZXJ0eTEyMzQ=',
        },
      );
      print('[SnapshotFilePicker] 📤 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print(
            '[SnapshotFilePicker] ✅ Image loaded successfully, size: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      }
      print(
          '[SnapshotFilePicker] ❌ Failed to load image: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[SnapshotFilePicker] ❌ Error fetching image: $e');
      return null;
    }
  }

  /// ตรวจสอบว่าเป็นรูปภาพหรือไม่
  bool _isImage(String fileType) {
    return fileType.startsWith('image/');
  }

  /// แสดง preview ไฟล์
  Widget _buildFilePreview(SnapshotAttachmentModel attachment) {
    if (_isImage(attachment.fileType ?? '')) {
      // ใช้ attachment.uuid แทนการ parse จาก filePath
      final url = _buildFileUrl(attachment.uuid ?? '');
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<Uint8List?>(
          future: _fetchImageWithAuth(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              );
            }
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      );
    }

    // ไฟล์อื่นๆ แสดงเป็น icon
    IconData iconData = Icons.insert_drive_file;
    Color iconColor = Colors.grey;

    if (attachment.fileType == 'application/pdf') {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Icon(iconData, color: iconColor, size: 32),
    );
  }

  /// แสดงขนาดไฟล์ในรูปแบบที่อ่านง่าย
  String _formatFileSize(int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// แปลงวันที่ ISO 8601 เป็นรูปแบบไทยที่อ่านง่าย
  String? _formatThaiDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final formatter = DateFormat('d MMM yyyy HH:mm', 'th');
      return formatter.format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.purple.shade200, width: 1.5),
        ),
        elevation: 24,
        shadowColor: Colors.black.withOpacity(0.5),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade700, Colors.purple.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.folder_open,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_selectedSnapshot != null)
                              Text(
                                'Snapshot v${_selectedSnapshot!.snapshotVersion}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purple.shade500),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'กำลังโหลดข้อมูล...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade300, size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _loadSnapshots,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('ลองใหม่'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade400,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _selectedSnapshot == null
                              ? _buildSnapshotList()
                              : _buildAttachmentList(),
                ),

                // Footer
                if (_selectedSnapshot != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedSnapshot = null;
                              _attachments = [];
                              _selectedAttachments = [];
                            });
                          },
                          icon: Icon(Icons.arrow_back,
                              color: Colors.purple.shade600),
                          label: Text(
                            'กลับ',
                            style: TextStyle(
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            'เลือก ${_selectedAttachments.length} ไฟล์',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _selectedAttachments.isEmpty
                              ? null
                              : () => Navigator.of(context)
                                  .pop(_selectedAttachments),
                          icon: const Icon(Icons.check),
                          label: const Text('ตกลง'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade400,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ));
  }

  /// แสดงรายการ snapshots
  Widget _buildSnapshotList() {
    if (_snapshots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'ไม่พบข้อมูล snapshots',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _snapshots.length,
      itemBuilder: (context, index) {
        final snapshot = _snapshots[index];
        return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSnapshot = snapshot;
                    });
                    _loadAttachments(snapshot.uuid!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade400,
                                Colors.purple.shade700,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${snapshot.snapshotVersion ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text(
                                  'เวอร์ชัน',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatThaiDate(snapshot.createdAt) ??
                                    _formatThaiDate(snapshot.sourceCreatedAt) ??
                                    'ไม่ระบุวันที่',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatThaiDate(snapshot.createdAt) ??
                                        _formatThaiDate(
                                            snapshot.sourceCreatedAt) ??
                                        'ไม่ระบุวันที่',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      snapshot.client?.cname ?? 'ไม่ระบุชื่อ',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.attach_file,
                                      size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${snapshot.attachmentsCount ?? 0} ไฟล์แนบ',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          _getStatusColor(snapshot.sourceStatus)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      snapshot.sourceStatus ?? 'ไม่ระบุ',
                                      style: TextStyle(
                                        color: _getStatusColor(
                                            snapshot.sourceStatus),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// แสดงรายการ attachments แบบ Grid 2 รายการต่อแถว
  Widget _buildAttachmentList() {
    if (_attachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'ไม่พบไฟล์แนบใน snapshot นี้',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 รายการต่อแถว
        childAspectRatio: 0.75, // ปรับอัตราส่วนเพื่อให้การ์ดสูงขึ้น
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final attachment = _attachments[index];
        final isSelected = _selectedAttachments.contains(attachment);

        return _buildAttachmentCard(attachment, isSelected);
      },
    );
  }

  Widget _buildAttachmentCard(
      SnapshotAttachmentModel attachment, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.deepPurple.shade200.withOpacity(0.5)
                : Colors.grey.shade200.withOpacity(0.5),
            blurRadius: isSelected ? 8 : 4,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedAttachments.remove(attachment);
                } else {
                  _selectedAttachments.add(attachment);
                }
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildAttachmentImage(attachment),
                      // Gradient overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Selected indicator (top-right)
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade400,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),

                      // Zoom button (top-right if not selected)
                      if (!isSelected && _isImage(attachment.fileType ?? ''))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final bytes = await _fetchImageWithAuth(
                                _buildFileUrl(attachment.uuid ?? ''),
                              );
                              if (bytes != null && context.mounted) {
                                _showImagePreview(context, bytes);
                              }
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                      // File type badge (bottom-left)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFileIcon(attachment.fileType),
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getFileTypeLabel(attachment.fileType),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info area
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: isSelected
                        ? Colors.deepPurple.shade50
                        : Colors.grey.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // File name
                        Text(
                          attachment.fileName ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),

                        // Size and checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.data_usage_outlined,
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatFileSize(attachment.fileSize),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            // Simplified Checkbox
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple.shade400
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple.shade400
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentImage(SnapshotAttachmentModel attachment) {
    if (_isImage(attachment.fileType ?? '')) {
      return FutureBuilder<Uint8List?>(
        future: _fetchImageWithAuth(
          _buildFileUrl(attachment.uuid ?? ''),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return GestureDetector(
              onTap: () => _showImagePreview(context, snapshot.data!),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
          );
        },
      );
    }

    // Non-image file
    return Container(
      color: _getFileTypeColor(attachment.fileType).withOpacity(0.08),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getFileTypeColor(attachment.fileType).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getFileIcon(attachment.fileType),
                color: _getFileTypeColor(attachment.fileType),
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFileTypeLabel(attachment.fileType),
              style: TextStyle(
                color: _getFileTypeColor(attachment.fileType),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// แสดงรูปภาพแบบเต็มจอ
  void _showImagePreview(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),

            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    if (fileType.startsWith('image/')) return Icons.image;
    if (fileType == 'application/pdf') return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  String _getFileTypeLabel(String? fileType) {
    if (fileType == null) return 'ไฟล์';
    if (fileType.startsWith('image/')) return 'รูปภาพ';
    if (fileType == 'application/pdf') return 'PDF';
    return 'ไฟล์';
  }

  Color _getFileTypeColor(String? fileType) {
    if (fileType == null) return Colors.grey;
    if (fileType.startsWith('image/')) return Colors.blue;
    if (fileType == 'application/pdf') return Colors.red;
    return Colors.grey;
  }
}

/// Extension method สำหรับแสดง dialog
extension SnapshotFilePickerDialogExtension on BuildContext {
  Future<List<SnapshotAttachmentModel>?> showSnapshotFilePicker({
    required String clientsUuid,
    String title = 'เลือกไฟล์จากระบบ',
  }) async {
    return showDialog<List<SnapshotAttachmentModel>>(
      context: this,
      builder: (context) => SnapshotFilePickerDialog(
        clientsUuid: clientsUuid,
        title: title,
      ),
    );
  }
}
