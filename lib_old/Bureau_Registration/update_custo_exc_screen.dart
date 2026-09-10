// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison
import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import '../Constant/Myconstant.dart';
import '../Model/GetCustomer_Model.dart';
import '../Style/colors.dart';

class _SheetRow {
  final String idCard;
  final String newValue;
  CustomerModel? matched;
  bool selected;
  String status;

  _SheetRow({
    required this.idCard,
    required this.newValue,
    this.matched,
    this.selected = true,
    this.status = 'idle',
  });
}

class UpdateCustoExcScreen extends StatefulWidget {
  final List<CustomerModel> customerList;
  const UpdateCustoExcScreen({super.key, required this.customerList});

  @override
  State<UpdateCustoExcScreen> createState() => _UpdateCustoExcScreenState();
}

class _UpdateCustoExcScreenState extends State<UpdateCustoExcScreen> {
  final _pasteCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  List<_SheetRow> _rows = [];
  bool _isUpdating = false;
  bool _isFetching = false;
  bool _cancelRequested = false;
  int _doneCount = 0;
  bool _selectAll = true;
  String? _sourceFileName;
  String? _fetchError;
  String _selectedField = 'birth';

  static const _fieldOptions = <String, String>{
    'birth': 'วันเกิด',
    'tel': 'เบอร์โทร',
    'email': 'อีเมล',
    'address': 'ที่อยู่',
    'nameshop': 'ชื่อ',
    'typeshop': 'ประเภทร้าน',
    'bussshop': 'ประเภทธุรกิจ',
    'type': 'ประเภทลูกค้า',
    'religion': 'ศาสนา',
    'national': 'สัญชาติ',
  };

  String _currentVal(CustomerModel c) {
    switch (_selectedField) {
      case 'birth':
        return c.birth ?? '-';
      case 'tel':
        return c.tel ?? '-';
      case 'email':
        return c.email ?? '-';
      case 'address':
        return c.addr1 ?? '-';
      case 'nameshop':
        return c.cname ?? '-';
      case 'typeshop':
        return c.stype ?? '-';
      case 'bussshop':
        return c.scname ?? '-';
      case 'type':
        return c.type ?? '-';
      case 'religion':
        return c.religion ?? '-';
      case 'national':
        return c.national ?? '-';
      default:
        return '-';
    }
  }

  static Color _accent = AppBarColors.hexColor; //Color(0xFF546E7A);
  Color get tc => _accent;
  Color get tcLight => Colors.white;
  Color get tcBorder => Colors.grey.shade300;

  @override
  void dispose() {
    _pasteCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  // ─── build lookup: tax → CustomerModel ───────────────────────────────────
  Map<String, CustomerModel> _buildLookup() {
    final lookup = <String, CustomerModel>{};
    for (final c in widget.customerList) {
      final t = (c.tax ?? '').trim().replaceAll('-', '').replaceAll(' ', '');
      if (t.isNotEmpty) lookup[t] = c;
    }
    return lookup;
  }

  // ─── parse rows from (idCard, newValue) pairs ────────────────────────────
  void _applyPairs(List<(String, String)> pairs, {String? fileName}) {
    final lookup = _buildLookup();
    final result = <_SheetRow>[];
    for (final pair in pairs) {
      final idCard = pair.$1;
      final newValue = pair.$2;
      if (idCard.isEmpty || newValue.isEmpty) continue;
      final matched = lookup[idCard];
      result.add(_SheetRow(
        idCard: idCard,
        newValue: newValue,
        matched: matched,
        selected: matched != null,
        status: matched != null ? 'idle' : 'not_found',
      ));
    }
    setState(() {
      _rows = result;
      _doneCount = 0;
      _selectAll = true;
      _sourceFileName = fileName;
    });
  }

  // ─── 1. Parse pasted text (tab-separated from Google Sheets) ─────────────
  void _parseSheet() {
    final text = _pasteCtrl.text.trim();
    if (text.isEmpty) return;

    final pairs = <(String, String)>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final cols = line.split('\t');
      if (cols.length < 3) continue;
      final idCard = cols[1].trim().replaceAll('-', '').replaceAll(' ', '');
      final newValue = cols[2].trim();
      if (idCard == 'เลขบัตรประชาชน' || idCard.length < 10) continue;
      pairs.add((idCard, newValue));
    }
    _applyPairs(pairs, fileName: 'Google Sheets (paste)');
  }

  // ─── 2. Fetch from Google Sheets URL ─────────────────────────────────────
  Future<void> _fetchFromUrl() async {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) return;

