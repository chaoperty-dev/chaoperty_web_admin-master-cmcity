import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Model/AnnounceMentActive_Model.dart';
import 'Model/AnnounceMentDetails_Model.dart';
import 'unity/API_announcement.dart';
import 'unity/show_dialog_cmm.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangeItem {
  final String startDate;
  final String endDate;
  final String announceDate;

  DateRangeItem({
    required this.startDate,
    required this.endDate,
    required this.announceDate,
  });
}

class RangePickerWidget extends StatefulWidget {
  const RangePickerWidget({
    super.key,
    this.title,
    this.minDate,
    this.maxDate,
    this.initialRange,
    this.onChanged,
    this.maxSpanDays,
  });

  final String? title;
  final DateTime? minDate;
  final DateTime? maxDate;
  final PickerDateRange? initialRange;
  final void Function(DateTime start, DateTime end)? onChanged;

  /// จำกัดจำนวนวันสูงสุดที่เลือกได้ เช่น 1 = เลือกได้วันเดียว
  final int? maxSpanDays;

  @override
  State<RangePickerWidget> createState() => _RangePickerWidgetState();
}

class _RangePickerWidgetState extends State<RangePickerWidget> {
  final _controller = DateRangePickerController();
  DateTime? _start, _end;

  @override
  void initState() {
    super.initState();

    // 👉 ถ้า widget.initialRange ไม่ได้ส่งมา → ใช้ "วันนี้" เป็นค่าเริ่มต้น
    final today = DateTime.now();
    final initRange = widget.initialRange ??
        PickerDateRange(
          DateTime(today.year, today.month, today.day),
          DateTime(today.year, today.month, today.day),
        );

    _controller.selectedRange = initRange;
    _controller.displayDate = initRange.startDate;

    _start = initRange.startDate;
    _end = initRange.endDate ?? initRange.startDate;

    // 🔥 callback กลับไปหา onChanged ด้วย (ถ้ากำหนดมา)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged?.call(_start!, _end!);
    });
  }

  // void initState() {
  //   super.initState();
  //   if (widget.initialRange != null) {
  //     _controller.selectedRange = widget.initialRange;
  //     _start = widget.initialRange!.startDate;
  //     _end = widget.initialRange!.endDate ?? widget.initialRange!.startDate;
  //   }
  // }

// true เมื่อจำกัดให้เลือกได้สูงสุด 1 วัน
  bool get _isSingleDay => (widget.maxSpanDays ?? 9999) <= 1;
// ใช้ฟังก์ชันนี้แทนการตั้งช่วงตรง ๆ
  void _applyRange(DateTime s, DateTime e) {
    // ถ้าเลือกได้แค่วันเดียว ตัด e ให้เท่ากับ s
    if (_isSingleDay) {
      e = DateTime(s.year, s.month, s.day);
    }
    _controller.selectedRange = PickerDateRange(s, e);

    // 🔁 สั่งให้ปฏิทินแสดงเดือนที่มีวันที่เริ่ม (focus กลับมา)
    _controller.displayDate = s;

    setState(() {
      _start = s;
      _end = e;
    });

    widget.onChanged?.call(s, e);
  }

  @override
  Widget build(BuildContext context) {
    final min =
        widget.minDate ?? DateTime.now().subtract(const Duration(days: 365));
    final max =
        widget.maxDate ?? DateTime.now().add(const Duration(days: 365 * 3));
    final selectionMode = _isSingleDay
        ? DateRangePickerSelectionMode.single
        : DateRangePickerSelectionMode.range;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //
        SizedBox(
          height: 5,
        ),

        // 🔹 ปุ่มลัด
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
                label: const Text('วันนี้'),
                onPressed: () {
                  final d = DateTime.now();
                  _applyRange(d, d);
                }),
            if (!_isSingleDay)
              ActionChip(
                  label: const Text('7 วัน'),
                  onPressed: () {
                    final s = DateTime.now();
                    final e = s.add(const Duration(days: 6));
                    _applyRange(s, e);
                  }),
            if (!_isSingleDay)
              ActionChip(
                  label: const Text('สิ้นเดือนนี้'),
                  onPressed: () {
                    final now = DateTime.now();
                    final s = DateTime(now.year, now.month, 1);
                    final e = DateTime(now.year, now.month + 1, 0);
                    _applyRange(s, e);
                  }),
            if (_start != null && _end != null)
              Center(
                child: Text(' วันที่เลือก : '
                    '${_start!.day}/${_start!.month}/${_start!.year + 0}'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 🔹 ปฏิทินเลือกวัน/ช่วง
        SfDateRangePicker(
          controller: _controller,
          // selectionMode: selectionMode,
          selectionMode: DateRangePickerSelectionMode.range,
          minDate: min,
          maxDate: max,
          onSelectionChanged: (args) {
            if (args.value is PickerDateRange) {
              final r = args.value as PickerDateRange;
              final s = r.startDate!;
              final e = (r.endDate ?? r.startDate!)!;
              _applyRange(DateTime(s.year, s.month, s.day),
                  DateTime(e.year, e.month, e.day));
            }
          },
          todayHighlightColor: Colors.orange,
          selectionColor: Colors.green,
          startRangeSelectionColor: Colors.green,
          endRangeSelectionColor: Colors.green,
          rangeSelectionColor: Colors.green.withOpacity(.25),
          headerStyle: const DateRangePickerHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 5),
        // if (_start != null && _end != null)
        //   Text('เลือกช่วง: '
        //       '${_start!.day}/${_start!.month}/${_start!.year + 543}'
        //       ' - ${_end!.day}/${_end!.month}/${_end!.year + 543}'),
      ],
    );
  }
}

class NoticeboardCMM extends StatefulWidget {
  const NoticeboardCMM({super.key});

  @override
  State<NoticeboardCMM> createState() => _NoticeboardCMMState();
}

class _NoticeboardCMMState extends State<NoticeboardCMM> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _fulltextController = TextEditingController();
  int selectedIndex = 0, _tapStatuAnnounce = 1;
  int? zoneId;
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> _zoneModels = <ZoneModel>[];
  List<AreaModel> areaModels = [];
  late List<bool> checkedStates;
  List<String> selectedSer = [];
  String? selectedZonesZn = '';
  bool check_all = false;
  bool _newNotice = false;
  List<AnnounceMentActiveModel> announceActive = [];
  List<AnnounceDetails> announceDetails = [];
  List<Map<String, dynamic>> json_zones = [];
  // final selectedSer = <dynamic>[]; // 1. ประกาศ controller
  ZoneModel? Dropdown_initialItem;
  final List<String> options = ['ประกาศทันที', 'ตั้งวันที่ประกาศ'];
  final List<DateRangeItem> items = [
    DateRangeItem(
        startDate: '01-01-2025',
        endDate: '01-12-2025',
        announceDate: '31-12-2024'),
    DateRangeItem(
        startDate: '01-03-2025',
        endDate: '30-09-2025',
        announceDate: '15-02-2025'),
    // เพิ่มได้เรื่อยๆ
  ];
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.enforced;
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String? sdateRequest = 'เลือกวันที่',
      sdatelicenseRequest = 'เลือกวันที่',
      ldateRequest = 'เลือกวันที่',
      ldateslicenseRequest = 'เลือกวันที่';
  int _tapStatus = 0;
  List<dynamic> _colorsMainTap = [
    Color.fromARGB(255, 177, 195, 240),
    Color.fromARGB(255, 177, 240, 180),
    Color.fromARGB(255, 177, 195, 240),
    Color.fromARGB(255, 240, 184, 177),
  ];
  List<dynamic> _colorsSubTap = [
    Color(0xFF102456),
    Colors.green[800],
    Color(0xFF102456),
    Colors.grey[600],
  ];
  dynamic file, ioFile;
  String? EditannouncementUuid;
//////////////////------------------------------>
  @override
  void initState() {
    super.initState();

    read_GC_zone();
    loadAnnounceMentActive();
  }

  Future<Null> setText() async {
    setState(() {
      _titleController.text = 'กำหนดการณ์ต่ออายุใบอนุญาตฯ';
      _contentController.text =
          'บริเวณ ${selectedZonesZn} ให้ผู้ค้ายื่นคำร้องต่อใบอนุญาตฯ ได้ตั้งแต่วันที่ $sdateRequest จนถึงวันที่ $ldateRequest โปรดอ่านรายละเอียดเพิ่มเติมใน เอกสารประกาศ ';
    });
    setFullText();
  }

  Future<Null> setFullText() async {
    setState(() {
      _fulltextController.text =
          '${_titleController.text}' + '${_contentController.text}';
    });
  }

