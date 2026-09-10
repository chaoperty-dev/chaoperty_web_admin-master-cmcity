import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io'
    show Directory, File, HttpClient, HttpClientRequest, HttpClientResponse;
import 'package:flutter/foundation.dart';

import 'ocr_web.dart' if (dart.library.io) 'noop.dart'; // จะอธิบายข้างล่าง

class Pair<A, B> {
  final A? a;
  final B? b;
  const Pair(this.a, this.b);
}

class OCRHomePage extends StatefulWidget {
  const OCRHomePage({super.key, required this.title});
  final String title;
  @override
  State<OCRHomePage> createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  String _ocrText = '';
  String? _error;
  String path = "";
  bool bload = false;
  bool bDownloadtessFile = false;

  // ✅ ชื่อภาษาให้ตรงกับ Tesseract
  final LangList = const ["eng", "tha", "kor", "deu", "chi_sim"];
  final Set<String> selectSet = {"eng", "tha"}; // เริ่มด้วยอังกฤษ+ไทย
  // ✅ ตัวอย่างรูปให้ key ตรงกับภาษา
  final Map<String, String> tessimgs = const {
    "eng": "https://tesseract.projectnaptha.com/img/eng_bw.png",
    "kor":
        "https://raw.githubusercontent.com/khjde1207/tesseract_ocr/master/example/assets/test1.png",
    "chi_sim": "https://tesseract.projectnaptha.com/img/chi_sim.png",
    "rus": "https://tesseract.projectnaptha.com/img/rus.png",
  };

  final urlEditController = TextEditingController(
    text: "https://tesseract.projectnaptha.com/img/eng_bw.png",
  );