    // extract spreadsheet ID
    final idMatch = RegExp(r'/spreadsheets/d/([a-zA-Z0-9_-]+)').firstMatch(raw);
    if (idMatch == null) {
      setState(() => _fetchError = 'ไม่พบ Spreadsheet ID ในลิงก์');
      return;
    }
    final sheetId = idMatch.group(1)!;

    // extract GID (query or fragment)
    String? gid;
    final gidMatch = RegExp(r'gid=(\d+)').firstMatch(raw);
    if (gidMatch != null) gid = gidMatch.group(1);

    final csvUrl = Uri.parse(
      'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq'
      '?tqx=out:csv${gid != null ? '&gid=$gid' : ''}',
    );

    setState(() {
      _isFetching = true;
      _fetchError = null;
    });

    try {
      final resp = await http.get(csvUrl).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        setState(() {
          _fetchError = 'ดึงข้อมูลไม่สำเร็จ (HTTP ${resp.statusCode})\n'
              'ตรวจสอบว่า Sheet ตั้งค่าให้ "ทุกคนที่มีลิงก์ดูได้"';
          _isFetching = false;
        });
        return;
      }

      final pairs = <(String, String)>[];
      final lines = resp.body.split('\n');
      for (int i = 1; i < lines.length; i++) {
        final cols = _parseCsv(lines[i]);
        if (cols.length < 3) continue;
        final idCard = cols[1].replaceAll('-', '').replaceAll(' ', '').trim();
        final newValue = cols[2].trim();
        if (idCard.length < 10 || newValue.isEmpty) continue;
        pairs.add((idCard, newValue));
      }

