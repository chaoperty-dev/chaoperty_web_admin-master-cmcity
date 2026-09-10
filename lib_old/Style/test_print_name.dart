import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constant/Myconstant.dart';
import '../Constant/api_cache.dart';
import '../Model/GetZone_Model.dart';

class TestPrintNamePage extends StatefulWidget {
  const TestPrintNamePage({super.key});

  @override
  State<TestPrintNamePage> createState() => _TestPrintNamePageState();
}

class SheetRowData {
  final String originalFileName;
  final String zone;
  final String lock;
  final String book;
  final String number;
  final String date;
  final String amount;
  final String suggestedName;
  final String imageUrl;

  String? uuid;
  bool isMatched;
  bool isHaveAttachment;
  bool isSelected;
  String? serverLn;

  SheetRowData({
    required this.originalFileName,
    required this.zone,
    required this.lock,
    required this.book,
    required this.number,
    required this.date,
    required this.amount,
    required this.suggestedName,
    required this.imageUrl,
    this.uuid,
    this.isMatched = false,
    this.isHaveAttachment = false,
    this.isSelected = true,
    this.serverLn,
  });
}

class _TestPrintNamePageState extends State<TestPrintNamePage>
    with SingleTickerProviderStateMixin {
  static final _apiCache = ApiCache(ttl: const Duration(seconds: 60));

  final TextEditingController _sheetUrlController = TextEditingController(
    text:
        'https://docs.google.com/spreadsheets/d/1h9A95Dykr9YnZOpk7jfuYrnQ8krfWjxIbRA-UxCCbz0/edit?gid=1656047005#gid=1656047005',
  );
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  bool _isLoading = false;
  bool _selectAll = true;
  List<ZoneModel> zoneModels = [];
  List attach_pay2Models = [];
  List<SheetRowData> _sheetData = [];
  List<String> _activityLogs = [];
  String? zone_ser;
  String? zone_name_display;
  String? selectedDocTypeId = '8';
  String? selectedDocTypeName = 'หลักฐานการชำระ';
  String _searchQuery = '';
  String _selectedMatchCriteria = 'ล็อค';
  final List<String> _matchOptions = [
    'ล็อค',
    'เล่มที่',
    'เลขที่',
    'จับคู่ทั้งหมด (ล็อค+เล่ม+เลข)'
  ];

  final List<Map<String, String>> _docTypes = [
    {'id': '1', 'name': 'รูปถ่าย'},
    {'id': '2', 'name': 'รูปถ่ายคู่กับร้านค้าและสินค้า'},
    {'id': '3', 'name': 'ใบรับรองแพทย์'},
    {'id': '4', 'name': 'ใบอนุญาติจำหน่ายสินค้า'},
    {'id': '5', 'name': 'บัตรประจำตัวผู้ค้า'},
    {'id': '6', 'name': 'ใบรับรองการผ่านการอบรม'},
    {'id': '7', 'name': 'เอกสารแนบอื่น ๆ'},
    {'id': '8', 'name': 'หลักฐานการชำระ'},
    {'id': '9', 'name': 'รูลายเซ็นผู้ขอ'},
    {'id': '12', 'name': 'เอกสารแนบอื่น ๆ'},
    {'id': '13', 'name': 'เอกสารแนบ คำขอต่อใบอนุญาต'},
    {'id': '14', 'name': 'เอกสารแนบ คำขอเปลี่ยนประเภทสินค้า'},
    {'id': '15', 'name': 'เอกสารแนบ ทะเบียนบ้าน'},
    {'id': '16', 'name': 'เอกสารแนบ หนังสือมอบอำนาจ'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    _addLog('ระบบพร้อมใช้งาน...');
    try {
      await read_GC_zone();
      _addLog('โหลดโซนเสร็จสิ้น');
    } catch (e) {
      _addLog('Error โหลดโซน: $e');
    }

    try {
      await _fetchSheetData();
    } catch (e) {
      _addLog('Error โหลด Sheet: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sheetUrlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _activityLogs.insert(
          0, '[${DateTime.now().toString().substring(11, 19)}] $msg');
      if (_activityLogs.length > 200) _activityLogs.removeLast();
    });
  }

  Future<void> read_GC_zone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'read_GC_zone_$ren';

    void updateZoneList(List data) {
      if (!mounted) return;
      setState(() {
        zoneModels = [
          // ZoneModel.fromJson({'ser': '0', 'zn': 'ทั้งหมด'}),
          ...data.map((e) => ZoneModel.fromJson(e))
        ];
        zoneModels.sort((a, b) => (a.zn ?? "").compareTo(b.zn ?? ""));

        // Default to the first zone if none is selected
        if (zoneModels.isNotEmpty && (zone_ser == null || zone_ser == '0')) {
          zone_ser = zoneModels[0].ser;
          zone_name_display = zoneModels[0].zn;
          read_attach_pay2(); // Automatically fetch data for the default zone
        }
      });
    }

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        updateZoneList(cachedData);
        return;
      }
    }

    try {
      final response = await http.get(
          Uri.parse('${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren'));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result != null && result is List) {
          _apiCache.set(cacheKey, result);
          updateZoneList(result);
        }
      }
    } catch (e) {
      _addLog('Error Zone: $e');
    }
  }

  Future<void> read_attach_pay2() async {
    _addLog('ดึงข้อมูล Server...');
    String url =
        'https://chaoperties.com/chao_api/@test_attachment/attach_pay2/run.php';
    try {
      int zserValue = (zone_ser == '0' || zone_ser == null)
          ? 0
          : int.tryParse(zone_ser!) ?? 0;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'zser': zserValue,
          'docId': int.tryParse(selectedDocTypeId ?? '8') ?? 8
        }),
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is Map<String, dynamic> && result.containsKey('data')) {
          print('attach_pay2 data: ${result['data']}');
          setState(() {
            attach_pay2Models = result['data'];
          });
          _addLog('โหลด Server สำเร็จ: ${attach_pay2Models.length} รายการ');
          _matchSheetData();
        }
      }
    } catch (e) {
      _addLog('Error Fetch: $e');
    }
  }

  String _convertToCsvExportUrl(String url) {
    if (url.isEmpty) return url;
    _addLog('ตรวจสอบ URL: $url');

    // Extract Spreadsheet ID
    final idMatch = RegExp(r'/d/([^/]+)').firstMatch(url);
    if (idMatch == null) {
      _addLog('ไม่พบ Spreadsheet ID ใน URL');
      return url;
    }
    final sheetId = idMatch.group(1);

    // Extract gid (tab ID) - defaults to 0
    String gid = '0';
    final gidMatch = RegExp(r'[#?&]gid=(\d+)').firstMatch(url);
    if (gidMatch != null) {
      gid = gidMatch.group(1)!;
    }

    final exportUrl =
        'https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv&gid=$gid&t=${DateTime.now().millisecondsSinceEpoch}';
    _addLog('แปลงเป็น CSV URL สำเร็จ');
    return exportUrl;
  }

  Future<void> _fetchSheetData() async {
    final rawUrl = _sheetUrlController.text.trim();
    if (rawUrl.isEmpty) {
      _addLog('URL ว่างเปล่า - เคลียร์ข้อมูล');
      setState(() {
        _sheetData = [];
        _isLoading = false;
      });
      return;
    }

    // แปลง URL เป็น CSV export URL
    final url = _convertToCsvExportUrl(rawUrl);
    _addLog('ใช้ URL: $url');

    setState(() {
      _isLoading = true;
      _sheetData = []; // เคลียร์ข้อมูลเดิมออกก่อน
    });
    _addLog('ดาวน์โหลด Sheets...');
    try {
      final response = await http.get(Uri.parse(url));
      _addLog('Response status: ${response.statusCode}');
      _addLog('Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        // ตรวจสอบว่าเป็น HTML หรือไม่
        final contentType =
            response.headers['content-type']?.toLowerCase() ?? '';
        if (contentType.contains('html')) {
          _addLog(
              'ข้อผิดพลาด: ได้รับ HTML แทน CSV - Sheet อาจไม่ได้ตั้งค่าเป็นสาธารณะ');
          setState(() => _isLoading = false);
          return;
        }

        final csvString = utf8.decode(response.bodyBytes);
        _addLog('ได้รับข้อมูล ${csvString.length} ตัวอักษร');

        // ตรวจสอบว่าข้อมูลว่างเปล่าหรือไม่
        if (csvString.trim().isEmpty) {
          _addLog('ข้อผิดพลาด: ไฟล์ CSV ว่างเปล่า');
          setState(() => _isLoading = false);
          return;
        }

        final List<List<dynamic>> rows = const CsvToListConverter(
                shouldParseNumbers: false, allowInvalid: true)
            .convert(csvString);

        _addLog('แปลง CSV ได้ ${rows.length} แถว');

        final List<SheetRowData> data = [];
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty || row[0].toString().trim().isEmpty) continue;

          String imgUrl = '';
          if (row.length > 8) {
            final rawUrl = row[8].toString();
            final match = RegExp(r'\((.*?)\)').firstMatch(rawUrl);
            imgUrl = match != null ? (match.group(1) ?? '') : rawUrl;
          }

          data.add(SheetRowData(
            originalFileName: row[0].toString(),
            zone: row.length > 1 ? row[1].toString() : '',
            lock: row.length > 2 ? row[2].toString() : '',
            book: row.length > 3 ? row[3].toString() : '',
            number: row.length > 4 ? row[4].toString() : '',
            date: row.length > 5 ? row[5].toString() : '',
            amount: row.length > 6 ? row[6].toString() : '',
            suggestedName: row.length > 7 ? row[7].toString() : '',
            imageUrl: imgUrl,
          ));
        }

        _addLog('สร้างข้อมูลสำเร็จ: ${data.length} รายการ');

        setState(() {
          _sheetData = data;
          _isLoading = false;
        });
        await read_attach_pay2();
      } else {
        _addLog('ข้อผิดพลาด: HTTP ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      _addLog('Error Sheets: $e');
      _addLog('Stack: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  void _matchSheetData() {
    if (_sheetData.isEmpty || attach_pay2Models.isEmpty) return;
    int matches = 0;
    setState(() {
      for (var row in _sheetData) {
        row.isMatched = false;
        row.uuid = null;
        for (var m in attach_pay2Models) {
          String mBook = (m['book'] ?? "").toString().trim();
          String mNum = (m['no'] ?? "").toString().trim();
          String mLnRaw = (m['ln'] ?? "").toString().trim();
          String mLn = mLnRaw.replaceAll(RegExp(r'\s+'), '');

          bool isMatched = false;

          if (_selectedMatchCriteria == 'ล็อค') {
            String lockClean = row.lock.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
            String mLnClean = mLnRaw.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
            isMatched = lockClean.isNotEmpty && lockClean == mLnClean;
          } else if (_selectedMatchCriteria == 'เล่มที่') {
            isMatched = row.book.isNotEmpty &&
                mBook.isNotEmpty &&
                row.book.trim() == mBook;
          } else if (_selectedMatchCriteria == 'เลขที่') {
            isMatched = row.number.isNotEmpty &&
                mNum.isNotEmpty &&
                row.number.trim() == mNum;
          } else {
            // จับคู่ทั้งหมด
            bool bookMatch = row.book.isEmpty || row.book.trim() == mBook;
            bool numMatch = row.number.isEmpty || row.number.trim() == mNum;

            String lockClean = row.lock.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
            String mLnClean = mLnRaw.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
            bool lockMatch = lockClean.isNotEmpty && lockClean == mLnClean;

            isMatched = bookMatch && numMatch && lockMatch;
          }

          if (isMatched) {
            row.isMatched = true;
            row.uuid = m['request_uuid']?.toString();
            row.isHaveAttachment = (m['is_have_attachment'] == 1 ||
                m['is_have_attachment'] == "1");
            row.serverLn = mLnRaw;
            matches++;
            break;
          }
        }
      }
    });
    _addLog(
        'จับคู่สำเร็จ: $matches รายการ (เงื่อนไข: $_selectedMatchCriteria)');
  }

  Future<String?> generatedUuid() async {
    String url =
        'https://chaoperties.com/chao_api/@test_attachment/attach_pay2/run.php';
    try {
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body:
              json.encode({"created_by": "tester", "generateAttachSystem": 1}));
      if (response.statusCode == 200)
        return json.decode(response.body)['data']['generated_uuid'];
    } catch (e) {
      _addLog('Error UUID: $e');
    }
    return null;
  }

  Future<void> _uploadFromSheet() async {
    final files = _sheetData.where((f) => f.isMatched && f.isSelected).toList();
    if (files.isEmpty) return;

    String? batchUuid = await generatedUuid();
    if (batchUuid == null) {
      _addLog('ไม่สามารถสร้าง Batch UUID ได้');
      return;
    }

    _showUploadProgressDialog(files, batchUuid);
  }

  void _showUploadProgressDialog(List<SheetRowData> files, String batchUuid) {
    int total = files.length;
    int successCount = 0;
    int errorCount = 0;
    int currentIndex = 0;
    bool isFinished = false;
    bool isCancelled = false;
    String lastError = '';
    String currentFileLabel = '';
    final List<String> uploadLogs = [];
    bool started = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          // Start upload queue on first build
          if (!started) {
            started = true;
            Future.delayed(Duration.zero, () async {
              final token = await MyToken.accessToken;
              for (int i = 0; i < total; i++) {
                if (!mounted || isFinished || isCancelled) break;

                currentIndex = i;
                final f = files[i];

                setDialogState(() {
                  currentFileLabel =
                      'ล็อค: ${f.lock} | ไฟล์: ${f.originalFileName}';
                });

                // Log request body to Logs tab
                final requestBody = {
                  "uuid": "$batchUuid",
                  "filePath": "${f.imageUrl}",
                  "docId": int.tryParse(selectedDocTypeId ?? '0') ?? 0,
                  "requestUuid": "${f.uuid}",
                  // "created_by": "tester",
                  "token": "${token}"
                };
                _addLog(
                    '📤 อัพโหลด: ${f.lock} | Body: ${json.encode(requestBody)}');
                debugPrint('========== REQUEST BODY ==========');
                debugPrint(json.encode(requestBody));
                debugPrint('===================================');
                try {
                  final res = await http.post(
                    Uri.parse(
                        'https://chaoperties.com/chao_api/@test_attachment/attach_pay2/run.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(requestBody),
                  );

                  if (mounted) {
                    setDialogState(() {
                      if (res.statusCode == 200) {
                        final result = json.decode(res.body);
                        if (result['success'] == true) {
                          successCount++;
                          uploadLogs.insert(0, '✅ ล็อค: ${f.lock} | สำเร็จ');
                        } else {
                          errorCount++;
                          lastError =
                              result['message'] ?? 'API fail ${res.statusCode}';
                          uploadLogs.insert(
                              0, '❌ ล็อค: ${f.lock} | ล้มเหลว: $lastError');
                        }
                      } else {
                        errorCount++;
                        lastError = 'HTTP ${res.statusCode}';
                        uploadLogs.insert(0,
                            '❌ ล็อค: ${f.lock} | HTTP Error: ${res.statusCode}');
                      }
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    setDialogState(() {
                      errorCount++;
                      lastError = e.toString();
                      uploadLogs.insert(0, '⚠️ ล็อค: ${f.lock} | Error: $e');
                    });
                  }
                }
              }

              if (mounted) {
                setDialogState(() {
                  isFinished = true;
                  currentIndex = total;
                });
              }
            });
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isFinished
                  ? 'อัพโหลดเสร็จสิ้น'
                  : (isCancelled
                      ? 'หยุดการทำงานแล้ว'
                      : 'กำลังอัพโหลดข้อมูล...'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCancelled ? Colors.red[900] : Colors.blueGrey[900],
              ),
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentFileLabel.isNotEmpty &&
                      !isFinished &&
                      !isCancelled) ...[
                    Text(
                      'กำลังดำเนินการ: $currentFileLabel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total > 0 ? currentIndex / total : 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFinished ? Colors.green : Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'คิวอัพโหลด: ${(currentIndex < total ? currentIndex + 1 : total)} จาก $total รายการ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Status Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard('สำเร็จ', '$successCount',
                            Colors.green, Icons.check_circle_outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard('ล้มเหลว', '$errorCount',
                            Colors.red, Icons.error_outline),
                      ),
                    ],
                  ),

                  if (lastError.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            'ข้อผิดพลาดล่าสุด: $lastError',
                            style:
                                TextStyle(color: Colors.red[900], fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ประวัติ 5 รายการล่าสุด',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                      if (uploadLogs.isNotEmpty)
                        Text(
                          'จากทั้งหมด ${uploadLogs.length} รายการ',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Log Console Box
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: uploadLogs.length > 5 ? 5 : uploadLogs.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[100]),
                      itemBuilder: (ctx, idx) {
                        final logEntry = uploadLogs[idx];
                        final isError =
                            logEntry.contains('❌') || logEntry.contains('⚠️');
                        return InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: logEntry));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'คัดลอกแล้ว: ${logEntry.length > 30 ? logEntry.substring(0, 30) + '...' : logEntry}'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: isError
                                    ? Colors.red[700]
                                    : Colors.green[700],
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isError ? Icons.error : Icons.check_circle,
                                  size: 12,
                                  color: isError
                                      ? Colors.red[300]
                                      : Colors.green[300],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    logEntry,
                                    style: TextStyle(
                                      color: isError
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                // Icon(
                                //   Icons.copy_rounded,
                                //   size: 14,
                                //   color: Colors.grey[400],
                                // ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (!isFinished && !isCancelled)
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      isCancelled = true;
                    });
                  },
                  child: Text('หยุดการทำงาน',
                      style: TextStyle(color: Colors.red[700])),
                ),
              if (isFinished || isCancelled)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCancelled ? Colors.grey[700] : Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    read_attach_pay2();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('ตกลง'),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildStatusCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCompactSetupConfig(),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue[800],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[800],
              tabs: const [
                Tab(text: 'ทั้งหมด'),
                Tab(text: 'จับคู่ผล'),
                Tab(text: 'พบเอกสารเก่า'),
                Tab(text: 'ไม่พบ'),
                Tab(text: 'Logs')
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('รีเฟรชข้อมูลคำขอ'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12)),
                      onPressed: _isLoading
                          ? null
                          : () {
                              _addLog('กดปุ่มรีเฟรชข้อมูลคำขอ');
                              read_attach_pay2();
                            },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_download, size: 16),
                      label: const Text('ดึงข้อมูล Sheet ใหม่'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12)),
                      onPressed: _isLoading ? null : () => _fetchSheetData(),
                    ),
                  ],
                ),
                SizedBox(
                  width: 250,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาข้อมูล...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTableHeader(),
          Expanded(child: _buildBodyTabs()),
          _buildBottomActionRow(),
        ],
      ),
    );
  }

  Widget _buildCompactSetupConfig() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(zone_name_display ?? 'เลือกโซน'),
                    value: zone_ser,
                    items: zoneModels
                        .map((z) => DropdownMenuItem(
                              value: z.ser,
                              child: Text(z.zn ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          zone_ser = v;
                          zone_name_display =
                              zoneModels.firstWhere((z) => z.ser == v).zn;
                        });
                        read_attach_pay2();
                      }
                    },
                    buttonHeight: 40,
                    buttonDecoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(selectedDocTypeName ?? 'ประเภทเอกสาร'),
                    value: selectedDocTypeId,
                    items: _docTypes
                        .map((d) => DropdownMenuItem(
                              value: d['id'],
                              child: Text(d['name']!),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          selectedDocTypeId = v;
                          selectedDocTypeName =
                              _docTypes.firstWhere((e) => e['id'] == v)['name'];
                        });
                        read_attach_pay2();
                      }
                    },
                    buttonHeight: 40,
                    buttonDecoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _sheetUrlController,
                    decoration: InputDecoration(
                      labelText: 'Google Sheet CSV URL',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.download, size: 20),
                          onPressed: _fetchSheetData),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: _selectedMatchCriteria,
                      items: _matchOptions
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMatchCriteria = value;
                          });
                          _matchSheetData();
                        }
                      },
                      buttonHeight: 40,
                      buttonDecoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAiPromptBanner(),
        ],
      ),
    );
  }

  void _showAiPromptDialog() {
    final List<String> lines = [
      'สร้างตารางใน Google Sheets โดยมีคอลัมน์ดังนี้:',
      '',
      '1. ชื่อไฟล์เดิม',
      '2. โซน (ถ้าไม่สามารถอ่านได้ให้ใส่ "-")',
      '3. ล็อค (ถ้าไม่สามารถอ่านได้ให้ใส่ "-")',
      '4. เล่มที่ (ถ้าไม่สามารถอ่านได้ให้ใส่ "-")',
      '5. เลขที่ (ถ้าไม่สามารถอ่านได้ให้ใส่ "-")',
      '6. วันที่ในใบเสร็จ (YYYY-MM-DD เช่น 2026-03-25 ถ้าอ่านไม่ได้ใช้ "0000-00-00")',
      '7. จำนวนเงิน (ถ้าอ่านไม่ได้ใช้ "0.00")',
      '8. ข้อเสนอแนะชื่อไฟล์ใหม่',
      '   - "โซน 2 ล็อค 348.jpg" → "ล็อค 348"',
      '   - มีข้อมูลบางส่วน → ใช้เท่าที่อ่านได้',
      '   - อ่านไม่ได้ → "-"',
      '9. URL image (ถ้าไม่มีให้เว้นว่าง)',
      '',
      'เงื่อนไขเพิ่มเติม:',
      '- ทุกช่องต้องมีค่า (ยกเว้น URL)',
      '- ใช้ "-" สำหรับข้อมูลที่อ่านไม่ได้',
      '- ตารางต้องพร้อมใช้ใน Google Sheets 10 รายการแรก ',
      '- หัวข้อ URL image ข้อมูลเป็นแบบ https://drive.google.com/file/d/1OKFnEjCXEy9BiiMJOzsoFyCXhDmLlHGP/view'
    ];

    final promptText = lines.join('\n');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Prompt Example'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: const TextStyle(height: 1.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: promptText));
              Navigator.pop(ctx);
            },
            child: const Text('คัดลอก'),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPromptBanner() {
    return InkWell(
      onTap: _showAiPromptDialog,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ดูตัวอย่าง AI Prompt สำหรับดึงข้อมูล (คลิกเพื่อคัดลอก/อ่านเงื่อนไข)',
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.purple, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Checkbox(
                  value: _selectAll,
                  onChanged: (v) {
                    setState(() {
                      _selectAll = v!;
                      for (var f in _sheetData) f.isSelected = v;
                    });
                  })),
          const Expanded(
              flex: 3,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('ชื่อไฟล์เดิม',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('โซน',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('ล็อค',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('จับคู่ล็อคในระบบ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blue)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('เล่มที่',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('เลขที่',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 2,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('วันที่ในใบเสร็จ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('จำนวนเงิน',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 3,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('ข้อเสนอแนะใหม่',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('เอกสารเก่า',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text('สถานะ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
          const SizedBox(
              width: 40,
              child: Text('รูป',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBodyTabs() => TabBarView(
        controller: _tabController,
        children: [
          _sheetList(_sheetData),
          _sheetList(_sheetData.where((f) => f.isMatched).toList()),
          _sheetList(_sheetData.where((f) => f.isHaveAttachment).toList()),
          _sheetList(_sheetData
              .where((f) => !f.isMatched && _sheetData.isNotEmpty)
              .toList()),
          ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _activityLogs.length,
              itemBuilder: (c, i) => Text(_activityLogs[i],
                  style:
                      const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      );

  Widget _sheetList(List<SheetRowData> items) {
    final filtered = items
        .where((f) =>
            f.originalFileName.toLowerCase().contains(_searchQuery) ||
            f.lock.contains(_searchQuery))
        .toList();
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.black12),
      itemBuilder: (context, index) {
        final f = filtered[index];
        return Container(
          color: f.isMatched ? Colors.green[50] : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                  width: 40,
                  child: Checkbox(
                      value: f.isSelected,
                      onChanged: (v) => setState(() => f.isSelected = v!))),
              Expanded(
                flex: 3,
                child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(f.originalFileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13))),
              ),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.zone.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.lock.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.serverLn ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: f.serverLn != null && f.serverLn != f.lock
                                  ? Colors.red
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.book.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.number.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))),
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.date.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.amount.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700])))),
              Expanded(
                  flex: 3,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.suggestedName.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.green)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.isHaveAttachment ? 'มี' : '-',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: f.isHaveAttachment
                                  ? Colors.orange
                                  : Colors.grey)))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(f.isMatched ? 'พบเอกสาร' : 'ไม่พบเอกสาร',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  f.isMatched ? Colors.green : Colors.red)))),
              SizedBox(
                  width: 40,
                  child: IconButton(
                      icon:
                          const Icon(Icons.image, size: 20, color: Colors.blue),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => launchUrl(Uri.parse(f.imageUrl)))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionRow() {
    final sel = _sheetData.where((f) => f.isMatched && f.isSelected).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('รายการพร้อมอัพโหลด: $sel',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: sel > 0 && !_isLoading ? _uploadFromSheet : null,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('เริ่ม Batch Upload'),
          )
        ],
      ),
    );
  }
}
