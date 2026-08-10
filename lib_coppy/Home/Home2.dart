import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../Style/colors.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GC_userSub_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Model/HomeDashboard_Model.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Style/Translate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'home_dashboard.dart';
import 'home_reservespace.dart';
import 'home_reservespace_calendar.dart';
import '../Constant/api_cache.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  static final _apiCache = ApiCache(ttl: const Duration(seconds: 60));
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("#,##0", "en_US");
  final TextEditingController Form_note = TextEditingController();
  List<DashNoteModel> noteModels = [];
  String? sernote;
  bool _isLoadingNote = false;
  int _totalTenants = 0;
  int _nearExpired = 0;
  int _expired = 0;
  int _interested = 0;
  List<DashTeNantModel> _currentTenants = []; // Store top 5 current tenants
  List<NearExpiredModel> _nearExpiredContracts = [];
  List<DashZoneModel> _popularZones = []; // Store top 5 popular zones
  List<DashZoneModel> _contractPopularZone = [];
  List<DashTeNantModel> _contractCancel = [];
  List<DailyRevenue> _recentRevenue = [];
  DashAreaModel? _areaData;
  bool _showMore = false;

  // Original Header State
  int show_Dashboard = 0;
  List<RenTalModel> renTalModels = [];
  List<UserSubModel> renTalusersubModel = [];
  String? renTal_name, renTalsub_name;
  bool _isFetchingTenantCounts = false;
  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await Future.wait([
      checkPreferance(),
      read_GC_rental(),
      readRentalUserSub(),
      // fetchPopularZones(), // Now handled by read_GC_note
      read_GC_note(),
      fetchTenantCounts(),
      fetchRecentRevenue(),
    ]);
  }

  @override
  void dispose() {
    Form_note.dispose();
    super.dispose();
  }

  Future<void> fetchTenantCounts() async {
    final prefs = await SharedPreferences.getInstance();

    final ren = prefs.getString('renTalSer');
    final zone = prefs.getString('zonePSer') ?? '0';

    if (ren == null || ren.isEmpty) return;

    final zoneVal =
        (zone == 'null' || zone == '0' || zone.isEmpty) ? '0' : zone;

    final cacheKey = 'fetchTenantCounts_${ren}_$zoneVal';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        setState(() {
          _totalTenants = cached['total'] ?? 0;
          _expired = cached['expired'] ?? 0;
          _nearExpired = cached['near_expired'] ?? 0;
          _interested = cached['interested'] ?? 0;

          if (cached['tenants'] != null) {
            _currentTenants = (cached['tenants'] as List)
                .map((m) => DashTeNantModel.fromJson(m))
                .toList();
          }
          if (cached['near_expired_list'] != null) {
            _nearExpiredContracts = (cached['near_expired_list'] as List)
                .map((m) => NearExpiredModel.fromJson(m))
                .toList();
          }
        });
        return;
      }
    }

    if (_isFetchingTenantCounts) return;
    _isFetchingTenantCounts = true;

    try {
      final url = Uri.parse(
        '${MyConstant().domain}/GC_tenantAll_V2_dash.php?isAdd=true&ren=$ren&zone=$zoneVal',
      );

      final headers = Security.generateAuthHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode != 200) {
        print('Tenant dashboard http error: ${response.statusCode}');
        return;
      }

      final decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic>) {
        print('Tenant dashboard: invalid json map');
        return;
      }

      if (decoded['success'] != true) {
        print('Tenant dashboard api error: ${decoded['error']}');
        return;
      }

      final int totalTenants = int.tryParse('${decoded['current'] ?? 0}') ?? 0;
      final int expired = int.tryParse('${decoded['expired'] ?? 0}') ?? 0;
      final int nearExpired =
          int.tryParse('${decoded['near_expired'] ?? 0}') ?? 0;
      final int interested = int.tryParse('${decoded['interested'] ?? 0}') ?? 0;

      final dynamic rawTop7 = decoded['current_top7'];
      final List<DashTeNantModel> tenants = <DashTeNantModel>[];

      if (rawTop7 is List) {
        for (final item in rawTop7) {
          try {
            if (item is Map) {
              tenants.add(
                DashTeNantModel.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          } catch (e) {
            print('Parse current_top7 item error: $e');
          }
        }
      }

      final dynamic rawNearExpired = decoded['near_expired_list'];
      final List<NearExpiredModel> nearExpiredContracts = <NearExpiredModel>[];

      if (rawNearExpired is List) {
        for (final item in rawNearExpired) {
          try {
            if (item is Map) {
              nearExpiredContracts.add(
                NearExpiredModel.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          } catch (e) {
            print('Parse near_expired_list item error: $e');
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _totalTenants = totalTenants;
        _expired = expired;
        _nearExpired = nearExpired;
        _interested = interested;

        _currentTenants = tenants;
        _nearExpiredContracts = nearExpiredContracts;
      });

      _apiCache.set(cacheKey, {
        'total': totalTenants,
        'expired': expired,
        'near_expired': nearExpired,
        'interested': interested,
        'tenants': rawTop7,
        'near_expired_list': rawNearExpired,
      });
    } catch (e) {
      print('Error fetching tenant dashboard: $e');
    } finally {
      _isFetchingTenantCounts = false;
    }
  }

  // Future<dynamic> _fetchData(String ren, String zone, int status) async {
  //   var zoneVal = (zone == 'null' || zone == '0' || zone.isEmpty) ? '0' : zone;
  //   var url = Uri.parse(
  //       '${MyConstant().domain}/GC_tenantAll_V2_das.php?isAdd=true&ren=$ren&zone=$zoneVal&status=$status${status == 4 ? "&where_quot=1" : ""}');

  //   try {
  //     var headers = Security.generateAuthHeaders();
  //     var response = await http.get(url, headers: headers);
  //     if (response.statusCode == 200) {
  //       var body = json.decode(response.body);
  //       var items = body is Map ? body['data'] as List? : body as List?;
  //       return items ?? [];
  //     }
  //   } catch (e) {
  //     print("Error fetching count for status $status: $e");
  //   }
  //   return [];
  // }

  // Future<void> fetchTenantCounts() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var zone = preferences.getString('zonePSer') ?? '0';

  //   if (ren == null || ren.isEmpty) return;

  //   try {
  //     // Fetch all 4 categories in parallel for accuracy and performance
  //     final results = await Future.wait([
  //       _fetchData(ren, zone, 1), // Current
  //       _fetchData(ren, zone, 2), // Expired
  //       _fetchData(ren, zone, 3), // Near Expired
  //       _fetchData(ren, zone, 4), // Interested
  //     ]);

  //     if (mounted) {
  //       setState(() {
  //         dynamic currentRef = results[0];
  //         List currentList = (currentRef is List) ? currentRef : [];
  //         _totalTenants = currentList.length;

  //         dynamic expiredRef = results[1];
  //         _expired = (expiredRef is List) ? expiredRef.length : 0;

  //         dynamic nearExpiredRef = results[2];
  //         _nearExpired = (nearExpiredRef is List) ? nearExpiredRef.length : 0;

  //         dynamic interestedRef = results[3];
  //         _interested = (interestedRef is List) ? interestedRef.length : 0;

  //         // Robust parsing for the top 7 current tenants
  //         _currentTenants = [];
  //         for (var item in currentList.take(7)) {
  //           try {
  //             if (item is Map) {
  //               _currentTenants.add(
  //                   DashTeNantModel.fromJson(Map<String, dynamic>.from(item)));
  //             }
  //           } catch (e) {
  //             print("Error parsing tenant item: $e");
  //           }
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching tenant counts: $e");
  //   }
  // }

  Future<void> fetchRecentRevenue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    if (ren == null || ren.isEmpty) return;

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 6));
    String sDate = DateFormat('yyyy-MM-dd').format(startDate);
    String lDate = DateFormat('yyyy-MM-dd').format(now);

    final cacheKey = 'fetchRecentRevenue_${ren}_$sDate$lDate';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        setState(() {
          _recentRevenue =
              (cached as List).map((e) => DailyRevenue.fromJson(e)).toList();
        });
        return;
      }
    }

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_DailyReport_All.php?isAdd=true&ren=$ren&s_date=$sDate&l_date=$lDate&serzone=0&seruser=0&ser_in=1&serzone=0';

    try {
      print('Bill dashboard http : $url');
      var response = await httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Bill dashboard http error: ${response.statusCode}');
        return;
      }

      var result = json.decode(response.body);
      if (!mounted) return;

      if (result != null && result != 'null') {
        Map<String, double> dailySum = {};

        for (int i = 0; i < 7; i++) {
          String dateKey =
              DateFormat('dd/MM').format(now.subtract(Duration(days: 6 - i)));
          dailySum[dateKey] = 0.0;
        }

        if (result is List) {
          for (var map in result) {
            TransReBillModel model = TransReBillModel.fromJson(map);
            String? dateStr = model.daterec ?? model.dateacc ?? model.date;

            if (dateStr != null && dateStr.isNotEmpty && dateStr != 'null') {
              try {
                DateTime date = DateTime.parse(dateStr);
                String dateKey = DateFormat('dd/MM').format(date);

                if (dailySum.containsKey(dateKey)) {
                  double amt = double.tryParse(model.total_bill ?? '0') ?? 0.0;
                  dailySum[dateKey] = (dailySum[dateKey] ?? 0.0) + amt;
                }
              } catch (e) {
                print("Error parsing date/amount for revenue: $e");
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _recentRevenue = dailySum.entries
                .map((e) => DailyRevenue(e.key, e.value))
                .toList();
          });

          _apiCache.set(
            cacheKey,
            _recentRevenue.map((e) => e.toJson()).toList(),
          );
        }
      }
    } catch (e) {
      print("Error fetching recent revenue: $e");
    }
  }

  Future<void> read_GC_note({List<String>? keys}) async {
    final fetchKeys = keys ?? ['popularzones', 'note'];

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser');

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 7));
    String sDate = DateFormat('yyyy-MM-dd').format(startDate);
    String lDate = DateFormat('yyyy-MM-dd').format(now);

    final keyPart = fetchKeys.join('_');
    final cacheKey =
        'read_GC_note_${ren}_${ser_user}_${sDate}_${lDate}_$keyPart';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        setState(() {
          if (cached['note'] != null) {
            noteModels = [DashNoteModel.fromJson(cached['note'])];
            Form_note.text = noteModels[0].note ?? '';
            sernote = noteModels[0].ser;
          }
          if (cached['popularzones'] != null) {
            _popularZones = (cached['popularzones'] as List)
                .map((m) => DashZoneModel.fromJson(m))
                .toList();
          }
          if (cached['contract_popularzone'] != null) {
            _contractPopularZone = (cached['contract_popularzone'] as List)
                .map((m) => DashZoneModel.fromJson(m))
                .toList();
          }
          if (cached['contract_cancel'] != null) {
            _contractCancel = (cached['contract_cancel'] as List)
                .map((m) => DashTeNantModel.fromJson(m))
                .toList();
          }
          if (cached['area'] != null) {
            _areaData = DashAreaModel.fromJson(cached['area']);
          }
        });
        return;
      }
    }

    setState(() {
      _isLoadingNote = true;
    });

    if (fetchKeys.contains('note') && noteModels.isNotEmpty) {
      noteModels.clear();
    }

    String url = '${MyConstant().domain}/GC_Note_das.php';

    try {
      var response = await httpClient.post(
        Uri.parse(url),
        body: {
          'isAdd': 'true',
          'ren': ren ?? '',
          'ser_user': ser_user ?? '',
          'sdate': sDate,
          'ldate': lDate,
          'data': jsonEncode(fetchKeys),
        },
      );

      var result = json.decode(response.body);

      if (result != null && result['status'] == true) {
        _apiCache.set(cacheKey, result);

        final List<DashNoteModel> tempNotes = [];
        String lastDescr = '';
        String lastSer = '';

        if (result['note'] != null && result['note'] is Map) {
          try {
            DashNoteModel noteModel = DashNoteModel.fromJson(result['note']);
            tempNotes.add(noteModel);
            lastDescr = noteModel.note ?? '';
            lastSer = noteModel.ser ?? '';
          } catch (e) {
            print("Error parsing single note: $e");
          }
        }

        List<DashZoneModel> tempZones = [];
        if (result['popularzones'] != null && result['popularzones'] is List) {
          for (var map in result['popularzones']) {
            try {
              tempZones.add(DashZoneModel.fromJson(map));
            } catch (e) {
              print("Error parsing zone item: $e");
            }
          }
        }

        List<DashZoneModel> tempContractZones = [];
        if (result['contract_popularzone'] != null &&
            result['contract_popularzone'] is List) {
          for (var map in result['contract_popularzone']) {
            try {
              tempContractZones.add(DashZoneModel.fromJson(map));
            } catch (e) {
              print("Error parsing contract zone item: $e");
            }
          }
        }

        DashAreaModel? tempArea;
        if (result['area'] != null) {
          if (result['area'] is Map) {
            tempArea = DashAreaModel.fromJson(result['area']);
          } else if (result['area'] is List && result['area'].isNotEmpty) {
            tempArea = DashAreaModel.fromJson(result['area'][0]);
          }
        }

        List<DashTeNantModel> tempCancel = [];
        Map<String, int> cancelMap = {};
        DateTime now = DateTime.now();

        for (int i = 0; i < 7; i++) {
          String dateKey = DateFormat('yyyy-MM-dd')
              .format(now.subtract(Duration(days: 6 - i)));
          cancelMap[dateKey] = 0;
        }

        if (result['contract_cancel'] != null &&
            result['contract_cancel'] is List) {
          for (var map in result['contract_cancel']) {
            try {
              String? ccDate = map['cc_date']?.toString();
              int total = int.tryParse(map['total']?.toString() ?? '0') ?? 0;
              if (ccDate != null && cancelMap.containsKey(ccDate)) {
                cancelMap[ccDate] = cancelMap[ccDate]! + total;
              }
            } catch (e) {
              print("Error parsing contract cancel item: $e");
            }
          }
        }

        cancelMap.forEach((date, total) {
          tempCancel.add(DashTeNantModel(
            ccDate: date,
            total: total.toString(),
            st: 'ยกเลิกสัญญา',
          ));
        });

        if (!mounted) return;

        setState(() {
          noteModels.clear();
          noteModels.addAll(tempNotes);

          if (lastDescr.isNotEmpty && lastDescr != 'null') {
            Form_note.text = lastDescr;
          }
          if (lastSer.isNotEmpty && lastSer != 'null') {
            sernote = lastSer;
          }

          if (fetchKeys.contains('popularzones')) {
            _popularZones = tempZones.take(7).toList();
          }
          if (fetchKeys.contains('contract_popularzone')) {
            _contractPopularZone = tempContractZones;
          }
          if (fetchKeys.contains('contract_cancel')) {
            _contractCancel = tempCancel;
          }
          if (fetchKeys.contains('area')) {
            _areaData = tempArea;
          }

          _isLoadingNote = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingNote = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching combined dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoadingNote = false;
        });
      }
    }
  }

  Future<void> save_GC_note() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser');

    String url = '${MyConstant().domain}/UDC_Note.php';
    try {
      var response = await httpClient.post(Uri.parse(url), body: {
        'isAdd': 'true',
        'ren': ren ?? '',
        'ser_user': ser_user ?? '',
        'descr': Form_note.text,
        'sernote': sernote ?? '',
      });

      var result = json.decode(response.body);
      if (result.toString() == 'null' || result.toString() == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกสำเร็จ',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
            backgroundColor: Colors.green,
          ),
        );
        read_GC_note();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error saving note: $e");
    }
  }

  Widget _buildSummaryCard(
      String title, String count, Color accentColor, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TextHome_Color.Sub_TextHome_Colors,
                  fontSize: 14,
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                count,
                style: const TextStyle(
                  color: HomeScreen_Color.Colors_Text1_,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalNote() {
    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'โน๊ตส่วนตัว',
                style: TextStyle(
                  color: HomeScreen_Color.Colors_Text1_,
                  fontSize: 18,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingNote)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: read_GC_note,
                  icon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
                  tooltip: 'รีเฟรช',
                )
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TextField(
              controller: Form_note,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: Font_.Fonts_T, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'พิมพ์โน๊ตส่วนตัวของคุณที่นี่...',
                hintStyle: const TextStyle(
                    color: Colors.black38, fontFamily: Font_.Fonts_T),
                filled: true,
                fillColor: AppbackgroundColor.Abg_Colors.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: save_GC_note,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppBarColors.hexColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text(
                'บันทึกโน๊ต',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickInsights() {
    final active = double.tryParse(_areaData?.areaActive ?? '0') ?? 0;
    final total = double.tryParse(_areaData?.totalArea ?? '0') ?? 0;
    final activePct = total > 0 ? (active / total) * 100 : 0;

    final expired = _expired.toDouble();
    final totalT = _totalTenants.toDouble();
    final expiredPct = totalT > 0 ? (expired / totalT) * 100 : 0;

    final totalRevenue =
        _recentRevenue.fold(0.0, (sum, item) => sum + item.revenue);
    final avgRevenue =
        _recentRevenue.isNotEmpty ? totalRevenue / _recentRevenue.length : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.blue, size: 24),
              const SizedBox(width: 10),
              const Text(
                'สรุปข้อมูลด่วน',
                style: TextStyle(
                  color: HomeScreen_Color.Colors_Text1_,
                  fontSize: 18,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: const [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 22),
                          SizedBox(width: 8),
                          Text('วิธีคำนวณข้อมูล',
                              style: TextStyle(
                                  fontFamily: FontWeight_.Fonts_T,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('📊 รายรับ 7 วันล่าสุด',
                                style: TextStyle(
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(
                                'รวมยอดรับชำระทั้งหมดภายใน 7 วัน เฉลี่ย = รายรับรวม ÷ 7 วัน',
                                style: TextStyle(
                                    fontFamily: Font_.Fonts_T, fontSize: 13)),
                            SizedBox(height: 12),
                            Text('📊 อัตราการใช้พื้นที่ (%)',
                                style: TextStyle(
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('= (พื้นที่ที่ถูกเช่า ÷ พื้นที่ทั้งหมด) × 100',
                                style: TextStyle(
                                    fontFamily: Font_.Fonts_T, fontSize: 13)),
                            SizedBox(height: 12),
                            Text('📊 สัญญาที่หมดอายุ',
                                style: TextStyle(
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(
                                'จำนวนสัญญาที่หมดอายุแล้ว % = (หมดอายุ ÷ จำนวนสัญญาทั้งหมด) × 100',
                                style: TextStyle(
                                    fontFamily: Font_.Fonts_T, fontSize: 13)),
                            SizedBox(height: 12),
                            Text('📊 การยกเลิกสัญญา',
                                style: TextStyle(
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('จำนวนรายการยกเลิกสัญญาภายใน 7 วันล่าสุด',
                                style: TextStyle(
                                    fontFamily: Font_.Fonts_T, fontSize: 13)),
                            SizedBox(height: 12),
                            Text('📊 โซนยอดนิยม',
                                style: TextStyle(
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('โซนที่มีจำนวนผู้เช่ามากที่สุด',
                                style: TextStyle(
                                    fontFamily: Font_.Fonts_T, fontSize: 13)),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('ปิด',
                              style: TextStyle(
                                  fontFamily: FontWeight_.Fonts_T,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.info_outline,
                    color: Colors.grey, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            label: 'รายรับ 7 วันล่าสุด',
            value: nFormat.format(totalRevenue),
            subtitle: 'เฉลี่ย ${nFormat.format(avgRevenue)} / วัน',
            icon: Icons.monetization_on,
            color: Colors.blue,
            trend: totalRevenue > 100000 ? '+8.5%' : '+2.1%',
            isPositive: true,
          ),
          const Divider(height: 20),
          _buildInsightItem(
            label: 'อัตราการใช้พื้นที่',
            value: '${activePct.toStringAsFixed(1)}%',
            subtitle: 'พื้นที่ที่ถูกเช่าอยู่ในขณะนี้',
            icon: Icons.pie_chart,
            color: Colors.green,
            trend: activePct > 50 ? '+1.2%' : '-0.5%',
            isPositive: activePct > 50,
          ),
          const Divider(height: 20),
          _buildInsightItem(
            label: 'สัญญาที่หมดอายุ',
            value: '${expired.toInt()}',
            subtitle: 'ความเสี่ยงพื้นที่ว่าง',
            icon: Icons.timer_off,
            color: Colors.red,
            trend: expiredPct > 10 ? '+5%' : '-2%',
            isPositive: expiredPct < 15,
          ),
          const Divider(height: 20),
          _buildInsightItem(
            label: 'การยกเลิกสัญญา',
            value: '${_contractCancel.length}',
            subtitle: 'สถิติ 7 วันล่าสุด',
            icon: Icons.assignment_return,
            color: Colors.deepOrange,
            trend: _contractCancel.length > 5 ? 'ระวัง' : 'ปกติ',
            isPositive: _contractCancel.length <= 5,
          ),
          const Divider(height: 20),
          if (_popularZones.isNotEmpty)
            _buildInsightItem(
              label: 'โซนยอดนิยมอันดับ 1',
              value: '${_popularZones[0].zn}',
              subtitle: 'มีผู้เช่าหนาแน่นที่สุด',
              icon: Icons.star,
              color: Colors.orange,
              trend: 'ยอดฮิต',
              isPositive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  trend,
                  style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 11,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTenantList(String title) {
    return Container(
        decoration: BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: HomeScreen_Color.Colors_Text1_,
                fontSize: 18,
                fontFamily: FontWeight_.Fonts_T,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _currentTenants.isEmpty
                  ? Center(
                      child: Text('ไม่มีข้อมูลผู้เช่าปัจจุบัน',
                          style: TextStyle(
                              fontFamily: Font_.Fonts_T, color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _currentTenants.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final tenant = _currentTenants[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: Text((index + 1).toString(),
                                style: const TextStyle(color: Colors.blue)),
                          ),
                          title: Text(
                            tenant.sname ?? tenant.cname ?? 'ไม่ระบุชื่อ',
                            style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          subtitle: Text(
                            '${tenant.zn ?? "-"} / ${tenant.ln_c ?? tenant.ln_q ?? "-"}',
                            style: const TextStyle(
                                fontFamily: Font_.Fonts_T, fontSize: 12),
                          ),
                          trailing: Text(
                            tenant.docno ?? tenant.cid ?? '-',
                            style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ));
  }

  Widget _buildPopularZonesChart(String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HomeScreen_Color.Colors_Text1_,
              fontSize: 18,
              fontFamily: FontWeight_.Fonts_T,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _popularZones.isEmpty
                ? Center(
                    child: Text('ไม่มีข้อมูลแสดงผล',
                        style: TextStyle(
                            color: Colors.grey.withOpacity(0.8),
                            fontFamily: Font_.Fonts_T)),
                  )
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 10),
                      labelIntersectAction: AxisLabelIntersectAction.wrap,
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                    ),
                    primaryYAxis: NumericAxis(
                      isVisible: false,
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<DashZoneModel, String>>[
                      ColumnSeries<DashZoneModel, String>(
                        dataSource: _popularZones,
                        xValueMapper: (DashZoneModel data, _) {
                          String zn = data.zn ?? 'ไม่ระบุ';
                          return zn.length > 15
                              ? '${zn.substring(0, 15)}...'
                              : zn;
                        },
                        yValueMapper: (DashZoneModel data, _) =>
                            int.tryParse(data.qty ?? '0') ?? 0,
                        name: 'จำนวนผู้เช่า',
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.bold),
                        ),
                        animationDuration: 1500,
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderChart(String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HomeScreen_Color.Colors_Text1_,
              fontSize: 18,
              fontFamily: FontWeight_.Fonts_T,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                      size: 44, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'ไม่มีข้อมูลแสดงผล',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWrap(bool isMobile, double maxWidth) {
    if (maxWidth > 1100) {
      return Row(
        children: [
          Expanded(
              child: _buildSummaryCard('ปัจจุบัน', _totalTenants.toString(),
                  Colors.blue, Icons.people_outline)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('ใกล้หมดสัญญา', _nearExpired.toString(),
                  Colors.orange, Icons.access_time)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('หมดสัญญา', _expired.toString(),
                  Colors.red, Icons.warning_amber_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('ผู้สนใจ', _interested.toString(),
                  Colors.green, Icons.person_add_alt_1)),
        ],
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildResponsiveStatCard('ปัจจุบัน', _totalTenants.toString(),
              Colors.blue, Icons.people_outline, maxWidth),
          _buildResponsiveStatCard('ใกล้หมดสัญญา', _nearExpired.toString(),
              Colors.orange, Icons.access_time, maxWidth),
          _buildResponsiveStatCard('หมดสัญญา', _expired.toString(), Colors.red,
              Icons.warning_amber_rounded, maxWidth),
          _buildResponsiveStatCard('ผู้สนใจ', _interested.toString(),
              Colors.green, Icons.person_add_alt_1, maxWidth),
        ],
      );
    }
  }

  Widget _buildResponsiveStatCard(
      String title, String count, Color color, IconData icon, double maxWidth) {
    double width = (maxWidth - (12 * 3)) / 2;
    if (maxWidth < 600) width = maxWidth - 24;
    return SizedBox(
      width: width.clamp(150.0, 400.0),
      child: _buildSummaryCard(title, count, color, icon),
    );
  }

  Widget _buildMainChartsAndList({required bool useExpanded}) {
    return Column(
      children: [
        if (useExpanded)
          Expanded(child: _buildTenantList('ผู้เช่าปัจจุบัน (ล่าสุด 7 ราย)'))
        else
          SizedBox(
              height: 350.0,
              child: _buildTenantList('ผู้เช่าปัจจุบัน (ล่าสุด 7 ราย)')),
        const SizedBox(height: 2),
        if (useExpanded)
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildShowMoreToggle(),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildPopularZonesChart(
                              'โซนที่มีพื้นที่มากที่สุด')),
                      const SizedBox(width: 15),
                      Expanded(
                          child:
                              _buildRecentRevenueChart('รายรับ 7 วันล่าสุด')),
                    ],
                  ),
                ),
                if (_showMore) ...[
                  const SizedBox(height: 15),
                  _buildAreaStats(),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 350,
                    child:
                        _buildAreaUtilizationChart('สัดส่วนการใช้งานพื้นที่'),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 350,
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              _buildContractPopularZoneChart('ยอดนิยมตามสัญญา'),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildContractCancelChart(
                              'การยกเลิกสัญญา 7 วันล่าสุด'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Column(
            children: [
              // On desktop, keep first two charts side-by-side even if not "Expanded" (scrollable mode)
              LayoutBuilder(builder: (context, box) {
                if (box.maxWidth > 600) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildShowMoreToggle(),
                      ),
                      SizedBox(
                        height: 320,
                        child: Row(
                          children: [
                            Expanded(
                                child: _buildPopularZonesChart(
                                    'โซนที่มีพื้นที่มากที่สุด')),
                            const SizedBox(width: 15),
                            Expanded(
                                child: _buildRecentRevenueChart(
                                    'รายรับ 7 วันล่าสุด')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_showMore) ...[
                        const SizedBox(height: 15),
                        _buildAreaStats(),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 350,
                          child: _buildAreaUtilizationChart(
                              'สัดส่วนการใช้งานพื้นที่'),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 350,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildContractPopularZoneChart(
                                    'ยอดนิยมตามสัญญา'),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildContractCancelChart(
                                    'การยกเลิกสัญญา 7 วันล่าสุด'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                } else {
                  // Mobile stack
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildShowMoreToggle(),
                      ),
                      SizedBox(
                          height: 300,
                          child: _buildPopularZonesChart(
                              'โซนที่มีพื้นที่มากที่สุด')),
                      const SizedBox(height: 15),
                      SizedBox(
                          height: 300,
                          child:
                              _buildRecentRevenueChart('รายรับ 7 วันล่าสุด')),
                      const SizedBox(height: 10),
                      if (_showMore) ...[
                        const SizedBox(height: 15),
                        _buildAreaStats(),
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 300,
                            child: _buildAreaUtilizationChart(
                                'สัดส่วนการใช้งานพื้นที่')),
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 300,
                            child: _buildContractPopularZoneChart(
                                'ยอดนิยมตามสัญญา')),
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 300,
                            child: _buildContractCancelChart(
                                'การยกเลิกสัญญา 7 วันล่าสุด')),
                      ],
                    ],
                  );
                }
              }),
            ],
          ),
      ],
    );
  }

  Widget _getContent(bool isMobile, BoxConstraints constraints) {
    if (show_Dashboard == 1) return const HomeDashboard();
    if (show_Dashboard == 2) return HomeReserveSpace();
    // if (show_Dashboard == 3) return Homereservespace_calendar();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsWrap(true, constraints.maxWidth),
          const SizedBox(height: 2),
          _buildMainChartsAndList(useExpanded: false),
          const SizedBox(height: 12),
          SizedBox(height: 400, child: _buildPersonalNote()),
        ],
      );
    } else {
      // For Desktop
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsWrap(false, constraints.maxWidth),
          const SizedBox(height: 12),
          if (_showMore)
            // Scrollable mode: Use fixed heights
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildMainChartsAndList(useExpanded: false),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildQuickInsights(),
                      const SizedBox(height: 15),
                      SizedBox(height: 500, child: _buildPersonalNote()),
                    ],
                  ),
                ),
              ],
            )
          else
            // Fixed viewport mode: Use Expanded
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildMainChartsAndList(useExpanded: true),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 3,
                    child:
                        //  _buildQuickInsights(),

                        _buildPersonalNote(),
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppbackgroundColor.Abg_Colors,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 950;
            Widget headerRow = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDashboardActionButton(
                      label: 'แดชบอร์ด',
                      dashboard: 0,
                      action: 'เข้าสู่หน้า แดชบอร์ด',
                      width: 120,
                      color: show_Dashboard == 0
                          ? HomeScreen_Color.Colors_Text1_
                          : HomeScreen_Color.Colors_Text2_.withOpacity(0.5),
                    ),
                    // _buildDashboardActionButton(
                    //   label: 'จองล็อกเสียบ/พื้นที่สำรอง',
                    //   dashboard: 2,
                    //   action: 'เข้าสู่หน้า จองล็อกเสียบ/พื้นที่สำรอง',
                    //   width: 180,
                    //   color: show_Dashboard == 2
                    //       ? HomeScreen_Color.Colors_Text1_
                    //       : HomeScreen_Color.Colors_Text2_.withOpacity(0.5),
                    // ),
                  ],
                ),
                const Spacer(),
                if (!isMobile)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'สถานที่หลัก',
                        style: TextStyle(
                          fontFamily: FontWeight_.Fonts_T,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildMainRentalDropdown(wide: true, cts: constraints),
                      // const Text(
                      //   'สถานที่รอง',
                      //   style: TextStyle(
                      //     fontFamily: FontWeight_.Fonts_T,
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // _buildSubRentalDropdown(wide: true, cts: constraints),
                    ],
                  ),
              ],
            );
            // Widget headerRow = Wrap(
            //   alignment: WrapAlignment.spaceBetween,
            //   crossAxisAlignment: WrapCrossAlignment.center,
            //   children: [
            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         _buildDashboardActionButton(
            //           label: 'แดชบอร์ด',
            //           dashboard: 0,
            //           action: 'เข้าสู่หน้า แดชบอร์ด',
            //           width: 120,
            //           color: show_Dashboard == 0
            //               ? HomeScreen_Color.Colors_Text1_
            //               : HomeScreen_Color.Colors_Text2_.withOpacity(0.5),
            //         ),
            //         _buildDashboardActionButton(
            //           label: 'จองล็อกเสียบ/พื้นที่สำรอง',
            //           dashboard: 2,
            //           action: 'เข้าสู่หน้า จองล็อกเสียบ/พื้นที่สำรอง',
            //           width: 180,
            //           color: show_Dashboard == 2
            //               ? HomeScreen_Color.Colors_Text1_
            //               : HomeScreen_Color.Colors_Text2_.withOpacity(0.5),
            //         ),
            //       ],
            //     ),Spacer(),

            //     if (!isMobile)
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.end,
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           const Text('สถานที่หลัก',
            //               style: TextStyle(
            //                   fontFamily: FontWeight_.Fonts_T,
            //                   fontSize: 13,
            //                   fontWeight: FontWeight.bold)),
            //           _buildMainRentalDropdown(wide: true, cts: constraints),
            //           const Text('สถานที่รอง',
            //               style: TextStyle(
            //                   fontFamily: FontWeight_.Fonts_T,
            //                   fontSize: 13,
            //                   fontWeight: FontWeight.bold)),
            //           _buildSubRentalDropdown(wide: true, cts: constraints),
            //           // IconButton(
            //           //   icon: const Icon(Icons.refresh, size: 20),
            //           //   onPressed: () {
            //           //     fetchTenantCounts();
            //           //     fetchPopularZones();
            //           //     fetchRecentRevenue();
            //           //   },
            //           // ),
            //         ],
            //       ),
            //   ],
            // );

            Widget mainContent = Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (show_Dashboard == 0) ...[
                    headerRow,
                    const SizedBox(height: 12),
                  ],
                  if (isMobile || _showMore)
                    _getContent(isMobile, constraints)
                  else
                    Expanded(child: _getContent(isMobile, constraints)),
                ],
              ),
            );

            return (isMobile || _showMore)
                ? SingleChildScrollView(
                    child: SizedBox(
                        width: constraints.maxWidth, child: mainContent))
                : mainContent;
          },
        ),
      ),
    );
  }

  Widget _buildDashboardActionButton({
    required String label,
    required int dashboard,
    required String action,
    required double width,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () async {
          setState(() => show_Dashboard = dashboard);
          // If we had the global show_Dashboard switching logic, we'd trigger it here.
          // For now, these buttons highlight.
        },
        child: Container(
          width: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Center(
            child: Translate.TranslateAndSetText(
              label,
              Colors.white,
              TextAlign.center,
              FontWeight.bold,
              FontWeight_.Fonts_T,
              14,
              1,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var seruser = preferences.getString('ser');
    var utype = preferences.getString('utype');
    var renTal = preferences.getString('renTalSer');

    final cacheKey = 'read_GC_rental_${seruser}_${utype}_${renTal}';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        setState(() {
          renTalModels.clear();
          for (var map in cached) {
            renTalModels.add(RenTalModel.fromJson(map));
          }
        });
        return;
      }
    }

    String url =
        '${MyConstant().domain}/GC_rental.php?isAdd=true&ser=$seruser&type=$utype&ren=$renTal';

    try {
      var headers = Security.generateAuthHeaders();
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        _apiCache.set(cacheKey, result);

        final List<RenTalModel> temp = [];
        for (var map in result) {
          temp.add(RenTalModel.fromJson(map));
        }

        if (mounted) {
          setState(() {
            renTalModels.clear();
            renTalModels.addAll(temp);
          });
        }
      }
    } catch (e) {}
  }

  Future<void> readRentalUserSub() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var seruser = preferences.getString('ser');

    final cacheKey = 'readRentalUserSub_$seruser';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        setState(() {
          renTalusersubModel.clear();
          for (var map in cached['data']) {
            renTalusersubModel.add(UserSubModel.fromJson(map));
          }
        });
        return;
      }
    }

    String url =
        '${MyConstant().domain}/GC_rentalUserSub.php?isAdd=true&ser=$seruser';

    try {
      var headers = Security.generateAuthHeaders();
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _apiCache.set(cacheKey, result);

        final List<UserSubModel> temp = [];
        for (var map in result['data']) {
          temp.add(UserSubModel.fromJson(map));
        }

        if (mounted) {
          setState(() {
            renTalusersubModel.clear();
            renTalusersubModel.addAll(temp);
          });
        }
      }
    } catch (e) {}
  }

  Future<void> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        renTal_name = preferences.getString('renTalName');
        // Extract sub rental name if it exists? Usually handled in handleSubRentalChanged
      });
    }
  }

  Future<void> _handleMainRentalChanged(String? value) async {
    if (value == null) return;
    final comma = value.indexOf(',');
    if (comma <= 0) return;

    final renTalSer = value.substring(0, comma);
    final renTalName = value.substring(comma + 1);
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString('renTalSer', renTalSer),
      p.setString('renTalName', renTalName),
      p.remove('zoneSer'),
      p.remove('zonesName'),
      p.remove('zonePSer'),
      p.remove('zonesPName'),
    ]);

    // Force refresh or reload
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AdminScafScreen(route: 'Dashboard')),
        (_) => false,
      );
    }
  }

  Future<void> _handleSubRentalChanged(UserSubModel? selected) async {
    if (selected == null) return;

    final prefs = await SharedPreferences.getInstance();
    final seruser = prefs.getString('ser') ?? '';
    final rser = selected.rser?.toString() ?? '';
    final pn = selected.pn?.toString() ?? '';

    try {
      final uri = Uri.parse('${MyConstant().domain}/UP_emailAdminSer.php');
      var headers = Security.generateAuthHeaders();
      final resp = await http.post(uri, headers: headers, body: {
        'isAdd': 'true',
        'seruser': seruser,
        'serrenTal': rser,
      });

      if (resp.statusCode == 200) {
        await Future.wait([
          prefs.remove('zoneSer'),
          prefs.remove('zonesName'),
          prefs.remove('zonePSer'),
          prefs.remove('zonesPName'),
          prefs.setString('renTalSer', rser),
          prefs.setString('renTalName', pn),
        ]);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => AdminScafScreen(route: 'Dashboard')),
            (_) => false,
          );
        }
      }
    } catch (e) {}
  }

  Widget _buildMainRentalDropdown(
      {required bool wide, required BoxConstraints cts}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: wide ? (cts.maxWidth / 5).clamp(200.0, 300.0) : 200,
        decoration: BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: DropdownButtonFormField2(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          isExpanded: true,
          hint: Translate.TranslateAndSetText(
            (renTal_name == null || renTal_name!.isEmpty)
                ? 'ค้นหา'
                : '$renTal_name',
            HomeScreen_Color.Colors_Text2_,
            TextAlign.center,
            FontWeight.bold,
            FontWeight_.Fonts_T,
            12,
            1,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          iconSize: 20,
          buttonHeight: 35,
          dropdownDecoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10)),
          items: renTalModels
              .map((item) => DropdownMenuItem<String>(
                    value: '${item.ser},${item.pn}',
                    child: Text(
                      item.pn ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HomeScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: _handleMainRentalChanged,
        ),
      ),
    );
  }

  Widget _buildSubRentalDropdown(
      {required bool wide, required BoxConstraints cts}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: wide ? (cts.maxWidth / 5).clamp(200.0, 300.0) : 200,
        decoration: BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: DropdownButtonFormField2<UserSubModel>(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          hint: Translate.TranslateAndSetText(
            renTalsub_name == null ? 'ค้นหา' : '$renTalsub_name',
            HomeScreen_Color.Colors_Text2_,
            TextAlign.center,
            FontWeight.bold,
            FontWeight_.Fonts_T,
            12,
            1,
          ),
          iconSize: 20,
          buttonHeight: 35,
          dropdownDecoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10)),
          items: renTalusersubModel
              .map((item) => DropdownMenuItem<UserSubModel>(
                    value: item,
                    child: Text(
                      item.pn ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: HomeScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: _handleSubRentalChanged,
        ),
      ),
    );
  }

  Widget _buildAreaUtilizationChart(String title) {
    if (_areaData == null) {
      return Container(
        height: 400,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    double active = double.tryParse(_areaData!.areaActive ?? '0') ?? 0;
    double empty = double.tryParse(_areaData!.areaEmpty ?? '0') ?? 0;
    double total = double.tryParse(_areaData!.totalArea ?? '0') ?? 0;

    final List<ChartData_Area> chartData = [
      ChartData_Area('ใช้งานแล้ว', active, Colors.orange),
      ChartData_Area('ยังว่าง', empty, Colors.green),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              return Row(
                children: [
                  Expanded(
                    flex: isWide ? 6 : 1,
                    child: SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        textStyle: const TextStyle(
                            fontFamily: Font_.Fonts_T, fontSize: 12),
                      ),
                      series: <CircularSeries<ChartData_Area, String>>[
                        PieSeries<ChartData_Area, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData_Area data, _) => data.x,
                          yValueMapper: (ChartData_Area data, _) => data.y,
                          pointColorMapper: (ChartData_Area data, _) =>
                              data.color,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(
                                fontSize: 11, fontFamily: Font_.Fonts_T),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: _buildDetailedAreaMetrics(active, empty, total),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAreaMetrics(double active, double empty, double total) {
    double activePct = total > 0 ? (active / total) * 100 : 0;
    double emptyPct = total > 0 ? (empty / total) * 100 : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMetricItem(
          label: 'ใช้งานแล้ว (Active)',
          value:
              '${nFormat2.format(double.tryParse(active.toStringAsFixed(0)) ?? 0)} พื้นที่',
          percentage: activePct,
          color: Colors.orange,
          icon: Icons.business_center,
        ),
        const SizedBox(height: 15),
        _buildMetricItem(
          label: 'ยังว่าง (Empty)',
          value:
              '${nFormat2.format(double.tryParse(empty.toStringAsFixed(0)) ?? 0)} พื้นที่',
          percentage: emptyPct,
          color: Colors.green,
          icon: Icons.meeting_room,
        ),
        const Divider(height: 30),
        _buildMetricItem(
          label: 'รวมทั้งสิ้น (Total)',
          value:
              '${nFormat2.format(double.tryParse(total.toStringAsFixed(0)) ?? 0)} พื้นที่',
          percentage: 100,
          color: Colors.purple,
          icon: Icons.square_foot,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required double percentage,
    required Color color,
    required IconData icon,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (!isTotal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontFamily: Font_.Fonts_T),
        ),
      ],
    );
  }

  Widget _buildAreaStats() {
    if (_areaData == null) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      bool useWrap = maxWidth < 700;

      if (useWrap) {
        double cardWidth = (maxWidth - 12) / 2; // 2 columns
        if (maxWidth < 450) cardWidth = maxWidth; // 1 column

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildSummaryCard(
                'พื้นที่ทั้งหมด',
                '${nFormat.format(double.tryParse(_areaData!.sqmTotal ?? '0') ?? 0)} ตร.ม.',
                Colors.purple,
                Icons.square_foot,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildSummaryCard(
                'พื้นที่ว่าง',
                '${nFormat.format(double.tryParse(_areaData!.sqmEmpty ?? '0') ?? 0)} ตร.ม.',
                Colors.green,
                Icons.meeting_room_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildSummaryCard(
                'พื้นที่ใช้งาน',
                '${nFormat.format(double.tryParse(_areaData!.sqmActive ?? '0') ?? 0)} ตร.ม.',
                Colors.orange,
                Icons.business_center_outlined,
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'พื้นที่ทั้งหมด',
              '${nFormat.format(double.tryParse(_areaData!.sqmTotal ?? '0') ?? 0)} ตร.ม.',
              Colors.purple,
              Icons.square_foot,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'พื้นที่ว่าง',
              '${nFormat.format(double.tryParse(_areaData!.sqmEmpty ?? '0') ?? 0)} ตร.ม.',
              Colors.green,
              Icons.meeting_room_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'พื้นที่ใช้งาน',
              '${nFormat.format(double.tryParse(_areaData!.sqmActive ?? '0') ?? 0)} ตร.ม.',
              Colors.orange,
              Icons.business_center_outlined,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShowMoreToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _showMore = !_showMore;
          });
          if (_showMore) {
            // Lazy load extra data if expanding
            read_GC_note(
                keys: ['contract_popularzone', 'contract_cancel', 'area']);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                _showMore ? 'ย่อข้อมูล' : 'แสดงข้อมูลเพิ่มเติม',
                style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRevenueChart(String title) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child:
                //  _recentRevenue.isEmpty
                //     ? const Center(child: CircularProgressIndicator())
                //     :
                SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 10,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 10,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<DailyRevenue, String>>[
                ColumnSeries<DailyRevenue, String>(
                  dataSource: _recentRevenue,
                  xValueMapper: (DailyRevenue data, _) => data.day,
                  yValueMapper: (DailyRevenue data, _) => data.revenue,
                  name: 'รายรับ',
                  color: Colors.green.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 9),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractPopularZoneChart(String title) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _contractPopularZone.isEmpty
                ? const Center(
                    child: Text(
                    'ไม่มีข้อมูล',
                    style: TextStyle(fontFamily: Font_.Fonts_T),
                  ))
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 10,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      numberFormat: NumberFormat.compact(),
                      labelStyle: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 10,
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<DashZoneModel, String>>[
                      ColumnSeries<DashZoneModel, String>(
                        dataSource: _contractPopularZone,
                        xValueMapper: (DashZoneModel data, _) =>
                            data.zn ?? 'ไม่ระบุ',
                        yValueMapper: (DashZoneModel data, _) =>
                            int.tryParse(data.total ?? '0') ?? 0,
                        name: 'จำนวนสัญญา',
                        color: Colors.orange.shade400,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(fontSize: 9),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCancelChart(String title) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 10,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                numberFormat: NumberFormat.compact(),
                labelStyle: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontSize: 10,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<DashTeNantModel, String>>[
                ColumnSeries<DashTeNantModel, String>(
                  dataSource: _contractCancel,
                  xValueMapper: (DashTeNantModel data, _) {
                    try {
                      DateTime date = DateTime.parse(data.ccDate!);
                      return DateFormat('dd/MM').format(date);
                    } catch (e) {
                      return data.ccDate ?? '-';
                    }
                  },
                  yValueMapper: (DashTeNantModel data, _) =>
                      int.tryParse(data.total ?? '0') ?? 0,
                  name: 'ยอดการยกเลิก',
                  color: Colors.red.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 9),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyRevenue {
  final String day;
  final double revenue;

  DailyRevenue(this.day, this.revenue);

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      json['day'] ?? '',
      (json['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'revenue': revenue,
    };
  }
}

class ChartData_Area {
  final String x;
  final double y;
  final Color color;

  ChartData_Area(this.x, this.y, this.color);
}