      _applyPairs(pairs, fileName: 'Google Sheets URL ($sheetId)');
    } catch (e) {
      setState(() => _fetchError = 'ไม่สามารถดึงข้อมูลได้ อาจเกิดจาก CORS\n'
          'ลองใช้วิธี Paste หรืออัพโหลด Excel แทน');
    } finally {
      setState(() => _isFetching = false);
    }
  }

  List<String> _parseCsv(String line) {
    final result = <String>[];
    var inQuotes = false;
    final buf = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        inQuotes = !inQuotes;
      } else if (c == ',' && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    result.add(buf.toString());
    return result;
  }

  // ─── 3. Upload Excel file ─────────────────────────────────────────────────
  Future<void> _pickExcel() async {
    final input = html.FileUploadInputElement();
    input.accept = '.xlsx,.xls';
    input.click();
    await input.onChange.first;

    if (input.files == null || input.files!.isEmpty) return;
    final file = input.files!.first;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;

    final bytes = reader.result as Uint8List;
    final excel = Excel.decodeBytes(bytes);

    // ใช้ sheet แรกที่มีข้อมูล
    Sheet? sheet;
    for (final name in excel.sheets.keys) {
      sheet = excel.sheets[name];
      if (sheet != null && sheet.maxRows > 1) break;
    }
    if (sheet == null) return;

    final pairs = <(String, String)>[];
    for (int r = 1; r < sheet.maxRows; r++) {
      final row = sheet.row(r);
      if (row.length < 3) continue;

      final colB = row[1]?.value?.toString().trim() ?? '';
      final colC = row[2]?.value?.toString().trim() ?? '';

      final idCard = colB.replaceAll('-', '').replaceAll(' ', '');
      final newValue = colC;

      if (idCard.length < 10 || newValue.isEmpty) continue;
      pairs.add((idCard, newValue));
    }

    _applyPairs(pairs, fileName: file.name);
  }

  // ─── Update one customer birth ────────────────────────────────────────────
  Future<bool> _updateField(
      CustomerModel c, String newVal, String ren, String serUser) async {
    final uri = Uri.parse('${MyConstant().domain}/Inc_customer_BureauV2.php')
        .replace(queryParameters: {'isAdd': 'true', 'ren': ren});

    String v(String field, String fallback) =>
        _selectedField == field ? newVal : fallback;

    final body = <String, String>{
      'user': c.ser?.toString() ?? '',
      'nameshop': v('nameshop', c.cname ?? ''),
      'typeshop': v('typeshop', c.stype ?? ''),
      'bussshop': v('bussshop', c.scname ?? ''),
      'bussscontact': v('bussshop', c.scname ?? ''),
      'address': v('address', c.addr1 ?? ''),
      'tel': v('tel', c.tel ?? ''),
      'email': v('email', c.email ?? ''),
      'tax': c.tax ?? '',
      'type': v('type', c.type ?? ''),
      'typeser': c.typeser?.toString() ?? '1',
      'sertap': '0',
      'birth': v('birth', c.birth ?? ''),
      'religion': v('religion', c.religion ?? ''),
      'national': v('national', c.national ?? ''),
      'ser_user': serUser,
    };

    final resp =
        await http.post(uri, body: body).timeout(const Duration(seconds: 20));

    if (resp.statusCode != 200) return false;
    final raw = resp.body.trim();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is bool) return decoded;
      if (decoded is String) return decoded.toLowerCase() == 'true';
      if (decoded is Map) {
        return decoded['ok'] == true || decoded['success'] == true;
      }
      if (decoded is List && decoded.isNotEmpty) return true;
    } catch (_) {
      return raw.toLowerCase() == 'true' ||
          raw.toLowerCase().contains('success');
    }
    return false;
  }

  // ─── Loop update ─────────────────────────────────────────────────────────
  Future<void> _updateAll() async {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
      _cancelRequested = false;
      _doneCount = 0;
    });

    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final serUser = prefs.getString('ser') ?? '';

    for (int i = 0; i < _rows.length; i++) {
      if (_cancelRequested) break;
      final row = _rows[i];
      if (!row.selected || row.matched == null) continue;

      setState(() => _rows[i].status = 'updating');
      try {
        final ok = await _updateField(row.matched!, row.newValue, ren, serUser);
        setState(() {
          _rows[i].status = ok ? 'success' : 'error';
          if (ok) _doneCount++;
        });
      } catch (_) {
        setState(() => _rows[i].status = 'error');
      }
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    setState(() {
      _isUpdating = false;
      _cancelRequested = false;
    });
  }

  // ─── Widget helpers ───────────────────────────────────────────────────────
  Widget _tplCell(String text, {bool header = false, bool highlight = false}) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: header ? FontWeight.bold : FontWeight.normal,
              color: header
                  ? Colors.white
                  : highlight
                      ? tc
                      : Colors.black87,
            ),
          ),
        ),
      );

  Widget _tplDivider() => Container(
        width: 1,
        color: tcBorder,
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('หรือ',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(child: Divider()),
        ]),
      );

  Widget _inputCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required Widget child,
    Color? cardBg,
  }) {
    final bg = cardBg ?? iconColor.withOpacity(0.04);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // thick colored left bar
            Container(width: 7, color: iconColor),
            // card body
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border(
                    top: BorderSide(color: iconColor.withOpacity(0.25)),
                    right: BorderSide(color: iconColor.withOpacity(0.25)),
                    bottom: BorderSide(color: iconColor.withOpacity(0.25)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 18, color: iconColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(label,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: iconColor)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(hint,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text('$label $count',
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      );

  Widget _hdr(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF37474F)));

  Widget _statusChip(String status) {
    final cfg = <String, (String, Color, IconData)>{
          'idle': ('รอ', Colors.grey, Icons.schedule),
          'updating': ('กำลังอัพเดต', Colors.orange, Icons.sync),
          'success': ('สำเร็จ', const Color(0xFF43A047), Icons.check_circle),
          'error': ('ผิดพลาด', Colors.red, Icons.error),
          'not_found': ('ไม่พบ', Colors.red, Icons.block),
        }[status] ??
        ('?', Colors.grey, Icons.help);

    final label = cfg.$1;
    final color = cfg.$2;
    final icon = cfg.$3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (status == 'updating')
          SizedBox(
            width: 11,
            height: 11,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
          )
        else
          Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final totalMatched = _rows.where((r) => r.matched != null).length;
    final totalSelected =
        _rows.where((r) => r.selected && r.matched != null).length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 10,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 640),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: tc,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.cake, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'จัดการอัพเดตข้อมูลทะเบียนลูกค้า',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed:
                          _isUpdating ? null : () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // ── Input area (shown only when no rows yet) ─────────────────
              if (_rows.isEmpty)
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Field selector ──────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: tcBorder),
                            ),
                            child: Row(children: [
                              Icon(Icons.edit_note, color: tc, size: 20),
                              const SizedBox(width: 10),
                              Text('หัวข้อที่ต้องการอัพเดต',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: tc)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedField,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(8),
                                    items: _fieldOptions.entries
                                        .map((e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.value,
                                                  style: const TextStyle(
                                                      fontSize: 13)),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          _selectedField = v;
                                          _rows = [];
                                          _pasteCtrl.clear();
                                          _sourceFileName = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),

                          // ── Template guide ──────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: tcLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: tcBorder),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(children: [
                                  Icon(Icons.info_outline, size: 15, color: tc),
                                  const SizedBox(width: 6),
                                  Text('รูปแบบข้อมูลที่ต้องการ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tc)),
                                ]),
                                const SizedBox(height: 10),
                                // mini table header
                                Container(
                                  decoration: BoxDecoration(
                                    color: tc,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                  child: Row(children: [
                                    _tplCell('คอลัมน์ A\nวันที่', header: true),
                                    _tplDivider(),
                                    _tplCell('คอลัมน์ B\nเลขบัตรประชาชน',
                                        header: true),
                                    _tplDivider(),
                                    _tplCell(
                                        'คอลัมน์ C\n${_fieldOptions[_selectedField] ?? _selectedField}',
                                        header: true),
                                  ]),
                                ),
                                // sample rows
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(6)),
                                    border: Border.all(color: tcBorder),
                                  ),
                                  child: Column(children: [
                                    Row(children: [
                                      _tplCell('2026-01-15'),
                                      _tplDivider(),
                                      _tplCell('1234567890123'),
                                      _tplDivider(),
                                      _tplCell('1990-05-20', highlight: true),
                                    ]),
                                    const Divider(height: 1),
                                    Row(children: [
                                      _tplCell('2026-01-15'),
                                      _tplDivider(),
                                      _tplCell('9876543210987'),
                                      _tplDivider(),
                                      _tplCell('1985-12-01', highlight: true),
                                    ]),
                                  ]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• แถวแรก (row 1) = หัวตาราง ระบบจะข้ามให้อัตโนมัติ',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade700,
                                      height: 1.6),
                                ),
                                Text(
                                  '• คอลัมน์ B = เลขบัตร 13 หลัก (มีหรือไม่มีขีดก็ได้)',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade700,
                                      height: 1.6),
                                ),
                                Text(
                                  '• คอลัมน์ C = ${_fieldOptions[_selectedField] ?? _selectedField}${_selectedField == 'birth' ? ' รูปแบบ yyyy-MM-dd เช่น 1990-05-20' : ''}',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade700,
                                      height: 1.6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── Card 1: URL ─────────────────────────────────────
                          _inputCard(
                            icon: Icons.link,
                            iconColor: tc,
                            cardBg: tcLight,
                            label: 'วิธีที่ 1 — วาง URL จาก Google Sheets',
                            hint: 'Sheet ต้องตั้งค่าเป็น "ทุกคนที่มีลิงก์ดูได้"'
                                'คอลัมน์: วันที่ | เลขบัตรประชาชน | วันเกิด (yyyy-MM-dd)',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _urlCtrl,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        hintText:
                                            'https://docs.google.com/spreadsheets/d/...',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _isFetching ? null : _fetchFromUrl,
                                    icon: _isFetching
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Icon(Icons.download, size: 16),
                                    label: const Text('ดึงข้อมูล',
                                        style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tc,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 11),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ]),
                                if (_fetchError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.red.shade200),
                                      ),
                                      child: Row(children: [
                                        Icon(Icons.warning_amber,
                                            color: Colors.red.shade400,
                                            size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(_fetchError!,
                                              style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontSize: 11)),
                                        ),
                                      ]),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          _divider(),

                          // ── Card 2: Paste ───────────────────────────────────
                          _inputCard(
                            icon: Icons.content_paste,
                            iconColor: tc,
                            cardBg: tcLight,
                            label: 'วิธีที่ 2 — Copy จาก Sheet แล้ว Paste',
                            hint:
                                'คอลัมน์: วันที่ | เลขบัตรประชาชน | วันเกิด (yyyy-MM-dd)',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _pasteCtrl,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    hintText: 'Paste ข้อมูลจาก Sheet ที่นี่...',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12),
                                    contentPadding: const EdgeInsets.all(12),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton.icon(
                                    onPressed: _parseSheet,
                                    icon: const Icon(Icons.search, size: 16),
                                    label: const Text(
                                        'วิเคราะห์และจับคู่ข้อมูล',
                                        style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tc,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 11),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _divider(),

                          // ── Card 3: Excel ───────────────────────────────────
                          _inputCard(
                            icon: Icons.table_chart,
                            iconColor: tc,
                            cardBg: tcLight,
                            label: 'วิธีที่ 3 — อัพโหลดไฟล์ Excel',
                            hint:
                                'รองรับ .xlsx และ .xls\nคอลัมน์ B = เลขบัตร, คอลัมน์ C = วันเกิด',
                            child: ElevatedButton.icon(
                              onPressed: _pickExcel,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text(
                                  'เลือกไฟล์ Excel (.xlsx / .xls)',
                                  style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tc,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Summary + list + bottom (shown when rows loaded) ─────────
              if (_rows.isNotEmpty) ...[
                // stat bar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(children: [
                    _statChip('ทั้งหมด', _rows.length, Colors.grey.shade600),
                    const SizedBox(width: 6),
                    _statChip('ตรงกัน', totalMatched, tc),
                    const SizedBox(width: 6),
                    _statChip('เลือก', totalSelected, tc),
                    if (_sourceFileName != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('· $_sourceFileName',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: tc),
                      onPressed: _isUpdating
                          ? null
                          : () => setState(() {
                                _selectAll = !_selectAll;
                                for (final r in _rows) {
                                  if (r.matched != null) {
                                    r.selected = _selectAll;
                                  }
                                }
                              }),
                      child: Text(_selectAll ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: _isUpdating
                          ? null
                          : () => setState(() {
                                _rows = [];
                                _pasteCtrl.clear();
                                _sourceFileName = null;
                              }),
                      child: const Text('เริ่มใหม่',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ]),
                ),

                // column header
                Container(
                  color: Colors.grey.shade100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(children: [
                    const SizedBox(width: 44),
                    Expanded(flex: 3, child: _hdr('เลขบัตรประชาชน / ชื่อ')),
                    Expanded(
                        flex: 3,
                        child: _hdr(
                            '${_fieldOptions[_selectedField] ?? _selectedField}  เดิม → ใหม่')),
                    SizedBox(width: 96, child: _hdr('สถานะ')),
                  ]),
                ),

                // list
                Expanded(
                  child: ListView.builder(
                    itemCount: _rows.length,
                    itemBuilder: (ctx, i) {
                      final r = _rows[i];
                      final notFound = r.matched == null;
                      Color rowBg =
                          i.isOdd ? Colors.white : const Color(0xFFF9F9F9);
                      if (r.status == 'success') {
                        rowBg = const Color(0xFFE8F5E9);
                      }
                      if (r.status == 'error') rowBg = const Color(0xFFFFEBEE);
                      if (notFound) rowBg = const Color(0xFFF5F5F5);

                      return Container(
                        color: rowBg,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        child: Row(children: [
                          // checkbox
                          SizedBox(
                            width: 44,
                            child: Checkbox(
                              value: r.selected,
                              activeColor: tc,
                              onChanged: (notFound || _isUpdating)
                                  ? null
                                  : (v) => setState(
                                      () => _rows[i].selected = v ?? false),
                            ),
                          ),
                          // id + name
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.idCard,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: notFound
                                          ? Colors.grey
                                          : Colors.black87,
                                      letterSpacing: 0.4,
                                    )),
                                const SizedBox(height: 2),
                                Text(
                                  notFound
                                      ? 'ไม่พบในระบบ'
                                      : (r.matched!.cname ?? '-'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: notFound
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontStyle: notFound
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // field old → new
                          Expanded(
                            flex: 3,
                            child: notFound
                                ? const SizedBox()
                                : Row(children: [
                                    Flexible(
                                      child: Text(
                                        r.matched != null
                                            ? _currentVal(r.matched!)
                                            : '-',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.blueGrey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(Icons.arrow_forward,
                                          size: 12, color: Colors.grey),
                                    ),
                                    Text(r.newValue,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tc,
                                        )),
                                  ]),
                          ),
                          // status
                          SizedBox(width: 96, child: _statusChip(r.status)),
                        ]),
                      );
                    },
                  ),
                ),

                // bottom bar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // progress bar (shown only while updating)
                      if (_isUpdating && totalSelected > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: LinearProgressIndicator(
                            value: _doneCount / totalSelected,
                            minHeight: 4,
                            backgroundColor: tc.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(tc),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(children: [
                          if (_isUpdating) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: tc),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              totalSelected > 0
                                  ? '${(_doneCount / totalSelected * 100).round()}%  ($_doneCount / $totalSelected รายการ)'
                                  : 'กำลังเริ่ม...',
                              style: TextStyle(
                                  color: tc,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ] else if (_doneCount > 0)
                            Row(children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Text('สำเร็จ $_doneCount รายการ',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ]),
                          const Spacer(),
                          if (_isUpdating)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: OutlinedButton.icon(
                                onPressed: _cancelRequested
                                    ? null
                                    : () =>
                                        setState(() => _cancelRequested = true),
                                icon: const Icon(Icons.stop_circle_outlined,
                                    size: 16),
                                label: const Text('หยุด',
                                    style: TextStyle(fontSize: 13)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 11),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ElevatedButton.icon(
                            onPressed: (_isUpdating || totalSelected == 0)
                                ? null
                                : _updateAll,
                            icon: _isUpdating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.update, size: 18),
                            label: Text('อัพเดตทั้งหมด ($totalSelected รายการ)',
                                style: const TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tc,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
