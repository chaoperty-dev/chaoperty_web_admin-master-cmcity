import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AdminScaffold/AdminScaffold.dart';
import '../Constant/Myconstant.dart';
import '../Constant/api_cache.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/test_print_name.dart';
import '../Style/view_pagenow.dart';
import '../main.dart';
import 'List_CMM/list_cmm.dart';
import 'Model/Review_Model.dart';
import 'request_examiner1_cmm.dart';
import 'request_examiner2_cmm.dart';
import 'request_examiner_plugins_cmm.dart';
import 'unity/API_approvals_lastaction.dart';
import 'unity/API_approvals_roles&checkup.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';
import 'unity/FormatPhone.dart';
import 'unity/SecurePrefs_helper.dart';
import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'unity/API_admin_signature.dart';
import 'PDF_CMM/unity_pdf_cmm/unitypdf_cmm.dart';
import 'Model/ReviewUuid_Model.dart';
import 'Make_contract_CMM/new_contract_popup_cmm.dart';
import 'unity/API_properties.dart';
import 'unity/show_dialog_cmm.dart';

class AvatarPrettyLoader extends StatefulWidget {
  final String asset;
  final double size;
  const AvatarPrettyLoader({super.key, required this.asset, this.size = 56});

  @override
  State<AvatarPrettyLoader> createState() => _AvatarPrettyLoaderState();
}