  // แก้เคส URL ที่ double-encoded (%25E0... → decode 1 ครั้ง แล้ว encode ใหม่รอบเดียว)
  String fixPossiblyDoubleEncoded(String url) {
    try {
      // ถ้าไม่ใช่ http/https ก็ปล่อยไป
      if (!url.startsWith('http')) return url;
      final u = Uri.parse(url);
      final last = u.pathSegments.isEmpty ? '' : u.pathSegments.last;
      final decodedOnce =
          Uri.decodeComponent(last); // ถ้าเดิมเป็น %25E0… จะได้ไทยถูก
      final safeLast = Uri.encodeComponent(decodedOnce);
      final newSegs = [...u.pathSegments]
        ..removeLast()
        ..add(safeLast);
      return u.replace(pathSegments: newSegs).toString();
    } catch (_) {
      return url;
    }
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> runFilePiker() async {
    if (kIsWeb) return; // เว็บยังไม่รองรับ file picker แบบเดียวกัน
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _ocr(pickedFile.path);
    }
  }

// ===== Helpers: ทำความสะอาด / แปลงเลขไทย / หาเลขเงิน =====
  String _normalizeOcrRaw(String s) {
    // ลบตัวคั่น/กลิทช์ที่แทรกบ่อย
    s = s
        .replaceAll('\u200b', '') // zero width
        .replaceAll(RegExp(r'[|=<>]+'), ' ')
        .replaceAll(RegExp(r'''["“”‘’'`]+'''), '') // ✅ ปลอดภัยสุด
        .replaceAll(RegExp(r'[\[\]{}]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return s;
  }

// อักขระ “หน้าตาคล้ายกัน” ที่เจอบ่อยในสลิป
  String _mapConfusables(String s) {
    const map = {
      // ไทย -> อารบิก
      '๐': '0',
      '๑': '1',
      '๒': '2',
      '๓': '3',
      '๔': '4',
      '๕': '5',
      '๖': '6',
      '๗': '7',
      '๘': '8',
      '๙': '9',

      // ตัวเพี้ยนที่ชอบโผล่ข้างตัวเลข
      'O': '0',
      'o': '0',
      '●': '0',
      '◦': '0',
      '•': '0',
      '@': '0',
      '○': '0', // ✅ เอา '๑':'0' ออก เพราะซ้ำ
      'I': '1',
      'l': '1',
      '!': '1',
      '|': '1',
      'S': '5',
      r'$': '5', // ✅ escape ด้วย raw string
      'B': '8',
      '»': '8',

      // ขยะคำ
      'I<+': 'K+',
      '!<+': 'K+',
      'I<K+': 'K+',
    };

    final b = StringBuffer();
    for (final ch in s.split('')) {
      b.write(map[ch] ?? ch);
    }
    return b.toString();
  }

  String _normalizeOcr(String s) {
    s = _normalizeOcrRaw(s);
    s = _mapConfusables(s);
    // คำเพี้ยนยอดฮิต
    const repl = {
      'โอนเงินสําเร็จ': 'โอนเงินสำเร็จ',
      'จํานวนเงิน': 'จำนวนเงิน',
      'เวลาแจ้งเตือน': 'เวลาแจ้งเตือน',
      'ธ.กสิกรไทย': 'ธนาคาร กสิกรไทย',
      'ธนาคารกสิกรไทย': 'ธนาคาร กสิกรไทย',
      'ธ.กรุงไทย': 'ธนาคาร กรุงไทย',
      'ธ.กรุงเทพ': 'ธนาคาร กรุงเทพ',
      'ธ.ไทยพาณิชย์': 'ธนาคาร ไทยพาณิชย์',
      'ธ.ออมสิน': 'ธนาคาร ออมสิน',
    };
    repl.forEach((a, b) {
      s = s.replaceAll(a, b);
    });
    return s;
  }

  String _thaiDigitsToAscii(String s) => s; // ทำแล้วใน _mapConfusables

  String? _firstMatch(RegExp re, String s, [int group = 1]) {
    final m = re.firstMatch(s);
    return m == null ? null : m.group(group)?.trim();
  }

// ============== DATE/TIME ==============
  String? _parseDateTime(String text) {
    final t = _normalizeOcr(text);
    final thMonths = {
      'ม.ค.': '01',
      'ก.พ.': '02',
      'มี.ค.': '03',
      'เม.ย.': '04',
      'พ.ค.': '05',
      'มิ.ย.': '06',
      'ก.ค.': '07',
      'ส.ค.': '08',
      'ก.ย.': '09',
      'ต.ค.': '10',
      'พ.ย.': '11',
      'ธ.ค.': '12',
    };
    final mTh = RegExp(
            r'(\d{1,2})\s*(ม\.ค\.|ก\.พ\.|มี\.ค\.|เม\.ย\.|พ\.ค\.|มิ\.ย\.|ก\.ค\.|ส\.ค\.|ก\.ย\.|ต\.ค\.|พ\.ย\.|ธ\.ค\.)\s*(\d{2,4})[ ,\-]*([0-2]\d:[0-5]\d)')
        .firstMatch(t);
    if (mTh != null) {
      final d = mTh.group(1)!;
      final mon = thMonths[mTh.group(2)!]!;
      int year = int.parse(mTh.group(3)!);
      if (year < 100) {
        year += 2500;
      } // 65 -> 2565
      if (year > 2400) year -= 543; // 2565 -> 2022
      final hm = mTh.group(4)!;
      return '${year.toString().padLeft(4, '0')}-$mon-${d.padLeft(2, '0')}T$hm:00+07:00';
    }

    // อังกฤษ: "25 Mar 25,13:13" หรือ "25 Mar 2025 13:13"
    final enMon = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12'
    };
    final mEn = RegExp(
            r'(\d{1,2})\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ,\-]+(\d{2,4})[ ,\-]*([0-2]\d:[0-5]\d)')
        .firstMatch(t);
    if (mEn != null) {
      final d = mEn.group(1)!;
      final mon = enMon[mEn.group(2)!]!;
      int year = int.parse(mEn.group(3)!);
      if (year < 100) year += 2000;
      final hm = mEn.group(4)!;
      return '${year.toString().padLeft(4, '0')}-$mon-${d.padLeft(2, '0')}T$hm:00+07:00';
    }
    return null;
  }

// ============== AMOUNT/FEE ==============
  double? _parseAmountLoose(String? raw) {
    if (raw == null) return null;
    var x = _normalizeOcr(raw);
    // เก็บเฉพาะ 0-9 , .
    x = x.replaceAll(RegExp(r'[^0-9\., ]'), '');
    // ลบช่องว่างแทรกระหว่างหลัก
    var noSpace = x.replaceAll(' ', '');
    // ตัดตัวอักษร/ตัวหลุดท้าย เช่น "400,000.00 8" -> "400,000.00"
    noSpace =
        _firstMatch(RegExp(r'^([0-9][0-9,\.]*[0-9])'), noSpace, 1) ?? noSpace;
    // ถ้ามีทั้ง , และ . → ลบ , ออก
    if (noSpace.contains(',') && noSpace.contains('.')) {
      noSpace = noSpace.replaceAll(',', '');
    } else if (noSpace.contains(',') && !noSpace.contains('.')) {
      // "555,55" ไทย → ใช้ , เป็นจุด
      noSpace = noSpace.replaceAll(',', '.');
    }
    // ถ้ายังไม่มีจุดและมี >=3 หลัก → เดาว่าทศนิยม 2 ตำแหน่ง
    if (!noSpace.contains('.') && RegExp(r'^\d{3,}$').hasMatch(noSpace)) {
      final digits = noSpace;
      final head = digits.substring(0, digits.length - 2);
      final tail = digits.substring(digits.length - 2);
      noSpace = '$head.$tail';
    }
    try {
      return double.parse(noSpace);
    } catch (_) {
      return null;
    }
  }

// ============== BANK/ACCOUNT/NAME ==============

  Pair<String?, String?> _splitFromToBank(String t) {
    // เก็บชื่อธนาคาร 2 ตัวแรก
    final hits = RegExp(
            r'(?:ธนาคาร\s+|Bank\s+)?(กสิกรไทย|กรุงไทย|กรุงเทพ|ไทยพาณิชย์|ออมสิน|Bangkok Bank|Krungthai|KTB|KBank|SCB)',
            caseSensitive: false)
        .allMatches(t)
        .map((m) => m.group(1)!.trim())
        .toList();
    final fromBank = hits.isNotEmpty ? hits.first : null;
    final toBank = hits.length > 1 ? hits[1] : null;
    return Pair(fromBank, toBank);
  }

  Pair<String?, String?> _splitFromToAccount(String t) {
    // mask (XXX-XXX721-6 / xxx45 / XXX-X-x8888-x)
    final mask = RegExp(
        r'([Xx]{2,}[- ]?[Xx]{2,}[- ]?[Xx\d]{2,}[- ]?\d|[Xx]{2,}[- ]?[Xx][- ]?[Xx\d]{4}[- ]?[Xx])');
    // full (888-8-8888-8)
    final full = RegExp(r'(\d{3}-\d-\d{4}-\d)');
    // long digits (12–20) – อาจเป็นเลขที่รายการด้วย ต้องกรองทีหลัง
    final long = RegExp(r'([0-9]{12,20})');

    String? fromAcct, toAcct;
    final mMask = _firstMatch(mask, t, 1);
    final mFull = _firstMatch(full, t, 1);

    if (mMask != null && mFull != null) {
      fromAcct = mMask;
      toAcct = mFull;
    } else if (mMask != null) {
      fromAcct = mMask;
    } else if (mFull != null) {
      toAcct = mFull;
    } else {
      // สำรอง: บางสลิปมี -1047 หรือ % -1047 → ถือเป็นท้ายเลขย่อ
      final tail4 = _firstMatch(RegExp(r'[-\s](\d{4})\b'), t);
      if (tail4 != null) {
        toAcct = 'xxxx-$tail4';
      }
    }
    return Pair(fromAcct, toAcct);
  }

  Pair<String?, String?> _splitFromToName(String t) {
    // ชื่อที่อยู่ก่อนคำว่า ธนาคาร/Bank
    final nameBefore =
        RegExp(r'([ก-๙A-Za-z\.\s]{2,})\s+(?:ธนาคาร|Bank)', caseSensitive: false)
            .allMatches(t)
            .map((m) => m.group(1)!.trim())
            .toList();
    final fromName = nameBefore.isNotEmpty ? nameBefore.first : null;
    final toName = nameBefore.length > 1 ? nameBefore[1] : null;
    return Pair(fromName, toName);
  }

// ============== REFERENCES ==============
  Map<String, String?> _extractRefs(String t) {
    String? thaiRef = _firstMatch(
        RegExp(r'(?:เลขที่รายการ|รหัสอ้างอิง)[:\s]+([A-Za-z0-9\-\| ]{10,})'),
        t);
    String? bankRef = _firstMatch(
        RegExp(
            r'(?:Bank reference no\.?|Bank reference)[:\s]+([A-Za-z0-9\-]{6,})',
            caseSensitive: false),
        t);
    String? txRef = _firstMatch(
        RegExp(r'(?:Transaction reference)[:\s]+([A-Za-z0-9]{12,})',
            caseSensitive: false),
        t);

    // ทำความสะอาด
    String _clean(String? s) {
      if (s == null) return '';
      s = s.replaceAll(RegExp(r'[^A-Za-z0-9\-\|]'), '').trim();
      return s.length >= 8 ? s : '';
    }

    thaiRef = _clean(thaiRef);
    bankRef = _clean(bankRef);
    txRef = _clean(txRef);

    // กรณีไม่มีคำบอก แต่มีบรรทัดยาว ๆ ตัวเลข → ใช้เป็น thai_ref
    if (thaiRef.isEmpty) {
      final guess = _firstMatch(RegExp(r'\b([0-9A-Za-z\|\-]{12,})\b'), t);
      if (guess != null && !RegExp(r'^\d{3}-\d-\d{4}-\d$').hasMatch(guess)) {
        thaiRef = _clean(guess);
      }
    }
    return {
      "thai_ref": thaiRef.isEmpty ? null : thaiRef,
      "bank_ref": bankRef.isEmpty ? null : bankRef,
      "tx_ref": txRef.isEmpty ? null : txRef
    };
  }

// ============== MAIN PARSER ==============
  Map<String, dynamic> parseTransferSlipToJson(String raw) {
    final t0 = raw;
    final t = _normalizeOcr(raw);

    // 1) สถานะ
    final status = (t.contains('โอนเงินสำเร็จ') ||
            t.toLowerCase().contains('verified by k+') ||
            t.toLowerCase().contains('transaction successful'))
        ? 'SUCCESS'
        : (t.contains('ไม่สำเร็จ') ? 'FAILED' : null);

    // 2) วันที่/เวลา (ลองหลายบล็อก)
    final dtCand = _firstMatch(
            RegExp(
                r'(\d{1,2}\s*[ก-๙]{2,}\.\s*\d{2,4}[^0-9A-Za-z]{0,3}[0-2]\d:[0-5]\d)'),
            t) ??
        _firstMatch(
            RegExp(
                r'(เวลาแจ้งเตือน)\s*([0-3]?\d\s*[ก-๙]{2,}\.\s*\d{2,4}[^0-9A-Za-z]{0,3}[0-2]\d:[0-5]\d)'),
            t,
            2) ??
        _firstMatch(
            RegExp(
                r'(\d{1,2}\s*(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ,\-]+\d{2,4}[ ,\-]*[0-2]\d:[0-5]\d)',
                caseSensitive: false),
            t);
    final notifiedAt = dtCand != null ? _parseDateTime(dtCand) : null;

    // 3) จำนวนเงิน / ค่าธรรมเนียม
    final amtNear = _firstMatch(
            RegExp(r'(?:จำนวน|จำนวนเงิน|Amount)[:\s]+(.{1,40}?)(?:บาท|THB|฿)',
                caseSensitive: false),
            t) ??
        _firstMatch(
            RegExp(r'([0-9 ,\.\-]{3,})\s*(?:บาท|THB|฿)', caseSensitive: false),
            t);
    final amount = _parseAmountLoose(amtNear);

    final feeNear = _firstMatch(
            RegExp(r'(?:ค่าธรรมเนียม|Fee)[:\s]+([0-9 ,\.\-]{1,20})',
                caseSensitive: false),
            t) ??
        _firstMatch(
            RegExp(r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2}))\s*(?:บาท|THB|฿)',
                caseSensitive: false),
            t);
    final fee = _parseAmountLoose(feeNear);

    // 4) ธนาคาร/ชื่อ/บัญชี
    final bPair = _splitFromToBank(t);
    final nPair = _splitFromToName(t);
    final aPair = _splitFromToAccount(t);

    // 5) อ้างอิง
    final refs = _extractRefs(t);

    return {
      "status": status,
      "amount": amount,
      "currency": "THB",
      "fee": fee,
      "notified_at": notifiedAt,
      "from": {
        "name": nPair.a,
        "bank": bPair.a,
        "account": aPair.a,
      },
      "to": {
        "name": nPair.b,
        "bank": bPair.b,
        "account": aPair.b,
      },
      "references": refs,
      "raw_text": _normalizeOcrRaw(t0), // เก็บดิบแบบล้างคั่นเบื้องต้น
    };
  }

  Map<String, dynamic>? jsonData;
  Future<void> _ocr(String inputUrlOrPath) async {
    _error = null;

    if (selectSet.isEmpty) {
      setState(() => _error = "Please select at least one language.");
      return;
    }

    String urlOrPath = inputUrlOrPath.trim();

    // แก้ URL double-encoded บนเว็บ (กรณี %25E0...)
    if (kIsWeb && urlOrPath.startsWith('http')) {
      urlOrPath = fixPossiblyDoubleEncoded(urlOrPath);
    }

    path = urlOrPath;

    // มือถือ: ดาวน์โหลดลง temp ถ้ามาเป็น http/https
    if (!kIsWeb &&
        (urlOrPath.startsWith("http://") || urlOrPath.startsWith("https://"))) {
      final tempDir = await getTemporaryDirectory();
      final httpClient = HttpClient();
      final HttpClientRequest request =
          await httpClient.getUrl(Uri.parse(urlOrPath));
      final HttpClientResponse response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final file = File('${tempDir.path}/ocr_input.jpg');
      await file.writeAsBytes(bytes);
      urlOrPath = file.path;
    }

    final langs = selectSet.join("+"); // e.g. "eng+kor"

    bload = true;
    _ocrText = '';
    setState(() {});

    try {
      if (kIsWeb) {
        // ✅ บนเว็บ: เรียก JS โดยตรง -> ไม่เข้า android_ios.dart อีก
        _ocrText = await webExtractText(
          imagePath: urlOrPath,
          languages: langs,
          args: const {
            "preserve_interword_spaces": "1",
            // "tessjs_create_hocr": "1",
          },
        );
        final data = parseTransferSlipToJson(_ocrText);

        setState(() => jsonData = data); // ถ้ามีตัวแปรใน State

        print("_ocrText : $_ocrText");
        print('jsonData : $jsonData');
      } else {
        // ✅ มือถือ: ใช้ปลั๊กอินเดิม
        _ocrText = await FlutterTesseractOcr.extractText(
          urlOrPath,
          language: langs,
          args: const {"preserve_interword_spaces": "1"},
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      bload = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    urlEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Select Url'),
                            children: tessimgs.entries.map((e) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  urlEditController.text = e.value;
                                  setState(() {});
                                  Navigator.pop(ctx);
                                },
                                child: Row(
                                  children: [
                                    Text(e.key),
                                    const Text(" : "),
                                    Flexible(child: Text(e.value)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      child: const Text("urls"),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'input image url or local path',
                        ),
                        controller: urlEditController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _ocr(urlEditController.text),
                      child: const Text("Run"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: LangList.map((lang) {
                    final checked = selectSet.contains(lang);
                    return FilterChip(
                      label: Text(lang),
                      selected: checked,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            selectSet.add(lang);
                          } else {
                            selectSet.remove(lang);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                if (!isWeb)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mobile note: จะดาวน์โหลด traineddata อัตโนมัติเมื่อเลือกภาษาในครั้งแรก",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      if (path.isNotEmpty)
                        path.startsWith("http")
                            ? Image.network(path,
                                errorBuilder: (_, __, ___) => const SizedBox())
                            : (!isWeb
                                ? Image.file(File(path))
                                : const SizedBox()),
                      const SizedBox(height: 8),
                      if (bload)
                        const Center(child: CircularProgressIndicator()),
                      if (_error != null && _error!.isNotEmpty)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (!bload && (_error == null || _error!.isEmpty))
                        if (jsonData != null) ...[
                          const SizedBox(height: 8),
                          const Text("Parsed JSON:"),
                          SelectableText(const JsonEncoder.withIndent('  ')
                              .convert(jsonData)),
                        ]
                      // SelectableText(
                      //   _ocrText,
                      //   style: const TextStyle(
                      //       fontFamily: 'RobotoMono'), // หรือ Menlo/Consolas
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (bDownloadtessFile)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('download Trained language files'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isWeb
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: runFilePiker,
              tooltip: 'OCR',
              child: const Icon(Icons.add),
            ),
    );
  }
}