//////////////////------------------------------>
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      setState(() {
        zoneModels.clear();
      });
    }
    setText();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        setState(() {
          zoneModels.add(zoneModel);
        });
      }
      zoneModels.sort((a, b) {
        if (a.zn == 'ทั้งหมด') {
          return -1; // 'all' should come before other elements
        } else if (b.zn == 'ทั้งหมด') {
          return 1; // 'all' should come after other elements
        } else {
          return a.zn!
              .compareTo(b.zn!); // sort other elements in ascending order
        }
      });
      setState(() {
        checkedStates = List.filled(zoneModels.length, false); // ✅ Safe setup
        _zoneModels = zoneModels;
      });
    } catch (e) {}
  }

  _searchBar_zone() {
    return TextField(
      // controller:
      //     _searchController,
      decoration: InputDecoration(
        hintText: 'Search',
        contentPadding: EdgeInsets.symmetric(horizontal: 7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onChanged: (text) {
        // //print(text);
        text = text.toLowerCase();
        setState(() {
          zoneModels = _zoneModels.where((zoneModelss) {
            var notTitle = zoneModelss.zn.toString().toLowerCase();
            // var notTitle2 = zoneModelss.lncode.toString().toLowerCase();

            return notTitle.contains(text);
          }).toList();
        });
      },
    );
  }

  Future<void> loadAnnounceMentActive() async {
    setState(() {
      announceActive.clear();
    });

    try {
      final response = await read_AnnounceMent_Active();

      if (response == null) {
        //print('❌ No response received.');
        return;
      }

      if (response.statusCode != 200) {
        //print('❌ Server error: ${response.statusCode}');
        return;
      }

      final result = json.decode(response.body);
      final data = result['data'];

      //print('📦 Raw data: $data');
      //print('📦 Data type: ${data.runtimeType}');

      if (data == null) {
        //print('❌ No data found.');
        return;
      }

      if (data is List) {
        final items =
            data.map((e) => AnnounceMentActiveModel.fromJson(e)).toList();
        setState(() {
          announceActive.addAll(items);
        });
      } else if (data is Map) {
        final item =
            AnnounceMentActiveModel.fromJson(Map<String, dynamic>.from(data));
        setState(() {
          announceActive.add(item);
        });
      } else {
        //print('❌ Unexpected data format: ${data.runtimeType}');
      }
    } catch (e, stack) {
      //print('❌ Exception: $e');
      //print('🧭 StackTrace:\n$stack');
    }
  }

  Future<void> loadAnnounceMentHistory() async {
    setState(() {
      announceActive.clear();
    });

    try {
      final response = await read_AnnounceMent_History();

      if (response == null) {
        //print('❌ No response received.');
        return;
      }

      if (response.statusCode != 200) {
        //print('❌ Server error: ${response.statusCode}');
        return;
      }

      final result = json.decode(response.body);
      final data = result['data']['data'];

      //print('📦 Raw data: $data');
      //print('📦 Data type: ${data.runtimeType}');

      if (data == null) {
        //print('❌ No data found.');
        return;
      }

      if (data is List) {
        final items =
            data.map((e) => AnnounceMentActiveModel.fromJson(e)).toList();
        setState(() {
          announceActive.addAll(items);
        });
      } else if (data is Map) {
        final item =
            AnnounceMentActiveModel.fromJson(Map<String, dynamic>.from(data));
        setState(() {
          announceActive.add(item);
        });
      } else {
        //print('❌ Unexpected data format: ${data.runtimeType}');
      }
    } catch (e, stack) {
      //print('❌ Exception: $e');
      //print('🧭 StackTrace:\n$stack');
    }
  }

  Future<void> loadAnnounceMentDetails(
      {required String announcementUuid}) async {
    setState(() {
      announceDetails.clear();
    });

    try {
      final response = await read_AnnounceMent_Details(
          announcementUuid: '$announcementUuid');

      if (response == null) {
        //print('❌ No response received.');
        return;
      }

      if (response.statusCode != 200) {
        //print('❌ Server error: ${response.statusCode}');
        return;
      }

      final result = json.decode(response.body);
      final data = result['data'];

      //print('📦 Raw data: $data');
      //print('📦 Data type: ${data.runtimeType}');

      if (data == null) {
        //print('❌ No data found.');
        return;
      }

      if (data is List) {
        final items = data.map((e) => AnnounceDetails.fromJson(e)).toList();
        setState(() {
          announceDetails.addAll(items);
        });
      } else if (data is Map) {
        final item = AnnounceDetails.fromJson(Map<String, dynamic>.from(data));
        setState(() {
          announceDetails.add(item);
        });
      } else {
        //print('❌ Unexpected data format: ${data.runtimeType}');
      }
    } catch (e, stack) {
      //print('❌ Exception: $e');
      //print('🧭 StackTrace:\n$stack');
    }
  }

  Future<String?> _selectDate(BuildContext context,
      {String? currentDate}) async {
    DateTime initialDate;

    // ✅ กำหนด initialDate ให้ปลอดภัย
    if (currentDate != null && currentDate.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(currentDate.trim());
      initialDate = parsed ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }

    // ✅ ป้องกันวันที่ก่อน 2024
    if (initialDate.isBefore(DateTime(2024))) {
      initialDate = DateTime(2024);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      locale: const Locale('th', 'TH'), // ✅ ภาษาไทย
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _colorsSubTap[_tapStatus], // สีวัน/ปุ่ม OK
              onPrimary: Colors.white, // สีข้อความบนปุ่ม
              onSurface: Colors.black, // สีข้อความทั่วไป
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _colorsSubTap[_tapStatus], // สีปุ่ม Cancel/OK
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return DateFormat('yyyy-MM-dd').format(picked);
    }

    return null; // ✅ ต้องมี return เสมอ
  }

  void fetchData() async {
    final schedule = announceDetails.first.schedule;
    final titleText = announceDetails.first.content!.title.toString();
    final originalText = announceDetails.first.content!.content.toString();
    setState(() {
      _titleController.text = titleText;

      // ถ้า content เริ่มต้นด้วย title ให้ตัด title ออก
      if (originalText.startsWith(titleText)) {
        _contentController.text = originalText.substring(titleText.length);
      } else {
        _contentController.text = originalText;
      }

      _fulltextController.text = originalText;
    });

    setState(() {
      sdateRequest = DateFormat('yyyy-MM-dd').format(
          DateTime.tryParse(schedule!.effectiveAt ?? '') ?? DateTime.now());

      ldateRequest = DateFormat('yyyy-MM-dd').format(
          DateTime.tryParse(schedule.expiredAt ?? '') ?? DateTime.now());

      sdatelicenseRequest = DateFormat('yyyy-MM-dd').format(
          DateTime.tryParse(schedule.cDateStart ?? '') ?? DateTime.now());

      ldateslicenseRequest = DateFormat('yyyy-MM-dd')
          .format(DateTime.tryParse(schedule.cDateEnd ?? '') ?? DateTime.now());

      _selectedDay =
          DateTime.tryParse(schedule.publishedAt ?? '') ?? DateTime.now();
    });

    // โหลดข้อมูล announceDetails...

    // โหลดเสร็จแล้วเช็ค zone_id
    final List<int> propertyZoneIds = announceDetails.first.properties
            ?.map((prop) => prop.zoneId ?? -1)
            .toList() ??
        [];
    //print('propertyZoneIds.length : ${propertyZoneIds.length}');
    final List<bool> newCheckedStates = List.filled(zoneModels.length, false);
    final List<String> newSelectedSer = [];

    for (int i = 0; i < zoneModels.length; i++) {
      final zone = zoneModels[i];
      final zoneId = int.tryParse(zone.ser ?? '');
      if (zoneId != null && propertyZoneIds.contains(zoneId)) {
        newCheckedStates[i] = true;
        newSelectedSer.add(zone.ser!);
      }
    }

    setState(() {
      checkedStates = newCheckedStates;
      selectedSer = newSelectedSer;
    });
    //print(checkedStates);
  }

  DateTime? safeParseDate(String? input) {
    if (input == null) return null;
    final s = input.trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;

    // ตัด timezone/ไมโครวินาทีที่เกินถ้ามี
    final cleaned = s
        .replaceAll('/', '-') // 01/10/2025 -> 01-10-2025
        .replaceAll(RegExp(r'\.\d+'), ''); // ลบ .123456

    // ลิสต์รูปแบบที่ลอง
    final fmts = <String>[
      "yyyy-MM-dd'T'HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd",
      "dd-MM-yyyy",
      "dd-MM-yyyy HH:mm:ss",
      "MM-dd-yyyy",
      "MM/dd/yyyy",
      "dd/MM/yyyy",
    ];

    for (final f in fmts) {
      try {
        return DateFormat(f).parseStrict(cleaned);
      } catch (_) {}
    }

    // เผื่อเคสตัดเวลาออกเฉพาะ 10 ตัวแรก (yyyy-MM-dd????)
    if (cleaned.length >= 10) {
      final first10 = cleaned.substring(0, 10);
      try {
        return DateTime.parse(first10);
      } catch (_) {}
    }
    return null; // บอกให้ call-site จัดการต่อ
  }

  //  '${howDayAndMonth(type: 'day', sdate: '${sdatelicenseRequest}', ldate: '${ldateslicenseRequest}')}',
  int howDayAndMonth({
    required String type,
    required String sdate,
    required String ldate,
  }) {
    final start = safeParseDate(sdate);
    final end = safeParseDate(ldate);

    if (start == null || end == null) {
      // บอกว่า format ไม่ถูก (จะ return 0 หรือ throw ก็เลือกได้)
      // throw FormatException('Invalid date format');
      return 0;
    }

    // final diffDays = end.difference(start).inDays;
    final diffDays = end.difference(start).inDays + 1;
    // final diffMonths = (end.year - start.year) * 12 + (end.month - start.month);
    int diffMonths = (end.year - start.year) * 12 + (end.month - start.month);
    if (type == 'day') return diffDays;
    if (type == 'month') {
      if (end.day >= start.day) {
        return diffMonths += 1;
      } else {
        return diffMonths;
      }
    }

    return 0;
  }

  int countMonthsInclusive(String start, String end) {
    final s = safeParseDate(start);
    final e = safeParseDate(end);

    int months = (e!.year - s!.year) * 12 + (e.month - s.month);
    if (e.day >= s.day) {
      months += 1;
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

// // ปรับขนาดตามจอ

    final double maxAllowedWidth = screenWidth * 0.85;

    double maxH = screenHeight * 0.75;
    double minH = 700;
    if (minH > maxH) minH = maxH;
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (maxAllowedWidth < 1300) ? 1400 : maxAllowedWidth,
                  maxHeight: (maxH < 560) ? 640 : maxH + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Row(children: [
                      //   Padding(
                      //     padding: const EdgeInsets.all(4.0),
                      //     child: ElevatedButton(
                      //       style: ButtonStyle(
                      //         backgroundColor: MaterialStateProperty.all<Color>(
                      //           AppbackgroundColor.TiTile_Box,
                      //         ),
                      //       ),
                      //       onPressed: () async {},
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(4.0),
                      //         child: Translate.TranslateAndSet_TextAutoSize(
                      //           'ประกาศ ',
                      //           Colors.black,
                      //           TextAlign.center,
                      //           FontWeight.bold,
                      //           FontWeight_.Fonts_T,
                      //           10,
                      //           12,
                      //           1,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   Expanded(
                      //     flex: 4,
                      //     child: SizedBox(),
                      //   )
                      // ]),

                      if (_tapStatus != 0)
                        SizedBox(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        AppbackgroundColor.TiTile_Box,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        if (_tapStatus == 1) {
                                          _newNotice = false;
                                          _tapStatus = 0;
                                          checkedStates = List.filled(
                                              zoneModels.length, false);
                                        } else {
                                          _tapStatus = 1;
                                          checkedStates = List.filled(
                                              zoneModels.length, false);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                        _tapStatus == 2
                                            ? 'ยกเลิกการแก้ไข'
                                            : 'กลับ',
                                        Colors.black,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        10,
                                        12,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSet_TextAutoSize(
                                    _tapStatus == 2
                                        ? 'แก้ไขรายละเอียดประกาศกำหนดการณ์'
                                        : 'รายละเอียดประกาศกำหนดการณ์',
                                    Colors.black,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    10,
                                    12,
                                    1,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.grey.shade600,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _tapStatus = 2;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                        'แก้ไข',
                                        Colors.white,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        10,
                                        12,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.red.shade200,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _tapStatus = 3;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                        'ยกเลิกประกาศ',
                                        Colors.black,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        10,
                                        12,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                              ])
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),
                      if (_tapStatus == 0)
                        SizedBox(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            _newNotice = (_newNotice == true)
                                                ? false
                                                : true;
                                          });
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: _colorsSubTap[0],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            child: Center(
                                                child: Translate.TranslateAndSetText(
                                                    (_newNotice == false)
                                                        ? '+ สร้างประกาศใหม่ '
                                                        : 'ยกเลิกสร้างประกาศใหม่ ',
                                                    ChaoAreaScreen_Color
                                                        .Colors_Text3_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      if (_newNotice == true)
                        Container(
                            constraints: BoxConstraints(
                              minHeight: 280,
                              maxHeight: _tapStatus == 0 ? 300 : 500,
                            ),
                            // height: 280,
                            // width: MediaQuery.of(context).size.width * 0.85,
                            // height: MediaQuery.of(context).size.height * 0.8,
                            decoration: const BoxDecoration(
                              // color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight:
                                                    Radius.circular(8)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: _colorsMainTap[
                                                            _tapStatus],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                          'เลือกโซนพื้นที่ (บริเวณ)',
                                                          ChaoAreaScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 35,
                                                      width: 35,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    6)),
                                                        border: Border.all(
                                                            color: check_all!
                                                                ? Colors.green
                                                                : Colors.grey,
                                                            width: 0.5),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(1),
                                                      child: Center(
                                                        child: IconButton(
                                                          onPressed:
                                                              (_tapStatus != 0)
                                                                  ? null
                                                                  : () async {
                                                                      setState(
                                                                          () {
                                                                        // 👉 toggle ค่า check_all
                                                                        check_all =
                                                                            !check_all;

                                                                        // 👉 เซ็ตค่า checkedStates ตาม check_all
                                                                        for (var i =
                                                                                0;
                                                                            i < zoneModels.length;
                                                                            i++) {
                                                                          checkedStates[i] =
                                                                              check_all;
                                                                        }

                                                                        // 👉 clear แล้วสร้าง selected ใหม่
                                                                        selectedSer =
                                                                            [];
                                                                        final Set<String>
                                                                            selectedZones =
                                                                            {};
                                                                        json_zones
                                                                            .clear();

                                                                        for (int i =
                                                                                0;
                                                                            i < checkedStates.length;
                                                                            i++) {
                                                                          if (checkedStates[
                                                                              i]) {
                                                                            selectedSer.add(zoneModels[i].ser!);
                                                                            selectedZones.add(zoneModels[i].zn ??
                                                                                '');

                                                                            json_zones.add({
                                                                              "property_id": 0,
                                                                              "property_pn": "0",
                                                                              "zone_id": int.tryParse(zoneModels[i].ser ?? '') ?? 0,
                                                                              "zone_pn": zoneModels[i].zn ?? '',
                                                                              "subzone_id": int.tryParse(zoneModels[i].sub_zone ?? '') ?? 0,
                                                                              "subzone_pn": "0",
                                                                            });
                                                                          }
                                                                        }

                                                                        final sortedZones = selectedZones
                                                                            .toList()
                                                                          ..sort();
                                                                        selectedZonesZn =
                                                                            sortedZones.join(', ');

                                                                        //print(
                                                                        //    '✅ Checked ser list: $selectedSer');
                                                                        //print(
                                                                        // json_zones);
                                                                        setText();
                                                                      });
                                                                    },
                                                          icon: Icon(
                                                            Icons.done_all,
                                                            size: 20,
                                                            color: check_all!
                                                                ? Colors.green
                                                                : Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          height: 30,
                                                          child:
                                                              _searchBar_zone(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  // child:
                                                  //     ZoneCheckboxList()
                                                  child: GridView.count(
                                                shrinkWrap: true,
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 4,
                                                childAspectRatio: 7,
                                                // physics:
                                                //     NeverScrollableScrollPhysics(),
                                                children: List.generate(
                                                  zoneModels.length,
                                                  (index) {
                                                    final zone =
                                                        zoneModels[index];
                                                    final isDisabled =
                                                        zone.st == 0;

                                                    return CheckboxListTile(
                                                      dense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        zone.zn!,
                                                        style: TextStyle(
                                                          color: isDisabled
                                                              ? Colors.red
                                                              : Colors.black,
                                                          decoration: isDisabled
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null,
                                                        ),
                                                      ),
                                                      value: (index <
                                                              checkedStates
                                                                  .length)
                                                          ? checkedStates[index]
                                                          : false,
                                                      onChanged: isDisabled
                                                          ? null
                                                          : (_tapStatus != 0)
                                                              ? null
                                                              : (bool? value) {
                                                                  setState(() {
                                                                    checkedStates[
                                                                            index] =
                                                                        value ??
                                                                            false;

                                                                    selectedSer =
                                                                        [];
                                                                    final Set<
                                                                            String>
                                                                        selectedZones =
                                                                        {};
                                                                    json_zones
                                                                        .clear(); // ✅ เคลียร์ก่อนแอดใหม่

                                                                    for (int i =
                                                                            0;
                                                                        i < checkedStates.length;
                                                                        i++) {
                                                                      if (checkedStates[
                                                                          i]) {
                                                                        selectedSer
                                                                            .add(zoneModels[i].ser!);
                                                                        selectedZones.add(zoneModels[i].zn ??
                                                                            '');

                                                                        json_zones
                                                                            .add({
                                                                          "property_id":
                                                                              0,
                                                                          "property_pn":
                                                                              "0",
                                                                          "zone_id":
                                                                              int.parse(zoneModels[i].ser!) ?? 0,
                                                                          "zone_pn":
                                                                              zoneModels[i].zn ?? '',
                                                                          "subzone_id":
                                                                              int.parse(zoneModels[i].sub_zone!) ?? 0,
                                                                          "subzone_pn":
                                                                              "0"
                                                                        });
                                                                      }
                                                                    }

                                                                    final sortedZones =
                                                                        selectedZones
                                                                            .toList()
                                                                          ..sort();
                                                                    selectedZonesZn =
                                                                        sortedZones
                                                                            .join(', ');

                                                                    //print(
                                                                    //  '✅ Checked ser list: $selectedSer');
                                                                    //print(
                                                                    // json_zones);
                                                                    setText();
                                                                  });
                                                                },
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                    );
                                                  },
                                                ),
                                              )), // ✅ นี่คือ Widget ที่แสดง checkbox zone
                                            ],
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          padding: const EdgeInsets.all(0.0),
                                          child: Column(
                                            children: [
                                              // Row(
                                              //   children: [
                                              //     Expanded(
                                              //       child: Container(
                                              //         decoration: BoxDecoration(
                                              //           color: _colorsMainTap[
                                              //               _tapStatus],
                                              //           borderRadius:
                                              //               BorderRadius
                                              //                   .circular(8),
                                              //           border: Border.all(
                                              //               color: Colors.white,
                                              //               width: 2),
                                              //         ),
                                              //         padding:
                                              //             const EdgeInsets.all(
                                              //                 4.0),
                                              //         child: Center(
                                              //           child: Translate
                                              //               .TranslateAndSetText(
                                              //                   'กำหนดการณ์ต่อใบอนุญาตฯ / สัญญา',
                                              //                   ChaoAreaScreen_Color
                                              //                       .Colors_Text1_,
                                              //                   TextAlign.left,
                                              //                   FontWeight.bold,
                                              //                   FontWeight_
                                              //                       .Fonts_T,
                                              //                   14,
                                              //                   2),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              Expanded(
                                                  child: SizedBox(
                                                child: Row(
                                                  children: [
                                                    for (int index = 1;
                                                        index < 3;
                                                        index++)
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color:
                                                                //     AppbackgroundColor.TiTile_Box,
                                                                // borderRadius:
                                                                //     BorderRadius.circular(8),
                                                                // border: Border.all(
                                                                //     color: Colors.white,
                                                                //     width: 2),
                                                                border:
                                                                    (index != 1)
                                                                        ? null
                                                                        : Border(
                                                                            right:
                                                                                BorderSide(color: Colors.grey.shade400, width: 3),
                                                                          ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(4.0),
                                                                          child: Container(
                                                                              decoration: BoxDecoration(
                                                                                color: (index == 1) ? _colorsMainTap[_tapStatus] : _colorsSubTap[_tapStatus],
                                                                                borderRadius: BorderRadius.circular(8),
                                                                                border: Border.all(color: Colors.white, width: 2),
                                                                              ),
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(child: Translate.TranslateAndSetText((index == 1) ? 'เปิดรับคำร้อง ต่ออายุใบอนุญาตฯ' : 'ใบอนุญาตฉบับใหม่', (index == 1) ? ChaoAreaScreen_Color.Colors_Text2_ : ChaoAreaScreen_Color.Colors_Text3_, TextAlign.left, FontWeight.bold, FontWeight_.Fonts_T, 14, 2))),
                                                                        ),
                                                                      ),
                                                                      if (index ==
                                                                          2)
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(1.0),
                                                                          child:
                                                                              InkWell(
                                                                            child:
                                                                                Icon(
                                                                              Icons.info_outline,
                                                                              color: _colorsSubTap[_tapStatus],
                                                                            ),
                                                                            onTap:
                                                                                () async {
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false,
                                                                                builder: (ctx) {
                                                                                  DateTime? issueDate, expireDate;

                                                                                  String fmt(DateTime? d) => d == null ? 'กรุณาเลือกวันที่' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year + 543}';

                                                                                  Future<void> pickIssue() async {
                                                                                    final d = await showDatePicker(
                                                                                      context: ctx,
                                                                                      initialDate: issueDate ?? DateTime.now(),
                                                                                      firstDate: DateTime(2000),
                                                                                      lastDate: DateTime(2100),
                                                                                    );
                                                                                    if (d != null) {
                                                                                      issueDate = d;
                                                                                      (ctx as Element).markNeedsBuild();
                                                                                    }
                                                                                  }

                                                                                  Future<void> pickExpire() async {
                                                                                    final base = issueDate ?? DateTime.now();
                                                                                    final d = await showDatePicker(
                                                                                      context: ctx,
                                                                                      initialDate: expireDate ?? base,
                                                                                      firstDate: DateTime(2000),
                                                                                      lastDate: DateTime(2100),
                                                                                    );
                                                                                    if (d != null) {
                                                                                      expireDate = d;
                                                                                      (ctx as Element).markNeedsBuild();
                                                                                    }
                                                                                  }

                                                                                  return StatefulBuilder(
                                                                                    builder: (context, setState) {
                                                                                      return AlertDialog(
                                                                                        backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                                                                                        titlePadding: const EdgeInsets.all(0.0),
                                                                                        contentPadding: const EdgeInsets.all(10.0),
                                                                                        actionsPadding: const EdgeInsets.all(6.0),
                                                                                        // insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                        content: Container(
                                                                                          width: 500,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                                                                                            // padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                                                                            child: Column(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    InkWell(
                                                                                                      onTap: () {
                                                                                                        Navigator.pop(context);
                                                                                                      },
                                                                                                      child: Padding(
                                                                                                        padding: const EdgeInsets.all(4.0),
                                                                                                        child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                // const SizedBox(height: 5),
                                                                                                // Text(
                                                                                                //   'โปรดเลือกวันที่ออกใบอนุญาตและวันสิ้นสุดใบอนุญาตสำหรับระบุในใบอนุญาตฯ ฉบับใหม่',
                                                                                                //   textAlign: TextAlign.center,
                                                                                                //   style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                                                                                // ),
                                                                                                // const SizedBox(height: 4),
                                                                                                // Text(
                                                                                                //   '(วันที่จะแสดงในใบอนุญาตฯ ฉบับใหม่ ตามภาพอย่างง)',
                                                                                                //   textAlign: TextAlign.center,
                                                                                                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                                                                                                // ),
                                                                                                // const SizedBox(height: 16),

                                                                                                // Row(
                                                                                                //   children: [
                                                                                                //     Expanded(
                                                                                                //       child: InkWell(
                                                                                                //         onTap: () async {
                                                                                                //           await pickIssue();
                                                                                                //           setState(() {});
                                                                                                //         },
                                                                                                //         borderRadius: BorderRadius.circular(10),
                                                                                                //         child: InputDecorator(
                                                                                                //           decoration: InputDecoration(
                                                                                                //             labelText: 'วันออกใบอนุญาต',
                                                                                                //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                //             isDense: true,
                                                                                                //             suffixIcon: const Icon(Icons.event),
                                                                                                //           ),
                                                                                                //           child: Text(fmt(issueDate)),
                                                                                                //         ),
                                                                                                //       ),
                                                                                                //     ),
                                                                                                //     // const SizedBox(width: 12),
                                                                                                //     // Expanded(
                                                                                                //     //   child: InkWell(
                                                                                                //     //     onTap: () async {
                                                                                                //     //       await pickExpire();
                                                                                                //     //       setState(() {});
                                                                                                //     //     },
                                                                                                //     //     borderRadius: BorderRadius.circular(10),
                                                                                                //     //     child: InputDecorator(
                                                                                                //     //       decoration: InputDecoration(
                                                                                                //     //         labelText: 'วันสิ้นสุดใบอนุญาต',
                                                                                                //     //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                //     //         isDense: true,
                                                                                                //     //         suffixIcon: const Icon(Icons.event),
                                                                                                //     //       ),
                                                                                                //     //       child: Text(fmt(expireDate)),
                                                                                                //     //     ),
                                                                                                //     //   ),
                                                                                                //     // ),
                                                                                                //   ],
                                                                                                // ),
                                                                                                const SizedBox(height: 5),

                                                                                                // พรีวิวเอกสาร + กรอบแดงไฮไลต์
                                                                                                AspectRatio(
                                                                                                  aspectRatio: 3 / 4,
                                                                                                  child: Container(
                                                                                                    // decoration: BoxDecoration(
                                                                                                    //   border: Border.all(color: Colors.black12),
                                                                                                    //   borderRadius: BorderRadius.circular(12),
                                                                                                    // ),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                                      child: Stack(
                                                                                                        children: [
                                                                                                          Positioned.fill(
                                                                                                            child: Image.asset(
                                                                                                              'images/ex_noti_cmm.png', // เปลี่ยนเป็นภาพของคุณ
                                                                                                              fit: BoxFit.contain,
                                                                                                            ),
                                                                                                          ),
                                                                                                          // Positioned(
                                                                                                          //   left: 16,
                                                                                                          //   right: 16,
                                                                                                          //   bottom: 14,
                                                                                                          //   child: Container(
                                                                                                          //     height: 72,
                                                                                                          //     decoration: BoxDecoration(
                                                                                                          //       border: Border.all(color: Colors.red, width: 2),
                                                                                                          //       borderRadius: BorderRadius.circular(8),
                                                                                                          //     ),
                                                                                                          //   ),
                                                                                                          // ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 10),

                                                                                                // Row(
                                                                                                //   children: [
                                                                                                //     Expanded(
                                                                                                //       child: OutlinedButton(
                                                                                                //         onPressed: () => Navigator.pop(context),
                                                                                                //         child: const Text('ยกเลิก'),
                                                                                                //       ),
                                                                                                //     ),
                                                                                                //     const SizedBox(width: 12),
                                                                                                //     Expanded(
                                                                                                //       child: ElevatedButton.icon(
                                                                                                //         onPressed: (issueDate != null && expireDate != null)
                                                                                                //             ? () {
                                                                                                //                 // TODO: ส่งผลลัพธ์กลับ/บันทึก
                                                                                                //                 Navigator.pop(context);
                                                                                                //               }
                                                                                                //             : null,
                                                                                                //         icon: const Icon(Icons.check),
                                                                                                //         label: const Text('ยืนยัน'),
                                                                                                //       ),
                                                                                                //     ),
                                                                                                //   ],
                                                                                                // ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                          ),
                                                                        )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              80,
                                                                          child: Translate.TranslateAndSetText(
                                                                              (index == 1) ? 'ตั้งแต่วันที่' : 'วันที่ออก',
                                                                              ChaoAreaScreen_Color.Colors_Text1_,
                                                                              TextAlign.left,
                                                                              null,
                                                                              Font_.Fonts_T,
                                                                              14,
                                                                              2),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              150,
                                                                          child: (_tapStatus != 0)
                                                                              ? ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: null,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      (index == 1)
                                                                                          ? (sdateRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${sdateRequest.toString()}')) ?? "เลือกวันที่"}'
                                                                                          : (sdatelicenseRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${sdatelicenseRequest.toString() ?? "เลือกวันที่"}'))}',
                                                                                      // (index == 1) ? sdateRequest.toString() : sdatelicenseRequest.toString(),
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: () async {
                                                                                    final value = await _selectDate(context);
                                                                                    if (value != null) {
                                                                                      if (index == 1) {
                                                                                        sdateRequest = value.toString();
                                                                                      } else {
                                                                                        sdatelicenseRequest = value.toString();
                                                                                      }
                                                                                    }
                                                                                    setText();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      (index == 1)
                                                                                          ? (sdateRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${sdateRequest.toString()}')) ?? "เลือกวันที่"}'
                                                                                          : (sdatelicenseRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${sdatelicenseRequest.toString() ?? "เลือกวันที่"}'))}',
                                                                                      // (index == 1) ? sdateRequest.toString() : sdatelicenseRequest.toString(),
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              80,
                                                                          child: Translate.TranslateAndSetText(
                                                                              (index == 1) ? 'จนถึงวันที่' : 'วันที่หมดอายุ',
                                                                              ChaoAreaScreen_Color.Colors_Text1_,
                                                                              TextAlign.left,
                                                                              null,
                                                                              Font_.Fonts_T,
                                                                              14,
                                                                              2),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(4.0),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              150,
                                                                          child: (_tapStatus != 0)
                                                                              ? ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: null,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      (index == 1)
                                                                                          ? (ldateRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${ldateRequest.toString()}')) ?? "เลือกวันที่"}'
                                                                                          : (ldateslicenseRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${ldateslicenseRequest.toString() ?? "เลือกวันที่"}'))}',
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: () async {
                                                                                    final value = await _selectDate(context);
                                                                                    if (value != null) {
                                                                                      setState(() {
                                                                                        if (index == 1) {
                                                                                          ldateRequest = value.toString();
                                                                                        } else {
                                                                                          ldateslicenseRequest = value.toString();
                                                                                        }
                                                                                      });
                                                                                      setText();
                                                                                    }
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      (index == 1)
                                                                                          ? (ldateRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${ldateRequest.toString()}')) ?? "เลือกวันที่"}'
                                                                                          : (ldateslicenseRequest == 'เลือกวันที่')
                                                                                              ? 'เลือกวันที่'
                                                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${ldateslicenseRequest.toString() ?? "เลือกวันที่"}'))}',
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  if (_tapStatus != 0 &&
                                                                      _tapStatus !=
                                                                          2 &&
                                                                      index ==
                                                                          1)
                                                                    Center(
                                                                      child: Container(
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            border:
                                                                                Border.all(color: Colors.grey, width: 0.5),
                                                                          ),
                                                                          height: 200,
                                                                          width: 250,
                                                                          padding: const EdgeInsets.all(4.0),
                                                                          child: FutureBuilder<Uint8List?>(
                                                                            future:
                                                                                read_Announcement_Preview(announcementUuid: announceDetails.first.attachment == null ? '' : '${announceDetails.first.attachment!.announcementUuid}'),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return const CircularProgressIndicator();
                                                                              } else if (snapshot.hasError || snapshot.data == null) {
                                                                                return Center(child: const Text('ไม่สามารถโหลดภาพได้'));
                                                                              } else {
                                                                                return Image.memory(
                                                                                  snapshot.data!,
                                                                                  fit: BoxFit.contain,
                                                                                );
                                                                              }
                                                                            },
                                                                          )),
                                                                    ),
                                                                  ((_tapStatus == 0 ||
                                                                              _tapStatus ==
                                                                                  2) &&
                                                                          index ==
                                                                              1)
                                                                      ? Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              20,
                                                                              0,
                                                                              0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: SizedBox(
                                                                                  width: 80,
                                                                                  child: Translate.TranslateAndSetText('จำนวน (วัน)', ChaoAreaScreen_Color.Colors_Text1_, TextAlign.left, null, Font_.Fonts_T, 14, 2),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 60,
                                                                                child: ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: null,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      '${howDayAndMonth(type: 'day', sdate: '${sdateRequest}', ldate: '${ldateRequest}')}',
                                                                                      // '${countMonthsInclusive(sdateRequest!, ldateRequest!)}',
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(4.0),
                                                                                child: SizedBox(
                                                                                  width: 170,
                                                                                  // width:
                                                                                  //     double.infinity,
                                                                                  child: (_tapStatus == 2)
                                                                                      ? SizedBox()
                                                                                      : ElevatedButton(
                                                                                          style: ButtonStyle(
                                                                                              backgroundColor: MaterialStateProperty.all<Color>(
                                                                                                Colors.grey.shade400,
                                                                                              ),
                                                                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.grey, width: 0.5)))),
                                                                                          onPressed: () async {
                                                                                            // dynamic file, ioFile;

                                                                                            final result = await PaypickAndUpload();
                                                                                            setState(() {
                                                                                              if (kIsWeb) {
                                                                                                file = result;
                                                                                              } else {
                                                                                                ioFile = result;
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              if (ioFile != null || file != null)
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                                  child: Icon(
                                                                                                    Icons.check,
                                                                                                    color: Colors.green,
                                                                                                  ),
                                                                                                ),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.all(4.0),
                                                                                                child: Translate.TranslateAndSet_TextAutoSize(
                                                                                                  'อัพโหลดไฟล์ ',
                                                                                                  Colors.black,
                                                                                                  TextAlign.center,
                                                                                                  FontWeight.bold,
                                                                                                  FontWeight_.Fonts_T,
                                                                                                  12,
                                                                                                  16,
                                                                                                  1,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              0,
                                                                              20,
                                                                              0,
                                                                              0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: SizedBox(
                                                                                  width: 120,
                                                                                  child: Translate.TranslateAndSetText('ระยะสัญญา (เดือน)', ChaoAreaScreen_Color.Colors_Text1_, TextAlign.left, null, Font_.Fonts_T, 14, 2),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 60,
                                                                                child: ElevatedButton(
                                                                                  style: ButtonStyle(
                                                                                      backgroundColor: MaterialStateProperty.all<Color>(
                                                                                        AppbackgroundColor.Sub_Abg_Colors,
                                                                                      ),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.black, width: 0.5)))),
                                                                                  onPressed: null,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(4.0),
                                                                                    child: Translate.TranslateAndSet_TextAutoSize(
                                                                                      '${howDayAndMonth(type: 'month', sdate: '${sdatelicenseRequest}', ldate: '${ldateslicenseRequest}')}',
                                                                                      Colors.black,
                                                                                      TextAlign.center,
                                                                                      FontWeight.bold,
                                                                                      FontWeight_.Fonts_T,
                                                                                      12,
                                                                                      16,
                                                                                      1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                ],
                                                              )),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ))
                                            ],
                                          ),
                                        ),
                                      )),
                                  // Expanded(
                                  //     flex: 1,
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(8.0),
                                  //       child: Container(
                                  //         decoration: BoxDecoration(
                                  //           color: AppbackgroundColor
                                  //               .Sub_Abg_Colors,
                                  //           borderRadius:
                                  //               BorderRadius.circular(8),
                                  //           border: Border.all(
                                  //               color: Colors.white, width: 2),
                                  //         ),
                                  //         padding: const EdgeInsets.all(4.0),
                                  //         child: Column(
                                  //           children: [
                                  //             Row(
                                  //               children: [
                                  //                 Expanded(
                                  //                   child: Container(
                                  //                     decoration: BoxDecoration(
                                  //                       color: _colorsMainTap[
                                  //                           _tapStatus],
                                  //                       borderRadius:
                                  //                           BorderRadius
                                  //                               .circular(8),
                                  //                       border: Border.all(
                                  //                           color: Colors.white,
                                  //                           width: 2),
                                  //                     ),
                                  //                     padding:
                                  //                         const EdgeInsets.all(
                                  //                             4.0),
                                  //                     child: Center(
                                  //                       child: Translate
                                  //                           .TranslateAndSetText(
                                  //                               'กำหนดวันที่เริ่มประกาศ',
                                  //                               ChaoAreaScreen_Color
                                  //                                   .Colors_Text1_,
                                  //                               TextAlign.left,
                                  //                               FontWeight.bold,
                                  //                               FontWeight_
                                  //                                   .Fonts_T,
                                  //                               14,
                                  //                               2),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             SizedBox(
                                  //               height: 10,
                                  //             ),
                                  //             Container(
                                  //               decoration: BoxDecoration(
                                  //                 border: Border.all(
                                  //                     color: Colors.grey),
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(8),
                                  //               ),
                                  //               child: (_tapStatus != 0 &&
                                  //                       _tapStatus != 2)
                                  //                   ? Container(
                                  //                       padding: EdgeInsets
                                  //                           .symmetric(
                                  //                               vertical: 2),
                                  //                       decoration:
                                  //                           BoxDecoration(
                                  //                         color: _colorsSubTap[
                                  //                             _tapStatus],
                                  //                         borderRadius:
                                  //                             BorderRadius
                                  //                                 .horizontal(
                                  //                           left:
                                  //                               Radius.circular(
                                  //                                   8),
                                  //                           right:
                                  //                               Radius.circular(
                                  //                                   8),
                                  //                         ),
                                  //                       ),
                                  //                       alignment:
                                  //                           Alignment.center,
                                  //                       child: Text(
                                  //                         'วันที่เริ่มประกาศ',
                                  //                         style: TextStyle(
                                  //                           color: Colors.white,
                                  //                           fontWeight:
                                  //                               FontWeight.w500,
                                  //                         ),
                                  //                       ))
                                  //                   : Row(
                                  //                       children: List.generate(
                                  //                           options.length,
                                  //                           (index) {
                                  //                         final isSelected =
                                  //                             index ==
                                  //                                 selectedIndex;
                                  //                         return Expanded(
                                  //                           child:
                                  //                               GestureDetector(
                                  //                             onTap: () {
                                  //                               setState(() {
                                  //                                 _rangeStart =
                                  //                                     null; // เคลียร์ช่วงเมื่อเลือกวันเดี่ยว
                                  //                                 _rangeEnd =
                                  //                                     null;
                                  //                                 _selectedDay =
                                  //                                     null;
                                  //                                 selectedIndex =
                                  //                                     index;
                                  //                               });
                                  //                             },
                                  //                             child: Container(
                                  //                               padding: EdgeInsets
                                  //                                   .symmetric(
                                  //                                       vertical:
                                  //                                           2),
                                  //                               decoration:
                                  //                                   BoxDecoration(
                                  //                                 color: isSelected
                                  //                                     ? _colorsSubTap[
                                  //                                         _tapStatus]
                                  //                                     : Colors
                                  //                                         .white,
                                  //                                 borderRadius:
                                  //                                     BorderRadius
                                  //                                         .horizontal(
                                  //                                   left: index ==
                                  //                                           0
                                  //                                       ? Radius
                                  //                                           .circular(
                                  //                                               8)
                                  //                                       : Radius
                                  //                                           .zero,
                                  //                                   right: index ==
                                  //                                           1
                                  //                                       ? Radius
                                  //                                           .circular(
                                  //                                               8)
                                  //                                       : Radius
                                  //                                           .zero,
                                  //                                 ),
                                  //                               ),
                                  //                               alignment:
                                  //                                   Alignment
                                  //                                       .center,
                                  //                               child: Text(
                                  //                                 options[
                                  //                                     index],
                                  //                                 style:
                                  //                                     TextStyle(
                                  //                                   color: isSelected
                                  //                                       ? Colors
                                  //                                           .white
                                  //                                       : Colors
                                  //                                           .black,
                                  //                                   fontWeight:
                                  //                                       FontWeight
                                  //                                           .w500,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           ),
                                  //                         );
                                  //                       }),
                                  //                     ),
                                  //             ),
                                  //             Expanded(
                                  //               child: (_tapStatus != 0 &&
                                  //                       _tapStatus != 2)
                                  //                   ? Padding(
                                  //                       padding:
                                  //                           const EdgeInsets
                                  //                                   .fromLTRB(
                                  //                               4, 35, 4, 4),
                                  //                       child: Translate
                                  //                           .TranslateAndSet_TextAutoSize(
                                  //                         '${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                                  //                         Colors.grey,
                                  //                         TextAlign.center,
                                  //                         FontWeight.bold,
                                  //                         FontWeight_.Fonts_T,
                                  //                         10,
                                  //                         12,
                                  //                         1,
                                  //                       ))
                                  //                   : (selectedIndex == 0)
                                  //                       ? RangePickerWidget(
                                  //                           maxSpanDays:
                                  //                               1, // ✅ จำกัดให้เลือกได้สูงสุด 1 วัน
                                  //                           title:
                                  //                               "เลือกวันที่ใบอนุญาต",
                                  //                           onChanged:
                                  //                               (start, end) {
                                  //                             //print(
                                  //                                 "เลือกช่วง $start → $end");
                                  //                             setState(() {
                                  //                               _selectedDay =
                                  //                                   DateTime(
                                  //                                       start
                                  //                                           .year,
                                  //                                       start
                                  //                                           .month,
                                  //                                       start
                                  //                                           .day);
                                  //                             });
                                  //                             // _focusedDay =
                                  //                             //     focusedDay;
                                  //                             // _rangeStart =
                                  //                             //     null; // เคลียร์ช่วงเมื่อเลือกวันเดี่ยว
                                  //                             // _rangeEnd =
                                  //                             //     null;
                                  //                             // _rangeSelectionMode =
                                  //                             //     RangeSelectionMode
                                  //                             //         .toggledOff;
                                  //                           },
                                  //                         )
                                  //                       : RangePickerWidget(
                                  //                           maxSpanDays:
                                  //                               1, // ✅ จำกัดให้เลือกได้สูงสุด 1 วัน
                                  //                           title:
                                  //                               "เลือกวันที่ใบอนุญาต",
                                  //                           onChanged:
                                  //                               (start, end) {
                                  //                             //print(
                                  //                                 "เลือกช่วง $start → $end");
                                  //                             setState(() {
                                  //                               _selectedDay =
                                  //                                   DateTime(
                                  //                                       start
                                  //                                           .year,
                                  //                                       start
                                  //                                           .month,
                                  //                                       start
                                  //                                           .day);
                                  //                             });
                                  //                           },
                                  //                         ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     )),
                                ])),
                      (checkedStates.isEmpty || !checkedStates.contains(true))
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Translate.TranslateAndSetText(
                                    'ตัวอย่างประกาศ : ${_fulltextController.text}',
                                    ChaoAreaScreen_Color.Colors_Text1_,
                                    TextAlign.left,
                                    null,
                                    Font_.Fonts_T,
                                    14,
                                    2),
                              ),
                            ),
                      (checkedStates.isEmpty || !checkedStates.contains(true))
                          ? SizedBox()
                          : Container(
                              // width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        // width: 400,
                                        child: TextField(
                                          readOnly:
                                              _tapStatus == 0 || _tapStatus == 2
                                                  ? false
                                                  : true,
                                          controller: _titleController,
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            // label: Text('title'),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 7),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                          onChanged: (text) {
                                            setFullText();
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        child: TextField(
                                          readOnly:
                                              _tapStatus == 0 || _tapStatus == 2
                                                  ? false
                                                  : true,
                                          controller: _contentController,
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            // label: Text('content'),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 7),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                          onChanged: (text) {
                                            setFullText();
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                                  (_tapStatus == 0 || _tapStatus == 2)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: (_tapStatus == 2)
                                                ? InkWell(
                                                    onTap: () async {
                                                      final announcementUuid =
                                                          "${EditannouncementUuid}";
                                                      if (announcementUuid ==
                                                              null ||
                                                          announcementUuid ==
                                                              '') {
                                                        return Dialog_error(
                                                            context,
                                                            'ขออภัยเกิดข้อผิดพลาดกรุณาลองอีดครั้งภายหลัง ');
                                                      }
                                                      final headers =
                                                          await MyHeaders
                                                              .build();
                                                      final url = Uri.parse(
                                                        '${MyConstant().domain_v1}/admin/announcement/$announcementUuid/content',
                                                      );

                                                      final body = jsonEncode({
                                                        'title':
                                                            '${_titleController.text}',
                                                        'content':
                                                            '${_fulltextController.text}'
                                                      });

                                                      try {
                                                        final response =
                                                            await http.put(
                                                          url,
                                                          headers: headers,
                                                          body: body,
                                                        );

                                                        if (response.statusCode >=
                                                                200 &&
                                                            response.statusCode <
                                                                300) {
                                                          // print(
                                                          //     '✅ POST Edit-content success: ${response.body}');
                                                          await read_GC_zone();
                                                          await loadAnnounceMentActive();
                                                          setState(() {
                                                            _tapStatus = 0;
                                                          });
                                                          Dialog_success(
                                                              context,
                                                              'บันทึกแก้ไขสำเร็จ');
                                                        } else {
                                                          final responseJson =
                                                              jsonDecode(
                                                                  response
                                                                      .body);
                                                          return Dialog_error(
                                                              context,
                                                              'ขออภัยเกิดข้อผิดพลาดกรุณาลองอีดครั้งภายหลัง $responseJson');
                                                          // print(
                                                          //     '❌ POST Edit-contentfailed [${response.statusCode}]: $responseJson');
                                                        }
                                                      } catch (e, stack) {
                                                        return Dialog_error(
                                                            context,
                                                            'ขออภัยเกิดข้อผิดพลาดกรุณาลองอีดครั้งภายหลัง ');
                                                        // print(
                                                        //     '💥 Exception in postEdit-content: $e');
                                                        // print(stack.toString());
                                                        // return null;
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        color: (_tapStatus ==
                                                                    0 ||
                                                                _tapStatus == 2)
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'บันทึกแก้ไข',
                                                                Colors.white,
                                                                TextAlign.left,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                2),
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    // onTap: () async {
                                                    //   // 1) validate ก่อน
                                                    //   final error = _validateForm();
                                                    //   if (error != null) {
                                                    //     Dialog_error(context, error);
                                                    //     return;
                                                    //   }

                                                    //   // 2) ยืนยัน
                                                    //   final ok =
                                                    //       await _confirmSave(context);
                                                    //   if (!ok) return;

                                                    //   // 3) ทำงานจริง
                                                    //   await _performSave(context);
                                                    // },
                                                    onTap: (checkedStates
                                                                .isEmpty ||
                                                            !checkedStates
                                                                .contains(true))
                                                        ? () async {
                                                            Dialog_error(
                                                                context,
                                                                'กรุณาระบุข้อมูลให้ครบถ้วน');
                                                          }
                                                        : () async {
                                                            List<
                                                                    Map<String,
                                                                        dynamic>>
                                                                meta = [
                                                              {
                                                                "key": "author",
                                                                "value": "Admin"
                                                              },
                                                              {
                                                                "key":
                                                                    "version",
                                                                "value": "1.0"
                                                              },
                                                            ];
                                                            // setState(() {
                                                            //   // checkedStates[index] =
                                                            //   //     value ?? false;

                                                            //   selectedSer = [];
                                                            //   final Set<String>
                                                            //       selectedZones = {};
                                                            //   json_zones
                                                            //       .clear(); // ✅ เคลียร์ก่อนแอดใหม่

                                                            //   for (int i = 0;
                                                            //       i <
                                                            //           checkedStates
                                                            //               .length;
                                                            //       i++) {
                                                            //     if (checkedStates[
                                                            //         i]) {
                                                            //       selectedSer.add(
                                                            //           zoneModels[i]
                                                            //               .ser!);
                                                            //       selectedZones.add(
                                                            //           zoneModels[i]
                                                            //                   .zn ??
                                                            //               '');

                                                            //       json_zones.add({
                                                            //         "property_id": 0,
                                                            //         "property_pn":
                                                            //             "0",
                                                            //         "zone_id": int.parse(
                                                            //                 zoneModels[
                                                            //                         i]
                                                            //                     .ser!) ??
                                                            //             0,
                                                            //         "zone_pn":
                                                            //             zoneModels[i]
                                                            //                     .zn ??
                                                            //                 '',
                                                            //         "subzone_id": int.parse(
                                                            //                 zoneModels[
                                                            //                         i]
                                                            //                     .sub_zone!) ??
                                                            //             0,
                                                            //         "subzone_pn": "0"
                                                            //       });
                                                            //     }
                                                            //   }

                                                            //   final sortedZones =
                                                            //       selectedZones
                                                            //           .toList()
                                                            //         ..sort();
                                                            //   selectedZonesZn =
                                                            //       sortedZones
                                                            //           .join(', ');

                                                            //   //print(
                                                            //   //  '✅ Checked ser list: $selectedSer');
                                                            //   //print(
                                                            //   // json_zones);
                                                            //   // setText();
                                                            // });
                                                            // print({
                                                            //   'fileBytes': file,
                                                            //   'filename':
                                                            //       '${_titleController.text}',
                                                            //   'file': ioFile,
                                                            //   'lang': 'TH',
                                                            //   'title':
                                                            //       '${_titleController.text}',
                                                            //   'content':
                                                            //       '${_fulltextController.text}',
                                                            //   meta: meta,
                                                            //   'zones': json_zones,
                                                            //   'cDateStart':
                                                            //       "$sdatelicenseRequest",
                                                            //   'cDateEnd':
                                                            //       "$ldateslicenseRequest",
                                                            //   'effectiveAt':
                                                            //       "$sdateRequest",
                                                            //   'expiredAt':
                                                            //       "$ldateRequest",
                                                            //   'publishedAt': DateFormat(
                                                            //           'yyyy-MM-dd')
                                                            //       .format(DateTime.parse(
                                                            //           sdateRequest
                                                            //               .toString())),
                                                            // });

                                                            final response =
                                                                await MainPost_AnnounceMent(
                                                              fileBytes: file,
                                                              filename:
                                                                  '${_titleController.text}',
                                                              file: ioFile,
                                                              lang: 'TH',
                                                              title:
                                                                  '${_titleController.text}',
                                                              content:
                                                                  '${_fulltextController.text}',
                                                              meta: meta,
                                                              zones: json_zones,
                                                              cDateStart:
                                                                  "$sdatelicenseRequest",
                                                              cDateEnd:
                                                                  "$ldateslicenseRequest",
                                                              effectiveAt:
                                                                  "$sdateRequest",
                                                              expiredAt:
                                                                  "$ldateRequest",
                                                              publishedAt: DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(DateTime.parse(
                                                                      sdateRequest
                                                                          .toString())),
                                                              //  DateFormat(
                                                              //         'yyyy-MM-dd')
                                                              //     .format(DateTime.parse(
                                                              //         _selectedDay
                                                              //             .toString())),
                                                            );

                                                            if (response !=
                                                                    null &&
                                                                (response.statusCode ==
                                                                        200 ||
                                                                    response.statusCode ==
                                                                        201)) {
                                                              //print(
                                                              //    '✅ Upload Success');
                                                            } else {
                                                              //print(
                                                              //   '❌ Upload Failed');
                                                            }

                                                            if (response!
                                                                        .statusCode ==
                                                                    200 ||
                                                                response.statusCode ==
                                                                    201 ||
                                                                response.statusCode ==
                                                                    409) {
                                                              Dialog_success(
                                                                  context,
                                                                  'บันทึกสำเร็จ');

                                                              setState(() {
                                                                checkedStates =
                                                                    [];
                                                                selectedSer =
                                                                    [];
                                                                selectedZonesZn =
                                                                    '';
                                                                _rangeStart =
                                                                    null;
                                                                _rangeEnd =
                                                                    null;
                                                                _focusedDay =
                                                                    DateTime
                                                                        .now();
                                                                _selectedDay =
                                                                    null;

                                                                sdateRequest =
                                                                    'เลือกวันที่';

                                                                sdatelicenseRequest =
                                                                    'เลือกวันที่';

                                                                ldateRequest =
                                                                    'เลือกวันที่';

                                                                ldateslicenseRequest =
                                                                    'เลือกวันที่';
                                                                _tapStatus = 0;
                                                              });
                                                              setText();
                                                              loadAnnounceMentActive();
                                                            } else if (response !=
                                                                null) {
                                                              final result =
                                                                  json.decode(
                                                                      response
                                                                          .body);
                                                              Dialog_error(
                                                                  context,
                                                                  'เกิดผิดพลาดบันทึกไม่สำเร็จ ${result['message']}');
                                                            } else {
                                                              Dialog_error(
                                                                  context,
                                                                  'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
                                                            }
                                                          },
                                                    child: Container(
                                                      height: 100,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        color: (_tapStatus ==
                                                                    0 ||
                                                                _tapStatus == 2)
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'บันทึก',
                                                                Colors.white,
                                                                TextAlign.left,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                2),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        )
                                      : (_tapStatus == 3)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () async {
                                                    final response =
                                                        await read_Announcement_Delete(
                                                            announcementUuid:
                                                                announceDetails
                                                                        .first
                                                                        .uuid ??
                                                                    '');
                                                    if (response != null &&
                                                        (response.statusCode ==
                                                                200 ||
                                                            response.statusCode ==
                                                                201 ||
                                                            response.statusCode ==
                                                                409)) {
                                                      Dialog_success(context,
                                                          'ยกเลิกสำเร็จ');
                                                    } else if (response !=
                                                        null) {
                                                      final result =
                                                          json.decode(
                                                              response.body);
                                                      Dialog_error(context,
                                                          'เกิดผิดพลาดยกเลิกไม่สำเร็จ ${result['message']}');
                                                    } else {
                                                      Dialog_error(context,
                                                          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
                                                    }
                                                    setState(() {
                                                      checkedStates = [];
                                                      selectedSer = [];
                                                      selectedZonesZn = '';
                                                      _rangeStart = null;
                                                      _rangeEnd = null;
                                                      _focusedDay =
                                                          DateTime.now();
                                                      _selectedDay = null;

                                                      sdateRequest =
                                                          'เลือกวันที่';

                                                      sdatelicenseRequest =
                                                          'เลือกวันที่';

                                                      ldateRequest =
                                                          'เลือกวันที่';

                                                      ldateslicenseRequest =
                                                          'เลือกวันที่';
                                                      _tapStatus = 0;
                                                    });
                                                    setText();
                                                    loadAnnounceMentActive();
                                                  },
                                                  child: Container(
                                                    height: 100,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      color: _colorsMainTap[
                                                          _tapStatus],
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8),
                                                      ),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 0.5),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ยืนยันการยกเลิก',
                                                              Colors.white,
                                                              TextAlign.left,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              2),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      if (_tapStatus == 0)
                        SizedBox(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        'ประกาศทั้งหมด',
                                        ChaoAreaScreen_Color.Colors_Text1_,
                                        TextAlign.left,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                // width: MediaQuery.of(context).size.width * 0.85,
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          height: 400,
                                          decoration: BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          padding: const EdgeInsets.all(2.0),
                                          child: Column(
                                            children: [
                                              FilterBar(
                                                  context), // 👈 เรียก Widget แบบฟังก์ชัน
                                              Expanded(
                                                child: (announceActive.isEmpty)
                                                    ? Card(
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6)),
                                                        child: Container(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(4),
                                                                child: Text(
                                                                    "ไม่พบข้อมูล",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            16)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : ListView.separated(
                                                        itemCount:
                                                            announceActive
                                                                .length,
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        separatorBuilder:
                                                            (_, __) =>
                                                                Divider(),
                                                        itemBuilder:
                                                            (context, index) {
                                                          final announce =
                                                              announceActive[
                                                                  index];
                                                          final effectiveAt =
                                                              DateTime.parse(announce
                                                                  .effectiveAt
                                                                  .toString());
                                                          final today =
                                                              DateTime.now();

// ตัดเวลาออก
                                                          final effectiveDate =
                                                              DateTime(
                                                                  effectiveAt
                                                                      .year,
                                                                  effectiveAt
                                                                      .month,
                                                                  effectiveAt
                                                                      .day);
                                                          final todayDate =
                                                              DateTime(
                                                                  today.year,
                                                                  today.month,
                                                                  today.day);

// เช็กว่า effectiveDate มากกว่า todayDate
                                                          final isFutureDate =
                                                              effectiveDate
                                                                  .isAfter(
                                                                      todayDate);

                                                          return Card(
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6)),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                            "${index + 1}. ${announce.announcement!.content!.title} ${announce.announcement!.properties!.first.zonePn ?? ""}",
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                                      ),
                                                                      // Expanded(
                                                                      //   flex: 2,
                                                                      //   child: Text(
                                                                      //       "${index + 1} กำหนดการณ์ต่ออายุใบอนุญาตฯ",
                                                                      //       style: TextStyle(
                                                                      //           fontWeight:
                                                                      //               FontWeight.bold,
                                                                      //           fontSize: 16)),
                                                                      // ),
                                                                      Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              RichText(
                                                                            text:
                                                                                TextSpan(
                                                                              text: 'เปิดรับคำร้องตั้งแต่วันที่ ',
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                              children: <TextSpan>[
                                                                                TextSpan(text: '${DateFormat('dd-MM-yyyy').format(DateTime.parse(announce.effectiveAt.toString()))}', style: DefaultTextStyle.of(context).style),
                                                                              ],
                                                                            ),
                                                                          )

                                                                          //  Text(
                                                                          //     "เปิดรับคำร้องตั้งแต่วันที่ ${DateFormat('dd-MM-yyyy').format(DateTime.parse(announce.effectiveAt.toString()))} "),
                                                                          ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            text:
                                                                                ' ถึง ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                            children: <TextSpan>[
                                                                              TextSpan(text: '${DateFormat('dd-MM-yyyy').format(DateTime.parse(announce.expiredAt.toString()))} ', style: DefaultTextStyle.of(context).style),
                                                                              TextSpan(
                                                                                text: '(${howDayAndMonth(type: 'day', sdate: '${announce.effectiveAt}', ldate: '${announce.expiredAt}')} วัน)',
                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // Text("ถึง ${DateFormat('dd-MM-yyyy').format(DateTime.parse(announce.expiredAt.toString()))} (${howDayAndMonth(type: 'day', sdate: '${announce.effectiveAt}', ldate: '${announce.expiredAt}')} วัน)")),
                                                                      // Expanded(
                                                                      //   flex: 1,
                                                                      //   child: Text(
                                                                      //       "วันที่เริ่มประกาศ:  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(announce.publishedAt.toString()))}"),
                                                                      // ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            "${announce.computedStatus}"),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child: (isFutureDate == false ||
                                                                                _tapStatuAnnounce == 2)
                                                                            ? SizedBox()
                                                                            : ElevatedButton(
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: MaterialStateProperty.all<Color>(
                                                                                    Colors.black,
                                                                                  ),
                                                                                ),
                                                                                onPressed: _isPublishing
                                                                                    ? null
                                                                                    : () async {
                                                                                        // final effectiveAt = DateTime.parse(announce.effectiveAt.toString());

                                                                                        // final today = DateTime.now();

                                                                                        // // เทียบเฉพาะวัน / เดือน / ปี ไม่เอาเวลา
                                                                                        // final isSameDate = today.year == effectiveAt.year && today.month == effectiveAt.month && today.day == effectiveAt.day;

                                                                                        // if (isSameDate) {
                                                                                        //   Dialog_error(context, 'ประการถูกเผยแพร่ไปแล้ว (${announce.computedStatus})');
                                                                                        //   return;
                                                                                        // }
                                                                                        final pickedDate = await _confirmSave(context);
                                                                                        if (pickedDate == null) return;

                                                                                        setState(() {
                                                                                          _selectedDay = pickedDate;
                                                                                          _isPublishing = true; // 🔒 ปิดปุ่ม
                                                                                        });

                                                                                        final String? announcementUuid = announce?.announcementUuid;
                                                                                        if (announcementUuid == null) {
                                                                                          if (context.mounted) Dialog_error(context, 'ไม่พบรหัสประกาศ (uuid)');
                                                                                          setState(() => _isPublishing = false);
                                                                                          return;
                                                                                        }

                                                                                        final String publishedAt = DateFormat('yyyy-MM-dd').format(pickedDate);
                                                                                        final headers = await MyHeaders.build(); // 🔐 เตรียม token/headers

                                                                                        final uri = Uri.parse(
                                                                                          '${MyConstant().domain_v1}/admin/announcement/${Uri.encodeComponent(announcementUuid)}/publish',
                                                                                        );

                                                                                        final body = jsonEncode({
                                                                                          'published_at': publishedAt
                                                                                        });
                                                                                        //print({
                                                                                        //'uri': uri,
                                                                                        // 'published_at': publishedAt
                                                                                        // });

                                                                                        try {
                                                                                          // แนะนำ: client + timeout กันเคสเครือข่ายค้าง
                                                                                          final client = http.Client();
                                                                                          final resp = await client.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 20));
                                                                                          client.close();

                                                                                          if (resp.statusCode == 200 || resp.statusCode == 201) {
                                                                                            if (context.mounted) {
                                                                                              Dialog_success(context, 'เผยแพร่สำเร็จ');
                                                                                              await loadAnnounceMentActive();
                                                                                            }
                                                                                          } else if (resp.statusCode == 401) {
                                                                                            if (context.mounted) {
                                                                                              Dialog_error(context, 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่');
                                                                                            }
                                                                                          } else if (resp.statusCode == 404) {
                                                                                            if (context.mounted) {
                                                                                              Dialog_error(context, 'ไม่พบประกาศที่ระบุ (404)');
                                                                                            }
                                                                                          } else if (resp.statusCode == 409) {
                                                                                            if (context.mounted) {
                                                                                              Dialog_error(context, 'สถานะขัดแย้ง (409): อาจเผยแพร่แล้ว');
                                                                                            }
                                                                                          } else if (resp.statusCode == 422) {
                                                                                            // validation error จาก backend (Laravel มักส่งรูปแบบนี้)
                                                                                            final msg = _extractApiErrorMessage(resp.body);
                                                                                            if (context.mounted) Dialog_error(context, 'ข้อมูลไม่ถูกต้อง:$msg');
                                                                                          } else {
                                                                                            final msg = _extractApiErrorMessage(resp.body);
                                                                                            if (context.mounted) {
                                                                                              Dialog_error(context, 'เผยแพร่ไม่สำเร็จ(${resp.statusCode})$msg');
                                                                                            }
                                                                                          }
                                                                                        } on TimeoutException {
                                                                                          if (context.mounted) {
                                                                                            Dialog_error(context, 'หมดเวลาเชื่อมต่อ (timeout)');
                                                                                          }
                                                                                        } catch (e) {
                                                                                          if (context.mounted) {
                                                                                            Dialog_error(context, 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e');
                                                                                          }
                                                                                        } finally {
                                                                                          if (mounted) setState(() => _isPublishing = false); // 🔓 เปิดปุ่มคืน
                                                                                        }
                                                                                      },
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                  child: Translate.TranslateAndSet_TextAutoSize(
                                                                                    'แจ้งเตือนผู้เช่า',
                                                                                    Colors.white,
                                                                                    TextAlign.center,
                                                                                    FontWeight.bold,
                                                                                    FontWeight_.Fonts_T,
                                                                                    10,
                                                                                    12,
                                                                                    1,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            ElevatedButton(
                                                                          style:
                                                                              ButtonStyle(
                                                                            backgroundColor:
                                                                                MaterialStateProperty.all<Color>(
                                                                              Colors.green,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await loadAnnounceMentDetails(announcementUuid: "${announce.announcementUuid}");
                                                                            setState(() {
                                                                              EditannouncementUuid = "${announce.announcementUuid}";
                                                                            });
                                                                            if (announceDetails.length >
                                                                                0) {
                                                                              setState(() {
                                                                                _newNotice = true;
                                                                                _tapStatus = 1;
                                                                              });

                                                                              fetchData();
                                                                            } else {
                                                                              Dialog_error(context, 'เกิดข้อผิดพลาดไม่สามารถโหลดข้อมูลได้');
                                                                            }
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(4.0),
                                                                            child:
                                                                                Translate.TranslateAndSet_TextAutoSize(
                                                                              'เรียกดู',
                                                                              Colors.black,
                                                                              TextAlign.center,
                                                                              FontWeight.bold,
                                                                              FontWeight_.Fonts_T,
                                                                              10,
                                                                              12,
                                                                              1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child: Translate
                                                                          .TranslateAndSet_TextAutoSize(
                                                                        '# ข้อมูลประกาศ : ',
                                                                        Colors
                                                                            .green,
                                                                        TextAlign
                                                                            .center,
                                                                        null,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        10,
                                                                        12,
                                                                        1,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                          "${announce.announcement!.content!.content}",
                                                                          style: TextStyle(
                                                                              color: Colors.grey,
                                                                              // fontWeight:
                                                                              //     FontWeight
                                                                              //         .bold,
                                                                              fontSize: 14)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ))));
  }

  bool _isPublishing = false; // <- ประกาศที่ state

  String _extractApiErrorMessage(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map<String, dynamic>) {
        if (j['message'] != null) return j['message'].toString();
        if (j['errors'] is Map) {
          final errs = (j['errors'] as Map)
              .values
              .whereType<List>()
              .expand((e) => e)
              .map((e) => e.toString())
              .join('\n• ');
          if (errs.isNotEmpty) return errs;
        }
        if (j['error'] != null) return j['error'].toString();
      }
    } catch (_) {}
    return body; // fallback
  }

// 1) ตัวช่วยเช็คสถานะเลือก
  bool get _hasAnyChecked => checkedStates.any((e) => e == true);

// 2) ยืนยันก่อนบันทึก (return true เมื่อกด Approve)
  Future<DateTime?> _confirmSave(BuildContext context) async {
    int localSelectedIndex = selectedIndex;
    DateTime? localSelectedDay = _selectedDay;

    final result = await showDialog<DateTime?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final safeTap = (_tapStatus >= 0 && _tapStatus < _colorsMainTap.length)
            ? _tapStatus
            : 0;

        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorsMainTap[safeTap],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Translate.TranslateAndSetText(
                              'โปรดเลือกวันที่ต้องการแจ้งเตือนผู้เช่า',
                              ChaoAreaScreen_Color.Colors_Text1_,
                              TextAlign.left,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              14,
                              2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (_tapStatus != 0 && _tapStatus != 2)
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _colorsSubTap[safeTap],
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                                right: Radius.circular(8),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'วันที่เริ่มประกาศ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Row(
                            children: List.generate(options.length, (index) {
                              final isSelected = index == localSelectedIndex;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setLocalState(() {
                                      localSelectedDay = null;
                                      localSelectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _colorsSubTap[safeTap]
                                          : Colors.white,
                                      borderRadius: BorderRadius.horizontal(
                                        left: index == 0
                                            ? const Radius.circular(8)
                                            : Radius.zero,
                                        right: index == (options.length - 1)
                                            ? const Radius.circular(8)
                                            : Radius.zero,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      options[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  minWidth: 200,
                  maxWidth: 600,
                  maxHeight: 420,
                ),
                child: SizedBox(
                  width: 520,
                  height: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              children: [
                                if (_tapStatus != 0 && _tapStatus != 2)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(4, 24, 4, 4),
                                    child:
                                        Translate.TranslateAndSet_TextAutoSize(
                                      localSelectedDay != null
                                          ? DateFormat('yyyy-MM-dd')
                                              .format(localSelectedDay!)
                                          : 'ยังไม่ได้เลือก',
                                      Colors.grey,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      10,
                                      12,
                                      1,
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: 380,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6)),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.7),
                                    ),
                                    child: RangePickerWidget(
                                      maxSpanDays: 1,
                                      title: "เลือกวันที่ใบอนุญาต",
                                      onChanged: (start, end) {
                                        final picked = DateTime(
                                            start.year, start.month, start.day);
                                        setLocalState(
                                            () => localSelectedDay = picked);
                                      },
                                    ),
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
              actions: <Widget>[
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
                TextButton(
                  child: const Text('บันทึก'),
                  onPressed: localSelectedDay == null
                      ? null
                      : () => Navigator.of(ctx).pop(localSelectedDay),
                ),
              ],
            );
          },
        );
      },
    );

    return result; // DateTime? (null = ยกเลิก)
  }

// 3) ตรวจความครบถ้วนขั้นพื้นฐาน (ปรับตามฟอร์มจริงได้)
  String? _validateForm() {
    // ตัวอย่าง: ตรวจวันว่าเลือกแล้ว (ไม่ใช่สตริง "เลือกวันที่")
    final badDate =
        (s) => s == null || s.toString().trim().isEmpty || s == 'เลือกวันที่';

    if (!_hasAnyChecked)
      return 'กรุณาระบุข้อมูลให้ครบถ้วน (ยังไม่ได้เลือกข้อมูล)';
    if (badDate(sdateRequest)) return 'กรุณาเลือกวันที่เริ่มต้น';
    if (badDate(ldateRequest)) return 'กรุณาเลือกวันที่สิ้นสุด';
    // เพิ่ม validation อื่นๆ ได้ เช่น title/content ว่าง
    if (_titleController.text.trim().isEmpty) return 'กรุณากรอกหัวข้อประกาศ';
    if (_fulltextController.text.trim().isEmpty) return 'กรุณากรอกรายละเอียด';

    return null; // ผ่าน
  }

// 4) เรียก API บันทึก (แยกความรับผิดชอบให้ชัด)
  Future<void> _performSave(BuildContext context) async {
    // meta ตัวอย่าง (ปรับเพิ่มลดได้)
    final List<Map<String, dynamic>> meta = [
      {"key": "author", "value": "Admin"},
      {"key": "version", "value": "1.0"},
    ];

    // วันที่เผยแพร่: ใช้ selectedDay ถ้า null จะ fallback เป็นวันนี้
    final published = (_selectedDay ?? DateTime.now());
    final publishedStr = DateFormat('yyyy-MM-dd').format(published);

    try {
      // แนะนำแสดง loader ระหว่างอัปโหลด
      // เช่น ChaoAppLoader.show(...);  // ถ้ามี lib ของคุณ
      final response = await MainPost_AnnounceMent(
        fileBytes: file,
        filename: _titleController.text,
        file: ioFile,
        lang: 'TH',
        title: _titleController.text,
        content: _fulltextController.text,
        meta: meta,
        zones: json_zones,
        cDateStart: '$sdatelicenseRequest',
        cDateEnd: '$ldateslicenseRequest',
        effectiveAt: '$sdateRequest',
        expiredAt: '$ldateRequest',
        publishedAt: publishedStr,
      );

      // ตรวจผลลัพธ์
      final okStatus = {
        200,
        201,
        409
      }; // 409 = ซ้ำ แต่ถือว่าบันทึกเวอร์ชัน/สถานะได้
      if (response != null && okStatus.contains(response.statusCode)) {
        if (!context.mounted) return;
        Dialog_success(context, 'บันทึกสำเร็จ');

        // reset state หลังบันทึก
        if (context.mounted) {
          setState(() {
            checkedStates = [];
            selectedSer = [];
            selectedZonesZn = '';
            _rangeStart = null;
            _rangeEnd = null;
            _focusedDay = DateTime.now();
            _selectedDay = null;

            sdateRequest = 'เลือกวันที่';
            sdatelicenseRequest = 'เลือกวันที่';
            ldateRequest = 'เลือกวันที่';
            ldateslicenseRequest = 'เลือกวันที่';
            _tapStatus = 0;
          });
          setText();
          await loadAnnounceMentActive();
        }
      } else if (response != null) {
        // มี response แต ่status ไม่โอเค -> แสดง message จาก backend
        final result = json.decode(response.body);
        if (!context.mounted) return;
        Dialog_error(
            context, 'เกิดผิดพลาดบันทึกไม่สำเร็จ ${result['message']}');
      } else {
        if (!context.mounted) return;
        Dialog_error(context, 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
      }
    } catch (e) {
      if (!context.mounted) return;
      Dialog_error(context, 'เกิดข้อผิดพลาด: $e');
    } finally {
      // ChaoAppLoader.hide(); // ถ้าใช้ loader
    }
  }

  Widget _filterButton(String label, {required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      child: Text(label, style: TextStyle(color: Colors.black)),
    );
  }

  Widget FilterBar(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    Widget _filterButton(String label, IconData icon,
        {required VoidCallback onTap,
        required Color colorsx,
        required Color textcolors}) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textcolors),
        label: Text(label, style: TextStyle(color: textcolors)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: colorsx,
          side: BorderSide(color: Colors.grey.shade400),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppbackgroundColor.TiTile_Box,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          // border: Border.all(
          //     color: Colors.white,
          //     width: 2),
        ),
        padding: EdgeInsets.all(6),
        child: Row(
          children: [
            SizedBox(
              height: 45,
              child: _filterButton("กำลังประกาศ", Icons.campaign, onTap: () {
                setState(() {
                  _tapStatuAnnounce = 1;
                });
                loadAnnounceMentActive();
                //print("กำลังประกาศ");
              },
                  colorsx: (_tapStatuAnnounce == 1)
                      ? Colors.green
                      : Colors.green.shade200,
                  textcolors: Colors.black),
            ),
            SizedBox(width: 8),
            SizedBox(
              height: 45,
              child: _filterButton(
                  "ประกาศทั้งหมด",
                  // "ประกาศหมดอายุ/ยกเลิก",
                  Icons.hourglass_empty, onTap: () async {
                setState(() {
                  _tapStatuAnnounce = 2;
                });
                loadAnnounceMentHistory();
                //print("ประกาศหมดอายุ");
              },
                  colorsx: (_tapStatuAnnounce == 2)
                      ? Colors.black
                      : Colors.grey.shade700,
                  textcolors: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  // border: Border.all(
                  //     color: Colors.white,
                  //     width: 2),
                ),
                child: TextField(
                  controller: _searchController,
                  readOnly: (announceActive.isEmpty) ? true : false,
                  decoration: InputDecoration(
                    hintText: (announceActive.isEmpty)
                        ? 'ดาวน์โหลดข้อมูล...'
                        : 'Search...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    //print("Search: $value");
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            SizedBox(
              height: 45,
              child: _filterButton("Sort by", Icons.sort, onTap: () {
                //print("Sort by");
                setState(() {
                  announceActive
                      .sort((a, b) => b.effectiveAt!.compareTo(a.effectiveAt!));
                });
              }, colorsx: Colors.white, textcolors: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoneCheckboxList extends StatefulWidget {
  @override
  _ZoneCheckboxListState createState() => _ZoneCheckboxListState();
}

class _ZoneCheckboxListState extends State<ZoneCheckboxList> {
  final List<String> _zones = [
    'ถนนวิษณานนท์',
    'ถนนวิษณานนท์',
    'ถนนวิษณานนท์',
    'ถนนวิษณานนท์',
  ];

  final List<String> _selectedZones = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _zones.map((zone) {
        return CheckboxListTile(
          title: Text(zone),
          value: _selectedZones.contains(zone),
          onChanged: (selected) {
            setState(() {
              if (selected!) {
                _selectedZones.add(zone);
              } else {
                _selectedZones.remove(zone);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