class _AvatarPrettyLoaderState extends State<AvatarPrettyLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 12,
      height: widget.size + 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _RingPainter(progress: _controller.value),
              ),
            ),
          ),
          ClipOval(
            child: Image.asset(
              widget.asset,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 4.0;
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        Colors.blueAccent,
        Colors.purpleAccent,
        Colors.tealAccent,
        Colors.blueAccent,
      ],
      stops: const [0.0, 0.5, 0.85, 1.0],
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final radius = (size.shortestSide - stroke) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      0,
      math.pi * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class RequestContract_CMM extends StatefulWidget {
  final String? route_getdata;
  final int? ser_title;
  const RequestContract_CMM({super.key, this.route_getdata, this.ser_title});

  @override
  State<RequestContract_CMM> createState() => _RequestContract_CMMState();
}

class _RequestContract_CMMState extends State<RequestContract_CMM> {
  static final _apiCache = ApiCache(ttl: const Duration(seconds: 60));
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;

  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  var nFormat3 = NumberFormat("#,##0", "en_US");
  DateTime datex = DateTime.now();

  final TextEditingController Dropdown_Controller_zone_Sub =
      TextEditingController();
  final TextEditingController Dropdown_Controller = TextEditingController();
  final TextEditingController Search_Controller = TextEditingController();
  final Set<String> _selectedUuids = {};
  final Map<String, TextEditingController> _rowBookNoControllers = {};
  final Map<String, TextEditingController> _rowBookDateControllers = {};
  final TextEditingController _bulkNoteNumberController =
      TextEditingController();
  final TextEditingController _bulkNoteDateController = TextEditingController();
  final ValueNotifier<int> _searchMenuTick = ValueNotifier<int>(0);
  List<ZoneModel> zoneModels = [];
  List<SubZoneModel> subzoneModels = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];

  List<Map<String, String>> _searchList = [
    {"ser": "0", "st": "0", "title": "เลขที่สัญญา", "value": "cid"},
    {"ser": "1", "st": "0", "title": "บริเวณ", "value": "subzone"},
    {"ser": "2", "st": "0", "title": "โซนพื้นที่", "value": "zn"},
    {"ser": "3", "st": "0", "title": "รหัสพื้นที่", "value": "ln"},
    {"ser": "4", "st": "1", "title": "ชื่อผู้ติดต่อ", "value": "scname"},
    {"ser": "5", "st": "0", "title": "เบอร์โทรติดต่อ", "value": "tel"},
    {"ser": "6", "st": "0", "title": "วันที่สิ้นสุดสัญญา", "value": "ldate"},
    {"ser": "7", "st": "0", "title": "รหัสรายการ", "value": "uuid"},
  ];

  String searchQuery = "";
  int currentPage_1 = 0;
  static const int rowsPerPage_1 = 50;

  bool sortAscending = true;
  String sortColumn = "รหัสพื้นที่";
  Timer? _debounce;
  bool isLoading = false;
  bool isLoading_main = false;
  String?
      _effectiveRouteData; // ล้างได้เมื่อ user clear search (ไม่เหมือน widget.route_getdata ที่เปลี่ยนไม่ได้)

  String Ser_nowpage = '3';
  String tappedIndex_ = '';
  String? zone_Subser, zone_Subname, zone_ser, zone_name;
  List<Map<String, dynamic>> title_data = [];
  int ser_tap = 2, serApitap = 2;
  int? ser_title;

  // API Response
  List<dynamic> reviewFlowUuid = [];
  List<ReviewModel> reviewModels = [];
  String? linksFirst, linksLast, linksPrev, linksNext, searchText;
  int? currentPage, lastPage, perPage = 50, totalPage;
  final ValueNotifier<int> _ac7MenuTick = ValueNotifier<int>(0);

  bool _bulkVerifyProcessing = false;
  double _bulkVerifyProgress = 0.0;
  String _bulkVerifyStatusText = '';

  String? _lastRouteData;
  bool _userClearedSearch =
      false; // ✅ flag เพื่อตรวจสอบว่าผู้ใช้ล้างค้นหาหรือไม่

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _lastRouteData = widget.route_getdata;
    _loadAdminSignature();
    addAcListTitle2();
    addAcListTitle().then((_) {
      Loding_route_getdata();
    });
    read_GC_zone().then((_) {
      read_GC_Sub_zone();
    });

    Search_Controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(RequestContract_CMM oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้า route_getdata เปลี่ยนจากภายนอก และผู้ใช้ไม่ได้ล้างค้นหา ให้อัปเดตและโหลดข้อมูลใหม่
    if (widget.route_getdata != _lastRouteData && !_userClearedSearch) {
      _lastRouteData = widget.route_getdata;
      _effectiveRouteData = widget.route_getdata;
      Loding_route_getdata();
    }
  }

  @override
  void dispose() {
    _ac7MenuTick.dispose();
    _searchMenuTick.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    Dropdown_Controller_zone_Sub.dispose();
    Dropdown_Controller.dispose();
    Search_Controller.dispose();
    _rowBookNoControllers.forEach((_, c) => c.dispose());
    _rowBookDateControllers.forEach((_, c) => c.dispose());
    _debounce?.cancel();
    super.dispose();
  }

  String fullNameAdmin = '',
      positionAdmin = '',
      proFileUuid = '',
      sigNatureUuid = '';
  Uint8List? signaturesUrl;

  Future<void> _loadAdminSignature() async {
    try {
      final response = await read_AdminSignature();
      if (response != null && response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          proFileUuid = result['data']['profile_uuid'] ?? '';
          fullNameAdmin = result['data']['profile'] ?? '';
          sigNatureUuid = result['data']['signature_uuid'] ?? '';
          positionAdmin = result['data']['position_name'] ?? '';
        });
        if (sigNatureUuid.isNotEmpty) {
          final sigResp = await img_signatureUuid(signatureUuid: sigNatureUuid);
          if (sigResp != null && sigResp.statusCode == 200) {
            setState(() {
              signaturesUrl = sigResp.bodyBytes;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading admin signature: $e');
    }
  }

  String _selectedTitlesLabel() {
    final titles = _searchList
        .where((e) => e['st'] == '1')
        .map((e) => e['title'])
        .whereType<String>()
        .where((t) => t.trim().isNotEmpty)
        .toList();

    if (titles.isEmpty) return 'พิมพ์คำค้นหา...';
    return titles.length <= 2
        ? titles.join(', ')
        : '${titles.take(2).join(', ')} +${titles.length - 2}';
  }

  Future<void> addAcListTitle() async {
    List<int> sertap = [0, 4, 5];
    int? targetSer; // เก็บ ser ของแท็บที่ต้องเริ่ม
    final userJson =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

    if (userJson == null || userJson.isEmpty) return; // ✅ ป้องกัน null/empty

    final decoded = json.decode(userJson) as Map<String, dynamic>;
    final approveFlow = decoded['approve_flow'] as List<dynamic>?;

    if (approveFlow != null) {
      final steps = approveFlow
          .map((e) => e['step_min_level'] as int)
          .where((step) => !sertap.contains(step))
          .toList();
      sertap.addAll(steps);

      // หาแท็บ "รออนุมัติ" (ser=3) จาก approve_flow step_min_level
      // step_min_level 3,4,5 → หมายถึงขั้นตอน "รออนุมัติคำขอต่อสัญญา"
      for (final flow in approveFlow) {
        final stepMinLevel = flow['step_min_level'] as int;
        if (stepMinLevel >= 3 && stepMinLevel <= 7) {
          targetSer = 3; // ser=3 คือ "รออนุมัติคำขอต่อสัญญา"
          break;
        }
      }
    }

    print('--- approveFlow userJson: $userJson');
    print('--- approveFlow steps: $sertap');

    setState(() {
      final filteredData = CMMListTitle()
          .data_tap
          .where(
              (item) => sertap.contains(int.tryParse(item['ser'] ?? '') ?? -1))
          .toList();

      title_data.addAll(filteredData);
    });

    if (title_data.isNotEmpty) {
      setState(() {
        // ถ้ามีการส่ง ser_title จากภายนอก ให้ใช้ค่านั้น
        if (widget.ser_title != null) {
          ser_title = widget.ser_title;
          // หา ser_tap ที่ตรงกับ ser_title
          for (int i = 0; i < title_data.length; i++) {
            final dataSer =
                int.tryParse(title_data[i]['ser']?.toString() ?? '');
            if (dataSer == widget.ser_title) {
              ser_tap = i + 1;
              serApitap = int.parse(title_data[i]['level'].toString());
              break;
            }
          }
        } else if (targetSer != null) {
          // หาแท็บที่ตรงกับ targetSer จาก approve_flow
          for (int i = 0; i < title_data.length; i++) {
            final dataSer =
                int.tryParse(title_data[i]['ser']?.toString() ?? '');
            if (dataSer == targetSer) {
              ser_tap = i + 1;
              ser_title = dataSer;
              serApitap =
                  int.tryParse(title_data[i]['level']?.toString() ?? '') ?? 1;
              break;
            }
          }
        } else if (ser_tap > 0 && ser_tap <= title_data.length) {
          ser_title =
              int.tryParse(title_data[ser_tap - 1]['ser']?.toString() ?? '');
          serApitap =
              int.parse(title_data[ser_tap - 1]['level']?.toString() ?? '1');
        } else {
          ser_title = int.tryParse(title_data[0]['ser']?.toString() ?? '');
          serApitap = int.parse(title_data[0]['level']?.toString() ?? '1');
        }
      });
    }
  }

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void Loding_route_getdata() {
    // ✅ ถ้าผู้ใช้ไม่ได้ล้างค้นหา ให้ใช้ route_getdata จากภายนอก
    if (!_userClearedSearch) {
      _effectiveRouteData = widget.route_getdata;
    }

    // ✅ ตรวจสอบค่า route_getdata
    final hasRouteData = _effectiveRouteData != null &&
        _effectiveRouteData!.toString().isNotEmpty &&
        _effectiveRouteData.toString() != 'null';

    if (hasRouteData) {
      _updateSearchField();
    }

    // ✅ โหลดข้อมูลหลัง delay
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (mounted) {
        final field = _sortFieldMap[sortColumn];
        final sortDir = sortAscending ? 'asc' : 'desc';
        await Loading_Main(
          query: hasRouteData ? _effectiveRouteData! : '',
          orderBy: field,
          sortDir: sortDir,
        );
      }
    });
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  String _autoFieldForValue(String value) {
    if (_uuidRegex.hasMatch(value.trim())) return '7'; // รหัสรายการ
    return _selectedSearchField;
  }

  // ✅ แยกฟังก์ชัน update search field
  void _updateSearchField() {
    final routeData = widget.route_getdata ?? '';
    final targetSer = _autoFieldForValue(routeData);

    setState(() {
      for (var e in _searchList) {
        e['st'] = '0';
      }
      final idx = _searchList.indexWhere((e) => e['ser'] == targetSer);
      if (idx != -1) {
        _searchList[idx]['st'] = '1';
        _selectedSearchField = targetSer;
      }
      Search_Controller.text = routeData;
    });
  }

  // ✅ ใช้ใน dropdown onChanged
  void _onSearchFieldChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedSearchField = value;

      // ✅ เคลียร์และเลือกใหม่
      for (var e in _searchList) {
        e['st'] = '0';
      }
      final idx = _searchList.indexWhere((e) => e['ser'] == value);
      if (idx != -1) {
        _searchList[idx]['st'] = '1';
      }
    });

    // ✅ ยิงโหลดข้อมูล
    _executeSearch();
  }

  // ✅ ฟังก์ชัน execute search
  void _executeSearch() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      final query = Search_Controller.text.trim();
      final field = _sortFieldMap[sortColumn];
      final sortDir = sortAscending ? 'asc' : 'desc';
      if (query.isEmpty) {
        _effectiveRouteData = null;
        Loading_Main(orderBy: field, sortDir: sortDir);
      } else {
        Loading_Main(query: query, orderBy: field, sortDir: sortDir);
      }
    });
  }

  static const Map<String, String> _sortFieldMap = {
    '...': '',
    'เลขที่สัญญา-เดิม': 'cid',
    'บริเวณ': 'subzone',
    'โซนพื้นที่': 'zn',
    'รหัสพื้นที่': 'ln',
    'ชื่อผู้ติดต่อ': 'scname',
    'เบอร์โทรติดต่อ': 'tel',
    'วันที่สิ้นสุดสัญญา': 'ldate',
    'สถานะ': 'status',
    'รหัสรายการ': 'uuid',
  };

  bool _canSortColumn(String column) {
    final field = _sortFieldMap[column];
    return field == 'zn' || field == 'ln';
  }

  Future<void> Loading_Main({
    String? customUrl,
    String query = '',
    bool append = false,
    String? orderBy,
    String sortDir = 'asc',
  }) async {
    print(
        'Loading_Main called with query: "$query", customUrl: "$customUrl", append: $append, serApitap: $serApitap');
    switch (serApitap) {
      case 1:
        startLoading();
        await loadClientReviews(
          customUrl: customUrl,
          query: _getQueryValue(query),
          append: append,
          orderBy: orderBy,
          sortDir: sortDir,
        );
        break;
      case -1:
        startLoading();
        await loadClientReviews(
          customUrl: customUrl,
          query: _getQueryValue(query),
          append: append,
          orderBy: orderBy,
          sortDir: sortDir,
        );
        break;
      case 2:
        startLoading();
        await loadApprovalsRoles(
          customUrl: customUrl,
          query: _getQueryValue(query),
          append: append,
          orderBy: orderBy,
          sortDir: sortDir,
        );
        break;
      case 3:
        startLoading();
        await loadApprovalsLastaction(
          customUrl: customUrl,
          query: _getQueryValue(query),
          append: append,
          orderBy: orderBy,
          sortDir: sortDir,
        );
        break;
      case 4:
        startLoading();
        await loadApprovalslastcompleted(
          customUrl: customUrl,
          query: _getQueryValue(query),
          append: append,
          orderBy: orderBy,
          sortDir: sortDir,
        );
        break;
    }

    if (mounted) {
      setState(() {
        currentPage_1 = 0;
        isLoading = false;
        isLoading_main = false;
        AddDaTa();
      });
    }
  }

  String _getQueryValue(String query) {
    if (query.isNotEmpty) return query;
    final searchText = Search_Controller.text.trim();
    if (searchText.isNotEmpty) return searchText;
    return _effectiveRouteData == null || _effectiveRouteData!.isEmpty
        ? ''
        : _effectiveRouteData!;
  }

  Future<void> RepageQuery() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('RepageQuery --- ใบอนุญาต');
      final materialPageRoute = MaterialPageRoute(
        builder: (BuildContext context) => AdminScafScreen(
          route: 'ใบอนุญาต',
          route_getdata: "",
        ),
      );

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          materialPageRoute,
          (route) => false,
        );
      }
    });
  }

  Future<void> updateTotalTap(final jsonMap) async {
    if (mounted) {
      setState(() {
        if (ser_tap > 0 && ser_tap <= title_data.length) {
          title_data[ser_tap - 1]['total'] = totalPage ?? '0';
        }
      });
    }
  }

  Future<void> loadClientReviews({
    String? customUrl,
    String query = '',
    bool append = false,
    String? orderBy,
    String sortDir = 'asc',
  }) async {
    setState(() {
      isLoading_main = true;
      reviewModels.clear();
      data.clear();
      filteredData.clear();
    });

    try {
      final res = await read_GC_Reviews(
        urlCustom: customUrl,
        query: query,
        perPage: 50,
        zser: zone_Subser,
        orderBy: orderBy,
        sortDir: sortDir,
        fild: _searchList.where((e) => e['st'] == '1').toList(),
        zn: (zone_name == 'ทั้งหมด') ? null : zone_name,
      );

      if (mounted) {
        if (res.currentPage == 0 && res.lastPage == 0 && res.data.isEmpty) {
          setState(() {
            if (customUrl != null && customUrl == linksNext) {
              linksNext = null;
              lastPage = currentPage;
            } else if (customUrl != null && customUrl == linksPrev) {
              linksPrev = null;
            }
            isLoading_main = false;
          });
          return;
        }
        setState(() {
          reviewModels = res.data;
          currentPage = res.currentPage;
          lastPage = res.lastPage;
          perPage = 50;
          totalPage = res.total;
          linksFirst = res.linksFirst;
          linksLast = res.linksLast;
          linksPrev = res.linksPrev;
          linksNext = res.linksNext;
          isLoading_main = false;
        });
        updateTotalTap(res.data);
      }
    } catch (e) {
      print('❌ ไม่สามารถโหลดข้อมูลได้: $e');
      if (mounted) {
        setState(() {
          isLoading_main = false;
        });
      }
    }
  }

  Future<void> loadApprovalsRoles({
    String? customUrl,
    String query = '',
    bool append = false,
    String? orderBy,
    String? sortDir,
  }) async {
    setState(() {
      isLoading_main = true;
      reviewModels.clear();
      data.clear();
      filteredData.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    final zonesName = prefs.getString('zonesPName');
    // await prefs.setString('zonePSer', zoneSer);
    // await prefs.setString('zonesPName', zonesName);
    try {
      final res = await read_GC_ApprovalsRoles(
        urlCustom: customUrl,
        query: query,
        perPage: 50,
        orderBy: orderBy,
        sortDir: sortDir,
        zn: (zonesName == 'ทั้งหมด') ? null : zonesName ?? null,
      );

      if (mounted) {
        setState(() {
          reviewModels = res.data;
          currentPage = res.currentPage;
          lastPage = res.lastPage;
          perPage = 50;
          totalPage = res.total;
          linksFirst = res.linksFirst;
          linksLast = res.linksLast;
          linksPrev = res.linksPrev;
          linksNext = res.linksNext;
          isLoading_main = false;
        });
        updateTotalTap(res.data);
      }
    } catch (e) {
      print('❌ ไม่สามารถโหลดข้อมูลได้: $e');
      if (mounted) {
        setState(() {
          isLoading_main = false;
        });
      }
    }
  }

  ///=====>
  Future<void> loadApprovalsLastaction({
    String? customUrl,
    String query = '',
    bool append = false,
    String? orderBy,
    String sortDir = 'asc',
  }) async {
    setState(() {
      isLoading_main = true;
      reviewModels.clear();
      data.clear();
      filteredData.clear();
    });

    try {
      final res = await read_GC_ApprovalsLastaction(
        urlCustom: customUrl,
        query: query,
        perPage: 50,
        orderBy: orderBy,
        sortDir: sortDir,
      );

      if (mounted) {
        setState(() {
          reviewModels = res.data;
          currentPage = res.currentPage;
          lastPage = res.lastPage;
          perPage = 50;
          totalPage = res.total;
          linksFirst = res.linksFirst;
          linksLast = res.linksLast;
          linksPrev = res.linksPrev;
          linksNext = res.linksNext;
          isLoading_main = false;
        });
        updateTotalTap(res.data);
      }
    } catch (e) {
      print('❌ ไม่สามารถโหลดข้อมูลได้: $e');
      if (mounted) {
        setState(() {
          isLoading_main = false;
        });
      }
    }
  }

  Future<void> loadApprovalslastcompleted({
    String? customUrl,
    String query = '',
    bool append = false,
    String? orderBy,
    String sortDir = 'asc',
  }) async {
    setState(() {
      isLoading_main = true;
      reviewModels.clear();
      data.clear();
      filteredData.clear();
    });

    try {
      final res = await read_GC_ApprovalsLastcompleted(
        urlCustom: customUrl,
        query: query, // ✅ แก้จาก searchText เป็น query
        perPage: 50,
        orderBy: orderBy,
        sortDir: sortDir,
      );

      if (mounted) {
        setState(() {
          reviewModels = res.data;
          currentPage = res.currentPage;
          lastPage = res.lastPage;
          perPage = 50;
          totalPage = res.total;
          linksFirst = res.linksFirst;
          linksLast = res.linksLast;
          linksPrev = res.linksPrev;
          linksNext = res.linksNext;
          isLoading_main = false;
        });
        updateTotalTap(res.data);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading_main = false;
        });
      }
    }
  }

  Future<void> _fetchAllAddonData() async {
    _rowBookNoControllers.forEach((_, c) => c.dispose());
    _rowBookDateControllers.forEach((_, c) => c.dispose());
    _rowBookNoControllers.clear();
    _rowBookDateControllers.clear();

    for (var model in reviewModels) {
      if (model.uuid == null || model.uuid!.isEmpty) continue;

      final uuid = model.uuid!;
      _rowBookNoControllers[uuid] = TextEditingController();
      _rowBookDateControllers[uuid] = TextEditingController();

      get_ReviewsAddon(requestUuid: uuid).then((resp) {
        if (resp != null && resp.statusCode == 200) {
          try {
            final body = json.decode(resp.body);
            if (body['data'] != null) {
              final addon = body['data'];
              final String bookNo = addon['book_no']?.toString() ?? '';
              final String bookDate = addon['book_date']?.toString() ?? '';
              debugPrint('Book No: $bookNo, Book Date: $bookDate');

              if (mounted) {
                _rowBookNoControllers[uuid]?.text = bookNo;
                if (bookDate.isNotEmpty) {
                  try {
                    DateTime dt = DateFormat('yyyy-MM-dd').parse(bookDate);
                    _rowBookDateControllers[uuid]?.text =
                        DateFormat('dd/MM/yyyy').format(dt);
                  } catch (e) {
                    _rowBookDateControllers[uuid]?.text = bookDate;
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('❌ Error decoding addon response for $uuid: $e');
          }
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> ac7 = [];
  List<Map<String, String>> Title = [
    {
      "ser": "0",
      "st": "1",
      "pn": "เลขที่สัญญา",
    },
    {
      "ser": "1",
      "st": "1",
      "pn": "บริเวณ",
    },
    {
      "ser": "2",
      "st": "1",
      "pn": "โซนพื้นที่",
    },
    {
      "ser": "3",
      "st": "1",
      "pn": "รหัสพื้นที่",
    },
    {
      "ser": "4",
      "st": "1",
      "pn": "ชื่อผู้ติดต่อ",
    },
    {
      "ser": "5",
      "st": "1",
      "pn": "เบอร์โทร",
    },
    {
      "ser": "6",
      "st": "1",
      "pn": "วันที่สิ้นสุด",
    },
    {
      "ser": "7",
      "st": "1",
      "pn": "สถานะ",
    },
    {
      "ser": "8",
      "st": "1",
      "pn": "รหัสรายการ",
    },
    {"ser": "10", "st": "0", "pn": "เลขที่บันทึก", "value": "book_no"},
    {"ser": "11", "st": "0", "pn": "วันที่บันทึก", "value": "book_date"},
  ];
  void addAcListTitle2() {
    setState(() {
      ac7 = List<Map<String, String>>.from(Title.map((e) => Map.of(e)));
    });
  }

  bool showTitle(String ser) {
    if (ac7.isEmpty) return true;
    return ac7.any((item) => item["ser"] == ser && item["st"] == '1');
  }

  Future<void> AddDaTa() async {
    data.clear();

    if (reviewModels.isNotEmpty) {
      setState(() {
        data = List.generate(reviewModels.length, (index) {
          final review = reviewModels[index];
          return {
            "index": "$index",
            if (showTitle("0"))
              "เลขที่สัญญา-เดิม": review.newRequest?.leaseNumber ?? "-",
            if (showTitle("1")) "บริเวณ": review.newRequest?.subzone ?? "",
            if (showTitle("2")) "โซนพื้นที่": review.newRequest?.zn ?? "",
            if (showTitle("3")) "รหัสพื้นที่": review.newRequest?.ln ?? "",
            if (showTitle("4")) "ชื่อผู้ติดต่อ": review.client?.cname ?? "",
            if (showTitle("5"))
              "เบอร์โทรติดต่อ":
                  formatPhoneNumber('${review.client?.tel ?? ""}'),
            if (showTitle("6"))
              "วันที่สิ้นสุดสัญญา": formatDate(
                review.newRequest?.ldate ?? "",
                type: DateFormatType.dmy,
              ),
            if (showTitle("7")) "สถานะ": review.status ?? "",
            if (showTitle("8")) "รหัสรายการ": review.uuid ?? "",
          };
        });

        filteredData = data;
      });
    } else {
      setState(() {
        data = [];
        filteredData = [];
      });
    }
  }

  Future<Null> read_GC_Sub_zone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'read_GC_Sub_zone_$ren';

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        setState(() {
          subzoneModels.clear();
          subzoneModels.add(SubZoneModel.fromJson({
            'ser': '0',
            'rser': '0',
            'zn': 'ทั้งหมด',
            'qty': '0',
            'img': '0',
            'data_update': '0',
          }));
          for (var map in cachedData) {
            subzoneModels.add(SubZoneModel.fromJson(map));
          }
        });
        return;
      }
    }

    if (subzoneModels.length != 0) {
      setState(() {
        subzoneModels.clear();
      });
    }

    String url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      Map<String, dynamic> map = {};
      map['ser'] = '0';
      map['rser'] = '0';
      map['zn'] = 'ทั้งหมด';
      map['qty'] = '0';
      map['img'] = '0';
      map['data_update'] = '0';

      SubZoneModel subzoneModelx = SubZoneModel.fromJson(map);

      setState(() {
        subzoneModels.add(subzoneModelx);
      });

      for (var map in result) {
        SubZoneModel subzoneModel = SubZoneModel.fromJson(map);
        setState(() {
          subzoneModels.add(subzoneModel);
        });
      }

      _apiCache.set(cacheKey, result);
    } catch (e) {}
  }

  Future<void> read_GC_zone() async {
    if (zoneModels.isNotEmpty) {
      zoneModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var zoneSubSer = preferences.getString('zoneSubSer');
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'read_GC_zone_$ren';

    void applyZoneData(List result) {
      ZoneModel defaultZone = ZoneModel.fromJson({
        'ser': '0',
        'rser': '0',
        'zn': 'ทั้งหมด',
        'qty': '0',
        'img': '0',
        'data_update': '0',
      });

      setState(() {
        zoneModels.clear();
        zoneModels.add(defaultZone);

        for (var map in result) {
          ZoneModel zoneModel = ZoneModel.fromJson(map);
          var sub = zoneModel.sub_zone;

          if (zoneSubSer == null || zoneSubSer == '0' || sub == zoneSubSer) {
            zoneModels.add(zoneModel);
          }
        }

        zoneModels.sort((a, b) {
          if (a.zn == 'ทั้งหมด') return -1;
          if (b.zn == 'ทั้งหมด') return 1;
          return (a.zn ?? '').compareTo(b.zn ?? '');
        });

        zone_ser = preferences.getString('zonePSer');
        zone_name = preferences.getString('zonesPName');
        zone_Subser = preferences.getString('zoneSubSer');
        zone_Subname = preferences.getString('zonesSubName');
      });
    }

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        applyZoneData(cachedData);
        return;
      }
    }

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = jsonDecode(response.body);

      if (result != null && result is List) {
        _apiCache.set(cacheKey, result);
        applyZoneData(result);
      }
    } catch (e) {
      print('Error reading zones: $e');
    }
  }

  String _selectedSearchField = '4'; // default: ชื่อผู้ติดต่อ

  Widget Next_page() {
    final canPrev = (linksPrev?.isNotEmpty ?? false);
    final canNext = (linksNext?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Container(
        height: 50,
        width: 180,
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            InkWell(
              onTap: canPrev && !isLoading
                  ? () async {
                      final field = _sortFieldMap[sortColumn];
                      final sortDir = sortAscending ? 'asc' : 'desc';
                      await Loading_Main(
                        customUrl: linksPrev,
                        orderBy: field,
                        sortDir: sortDir,
                      );
                    }
                  : null,
              child: Opacity(
                opacity: canPrev ? 1.0 : 0.4,
                child: const Icon(Icons.arrow_left, size: 25),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'หน้า ${currentPage ?? '?'} / ${lastPage ?? '?'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: canNext && !isLoading
                  ? () async {
                      final field = _sortFieldMap[sortColumn];
                      final sortDir = sortAscending ? 'asc' : 'desc';
                      await Loading_Main(
                        customUrl: linksNext,
                        orderBy: field,
                        sortDir: sortDir,
                      );
                    }
                  : null,
              child: Opacity(
                opacity: canNext ? 1.0 : 0.4,
                child: const Icon(Icons.arrow_right, size: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isSidebarOpen = true; // state
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cts) {
      final screenW = cts.maxWidth - 20;
      final tableMinW = Responsive.isDesktop(context) ? screenW : 980.0;
      final isOpen =
          context.watch<SidebarController>().isOpen; // ← อ่านสถานะข้ามหน้า
      double screenWidth = MediaQuery.of(context).size.width;
      double calculatedWidth = math.max(
        Responsive.isTablet(context) ? screenWidth * 0.81 : 700,
        Responsive.isDesktop(context)
            ? isOpen
                ? screenWidth * 0.85
                : screenWidth - 50
            : (filteredData.isNotEmpty
                ? filteredData.first.length * 150
                : screenWidth),
      );

      // 1400;

      final displayedData = filteredData
          .skip(currentPage_1 * rowsPerPage_1)
          .take(rowsPerPage_1)
          .toList();

      final columnHeaders =
          filteredData.isNotEmpty ? filteredData[0].keys.toList() : [];

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 2, 0),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Box,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'ใบอนุญาต',
                                          ChaoAreaScreen_Color.Colors_Text1_,
                                          TextAlign.center,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          14,
                                          2),
                                      AutoSizeText(
                                        ' > > ',
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        maxFontSize: 20,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // if (!Responsive.isMobile(context)) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: viewpage(context, '$Ser_nowpage'),
                        ),
                        // ]
                      ],
                    ),
                    // Dropdowns row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppbackgroundColor.TiTile_Box,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow =
                                constraints.maxWidth < 650; // ปรับจุดตัดได้

                            final zoneLabel = Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Translate.TranslateAndSetText(
                                'โซน:',
                                PeopleChaoScreen_Color.Colors_Text1_,
                                TextAlign.left,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                16,
                                1,
                              ),
                            );

                            final rentZoneLabel = Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Translate.TranslateAndSetText(
                                'โซนพื้นที่เช่า:',
                                PeopleChaoScreen_Color.Colors_Text1_,
                                TextAlign.left,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                16,
                                1,
                              ),
                            );

                            // ✅ มือถือ/จอแคบ: เรียงลง กว้างเต็ม
                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (subzoneModels.length != 1) ...[
                                    zoneLabel,
                                    SizedBox(
                                        height: 44,
                                        child: _buildZoneDropdown(true)),
                                    const SizedBox(height: 12),
                                  ],
                                  rentZoneLabel,
                                  SizedBox(
                                      height: 44,
                                      child: _buildZoneDropdown(false)),
                                ],
                              );
                            }

                            // ✅ จอกว้าง: ใช้ Row เหมือนเดิม แต่ไม่ต้อง scroll
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (subzoneModels.length != 1) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Translate.TranslateAndSetText(
                                      'โซน:',
                                      PeopleChaoScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      16,
                                      1,
                                    ),
                                  ),
                                  SizedBox(
                                      width: 240,
                                      height: 44,
                                      child: _buildZoneDropdown(true)),
                                  const SizedBox(width: 16),
                                ],
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Translate.TranslateAndSetText(
                                    'โซนพื้นที่เช่า:',
                                    PeopleChaoScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    16,
                                    1,
                                  ),
                                ),
                                SizedBox(
                                    width: 240,
                                    height: 44,
                                    child: _buildZoneDropdown(false)),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () async {
                                            // โหลด Properties ตามโซนปัจจุบัน แล้วเปิด popup
                                            final props =
                                                await read_GC_properties(
                                              zone_Subser,
                                              null,
                                              null,
                                            );
                                            if (!context.mounted) return;
                                            await NewContractStepOnePopup.show(
                                              context,
                                              properties: props,
                                              title: 'ผู้เช่า (Popup)',
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.orange,
                                            radius: 20,
                                            child: Center(
                                                child: Icon(
                                              Icons.contact_page,
                                              color: Colors.white,
                                            )),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminScafScreen(
                                                        route:
                                                            'TestPrintNamePage'),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.orange,
                                            radius: 20,
                                            child: Center(
                                                child: Icon(
                                              Icons.folder,
                                              color: Colors.white,
                                            )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    // Status tabs
                    // if(Responsive.isMobile(context))...[]else...[ ]
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white60,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow =
                                constraints.maxWidth < 720; // ปรับได้

                            return Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 6,
                              spacing: 6,
                              children: [
                                // ✅ label
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: isNarrow ? 0 : 6),
                                  child: Translate.TranslateAndSetText(
                                    'สถานะ :',
                                    AccountScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    16,
                                    1,
                                  ),
                                ),

                                // ✅ buttons
                                ...title_data.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final isActive = ser_tap == index + 1;

                                  return SizedBox(
                                    height: 32, // เดิม 30 เพิ่มนิดให้กดง่าย
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 0.5,
                                          ),
                                        ),
                                        backgroundColor: isActive
                                            ? Colors.grey.shade900
                                            : Colors.grey.shade300,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          ser_tap = index + 1;
                                          serApitap = int.parse(
                                              title_data[index]['level']
                                                  .toString());
                                          ser_title = int.parse(
                                              title_data[index]['ser']
                                                  .toString());
                                        });
                                        await Loading_Main();
                                      },
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                        '${entry.value['title']} (${entry.value['total']})',
                                        isActive ? Colors.white : Colors.black,
                                        TextAlign.center,
                                        null,
                                        FontWeight_.Fonts_T,
                                        11,
                                        13,
                                        1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ), // Search row
              if (Responsive.isTablet(context) ||
                  Responsive.isMobile(context)) ...[
                ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: 48,
                      width: math.max(
                          Responsive.isMobile(context)
                              ? screenWidth + 250
                              : screenWidth,
                          Responsive.isMobile(context)
                              ? screenWidth + 250
                              : screenWidth),
                      decoration: BoxDecoration(
                        color: AppbackgroundColor.TiTile_Colors,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6), // ✅ ลดลง
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            height: 44, // ✅ เตี้ยลง
                            child: _buildSearchFilterDropdown(),
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            child: Container(
                              height: 44, // ✅ เตี้ยลง
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(0)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              child: (isLoading_main)
                                  ? const Text(
                                      'ดาวน์โหลดข้อมูล',
                                      style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    )
                                  : TextField(
                                      controller: Search_Controller,
                                      onChanged: (value) async {
                                        if (value.length > 1 || value.isEmpty) {
                                          if (_debounce?.isActive ?? false)
                                            _debounce!.cancel();

                                          _debounce = Timer(
                                            const Duration(milliseconds: 600),
                                            () async {
                                              if (value.trim().isEmpty) {
                                                // reset กลับ default field เมื่อลบ search
                                                setState(() {
                                                  _selectedSearchField = '4';
                                                  for (var e in _searchList) {
                                                    e['st'] = '0';
                                                  }
                                                  _searchList[_searchList
                                                          .indexWhere((e) =>
                                                              e['ser'] == '4')]
                                                      ['st'] = '1';
                                                  _searchMenuTick.value++;
                                                });
                                                _effectiveRouteData = null;
                                                _userClearedSearch =
                                                    true; // ✅ ตั้ง flag ว่าผู้ใช้ล้างค้นหา
                                                await Loading_Main();
                                              } else {
                                                // auto-switch เป็น uuid field เมื่อ detect UUID format
                                                final autoSer =
                                                    _autoFieldForValue(value);
                                                if (autoSer !=
                                                    _selectedSearchField) {
                                                  setState(() {
                                                    _selectedSearchField =
                                                        autoSer;
                                                    for (var e in _searchList) {
                                                      e['st'] = '0';
                                                    }
                                                    final idx = _searchList
                                                        .indexWhere((e) =>
                                                            e['ser'] ==
                                                            autoSer);
                                                    if (idx != -1) {
                                                      _searchList[idx]['st'] =
                                                          '1';
                                                    }
                                                    _searchMenuTick.value++;
                                                  });
                                                }
                                                await Loading_Main(
                                                    query: value.trim());
                                              }
                                            },
                                          );
                                        }
                                      },
                                      decoration: InputDecoration(
                                        isDense:
                                            true, // ✅ ทำให้ TextField เตี้ย
                                        border: InputBorder.none,
                                        hintText: Search_Controller.text.isEmpty
                                            ? _selectedTitlesLabel()
                                            : ' Search...',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: Search_Controller
                                                .text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear,
                                                    size: 18),
                                                onPressed: () async {
                                                  Search_Controller.clear();
                                                  _effectiveRouteData = null;
                                                  _userClearedSearch =
                                                      true; // ✅ ตั้ง flag ว่าผู้ใช้ล้างค้นหา
                                                  setState(() {
                                                    _selectedSearchField = '4';
                                                    for (var e in _searchList) {
                                                      e['st'] = '0';
                                                    }
                                                    final idx = _searchList
                                                        .indexWhere((e) =>
                                                            e['ser'] == '4');
                                                    if (idx != -1) {
                                                      _searchList[idx]['st'] =
                                                          '1';
                                                    }
                                                    _searchMenuTick.value++;
                                                  });
                                                  final field =
                                                      _sortFieldMap[sortColumn];
                                                  final sortDir = sortAscending
                                                      ? 'asc'
                                                      : 'desc';
                                                  await Loading_Main(
                                                      orderBy: field,
                                                      sortDir: sortDir);
                                                },
                                              )
                                            : null,
                                      ),
                                    ),
                            ),
                          ),

                          // const SizedBox(width: 10),
                          // const Spacer(),

                          // ขวา (กันล้น)
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            }),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 2, 2),
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        // .withOpacity(0.5),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(8)),
                                        // border: Border.all(
                                        //     color:
                                        //         Colors.grey,
                                        //     width: 1),
                                      ),
                                      width: 130,
                                      // height: 30,
                                      padding: const EdgeInsets.all(2.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: Center(
                                            child: Text(
                                              'หัวข้อ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AccountScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),

                                          items: ac7.map((item) {
                                            return DropdownMenuItem<String>(
                                              value: item["ser"],
                                              enabled: false,
                                              child:
                                                  ValueListenableBuilder<int>(
                                                valueListenable: _ac7MenuTick,
                                                builder: (context, _, __) {
                                                  final selected =
                                                      item["st"] == '1';

                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        // toggle ได้หลายช่อง
                                                        item["st"] = selected
                                                            ? '0'
                                                            : '1';
                                                      });

                                                      _ac7MenuTick
                                                          .value++; // ✅ ให้ทั้งเมนู redraw ติ๊กพร้อมกัน
                                                      AddDaTa(); // ✅ rebuild columns
                                                    },
                                                    child: Container(
                                                      height: double.infinity,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 6),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            selected
                                                                ? Icons
                                                                    .check_box_outlined
                                                                : Icons
                                                                    .check_box_outline_blank,
                                                            color: selected
                                                                ? Colors.green
                                                                : Colors
                                                                    .black45,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              item["pn"] ?? '',
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }).toList(),
                                          //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                                          // value: selectedItems.isEmpty ? null : selectedItems.last,
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ),
                                  ),
                                  if ((ser_title == 1 || ser_title == 2) &&
                                      reviewModels.isNotEmpty) ...[
                                    // ✅ จัดการบันทึกข้อความแบบกลุ่ม
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                        ),
                                        onPressed: _showBulkEditAddonDialog,
                                        icon: const Icon(Icons.auto_fix_high,
                                            size: 16),
                                        label: const Text(
                                          'บันทึกข้อความกลุ่ม',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    // ✅ ตรวจสอบเอกสารแบบกลุ่ม
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade800,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                        ),
                                        onPressed:
                                            _showBulkDocumentReviewDialog,
                                        icon: const Icon(
                                            Icons.checklist_rtl_rounded,
                                            size: 16),
                                        label: const Text(
                                          'ตรวจสอบเอกสารกลุ่ม',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (ser_title == 3 &&
                                      reviewModels.isNotEmpty) ...[
                                    SizedBox(
                                      height: 34, // ✅ เตี้ยลง
                                      width: 130,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.deepPurple.shade900,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await SecurePrefs.setEncrypted(
                                              SecurePrefsType.approverAll,
                                              'true');

                                          final materialPageRoute =
                                              MaterialPageRoute(
                                            builder: (context) =>
                                                AdminScafScreen(
                                              route:
                                                  '${title_data[ser_tap - 1]['page']}',
                                            ),
                                          );
                                          if (context.mounted) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              materialPageRoute,
                                              (route) => false,
                                            );
                                          }
                                        },
                                        child: Translate
                                            .TranslateAndSet_TextAutoSize(
                                          'อนุมัติทั้งหมด',
                                          CustomerScreen_Color.Colors_Text3_,
                                          TextAlign.center,
                                          null,
                                          Font_.Fonts_T,
                                          10,
                                          14,
                                          1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Next_page(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Data table section
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: Responsive.isDesktop(context)
                          ? math.max(600.0, cts.maxHeight - 250.0)
                          : 500, // ✅ อย่างน้อย 500
                    ),
                    width: calculatedWidth,
                    decoration: const BoxDecoration(
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        if (Responsive.isDesktop(context)) ...[
                          Container(
                            height: 48,
                            width: calculatedWidth,
                            decoration: BoxDecoration(
                              color: AppbackgroundColor.TiTile_Colors,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6), // ✅ ลดลง
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 44, // ✅ เตี้ยลง
                                  child: _buildSearchFilterDropdown(),
                                ),
                                const SizedBox(width: 8),

                                Expanded(
                                  child: Container(
                                    height: 44, // ✅ เตี้ยลง
                                    decoration: BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(0)),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    alignment: Alignment.center,
                                    child: (isLoading_main)
                                        ? const Text(
                                            'ดาวน์โหลดข้อมูล',
                                            style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          )
                                        : TextField(
                                            controller: Search_Controller,
                                            onChanged: (value) async {
                                              if (value.length > 1 ||
                                                  value.isEmpty) {
                                                if (_debounce?.isActive ??
                                                    false) _debounce!.cancel();

                                                _debounce = Timer(
                                                  const Duration(
                                                      milliseconds: 600),
                                                  () async {
                                                    if (value.trim().isEmpty) {
                                                      _effectiveRouteData =
                                                          null;
                                                      _userClearedSearch =
                                                          true; // ✅ ตั้ง flag ว่าผู้ใช้ล้างค้นหา
                                                      await Loading_Main();
                                                    } else {
                                                      await Loading_Main(
                                                          query: value.trim());
                                                    }
                                                  },
                                                );
                                              }
                                            },
                                            decoration: InputDecoration(
                                              isDense:
                                                  true, // ✅ ทำให้ TextField เตี้ย
                                              border: InputBorder.none,
                                              hintText:
                                                  Search_Controller.text.isEmpty
                                                      ? _selectedTitlesLabel()
                                                      : ' Search...',
                                              prefixIcon:
                                                  const Icon(Icons.search),
                                              suffixIcon: Search_Controller
                                                      .text.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.clear,
                                                          size: 18),
                                                      onPressed: () async {
                                                        Search_Controller
                                                            .clear();
                                                        _effectiveRouteData =
                                                            null;
                                                        setState(() {
                                                          _selectedSearchField =
                                                              '4';
                                                          for (var e
                                                              in _searchList) {
                                                            e['st'] = '0';
                                                          }
                                                          final idx = _searchList
                                                              .indexWhere((e) =>
                                                                  e['ser'] ==
                                                                  '4');
                                                          if (idx != -1) {
                                                            _searchList[idx]
                                                                ['st'] = '1';
                                                          }
                                                          _searchMenuTick
                                                              .value++;
                                                        });
                                                        final field =
                                                            _sortFieldMap[
                                                                sortColumn];
                                                        final sortDir =
                                                            sortAscending
                                                                ? 'asc'
                                                                : 'desc';
                                                        await Loading_Main(
                                                            orderBy: field,
                                                            sortDir: sortDir);
                                                      },
                                                    )
                                                  : null,
                                            ),
                                          ),
                                  ),
                                ),

                                // const SizedBox(width: 10),
                                // const Spacer(),

                                // ขวา (กันล้น)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 2, 2, 2),
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            // .withOpacity(0.5),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(8)),
                                            // border: Border.all(
                                            //     color:
                                            //         Colors.grey,
                                            //     width: 1),
                                          ),
                                          width: 130,
                                          // height: 30,
                                          padding: const EdgeInsets.all(2.0),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              hint: Center(
                                                child: Text(
                                                  'หัวข้อ',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AccountScreen_Color
                                                        .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),

                                              items: ac7.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item["ser"],
                                                  enabled: false,
                                                  child: ValueListenableBuilder<
                                                      int>(
                                                    valueListenable:
                                                        _ac7MenuTick,
                                                    builder: (context, _, __) {
                                                      final selected =
                                                          item["st"] == '1';

                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            // toggle ได้หลายช่อง
                                                            item["st"] =
                                                                selected
                                                                    ? '0'
                                                                    : '1';
                                                          });

                                                          _ac7MenuTick
                                                              .value++; // ✅ ให้ทั้งเมนู redraw ติ๊กพร้อมกัน
                                                          AddDaTa(); // ✅ rebuild columns
                                                        },
                                                        child: Container(
                                                          height:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      6),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                selected
                                                                    ? Icons
                                                                        .check_box_outlined
                                                                    : Icons
                                                                        .check_box_outline_blank,
                                                                color: selected
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .black45,
                                                                size: 18,
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                  item["pn"] ??
                                                                      '',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                              //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                                              // value: selectedItems.isEmpty ? null : selectedItems.last,
                                              onChanged: (value) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                      if ((ser_title == 1 || ser_title == 2) &&
                                          reviewModels.isNotEmpty) ...[
                                        // ✅ บันทึกข้อความแบบกลุ่ม
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade900,
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                            onPressed: _showBulkEditAddonDialog,
                                            icon: const Icon(
                                                Icons.auto_fix_high,
                                                size: 18),
                                            label: const Text(
                                              'บันทึกข้อความกลุ่ม',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        // ✅ ตรวจสอบเอกสารแบบกลุ่ม
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 4),
                                        //   child: ElevatedButton.icon(
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor:
                                        //           Colors.indigo.shade800,
                                        //       foregroundColor: Colors.white,
                                        //       elevation: 2,
                                        //       shape: RoundedRectangleBorder(
                                        //           borderRadius:
                                        //               BorderRadius.circular(8)),
                                        //       padding:
                                        //           const EdgeInsets.symmetric(
                                        //               horizontal: 12,
                                        //               vertical: 8),
                                        //     ),
                                        //     onPressed:
                                        //         _showBulkDocumentReviewDialog,
                                        //     icon: const Icon(
                                        //         Icons.checklist_rtl_rounded,
                                        //         size: 18),
                                        //     label: const Text(
                                        //       'ตรวจสอบเอกสารกลุ่ม',
                                        //       style: TextStyle(
                                        //           color: Colors.white,
                                        //           fontFamily: Font_.Fonts_T,
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 13),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                      if (ser_title == 3 &&
                                          reviewModels.isNotEmpty) ...[
                                        SizedBox(
                                          height: 34, // ✅ เตี้ยลง
                                          width: 130,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple.shade900,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              await SecurePrefs.setEncrypted(
                                                  SecurePrefsType.approverAll,
                                                  'true');

                                              final materialPageRoute =
                                                  MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminScafScreen(
                                                  route:
                                                      '${title_data[ser_tap - 1]['page']}',
                                                ),
                                              );
                                              if (context.mounted) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  materialPageRoute,
                                                  (route) => false,
                                                );
                                              }
                                            },
                                            child: Translate
                                                .TranslateAndSet_TextAutoSize(
                                              'อนุมัติทั้งหมด',
                                              CustomerScreen_Color
                                                  .Colors_Text3_,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              10,
                                              14,
                                              1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      Next_page(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Container(
                          color: AppbackgroundColor.TiTile_Colors,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 16),
                          child: Row(
                            children: [
                              if (ser_tap == 1 || ser_tap == 2 || ser_tap == 3)
                                SizedBox(
                                  width: 120,
                                  child: Translate.TranslateAndSetText(
                                      '...',
                                      AccountScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      14,
                                      1),
                                ),
                              ...columnHeaders.skip(1).map((column) => Expanded(
                                    child: InkWell(
                                      onTap: _canSortColumn(column)
                                          ? () {
                                              setState(() {
                                                if (sortColumn == column) {
                                                  sortAscending =
                                                      !sortAscending;
                                                } else {
                                                  sortColumn = column;
                                                  sortAscending = true;
                                                }
                                              });
                                              final field =
                                                  _sortFieldMap[column];
                                              if (field != null) {
                                                Loading_Main(
                                                  orderBy: field,
                                                  sortDir: sortAscending
                                                      ? 'asc'
                                                      : 'desc',
                                                );
                                              }
                                            }
                                          : null,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_canSortColumn(column) &&
                                              sortColumn == column)
                                            Icon(
                                              sortAscending
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 20,
                                              color: Colors.red[600],
                                            ),
                                          Expanded(
                                            child:
                                                (column.toString() == 'สถานะ')
                                                    ? Row(
                                                        children: [
                                                          Translate.TranslateAndSetText(
                                                              column,
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.left,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              13.8,
                                                              1),
                                                          if (column
                                                                  .toString() ==
                                                              'สถานะ')
                                                            InkWell(
                                                              child: Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 20,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              onTap: () async {
                                                                final List<
                                                                        Map<String,
                                                                            String>>
                                                                    statusRows =
                                                                    [
                                                                  {
                                                                    "status":
                                                                        "ร่างคำขอ, รอกรอกข้อมูลชำระเงิน",
                                                                    "owner":
                                                                        "รอยืนยันข้อมูลคำขอ",
                                                                  },
                                                                  {
                                                                    "status":
                                                                        "ส่งหลักฐานการชำระเงินแล้ว, ส่งคำร้อง",
                                                                    "owner":
                                                                        "รอการตรวจสอบหลักฐาน",
                                                                  },
                                                                  {
                                                                    "status":
                                                                        "กำลังรอตรวจสอบ",
                                                                    "owner":
                                                                        "รอการตรวจสอบข้อเท็จจริง",
                                                                  },
                                                                  {
                                                                    "status":
                                                                        "กำลังดำเนินการ",
                                                                    "owner":
                                                                        "รอการลงลายมือชื่ออนุมัติ",
                                                                  },
                                                                  {
                                                                    "status":
                                                                        "กำลังสร้างสัญญา",
                                                                    "owner":
                                                                        "โปรดรอประมาณ 1-2 นาทีระบบจะรีเฟรชอัตโนมัติ",
                                                                  },
                                                                  {
                                                                    "status":
                                                                        "เสร็จสมบูรณ์",
                                                                    "owner":
                                                                        "ใบอนุญาตพร้อมใช้งาน",
                                                                  },
                                                                ];
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (ctx) {
                                                                    return StatefulBuilder(
                                                                      builder:
                                                                          (context,
                                                                              setState) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              AppbackgroundColor.Sub_Abg_Colors,
                                                                          titlePadding:
                                                                              const EdgeInsets.all(0.0),
                                                                          contentPadding:
                                                                              const EdgeInsets.all(10.0),
                                                                          actionsPadding:
                                                                              const EdgeInsets.all(6.0),
                                                                          // insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                          content:
                                                                              Container(
                                                                            width:
                                                                                500,
                                                                            child:
                                                                                Padding(
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

                                                                                  const SizedBox(height: 5),

                                                                                  // ตารางอธิบายสถานะ
                                                                                  Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      border: Border.all(color: Colors.grey.shade300),
                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                      boxShadow: [
                                                                                        BoxShadow(
                                                                                          color: Colors.black.withOpacity(0.04),
                                                                                          blurRadius: 8,
                                                                                          offset: const Offset(0, 2),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                      child: Table(
                                                                                        border: TableBorder(
                                                                                          horizontalInside: BorderSide(
                                                                                            width: 1,
                                                                                            color: Colors.grey.shade300,
                                                                                            style: BorderStyle.solid,
                                                                                          ),
                                                                                          verticalInside: BorderSide(
                                                                                            width: 1,
                                                                                            color: Colors.grey.shade300,
                                                                                            style: BorderStyle.solid,
                                                                                          ),
                                                                                        ),
                                                                                        columnWidths: const {
                                                                                          0: FlexColumnWidth(1.2),
                                                                                          1: FlexColumnWidth(1),
                                                                                        },
                                                                                        children: [
                                                                                          TableRow(
                                                                                            decoration: BoxDecoration(
                                                                                              color: Colors.grey.shade100,
                                                                                            ),
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                                                                child: Translate.TranslateAndSetText(
                                                                                                  'สถานะ',
                                                                                                  AccountScreen_Color.Colors_Text1_,
                                                                                                  TextAlign.center,
                                                                                                  FontWeight.bold,
                                                                                                  FontWeight_.Fonts_T,
                                                                                                  14,
                                                                                                  1,
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                                                                child: Translate.TranslateAndSetText(
                                                                                                  'ขั้นตอนถัดไป',
                                                                                                  AccountScreen_Color.Colors_Text1_,
                                                                                                  TextAlign.center,
                                                                                                  FontWeight.bold,
                                                                                                  FontWeight_.Fonts_T,
                                                                                                  14,
                                                                                                  1,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          ...statusRows.map(
                                                                                            (row) => TableRow(
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                                                                  child: Translate.TranslateAndSetText(
                                                                                                    row["status"] ?? '',
                                                                                                    AccountScreen_Color.Colors_Text2_,
                                                                                                    TextAlign.left,
                                                                                                    null,
                                                                                                    Font_.Fonts_T,
                                                                                                    13,
                                                                                                    2,
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                                                                  child: Translate.TranslateAndSetText(
                                                                                                    row["owner"] ?? '',
                                                                                                    AccountScreen_Color.Colors_Text2_,
                                                                                                    TextAlign.left,
                                                                                                    null,
                                                                                                    Font_.Fonts_T,
                                                                                                    13,
                                                                                                    2,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
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
                                                        ],
                                                      )
                                                    : Translate
                                                        .TranslateAndSetText(
                                                            column,
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.left,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            13.8,
                                                            1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        // Data rows
                        Container(
                          child: (isLoading)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(),
                                      StreamBuilder(
                                        stream: Stream.periodic(
                                            const Duration(milliseconds: 25),
                                            (i) => i),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData)
                                            return const Text('');
                                          double elapsed = double.parse(
                                                  snapshot.data.toString()) *
                                              0.05;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                              style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : (displayedData.isEmpty)
                                  ? Container(
                                      height: 200,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'ไม่พบข้อมูล',
                                          style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true, // ✅
                                      physics:
                                          const NeverScrollableScrollPhysics(), // ✅
                                      controller: _scrollController2,
                                      itemCount: displayedData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final row = displayedData[index];
                                        return List_Material(
                                          index,
                                          columnHeaders,
                                          row,
                                          'รายการ',
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildZoneDropdown(bool isSubZone) {
    // ✅ ประกาศตัวแปรให้ครบ
    final List<dynamic> items = isSubZone ? subzoneModels : zoneModels;
    final TextEditingController controller =
        isSubZone ? Dropdown_Controller_zone_Sub : Dropdown_Controller;
    final String? selectedName = isSubZone ? zone_Subname : zone_name;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          searchController: controller,
          hint: Text(
            selectedName ?? 'ทั้งหมด',
            style: const TextStyle(
              fontSize: 14,
              color: PeopleChaoScreen_Color.Colors_Text2_,
              fontFamily: Font_.Fonts_T,
            ),
          ),
          items: items.map<DropdownMenuItem<String>>((dynamic item) {
            final String ser = item?.ser?.toString() ?? '0';
            final String zn = item?.zn?.toString() ?? 'ไม่มีข้อมูล';

            return DropdownMenuItem<String>(
              value: '$ser,$zn',
              child: Text(
                zn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) async {
            if (value == null || value.isEmpty) return;

            final parts = value.split(',');
            if (parts.length < 2) return;

            final String zoneSer = parts[0];
            final String zonesName = parts[1];
            final prefs = await SharedPreferences.getInstance();

            if (isSubZone) {
              await prefs.setString('zoneSubSer', zoneSer);
              await prefs.setString('zonesSubName', zonesName);
            } else {
              await prefs.setString('zonePSer', zoneSer);
              await prefs.setString('zonesPName', zonesName);
            }

            if (mounted) {
              final route = prefs.getString('route') ?? 'ใบอนุญาต';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => AdminScafScreen(route: route)),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchFilterDropdown() {
    const buttonH = 44.0; // ปรับได้ 40/44/50 ตามชอบ
    const itemH = 42.0;

    return Container(
      height: buttonH, // ✅ คุมความสูงทั้งก้อน
      decoration: const BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          bottomLeft: Radius.circular(6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          dropdownWidth: 200,
          isExpanded: true,

          // ✅ ปุ่ม (ตัวที่โชว์อยู่บนแถบ)
          hint: const Center(child: Icon(Icons.sort_outlined)),

          items: _searchList.map((item) {
            return DropdownMenuItem<String>(
              value: item["ser"],
              enabled: false,
              child: ValueListenableBuilder<int>(
                valueListenable: _searchMenuTick,
                builder: (context, _, __) {
                  final selected =
                      item["st"] == '1'; // อ่านสดทุกครั้งที่ tick เปลี่ยน

                  return InkWell(
                    onTap: () {
                      final idx = _searchList
                          .indexWhere((m) => m["ser"] == item["ser"]);
                      if (idx == -1) return;

                      // ✅ เคลียร์ทุกอัน แล้วเลือกอันใหม่
                      for (final e in _searchList) {
                        e["st"] = '0';
                      }
                      _searchList[idx]["st"] = '1';

                      // ✅ บังคับให้ทุก item ในเมนู rebuild
                      _searchMenuTick.value++;

                      // (ถ้าจะยิงโหลดต่อก็เหมือนเดิม)
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 600), () {
                        if (!mounted) return;
                        setState(() {
                          if (Search_Controller.text.trim().isEmpty) {
                            Loading_Main();
                          } else {
                            Loading_Main(query: Search_Controller.text.trim());
                          }
                        });
                      });
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            color: selected ? Colors.green : Colors.black45,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item["title"] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AccountScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.w600,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return (reviewModels.isEmpty)
        ? const SizedBox.shrink()
        : Material(
            color: tappedIndex_ == index.toString()
                ? tappedIndex_Color.tappedIndex_Colors
                : AppbackgroundColor.Sub_Abg_Colors,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              child: Row(children: [
                if (ser_tap == 1 || ser_tap == 2 || ser_tap == 3)
                  SizedBox(
                    width: 120,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                        ),
                        onPressed: (ser_title == 0)
                            ? () {
                                // ser=0: คำขอต่อสัญญา → แสดง ReviewDialog
                                final modelIndex = int.tryParse(
                                        row['index']?.toString() ?? '') ??
                                    index;
                                _showReviewDialog(modelIndex);
                              }
                            : (ser_title == -1)
                                // (ser_title == 0)
                                ? () {
                                    // ser=-1: 3 แท็บหลัก → ตรวจสอบสถานะก่อน
                                    final modelIndex = int.tryParse(
                                            row['index']?.toString() ?? '') ??
                                        index;
                                    final reviewModel =
                                        reviewModels[modelIndex];
                                    final status =
                                        (reviewModel.status ?? '').trim();
                                    final requestUuid = reviewModel
                                        .newRequest?.requestUuid
                                        ?.toString();

                                    // Debug: แสดงสถานะที่ได้รับ
                                    print(
                                        'DEBUG: status = "$status", requestUuid = $requestUuid');

                                    // ใช้ทั้ง requestStep (numeric) และ status (string) ควบคู่กัน
                                    final requestStep = reviewModels[modelIndex]
                                        .newRequest
                                        ?.requestStep;
                                    final paymentStatuses = [
                                      'ร่างคำขอ',
                                      'ส่งเอกสารแล้ว',
                                      'รอกรอกข้อมูลการรับชำระ',
                                      'รอกรอกข้อมูลชำระเงิน',
                                      'ส่งหลักฐานการชำระเงินแล้ว',
                                      'กำลังดำเนินการ',
                                    ];

                                    final isPaymentStatus = paymentStatuses.any(
                                            (s) =>
                                                s.toLowerCase() ==
                                                status.toLowerCase()) ||
                                        (requestStep != null &&
                                            requestStep >= 2 &&
                                            requestStep <= 4);

                                    if (isPaymentStatus) {
                                      // สถานะทั้งหมด → แสดง dialog ชำระเงิน
                                      print(
                                          'DEBUG: สถานะชำระเงิน → RequestExaminer_plugin_CMM');
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) =>
                                            RequestExaminer_plugin_CMM(
                                          modelIndex: modelIndex,
                                          reviewModels: reviewModels,
                                        ),
                                      );
                                    } else if (requestUuid != null &&
                                        requestUuid.isNotEmpty) {
                                      // สถานะอื่นๆ → พุ่งไปหน้า request_contract_cmm.dart พร้อมส่ง UUID
                                      print(
                                          'DEBUG: สถานะอื่นๆ → AdminScafScreen with UUID');
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminScafScreen(
                                            route: 'ใบอนุญาต',
                                            route_getdata: requestUuid,
                                          ),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                : () {
                                    // ser=3,4,5: รออนุมัติ ฯลฯ → นำทางไปหน้าอื่น
                                    final modelIndex = int.tryParse(
                                            row['index']?.toString() ?? '') ??
                                        index;
                                    _navigateToPage(modelIndex);
                                  },
                        child: Translate.TranslateAndSet_TextAutoSize(
                            'เรียกดู',
                            CustomerScreen_Color.Colors_Text3_,
                            TextAlign.center,
                            null,
                            Font_.Fonts_T,
                            10,
                            14,
                            1),
                      ),
                    ),
                  ),
                ...columnHeaders.skip(1).map((column) {
                  final isCopyableColumn = (column == 'เลขที่สัญญา-เดิม' ||
                          column == 'รหัสรายการ') &&
                      row[column]?.toString() != 'NEW';

                  return Expanded(
                    child: isCopyableColumn
                        ? Row(children: [
                            Copy_Text(context, row[column]?.toString() ?? ''),
                            Expanded(
                              child: AutoSizeText(
                                row[column]?.toString() == 'NEW'
                                    ? 'ผู้เช่ารายใหม่'
                                    : row[column]?.toString() ?? '',
                                minFontSize: 11,
                                maxFontSize: 15,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            )
                          ])
                        : AutoSizeText(
                            row[column]?.toString() == 'NEW'
                                ? 'ผู้เช่ารายใหม่'
                                : row[column]?.toString() ?? '',
                            minFontSize: 11,
                            maxFontSize: 15,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                  );
                }).toList(),
              ]),
            ),
          );
  }

  Future<void> _showBulkEditAddonDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool localLoading = true;
        int progressCount = 0;
        int totalToFetch = reviewModels.length;

        final TextEditingController masterBookNo = TextEditingController();
        final TextEditingController masterBookDate = TextEditingController();

        int filterStatus = 0; // 0: ทั้งหมด, 1: ยังไม่กรอก, 2: กรอกแล้ว
        final Set<String> _alreadyHasData = {};

        return StatefulBuilder(
          builder: (context, setStateSB) {
            // ✅ Local Helper for Filter Tabs
            Widget _buildFilterTab(
                StateSetter setStateSB, int status, String label, int current) {
              bool isSelected = status == current;
              return Expanded(
                child: InkWell(
                  onTap: () => setStateSB(() => filterStatus = status),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade600,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Sequential fetching logic
            if (localLoading && progressCount == 0) {
              Future.microtask(() async {
                for (var model in reviewModels) {
                  if (!context.mounted) break;
                  final uuid = model.uuid ?? '';
                  if (uuid.isEmpty) {
                    setStateSB(() => progressCount++);
                    continue;
                  }

                  // ✅ Initialize controllers if they don't exist
                  _rowBookNoControllers[uuid] ??= TextEditingController();
                  _rowBookDateControllers[uuid] ??= TextEditingController();

                  try {
                    final resp = await get_ReviewsAddon(requestUuid: uuid);
                    if (resp != null && resp.statusCode == 200) {
                      try {
                        final body = json.decode(resp.body);
                        if (body['data'] != null) {
                          final addon = body['data'];
                          final bNo = addon['book_no']?.toString() ?? '';
                          final bDateRaw = addon['book_date']?.toString() ?? '';

                          _rowBookNoControllers[uuid]?.text = bNo;
                          if (bDateRaw.isNotEmpty) {
                            try {
                              DateTime dt =
                                  DateFormat('yyyy-MM-dd').parse(bDateRaw);
                              _rowBookDateControllers[uuid]?.text =
                                  DateFormat('dd/MM/yyyy').format(dt);
                            } catch (e) {}
                          }

                          if (bNo.isNotEmpty || bDateRaw.isNotEmpty) {
                            _alreadyHasData.add(uuid);
                          }
                        }
                      } catch (e) {
                        debugPrint(
                            '❌ Error decoding addon response for $uuid: $e');
                      }
                    }
                  } catch (e) {
                    debugPrint('❌ Error fetching addon for $uuid: $e');
                  }

                  setStateSB(() => progressCount++);
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                if (context.mounted) {
                  setStateSB(() => localLoading = false);
                }
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.edit_document, color: Colors.black),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'แก้ไข/เพิ่ม เอกสารบันทึกข้อความ',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (!localLoading)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 600,
                height: 500,
                child: localLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          Text(
                            'กำลังดึงข้อมูล ($progressCount/$totalToFetch)...',
                            style: const TextStyle(fontFamily: Font_.Fonts_T),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '(ดึงข้อมูลทีละรายการเพื่อป้องกันการถูกบล็อก)',
                            style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // ✅ Modern Master Input Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_fix_high,
                                        color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'เครื่องมือช่วยกรอกข้อมูล',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: masterBookNo,
                                            decoration: InputDecoration(
                                              labelText: 'เลขที่บันทึกกลาง',
                                              hintText: 'กรอกเลขที่...',
                                              isDense: true,
                                              filled: true,
                                              fillColor: Colors.blue.shade50
                                                  .withOpacity(0.3),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              prefixIcon: const Icon(
                                                  Icons.numbers,
                                                  size: 18),
                                            ),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                if (masterBookNo.text.isEmpty)
                                                  return;
                                                setStateSB(() {
                                                  for (var model
                                                      in reviewModels) {
                                                    final uuid =
                                                        model.uuid ?? '';
                                                    if (uuid.isNotEmpty) {
                                                      _rowBookNoControllers[
                                                                  uuid]
                                                              ?.text =
                                                          masterBookNo.text;
                                                    }
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.done_all,
                                                  size: 14),
                                              label: const Text(
                                                  'ใช้เลขนี้ทั้งหมด',
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue.shade600,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: masterBookDate,
                                            readOnly: true,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2101),
                                                locale:
                                                    const Locale('th', 'TH'),
                                              );
                                              if (pickedDate != null) {
                                                setStateSB(() {
                                                  masterBookDate.text =
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(pickedDate);
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'วันที่บันทึกกลาง',
                                              isDense: true,
                                              filled: true,
                                              fillColor: Colors.blue.shade50
                                                  .withOpacity(0.3),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              suffixIcon: const Icon(
                                                  Icons.calendar_today,
                                                  size: 18),
                                            ),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                if (masterBookDate.text.isEmpty)
                                                  return;
                                                setStateSB(() {
                                                  for (var model
                                                      in reviewModels) {
                                                    final uuid =
                                                        model.uuid ?? '';
                                                    if (uuid.isNotEmpty) {
                                                      _rowBookDateControllers[
                                                                  uuid]
                                                              ?.text =
                                                          masterBookDate.text;
                                                    }
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.done_all,
                                                  size: 14),
                                              label: const Text(
                                                  'ใช้วันนี้ทั้งหมด',
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.teal.shade600,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          // ✅ Status Filter Tabs
                          Container(
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _buildFilterTab(
                                    setStateSB,
                                    0,
                                    'ทั้งหมด (${reviewModels.length})',
                                    filterStatus),
                                _buildFilterTab(
                                    setStateSB,
                                    1,
                                    'รอกรอก (${reviewModels.where((m) => !_alreadyHasData.contains(m.uuid)).length})',
                                    filterStatus),
                                _buildFilterTab(
                                    setStateSB,
                                    2,
                                    'กรอกแล้ว (${reviewModels.where((m) => _alreadyHasData.contains(m.uuid)).length})',
                                    filterStatus),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.list_alt,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'รายการ (${reviewModels.where((m) {
                                  if (filterStatus == 0) return true;
                                  final hasData =
                                      _alreadyHasData.contains(m.uuid);
                                  return filterStatus == 2 ? hasData : !hasData;
                                }).length} รายการ)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: reviewModels.length,
                              itemBuilder: (context, index) {
                                final model = reviewModels[index];
                                final uuid = model.uuid ?? '';
                                if (uuid.isEmpty) return const SizedBox();

                                // ✅ Filtering Logic based on SAVED state
                                final hasDataSaved =
                                    _alreadyHasData.contains(uuid);
                                if (filterStatus == 1 && hasDataSaved)
                                  return const SizedBox();
                                if (filterStatus == 2 && !hasDataSaved)
                                  return const SizedBox();

                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 16, color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${model.client?.cname ?? 'ไม่ระบุชื่อ'} (${model.newRequest?.ln ?? '-'})',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.map,
                                                          size: 12,
                                                          color: Colors
                                                              .blue.shade300),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'บริเวณ: ${model.newRequest?.subzone ?? '-'}',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Icon(Icons.key,
                                                          size: 12,
                                                          color: Colors
                                                              .grey.shade400),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'UUID: ${uuid.substring(0, 8)}...',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey.shade500,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _rowBookNoControllers[uuid],
                                                decoration: InputDecoration(
                                                  labelText: 'เลขที่บันทึก',
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12,
                                                          vertical: 12),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  prefixIcon: const Icon(
                                                      Icons.edit,
                                                      size: 16),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _rowBookDateControllers[
                                                        uuid],
                                                readOnly: true,
                                                onTap: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2101),
                                                    locale: const Locale(
                                                        'th', 'TH'),
                                                  );
                                                  if (pickedDate != null) {
                                                    setStateSB(() {
                                                      _rowBookDateControllers[
                                                              uuid]
                                                          ?.text = DateFormat(
                                                              'dd/MM/yyyy')
                                                          .format(pickedDate);
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'วันที่บันทึก',
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12,
                                                          vertical: 12),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  suffixIcon: const Icon(
                                                      Icons.calendar_today,
                                                      size: 16),
                                                ),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ],
                                        ),
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
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              actions: localLoading
                  ? [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: totalToFetch > 0
                                  ? progressCount / totalToFetch
                                  : 0,
                              minHeight: 8,
                              backgroundColor: Colors.blue.shade50,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade700),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'กำลังดำเนินการ... $progressCount / $totalToFetch',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ],
                      )
                    ]
                  : [
                      Row(
                        children: [
                          // TextButton.icon(
                          //   onPressed: () => Navigator.pop(context),
                          //   icon: const Icon(Icons.close, size: 18),
                          //   label: const Text('ยกเลิก',
                          //       style: TextStyle(fontFamily: Font_.Fonts_T)),
                          //   style: TextButton.styleFrom(
                          //       foregroundColor: Colors.grey.shade600),
                          // ),
                          // const Spacer(),
                          if (filterStatus != 0)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: filterStatus == 1
                                    ? Colors.blue.shade700
                                    : Colors.teal.shade700,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                setStateSB(() {
                                  localLoading = true;
                                  progressCount = 0;
                                });
                                int successCount = 0;
                                int total = reviewModels.length;

                                for (var model in reviewModels) {
                                  if (!context.mounted) break;
                                  final uuid = model.uuid ?? '';
                                  if (uuid.isEmpty) {
                                    setStateSB(() => progressCount++);
                                    continue;
                                  }

                                  // ✅ บันทึกตามหัวข้อ (กรองตามแท็บที่เลือก)
                                  final hasDataSaved =
                                      _alreadyHasData.contains(uuid);
                                  if (filterStatus == 1 && hasDataSaved) {
                                    setStateSB(() => progressCount++);
                                    continue;
                                  }
                                  if (filterStatus == 2 && !hasDataSaved) {
                                    setStateSB(() => progressCount++);
                                    continue;
                                  }

                                  final bookNo =
                                      _rowBookNoControllers[uuid]?.text ?? '';
                                  final dateText =
                                      _rowBookDateControllers[uuid]?.text ?? '';

                                  String apiDate = '';
                                  if (dateText.isNotEmpty) {
                                    try {
                                      DateTime dt = DateFormat('dd/MM/yyyy')
                                          .parse(dateText);
                                      apiDate =
                                          DateFormat('yyyy-MM-dd').format(dt);
                                    } catch (e) {
                                      apiDate = dateText;
                                    }
                                  }

                                  final resp = await Post_ReviewsAddon(
                                    requestUuid: uuid,
                                    bookNo: bookNo,
                                    bookDate: apiDate,
                                  );

                                  if (resp != null &&
                                      (resp.statusCode == 200 ||
                                          resp.statusCode == 201)) {
                                    successCount++;
                                    _alreadyHasData
                                        .add(uuid); // ✅ Mark as filled
                                  }

                                  setStateSB(() => progressCount++);
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                }

                                if (context.mounted) {
                                  // ✅ ถ้าบันทึกในหน้า "รอกรอก" ให้รีเฟรชข้อมูลหลักด้วย
                                  if (filterStatus == 1) {
                                    Loading_Main();
                                  }

                                  setStateSB(() => localLoading = false);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green.shade800,
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 12),
                                          Text(
                                              'บันทึกสำเร็จ $successCount รายการ'),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.save_rounded),
                              label: Text(
                                  filterStatus == 1
                                      ? 'บันทึกข้อมูล'
                                      : 'บันทึกการแก้ไข',
                                  style: const TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // ✅ แบบฟอร์มตรวจสอบเอกสารแบบกลุ่ม
  void _showBulkDocumentReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFFF4F6FA),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.88,
            height: MediaQuery.of(context).size.height * 0.85,
            child: StatefulBuilder(
              builder: (ctx, setStateDialog) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // ═ Header ═
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade800,
                                Colors.indigo.shade500
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.checklist_rtl_rounded,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'ตรวจสอบเอกสารแบบกลุ่ม',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text('${reviewModels.length} รายการ',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 13)),
                              const SizedBox(width: 12),
                              // ✅ ปุ่มตรวจสอบทั้งหมด
                              if (reviewModels.any((m) => m.needReview == true))
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _showBulkVerifyConfirmationDialog(
                                          onConfirm: () =>
                                              setStateDialog(() {})),
                                  icon: const Icon(Icons.done_all, size: 18),
                                  label: const Text('ตรวจสอบทั้งหมดพร้อมกัน',
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(ctx)),
                            ],
                          ),
                        ),
                        // ═ Column Headers ═
                        Container(
                          color: Colors.indigo.shade50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 32,
                                  child: Text('#',
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                              const Expanded(
                                  flex: 3,
                                  child: Text('ชื่อผู้เช่า',
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                              const Expanded(
                                  flex: 2,
                                  child: Text('บริเวณ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                              const Expanded(
                                  flex: 2,
                                  child: Text('สถานะเอกสาร',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                              const SizedBox(
                                  width: 90,
                                  child: Text('ตรวจสอบ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // ═ List ═
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: reviewModels.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, thickness: 0.5),
                            itemBuilder: (ctx, index) {
                              final model = reviewModels[index];
                              final clientName =
                                  model.client?.cname?.toString() ?? '-';
                              final zn = model.newRequest?.zn ?? '';
                              final ln = model.newRequest?.ln ?? '';
                              final subzone = model.newRequest?.subzone ?? '';
                              final area = [subzone, zn, ln]
                                  .where((s) => s.isNotEmpty)
                                  .join(' / ');
                              final allApproved =
                                  model.allAttachmentsApproved == true;
                              final needReview = model.needReview == true;
                              final hasNew = model.hasNewAttachment == true;

                              // status chip
                              Color chipColor;
                              String chipLabel;
                              IconData chipIcon;
                              if (allApproved) {
                                chipColor = Colors.green.shade700;
                                chipLabel = 'ผ่านครบ';
                                chipIcon = Icons.check_circle;
                              } else if (needReview) {
                                chipColor = Colors.orange.shade700;
                                chipLabel = 'รอตรวจ';
                                chipIcon = Icons.hourglass_top;
                              } else if (hasNew) {
                                chipColor = Colors.blue.shade700;
                                chipLabel = 'เอกสารใหม่';
                                chipIcon = Icons.fiber_new;
                              } else {
                                chipColor = Colors.grey.shade600;
                                chipLabel = 'ยังไม่รับ';
                                chipIcon = Icons.upload_file;
                              }

                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : Colors.indigo.shade50.withOpacity(0.4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 32,
                                        child: Text('${index + 1}',
                                            style: const TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                fontSize: 12,
                                                color: Colors.blueGrey))),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        clientName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        area.isEmpty ? '-' : area,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 12,
                                            color: Colors.blueGrey),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(chipIcon,
                                              size: 14, color: chipColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            chipLabel,
                                            style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                fontSize: 11,
                                                color: chipColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade700,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await _showReviewDialog(index);
                                        },
                                        child: const Text('ตรวจสอบ',
                                            style: TextStyle(
                                                fontFamily: Font_.Fonts_T,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // ═ Footer summary ═
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                            border: Border(
                                top: BorderSide(
                                    color: Colors.indigo.shade100, width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _docStatusChip(
                                  Icons.check_circle,
                                  Colors.green.shade700,
                                  'ผ่านครบ',
                                  reviewModels
                                      .where((m) =>
                                          m.allAttachmentsApproved == true)
                                      .length),
                              _docStatusChip(
                                  Icons.hourglass_top,
                                  Colors.orange.shade700,
                                  'รอตรวจ',
                                  reviewModels
                                      .where((m) =>
                                          m.needReview == true &&
                                          m.allAttachmentsApproved != true)
                                      .length),
                              _docStatusChip(
                                  Icons.fiber_new,
                                  Colors.blue.shade700,
                                  'เอกสารใหม่',
                                  reviewModels
                                      .where((m) =>
                                          m.hasNewAttachment == true &&
                                          m.needReview != true &&
                                          m.allAttachmentsApproved != true)
                                      .length),
                              _docStatusChip(
                                  Icons.upload_file,
                                  Colors.grey.shade600,
                                  'ยังไม่รับ',
                                  reviewModels
                                      .where((m) =>
                                          m.allAttachmentsApproved != true &&
                                          m.needReview != true &&
                                          m.hasNewAttachment != true)
                                      .length),
                              TextButton.icon(
                                onPressed: () => Navigator.pop(ctx),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('ปิด',
                                    style:
                                        TextStyle(fontFamily: Font_.Fonts_T)),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_bulkVerifyProcessing)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Card(
                              elevation: 8,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 20),
                                    Text('กำลังดำเนินการ...',
                                        style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Text(_bulkVerifyStatusText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 14)),
                                    const SizedBox(height: 20),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _bulkVerifyProgress,
                                        minHeight: 10,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.indigo.shade700),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        '${(_bulkVerifyProgress * 100).toInt()}%',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ✅ แสดงความคืบหน้าการตรวจสอบแบบกลุ่ม
  void _showBulkVerifyProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setProgressState) {
            // เราใช้ setState ของ class หลักเพื่อคุม progress แต่ถ้าจะให้ลื่นไหลอาจต้องใช้ NotificationListener หรือแนวทางอื่น
            // ในที่นี้เราจะใช้ Timer สั้นๆ เพื่อดึงค่าจาก _bulkVerifyProgress มาแสดง
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('กำลังดำเนินการตรวจสอบ...',
                  style: TextStyle(
                      fontFamily: Font_.Fonts_T, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _bulkVerifyProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 20),
                  Text(_bulkVerifyStatusText,
                      style:
                          TextStyle(fontFamily: Font_.Fonts_T, fontSize: 14)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performBulkVerification(
      String auditorName, String auditorPosition, String statusNote,
      {VoidCallback? onUpdate}) async {
    // กรองเอาเฉพาะรายการที่ต้องตรวจสอบ
    final targets = reviewModels.where((m) => m.needReview == true).toList();
    if (targets.isEmpty) {
      Dialog_success(context, 'ไม่พบรายการที่ต้องตรวจสอบ');
      return;
    }

    setState(() {
      _bulkVerifyProcessing = true;
      _bulkVerifyProgress = 0.0;
      _bulkVerifyStatusText = 'เริ่มต้นดำเนินการ...';
    });
    if (onUpdate != null) onUpdate();

    // แสดง Progress Dialog (อาจต้องจัดการ context ดีๆ)
    // สำหรับการ demo นี้ จะทำแบบ sequential และ update state

    int completed = 0;
    final total = targets.length;

    try {
      final ttf = await font1();
      final imageCheck = await rootBundle.load('images/check1.png');
      final imageSquare = await rootBundle.load('images/square3.png');
      final checkIcon = pw.MemoryImage(imageCheck.buffer.asUint8List());
      final squareIcon = pw.MemoryImage(imageSquare.buffer.asUint8List());

      for (var model in targets) {
        final requestUuid = model.newRequest?.requestUuid;
        if (requestUuid == null) continue;

        setState(() {
          _bulkVerifyStatusText =
              'กำลังดำเนินการ: ${model.client?.cname ?? 'ไม่ระบุชื่อ'} ($completed/$total)';
          _bulkVerifyProgress = completed / total;
        });
        if (onUpdate != null) onUpdate();

        // 1. ดึงรายละเอียดเพื่อเอารายการเอกสาร
        final detailResp = await read_GC_ReviewsUuid(requestUuid);
        if (detailResp != null && detailResp.statusCode == 200) {
          final detailData = json.decode(detailResp.body);
          final reviewDetail = ReviewDetail.fromJson(detailData['data']);

          // 2. สร้าง PDF
          final pdfBytes = await _generateChecklistPdfBytes(
            reviewDetail: reviewDetail,
            ttf: ttf,
            checkIcon: checkIcon,
            squareIcon: squareIcon,
            auditorName: auditorName,
            auditorPosition: auditorPosition,
          );

          // 3. ส่ง Commit
          await Post_ReviewsCheckListCommit(
            requestUuid: requestUuid,
            profileUuid: proFileUuid,
            signatureUuid: sigNatureUuid,
            staTus: 'approved',
            documentId: '', // ตาม examiner1_cmm ส่งว่างได้
            file: pdfBytes,
          );
        }

        completed++;
      }

      setState(() {
        _bulkVerifyProgress = 1.0;
        _bulkVerifyStatusText = 'ดำเนินการสำเร็จ $total รายการ';
      });
      if (onUpdate != null) onUpdate();

      await Dialog_success(context, 'ตรวจสอบเอกสารทั้งหมดสำเร็จ');
      Loding_route_getdata(); // Refresh ข้อมูล
    } catch (e) {
      debugPrint('Bulk Verify Error: $e');
      Dialog_error(context, 'เกิดข้อผิดพลาดในการตรวจสอบแบบกลุ่ม');
    } finally {
      setState(() {
        _bulkVerifyProcessing = false;
      });
      if (onUpdate != null) onUpdate();
    }
  }

  Future<Uint8List> _generateChecklistPdfBytes({
    required ReviewDetail reviewDetail,
    required pw.Font ttf,
    required pw.ImageProvider checkIcon,
    required pw.ImageProvider squareIcon,
    required String auditorName,
    required String auditorPosition,
  }) async {
    final pdf = pw.Document();

    // ฟังก์ชันช่วยสร้าง section (ลอกตรรกะจาก PreviewPdfgenchecklist_CMM2)
    List<pw.Widget> buildSection(String titleTag) {
      final docs = reviewDetail.submitteddocuments
          .where((doc) => doc.document.nameTh.toUpperCase() != 'SAMPLE')
          .toList();

      return [
        pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text('[$titleTag]',
              style: pw.TextStyle(
                  font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('สำหรับเจ้าหน้าที่',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('ได้รับเอกสารประกอบคำขอต่ออายุใบอนุญาต',
                      style: pw.TextStyle(font: ttf, fontSize: 13)),
                  pw.Text(
                      'พื้นที่ผ่อนผันบริเวณ : ${reviewDetail.newRequest.zn}',
                      style: pw.TextStyle(font: ttf, fontSize: 13)),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  children: [
                    pw.Text('ตรวจเอกสาร',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'โซน: ${reviewDetail.newRequest.zn} / พื้นที่: ${reviewDetail.newRequest.ln}',
                        style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(checkIcon, width: 10, height: 10),
                        pw.SizedBox(width: 2),
                        pw.Text('ผ่าน',
                            style: pw.TextStyle(font: ttf, fontSize: 10)),
                        pw.SizedBox(width: 10),
                        pw.Image(squareIcon, width: 10, height: 10),
                        pw.SizedBox(width: 2),
                        pw.Text('ไม่ผ่าน',
                            style: pw.TextStyle(font: ttf, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        for (int i = 0; i < docs.length; i += 2)
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Image(
                        (docs[i].attachment?.fileName?.isNotEmpty ?? false)
                            ? checkIcon
                            : squareIcon,
                        width: 12,
                        height: 12),
                    pw.SizedBox(width: 5),
                    pw.Text(docs[i].document.nameTh,
                        style: pw.TextStyle(font: ttf, fontSize: 11)),
                  ],
                ),
              ),
              if (i + 1 < docs.length)
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Image(
                          (docs[i + 1].attachment?.fileName?.isNotEmpty ??
                                  false)
                              ? checkIcon
                              : squareIcon,
                          width: 12,
                          height: 12),
                      pw.SizedBox(width: 5),
                      pw.Text(docs[i + 1].document.nameTh,
                          style: pw.TextStyle(font: ttf, fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
        pw.SizedBox(height: 15),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            children: [
              if (signaturesUrl != null)
                pw.Image(pw.MemoryImage(signaturesUrl!),
                    width: 80, height: 40, fit: pw.BoxFit.contain),
              pw.Text('(ลงชื่อ) $auditorName',
                  style: pw.TextStyle(font: ttf, fontSize: 12)),
              pw.Text('$auditorPosition',
                  style: pw.TextStyle(font: ttf, fontSize: 11)),
            ],
          ),
        ),
      ];
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          ...buildSection('ต้นฉบับ'),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
          pw.SizedBox(height: 20),
          ...buildSection('สำเนา'),
        ],
      ),
    );

    return pdf.save();
  }

  void _showBulkVerifyConfirmationDialog({VoidCallback? onConfirm}) {
    final nameController = TextEditingController(text: fullNameAdmin);
    final posController = TextEditingController(text: positionAdmin);
    final noteController =
        TextEditingController(text: 'เอกสารนี้ถูกต้องผ่านเกณฑ์แล้ว');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ยืนยันการตรวจสอบเอกสารแบบกลุ่ม',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'ลงชื่อยืนยันความถูกต้องสำหรับทุกรายการที่ "รอการตรวจสอบ"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                      labelText: 'บันทึกเพิ่มเติม',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (signaturesUrl != null)
                        Image.memory(signaturesUrl!,
                            height: 100, fit: BoxFit.contain)
                      else
                        const Icon(Icons.draw, size: 50, color: Colors.grey),
                      const Divider(),
                      const Text('ตัวอย่างลายเซ็น',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ตรวจสอบ',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: posController,
                  decoration: const InputDecoration(
                      labelText: 'ตำแหน่ง', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                if (onConfirm != null) onConfirm();
                _performBulkVerification(nameController.text,
                    posController.text, noteController.text,
                    onUpdate: onConfirm);
              },
              child: const Text('ยืนยันและตรวจสอบทั้งหมด'),
            ),
          ],
        );
      },
    );
  }

  Widget _docStatusChip(IconData icon, Color color, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text('$label: $count',
            style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _showReviewDialog(int indexX) async {
    if (indexX < 0 || indexX >= reviewModels.length) return;
    final model = reviewModels[indexX];
    if (model.newRequest == null) return;

    final requestUuidStr = model.newRequest?.requestUuid?.toString();
    if (requestUuidStr == null || requestUuidStr.isEmpty) return;

    await SecurePrefs.setEncrypted(SecurePrefsType.UuidRequest, requestUuidStr);

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          int tapSer = 0;
          return StatefulBuilder(
            builder: (context, setStateSB) {
              return AlertDialog(
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                actionsPadding: const EdgeInsets.all(8),
                title: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50.withOpacity(0.5),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setStateSB(() => tapSer = 0),
                            child: Container(
                              width: 150,
                              decoration: BoxDecoration(
                                color: (tapSer == 0)
                                    ? Colors.black
                                    : Colors.black54,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Row(
                                children: [
                                  Icon(Icons.list,
                                      color: Colors.white, size: 25),
                                  SizedBox(width: 4),
                                  Text(
                                    'ข้อมูลผู้ทำรายการ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () => setStateSB(() => tapSer = 1),
                            child: Container(
                              width: 150,
                              decoration: BoxDecoration(
                                color: (tapSer == 1)
                                    ? Colors.black
                                    : Colors.black54,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Row(
                                children: [
                                  Icon(Icons.safety_check,
                                      color: Colors.white, size: 25),
                                  SizedBox(width: 4),
                                  Text(
                                    'ข้อมูลข้อเท็จจริง',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.redAccent, size: 26),
                        tooltip: 'ปิดหน้าต่าง',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: (tapSer == 0)
                          ? const RequestExaminer1_CMM(
                              viewver: true,
                              plugin: false,
                            )
                          : const RequestExaminer2_CMM(
                              viewver: true,
                              plugin: false,
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> _navigateToPage(int indexX) async {
    if (indexX < 0 || indexX >= reviewModels.length) return;
    final model = reviewModels[indexX];
    if (model.newRequest == null) return;

    final requestUuidStr = model.newRequest?.requestUuid?.toString();
    if (requestUuidStr == null || requestUuidStr.isEmpty) return;

    await SecurePrefs.setEncrypted(SecurePrefsType.UuidRequest, requestUuidStr);

    // ✅ ป้องกัน RangeError: Index out of range: index should be less than 4: 4
    if (ser_tap - 1 < 0 || ser_tap - 1 >= title_data.length) return;
    final pageTarget = title_data[ser_tap - 1]['page'];
    if (pageTarget == null) return;

    MaterialPageRoute materialPageRoute = MaterialPageRoute(
        builder: (BuildContext context) =>
            AdminScafScreen(route: '$pageTarget'));
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context, materialPageRoute, (route) => false);
    }
  }
}
