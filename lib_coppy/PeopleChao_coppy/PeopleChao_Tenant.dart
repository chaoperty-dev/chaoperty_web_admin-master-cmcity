import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../../Model/GetFinnancetrans_Model.dart';
import '../../Model/GetPakan_Contractx_Model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/GetTrans_Kon_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/electricity_model.dart';
import 'Pe_List/Pe_List_Title.dart';

class PeopleChaoTenant extends StatefulWidget {
  final Status;
  final updateMessage;
  const PeopleChaoTenant({
    super.key,
    this.Status,
    this.updateMessage,
  });

  @override
  _PeopleChaoTenantState createState() => _PeopleChaoTenantState();
}

class _PeopleChaoTenantState extends State<PeopleChaoTenant> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  //--------------------------------------->

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  final TextEditingController search_controller = TextEditingController();
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<QuotxSelectModel> quotxSelectModels_Select = [];
  List<ElectricityModel> electricityModels = [];
  //-------------------------------------->

  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> pe1 = [];
  List<int> Fix_data = [4, 5];
  ///////////--------------------------------------------->
  String? numinvoice;
  int TitleType_Default_Receipt = 0;
  String _ReportValue_type = "ไม่ระบุ";
  String? TitleType_Default_Receipt_Name;
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'คู่ฉบับ',
    'สำเนา',
    'สำเนาคู่ฉบับ',
  ];
  String? base64_Imgmap, tem_page_ser;
  ///////////--------------------------------------------->
  var round_p, paper, paper_run;
  ///////////--------------------------------------------->
  List<String> YE_Th = [];
  String? base64_Slip, fileName_Slip, Slip_history, pdate;
  String? MONTH_Now, YEAR_Now;
  String tappedIndex_ = '';
  String? ser_payby, numdoctax;
  int Ser_Tap = 0;
  int Status_ = 1, open_set_date = 30;
  int? ser_indexShow;
  int renTal_lavel = 0;
  //-------------------------------------->

  // ตัวแปรสำหรับการค้นหา
  String searchQuery = "";
  //-------------------------------------->
  // Pagination
  int currentPage_1 = 0;
  static const int rowsPerPage_1 = 50;
  int Fix_Expan1 = 2, Fix_Expan2 = 1;
  //-------------------------------------->
  // ตัวแปรสำหรับการจัดเรียง
  bool sortAscending = true;
  String sortColumn = "เลขที่สัญญา/เสนอราคา";
  //-------------------------------------->

  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;
  ///////////--------------------------------------------->

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      dis_sum_Matjum = 0.00,
      sum_duesbill = 0.00;

  ///------------------------>
  String? renTal_user, renTal_name, zone_ser, zone_name;
  String Value_NameShop_index = '';
  String? Value_cid, Value_stasus;
  String ReturnBodyPeople = 'PeopleChao_Screen';
  ///////////--------------------------------------------->
  List<String> monthsInThai = [
    'มกราคม', // January
    'กุมภาพันธ์', // February
    'มีนาคม', // March
    'เมษายน', // April
    'พฤษภาคม', // May
    'มิถุนายน', // June
    'กรกฎาคม', // July
    'สิงหาคม', // August
    'กันยายน', // September
    'ตุลาคม', // October
    'พฤศจิกายน', // November
    'ธันวาคม', // December
  ];
////////////----------------------------------->
  @override
  void initState() {
    super.initState();
    read_GC_rental();
    checkPreferance();
    addAcListTitle();
  }

  @override
  void didUpdateWidget(PeopleChaoTenant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.Status != oldWidget.Status) {
      Loading_Trans_bill();
    }
  }

  ////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1

      pe1.addAll(PeListTitle().Pe_1);
    });
  }

  where_pe1(String ser) {
    if (pe1
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  ///////////--------------------------------------------->
  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var utype = preferences.getString('utype');
    var seruser = preferences.getString('ser');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ser=$seruser&type=$utype&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);

          var open_set_datex = int.parse(renTalModel.open_set_date!);
          setState(() {
            open_set_date = open_set_datex == 0 ? 30 : open_set_datex;

            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
  }

  ///////////--------------------------------------------->
  Future<Null> checkPreferance() async {
    int currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 10; i--) {
      YE_Th.add(i.toString());
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      MONTH_Now = DateFormat('MM').format(DateTime.parse('${datex}'));
      YEAR_Now = DateFormat('yyyy').format(DateTime.parse('${datex}'));
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
    Loading_Trans_bill();
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    read_GC_areaSelect().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
        _loadSearchQuery();
      });
    });
  }

  ////////-------------------------------------------------------->(รับเงินประกัน)
  // Future<Null> tenant_Pakan() async {
  //   setState(() {
  //     isLoading_main = true;
  //     isLoading = true;
  //     // teNantModels.clear();
  //     data.clear();
  //     filteredData.clear();
  //   });

  //   // setState(() {
  //   //   teNantModels = widget.tenantModelss;
  //   // });
  //   await AddDaTa();
  // }
/////////////////////----------------------------------------->
  Future<Null> read_GC_areaSelect() async {
    int select = widget.Status;
    setState(() {
      isLoading_main = true;
      isLoading = true;
      teNantModels.clear();
      data.clear();
      filteredData.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');

    // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $select');

    if (select == 1) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            TeNantModel teNantModel = TeNantModel.fromJson(map);
            if (teNantModel.quantity == '1') {
              var daterx = teNantModel.ldate == null
                  ? teNantModel.ldate_q
                  : teNantModel.ldate;

              if (daterx != null) {
                int daysBetween(DateTime from, DateTime to) {
                  from = DateTime(from.year, from.month, from.day);
                  to = DateTime(to.year, to.month, to.day);
                  return (to.difference(from).inHours / 24).round();
                }

                var birthday = DateTime.parse('$daterx 00:00:00.000')
                    .add(const Duration(days: -30));
                var date2 = DateTime.now();
                var difference = daysBetween(birthday, date2);

                //   print('difference == $difference');

                var daterx_now = DateTime.now();

                var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

                final now = DateTime.now();
                final earlier = daterx_ldate.subtract(const Duration(days: 0));
                var daterx_A = now.isAfter(earlier);
                // print(now.isAfter(earlier)); // true
                // print(now.isBefore(earlier)); // true

                if (daterx_A != true) {
                  setState(() {
                    teNantModels.add(teNantModel);
                  });
                }
              }
              // setState(() {
              //   teNantModels.add(teNantModel);
              // });
            }
            // setState(() {
            //   teNantModels.add(teNantModel);
            // });
          }
        } else {
          setState(() {
            if (teNantModels.isEmpty) {
              preferences.remove('zonePSer');
              preferences.remove('zonesPName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }

        setState(() {
          zone_ser = preferences.getString('zonePSer');
          zone_name = preferences.getString('zonesPName');
        });
      } catch (e) {}
    } else if (select == 2) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            TeNantModel teNantModel = TeNantModel.fromJson(map);
            var daterx = teNantModel.ldate == null
                ? teNantModel.ldate_q
                : teNantModel.ldate;

            if (daterx != null) {
              int daysBetween(DateTime from, DateTime to) {
                from = DateTime(from.year, from.month, from.day);
                to = DateTime(to.year, to.month, to.day);
                return (to.difference(from).inHours / 24).round();
              }

              var birthday = DateTime.parse('$daterx 00:00:00.000')
                  .add(const Duration(days: -30));
              var date2 = DateTime.now();
              var difference = daysBetween(birthday, date2);

             //  print('difference == $difference');

              var daterx_now = DateTime.now();

              var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

              final now = DateTime.now();
              final earlier = daterx_ldate.subtract(const Duration(days: 0));
              var daterx_A = now.isAfter(earlier);
              // print(now.isAfter(earlier)); // true
              // print(now.isBefore(earlier)); // true

              if (daterx_A == true) {
                setState(() {
                  if (teNantModel.quantity == '1') {
                    teNantModels.add(teNantModel);
                  }
                });
              }
            }
          }
        } else {
          setState(() {
            if (teNantModels.isEmpty) {
              preferences.remove('zonePSer');
              preferences.remove('zonesPName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          zone_ser = preferences.getString('zonePSer');
          zone_name = preferences.getString('zonesPName');
        });
      } catch (e) {}
    } else if (select == 3) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
      //   print(result);
        if (result != null) {
          for (var map in result) {
            TeNantModel teNantModel = TeNantModel.fromJson(map);
            if (teNantModel.quantity == '1') {
              if (datex.isAfter(
                      DateTime.parse('${teNantModel.ldate} 00:00:00.000')
                          .subtract(Duration(days: open_set_date))) ==
                  true) {
                var daterx = teNantModel.ldate == null
                    ? teNantModel.ldate_q
                    : teNantModel.ldate;

                if (daterx != null) {
                  int daysBetween(DateTime from, DateTime to) {
                    from = DateTime(from.year, from.month, from.day);
                    to = DateTime(to.year, to.month, to.day);
                    return (to.difference(from).inHours / 24).round();
                  }

                  var birthday = DateTime.parse('$daterx 00:00:00.000')
                      .add(const Duration(days: -30));
                  var date2 = DateTime.now();
                  var difference = daysBetween(birthday, date2);

                  // print('difference == $difference');

                  var daterx_now = DateTime.now();

                  var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

                  final now = DateTime.now();
                  final earlier =
                      daterx_ldate.subtract(const Duration(days: 0));
                  var daterx_A = now.isAfter(earlier);
                  // print(now.isAfter(earlier)); // true
                  // print(now.isBefore(earlier)); // true

                  if (daterx_A != true) {
                    setState(() {
                      teNantModels.add(teNantModel);
                    });
                  }
                }
              }
            }
          }
        } else {
          setState(() {
            if (teNantModels.isEmpty) {
              preferences.remove('zonePSer');
              preferences.remove('zonesPName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          zone_ser = preferences.getString('zonePSer');
          zone_name = preferences.getString('zonesPName');
        });
      } catch (e) {}
    } else if (select == 4) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            TeNantModel teNantModel = TeNantModel.fromJson(map);
            if (teNantModel.quantity == '2' || teNantModel.quantity == '3') {
              setState(() {
                teNantModels.add(teNantModel);
              });
            }
          }
        } else {
          setState(() {
            if (teNantModels.isEmpty) {
              preferences.remove('zonePSer');
              preferences.remove('zonesPName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          zone_ser = preferences.getString('zonePSer');
          zone_name = preferences.getString('zonesPName');
        });
      } catch (e) {}
    }
    await AddDaTa();
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (teNantModels.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(teNantModels.length, (index) {
          // Ensure that docno exists and is not null
          final docno = teNantModels[index].docno;
          final cid = teNantModels[index].cid ?? "";
          final renew_cid = teNantModels[index].renew_cid ?? "";
          final fid = teNantModels[index].fid ?? "";

          final cname = teNantModels[index].cname == null
              ? teNantModels[index].cname_q == null
                  ? ''
                  : '${teNantModels[index].cname_q}'
              : '${teNantModels[index].cname}';
          final sname = teNantModels[index].sname == null
              ? teNantModels[index].sname_q == null
                  ? ''
                  : '${teNantModels[index].sname_q}'
              : '${teNantModels[index].sname}';
          final zn = teNantModels[index].zn ?? "";
          final ln = teNantModels[index].ln_c == null
              ? teNantModels[index].ln_q == null
                  ? ''
                  : '${teNantModels[index].ln_q}'
              : '${teNantModels[index].ln_c}';
          final period = teNantModels[index].period == null
              ? teNantModels[index].period_q == null
                  ? ''
                  : '${teNantModels[index].period_q}  ${teNantModels[index].rtname_q!.substring(3)}'
              : '${teNantModels[index].period}  ${teNantModels[index].rtname!.substring(3)}';

          final sdate = teNantModels[index].sdate_q == null
              ? teNantModels[index].sdate == null
                  ? ''
                  : DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(
                          '${teNantModels[index].sdate} 00:00:00'))
                      .toString()
              : DateFormat('dd-MM-yyyy')
                  .format(
                      DateTime.parse('${teNantModels[index].sdate_q} 00:00:00'))
                  .toString();
          final ldate = teNantModels[index].ldate_q == null
              ? teNantModels[index].ldate == null
                  ? ''
                  : DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(
                          '${teNantModels[index].ldate} 00:00:00'))
                      .toString()
              : DateFormat('dd-MM-yyyy')
                  .format(
                      DateTime.parse('${teNantModels[index].ldate_q} 00:00:00'))
                  .toString();
          final status = teNantModels[index].quantity == '1'
              ? datex.isAfter(DateTime.parse(
                              '${teNantModels[index].ldate} 00:00:00.000')
                          .subtract(const Duration(days: 0))) ==
                      true
                  ? 'หมดสัญญา'
                  : datex.isAfter(DateTime.parse(
                                  '${teNantModels[index].ldate} 00:00:00.000')
                              .subtract(Duration(days: open_set_date))) ==
                          true
                      ? 'ใกล้หมดสัญญา'
                      : 'เช่าอยู่'
              : teNantModels[index].quantity == '2'
                  ? 'เสนอราคา'
                  : teNantModels[index].quantity == '3'
                      ? 'เสนอราคา(มัดจำ)'
                      : 'ว่าง';
          final wnote = teNantModels[index].wnote == null
              ? ''
              : '${teNantModels[index].wnote}';
          return {
            "index": "$index",
            if (where_pe1("0") == false)
              "เลขที่สัญญา/เสนอราคา": (docno != null) ? "$docno" : "$cid",
            if (where_pe1("1") == false) "เลขที่สัญญา-เดิม": "$fid",
            if (where_pe1("2") == false) "โซนพื้นที่": "$zn",
            if (where_pe1("3") == false) "รหัสพื้นที่": "$ln",
            if (where_pe1("4") == false) "ชื่อร้านค้า": "$sname",
            if (where_pe1("5") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_pe1("6") == false) "ระยะเวลาเช่า": "$period",
            if (where_pe1("7") == false) "เริ่มสัญญา": "$sdate",
            if (where_pe1("8") == false) "สิ้นสุดสัญญา": "$ldate",
            if (where_pe1("9") == false) "สถานะ": "$status",
            if (where_pe1("10") == false) "เลขอ้างอิง": "$wnote",
          };
        });
        filteredData = data;
      });
    } else {
      // Handle the case where contractxPakanModels is empty
      // print("contractxPakanModels is empty, no data to add. $data");
    }

    // print("Data added: $data");
  }

  /////////------------------------------------------------------>
  Future<Null> red_quotx_Select(index) async {
    setState(() {
      quotxSelectModels_Select.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = teNantModels[index].docno == null
        ? teNantModels[index].cid == null
            ? ''
            : '${teNantModels[index].cid}'
        : '${teNantModels[index].docno}';
    var qutser = teNantModels[index].quantity;

    String url =
        '${MyConstant().domain}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
          setState(() {
            quotxSelectModels_Select.add(quotxSelectModel);
          });
        }
      } else {}
      // quotxSelectModels[index].sort((a, b) => a.expser!.compareTo(b.expser!));
    } catch (e) {}
  }

  /////////------------------------------------------------------>
  Future<dynamic> showcountmiter(int index) async {
    var ser = quotxSelectModels_Select[index].ele_ty;
    if (electricityModels.isNotEmpty) {
      electricityModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_electricity.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
     //  print(result);
      if (result != null) {
        for (var map in result) {
          ElectricityModel electricityModel = ElectricityModel.fromJson(map);

          if (electricityModel.ser == ser) {
            setState(() {
              electricityModels.add(electricityModel);
            });
          }
        }
      } else {}
    } catch (e) {}
  }

  //-------------------------------------->
  // ฟังก์ชันค้นหา
  Future<void> _loadSearchQuery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedQuery = prefs.getString('search_PeopleChao_Tenant');
    if (savedQuery != null) {
      setState(() {
        searchQuery = savedQuery;
        search_controller.text = savedQuery;
        _filterData(savedQuery);
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      filteredData = data.where((row) {
        return row.entries.any((entry) {
          return entry.value
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
        });
      }).toList();
    });
  }

  void onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      search_controller.text = query.toString();
      isLoading = true; // กำหนดให้กำลังโหลด
    });

    // Save the search query to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('search_PeopleChao_Tenant', query);

    _debounce = Timer(Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = query;
        currentPage_1 = 0; // รีเซ็ตหน้า
        filteredData = data.where((row) {
          return row.entries.any((entry) {
            return entry.value
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          });
        }).toList();
        isLoading = false; // กำหนดให้โหลดเสร็จแล้ว
      });
    });
  }
  // void onSearchChanged(String query) {
  //   if (_debounce?.isActive ?? false) _debounce?.cancel();
  //   setState(() {
  //     search_controller.text = query.toString();
  //     isLoading = true; // กำหนดให้กำลังโหลด
  //   });
  //   _debounce = Timer(Duration(milliseconds: 400), () {
  //     setState(() {
  //       searchQuery = query;
  //       currentPage_1 = 0; // รีเซ็ตหน้า
  //       filteredData = data.where((row) {
  //         return row.entries.any((entry) {
  //           return entry.value
  //               .toString()
  //               .toLowerCase()
  //               .contains(searchQuery.toLowerCase());
  //         });
  //       }).toList();
  //       isLoading = false; // กำหนดให้โหลดเสร็จแล้ว
  //     });
  //   });
  // }

  ////////--------------------------------------------------------------->
  Widget Next_page_TeNant() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Container(
          height: 30,
          width: 140,
          child: Container(
              decoration: const BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(4.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: currentPage_1 > 0
                                  ? () async {
                                      setState(() {
                                        currentPage_1--;
                                      });
                                      _scrollController1.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  : null,
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.black,
                                size: 25,
                              )),
                          Text(
                            '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                              //fontSize: 10.0 Account_BillPayVerifi
                            ),
                          ),
                          InkWell(
                              onTap: (currentPage_1 + 1) * rowsPerPage_1 <
                                      filteredData.length
                                  ? () async {
                                      setState(() {
                                        currentPage_1++;
                                      });
                                      _scrollController1.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  : null,
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.black,
                                size: 25,
                              )),
                        ],
                      ),
                    )
                  ]))),
    );
  }

  bool firstRound = true;
  ////////--------------------------------------------------------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    double calculatedWidth = (Responsive.isDesktop(context))
        ? MediaQuery.of(context).size.width * 0.84
        : 1200;
    // For the first round, use the extracted data as is, no need to sort.
    List<Map<String, dynamic>> displayedData;

    if (firstRound) {
      displayedData = filteredData; // Use the extracted data without sorting
      displayedData = filteredData
          .skip(currentPage_1 * rowsPerPage_1)
          .take(rowsPerPage_1)
          .toList();
    } else {
      // For subsequent rounds, apply sorting
      filteredData.sort((a, b) {
        if (sortAscending) {
          return a[sortColumn].toString().compareTo(b[sortColumn].toString());
        } else {
          return b[sortColumn].toString().compareTo(a[sortColumn].toString());
        }
      });

      // Apply pagination
      displayedData = filteredData
          .skip(currentPage_1 * rowsPerPage_1)
          .take(rowsPerPage_1)
          .toList();
    }

    // ดึงคีย์จากแถวแรกเพื่อใช้เป็นคอลัมน์
    final columnHeaders =
        filteredData.isNotEmpty ? filteredData[0].keys.toList() : [];
    // final Expan = columnHeaders.skip(1).map().toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          // ช่องค้นหา
          Container(
            width: calculatedWidth,
            decoration: BoxDecoration(
              color: AppbackgroundColor.TiTile_Colors,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30, //Date_ser
                        // width: 150,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: (isLoading_main)
                            ? Center(
                                child: Text(
                                  'ดาวน์โหลดข้อมูล',
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T
                                      //fontSize: 10.0
                                      ),
                                ),
                              )
                            : (teNantModels.isEmpty)
                                ? Center(
                                    child: Text(
                                      'ไม่พบข้อมูล',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  )
                                : TextFormField(
                                    initialValue: search_controller.text,
                                    onChanged: onSearchChanged,
                                    decoration: const InputDecoration(
                                      // labelText:
                                      //     (isLoading_main) ? 'ดาวน์โหลดข้อมูล...' : null,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                        ),
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          // .withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(6),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(6)),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AccountScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),

                            items: pe1.asMap().entries.map((entry) {
                              int index = entry.key; // Get the index
                              var item = entry.value;
                              return DropdownMenuItem<String>(
                                value: item["ser"], // Use "ser" as the value
                                enabled:
                                    false, // Set to true to allow selection
                                child: StatefulBuilder(
                                  builder: (context, menuSetState) {
                                    // final isSelected = selectedItems.contains(item);
                                    return InkWell(
                                      onTap: () {
                                        int selectedIndex = pe1.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            pe1[selectedIndex]["st"] = '0';
                                          } else {
                                            pe1[selectedIndex]["st"] = '1';
                                          }
                                        });
                                        AddDaTa();
                                        //This rebuilds the dropdownMenu Widget to update the check mark
                                        menuSetState(() {});
                                      },
                                      child: Container(
                                        height: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Row(
                                          children: [
                                            if (item["st"]! == '1')
                                              Icon(
                                                Icons.check_box_outlined,
                                                color: Colors.green[400],
                                              )
                                            else
                                              const Icon(Icons
                                                  .check_box_outline_blank),
                                            Expanded(
                                              child: Text(
                                                item["pn"]!,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
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
                            //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                            // value: selectedItems.isEmpty ? null : selectedItems.last,
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ),
                    Container(child: Next_page_TeNant())
                  ],
                ),
                const Divider(),
              ],
            ),
          ),

          // ตารางข้อมูล
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                  width: calculatedWidth,
                  height: MediaQuery.of(context).size.height / 1.63,
                  decoration: const BoxDecoration(
                    color: AppbackgroundColor.Sub_Abg_Colors,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    // border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Fixed Topic Row (Header)
                      Container(
                        color: AppbackgroundColor.TiTile_Colors,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                        child: Row(children: [
                          SizedBox(
                            width: 80,
                          ),
                          ...columnHeaders
                              .skip(1)
                              .map((column) => Expanded(
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'เลขที่สัญญา/เสนอราคา' ||
                                          column.toString() ==
                                              'เลขที่สัญญา-เดิม';
                                    }))
                                        ? 2
                                        : (Fix_data.contains(
                                                columnHeaders.indexWhere(
                                                    (item) => item == column)))
                                            ? Fix_Expan1
                                            : Fix_Expan2,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          firstRound = false;
                                          // Toggle sort order
                                          if (sortColumn == column) {
                                            sortAscending = !sortAscending;
                                          } else {
                                            sortColumn = column;
                                            sortAscending = true;
                                          }

                                          // Sort the displayed data
                                          displayedData.sort((a, b) {
                                            final aValue = a[column];
                                            final bValue = b[column];

                                            // Handle null values gracefully
                                            if (aValue == null &&
                                                bValue == null) return 0;
                                            if (aValue == null)
                                              return sortAscending ? -1 : 1;
                                            if (bValue == null)
                                              return sortAscending ? 1 : -1;

                                            // Compare values
                                            return sortAscending
                                                ? aValue.compareTo(bValue)
                                                : bValue.compareTo(aValue);
                                          });
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: ([9].contains(
                                                columnHeaders.indexWhere(
                                                    (item) => item == column)))
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (sortColumn ==
                                              column) // Show sorting indicator
                                            Icon(
                                              sortAscending
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 20,
                                              color: Colors.red[600],
                                            ),
                                          Expanded(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    column,
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    (columnHeaders
                                                            .any((columnx) {
                                                      return column
                                                              .toString() ==
                                                          'สถานะ';
                                                    }))
                                                        ? TextAlign.center
                                                        : TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                          SizedBox(
                            width: 40,
                          )
                        ]),
                      ),

                      // Scrollable ListView.builder for Data Rows
                      Expanded(
                        child: (isLoading)
                            ? SizedBox(
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
                                            'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
                                            // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T
                                                //fontSize: 10.0
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : (displayedData.isEmpty)
                                ? const Center(
                                    child: Text(
                                      'ไม่พบข้อมูล',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController1,
                                    itemCount: displayedData.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final row = displayedData[index];
                                      final columnToCheck = 'รหัสพื้นที่';
                                      int index_x = int.parse(
                                          '${displayedData[index]['index']}');
                                      return List_Material(index, columnHeaders,
                                          row, columnToCheck);
                                    },
                                  ),
                      ),
                    ],
                  )),
            ),
          ),
          Container(
              width: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.84
                  : MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              _scrollController1.animateTo(
                                0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  // color: AppbackgroundColor
                                  //     .TiTile_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(8)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: const EdgeInsets.all(3.0),
                                child: const Text(
                                  'Top',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_scrollController1.hasClients) {
                              final position =
                                  _scrollController1.position.maxScrollExtent;
                              _scrollController1.animateTo(
                                position,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                // color: AppbackgroundColor
                                //     .TiTile_Colors,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(6)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                'Down',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _moveDown1,
                          child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              // color: AppbackgroundColor
                              //     .TiTile_Colors,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(3.0),
                            child: const Text(
                              'Scroll',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        InkWell(
                          onTap: _moveDown1,
                          child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              )),

          // Pagination Controls
        ],
      ),
    );
  }

  String? _message, Valuecid;

  void updateMessage1(
      PeopleChaoScreen2, ValueNameShop_index, Valuecid, Value_stasus) {
    setState(() {
      widget.updateMessage(
          PeopleChaoScreen2, ValueNameShop_index, Valuecid, Value_stasus);

      Valuecid = Value_cid;
    });
  }

  /////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Column(
      children: [
        Material(
          // surfaceTintColor: tappedIndex_Color
          //     .tappedIndex_Colors,
          color: tappedIndex_ == index.toString()
              ? tappedIndex_Color.tappedIndex_Colors
              : AppbackgroundColor.Sub_Abg_Colors,
          child: InkWell(
            hoverColor: Colors.grey[350]!.withOpacity(0.5),
            onTap: () async {
              // await Dia_log1();
              int index_x = int.parse('${row['index']}');

              // setState(() {
              //   tappedIndex_ = index.toString();
              //   red_Trans_select2(index_x);
              //   red_Finnan2(index_x);
              // });
              // // print(_TransReBillHistoryModels.length);
              // Future.delayed(const Duration(milliseconds: 500), () {
              //   checkshowDialog2(index_x);
              // });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                // color: Colors.green[100]!
                //     .withOpacity(0.5),
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Row(children: [
                Container(
                  width: 80,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                          // side: BorderSide(
                          //   color: Colors.grey.shade300,
                          //   width: 0.5,
                          // ),
                        ),

                        // shape: CircleBorder(),
                        //  backgroundColor:
                        // MaterialStateProperty.all<
                        //     Color>(Colors.green),
                        backgroundColor: (widget.Status == 1)
                            ? Colors.grey.shade700
                            : (widget.Status == 2)
                                ? Colors.orange.shade700
                                : (widget.Status == 3)
                                    ? Colors.blue.shade700
                                    : (widget.Status == 4)
                                        ? Colors.deepPurple.shade700
                                        : Colors.grey.shade700),
                    // style: ButtonStyle(
                    //   backgroundColor:
                    //       MaterialStateProperty.all<Color>(
                    //(widget.Status == 1)
                    //           ? Colors.grey.shade700
                    //           : (widget.Status == 2)
                    //               ? Colors.orange.shade700
                    //               : (widget.Status == 3)
                    //                   ? Colors.blue.shade700
                    //                   : (widget.Status == 4)
                    //                       ? Colors.deepPurple.shade700
                    //                       : Colors.grey.shade700
                    // ),
                    // ),
                    onPressed: () async {},
                    child: PopupMenuButton(
                      onOpened: () {
                        setState(() {
                          quotxSelectModels_Select.clear();
                          ser_indexShow = null;
                          tappedIndex_ = index.toString();
                        });
                      },
                      child: Translate.TranslateAndSetText(
                          'เรียกดู >',
                          Colors.white,
                          TextAlign.center,
                          null,
                          Font_.Fonts_T,
                          12,
                          1),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: Column(
                            children: [
                              InkWell(
                                  onTap: () {
                                    if (renTal_lavel <= 2) {
                                      Navigator.pop(context);
                                      infomation();
                                    } else {
                                      int index_x =
                                          int.parse('${row['index']}');
                                      var ser_teNant =
                                          teNantModels[index_x].quantity;
                                      var ser_ciddoc =
                                          teNantModels[index_x].docno == null
                                              ? teNantModels[index_x].cid
                                              : teNantModels[index_x].docno;
                                      var Value_stasus_x = teNantModels[index_x]
                                                  .quantity ==
                                              '1'
                                          ? datex.isAfter(DateTime.parse(
                                                          '${teNantModels[index_x].ldate} 00:00:00.000')
                                                      .subtract(const Duration(
                                                          days: 0))) ==
                                                  true
                                              ? 'หมดสัญญา'
                                              : datex.isAfter(DateTime.parse(
                                                              '${teNantModels[index_x].ldate} 00:00:00.000')
                                                          .subtract(
                                                              Duration(days: open_set_date))) ==
                                                      true
                                                  ? 'ใกล้หมดสัญญา'
                                                  : 'เช่าอยู่'
                                          : teNantModels[index_x].quantity == '2'
                                              ? 'เสนอราคา'
                                              : teNantModels[index_x].quantity == '3'
                                                  ? 'เสนอราคา(มัดจำ)'
                                                  : 'ว่าง';
                                      setState(() {
                                        Value_NameShop_index = '$ser_teNant';
                                        Value_cid = '$ser_ciddoc';
                                      });

                                      setState(() {
                                        ReturnBodyPeople = 'PeopleChaoScreen2';
                                      });
                                      Navigator.pop(context);
                                      updateMessage1(
                                          'PeopleChaoScreen2',
                                          '$ser_teNant',
                                          '$ser_ciddoc',
                                          '$Value_stasus_x');
                                    }
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const PeopleChaoScreen2()));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            teNantModels[int.parse(
                                                            '${row['index']}')]
                                                        .docno ==
                                                    null
                                                ? teNantModels[int.parse(
                                                                '${row['index']}')]
                                                            .cid ==
                                                        null
                                                    ? ''
                                                    : '${teNantModels[int.parse('${row['index']}')].cid}'
                                                : '${teNantModels[int.parse('${row['index']}')].docno}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ))
                                        ],
                                      ))),
                              teNantModels[int.parse('${row['index']}')].cid ==
                                      teNantModels[int.parse('${row['index']}')]
                                          .fid
                                  ? SizedBox()
                                  : InkWell(
                                      onTap: () {
                                        if (renTal_lavel <= 2) {
                                          Navigator.pop(context);
                                          infomation();
                                        } else {
                                          int index_x =
                                              int.parse('${row['index']}');
                                          var ser_teNant =
                                              teNantModels[index_x].quantity;
                                          var ser_ciddoc =
                                              teNantModels[index_x].docno ==
                                                      null
                                                  ? teNantModels[index_x].fid
                                                  : teNantModels[index_x].docno;
                                          var Value_stasus_x = teNantModels[index_x]
                                                      .quantity ==
                                                  '1'
                                              ? datex.isAfter(DateTime.parse(
                                                              '${teNantModels[index_x].ldate} 00:00:00.000')
                                                          .subtract(
                                                              const Duration(
                                                                  days: 0))) ==
                                                      true
                                                  ? 'หมดสัญญา'
                                                  : datex.isAfter(DateTime.parse(
                                                                  '${teNantModels[index_x].ldate} 00:00:00.000')
                                                              .subtract(
                                                                  Duration(days: open_set_date))) ==
                                                          true
                                                      ? 'ใกล้หมดสัญญา'
                                                      : 'เช่าอยู่'
                                              : teNantModels[index_x].quantity == '2'
                                                  ? 'เสนอราคา'
                                                  : teNantModels[index_x].quantity == '3'
                                                      ? 'เสนอราคา(มัดจำ)'
                                                      : 'ว่าง';
                                          setState(() {
                                            Value_NameShop_index =
                                                '$ser_teNant';
                                            Value_cid = '$ser_ciddoc';
                                          });

                                          setState(() {
                                            ReturnBodyPeople =
                                                'PeopleChaoScreen2';
                                          });

                                          Navigator.pop(context);
                                          updateMessage1(
                                              'PeopleChaoScreen2',
                                              '$ser_teNant',
                                              '$ser_ciddoc',
                                              '$Value_stasus_x');
                                        }
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             const PeopleChaoScreen2()));
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              Translate.TranslateAndSetText(
                                                  teNantModels[int.parse(
                                                                  '${row['index']}')]
                                                              .docno ==
                                                          null
                                                      ? teNantModels[int.parse(
                                                                      '${row['index']}')]
                                                                  .cid ==
                                                              null
                                                          ? ''
                                                          : 'สัญญาเดิม : '
                                                      : '',
                                                  PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  TextAlign.left,
                                                  null,
                                                  Font_.Fonts_T,
                                                  14,
                                                  1),
                                              Text(
                                                teNantModels[int.parse(
                                                                '${row['index']}')]
                                                            .docno ==
                                                        null
                                                    ? teNantModels[int.parse(
                                                                    '${row['index']}')]
                                                                .cid ==
                                                            null
                                                        ? ''
                                                        : '${teNantModels[int.parse('${row['index']}')].fid}'
                                                    : '${teNantModels[int.parse('${row['index']}')].docno}',
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ],
                                          ))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...columnHeaders
                    .skip(1)
                    .map((column) => (columnHeaders.any((columnx) {
                          return column.toString() == 'เลขที่สัญญา/เสนอราคา' ||
                              column.toString() == 'เลขที่สัญญา-เดิม';
                        }))
                            ? Expanded(
                                flex: (columnHeaders.any((columnx) {
                                  return column.toString() ==
                                          'เลขที่สัญญา/เสนอราคา' ||
                                      column.toString() == 'เลขที่สัญญา-เดิม';
                                }))
                                    ? 2
                                    : (Fix_data.contains(
                                            columnHeaders.indexWhere(
                                                (item) => item == column)))
                                        ? Fix_Expan1
                                        : Fix_Expan2,
                                child: Row(children: [
                                  (row[column]?.toString() == '' ||
                                          row[column] == null)
                                      ? SizedBox()
                                      : Copy_Text(context,
                                          row[column]?.toString() ?? ''),
                                  Expanded(
                                    child: Tooltip(
                                      richMessage: TextSpan(
                                        text: row[column]?.toString() ?? '',
                                        style: const TextStyle(
                                          color: HomeScreen_Color.Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                          //fontSize: 10.0
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey[200],
                                      ),
                                      child: AutoSizeText(
                                        minFontSize: 12,
                                        maxFontSize: 16,
                                        maxLines: 1,
                                        row[column]?.toString() ?? '',
                                        textAlign:
                                            (columnHeaders.any((columnx) {
                                          return column.toString() == 'สถานะ';
                                        }))
                                                ? TextAlign.center
                                                : TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                  )
                                ]))
                            : Expanded(
                                flex: (columnHeaders.any((columnx) {
                                  return column.toString() ==
                                          'เลขที่สัญญา/เสนอราคา' ||
                                      column.toString() == 'เลขที่สัญญา-เดิม';
                                }))
                                    ? 2
                                    : (Fix_data.contains(
                                            columnHeaders.indexWhere(
                                                (item) => item == column)))
                                        ? Fix_Expan1
                                        : Fix_Expan2,
                                child: AutoSizeText(
                                  minFontSize: 12,
                                  maxFontSize: 16,
                                  maxLines: 1,
                                  row[column]?.toString() ?? '',
                                  textAlign: (columnHeaders.any((columnx) {
                                    return column.toString() == 'สถานะ';
                                  }))
                                      ? TextAlign.center
                                      : TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: (columnHeaders.any((columnx) {
                                        return column.toString() == 'สถานะ';
                                      }))
                                          ? teNantModels[int.parse('${row['index']}')]
                                                      .quantity ==
                                                  '1'
                                              ? datex.isAfter(DateTime.parse(
                                                              '${teNantModels[int.parse('${row['index']}')].ldate} 00:00:00.000')
                                                          .subtract(
                                                              const Duration(
                                                                  days: 0))) ==
                                                      true
                                                  ? Colors.red
                                                  : datex.isAfter(DateTime.parse(
                                                                  '${teNantModels[int.parse('${row['index']}')].ldate} 00:00:00.000')
                                                              .subtract(
                                                                  Duration(days: open_set_date))) ==
                                                          true
                                                      ? Colors.orange.shade900
                                                      : Colors.black
                                              : teNantModels[int.parse('${row['index']}')].quantity == '2'
                                                  ? Colors.blue
                                                  : teNantModels[int.parse('${row['index']}')].quantity == '3'
                                                      ? Colors.blue
                                                      : Colors.green
                                          : Colors.black,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ))
                    .toList(),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: SizedBox(
                    width: 40,
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () async {
                          await Dia_log1();
                          int index_x = int.parse('${row['index']}');
                          if (renTal_lavel <= 2) {
                            infomation();
                          } else {
                            setState(() {
                              tappedIndex_ = index.toString();
                              if (ser_indexShow == index) {
                                quotxSelectModels_Select.clear();
                                ser_indexShow = null;
                              } else {
                                red_quotx_Select(index_x);
                                ser_indexShow = index;
                              }
                            });
                          }
                        },
                        child: CircleAvatar(
                            radius: 17,
                            backgroundColor: (ser_indexShow == index)
                                ? Colors.red[700]!.withOpacity(0.5)
                                : Colors.grey[600]!.withOpacity(0.5),
                            child: Icon(
                              (ser_indexShow == index)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down_outlined,
                              color: Colors.white,
                              size: 15,
                            )),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        if (ser_indexShow == index)
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Translate.TranslateAndSetText(
                                'งวด',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Translate.TranslateAndSetText(
                                'วันที่',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Translate.TranslateAndSetText(
                                'รายการ',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Translate.TranslateAndSetText(
                                'ยอด/งวด',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.end,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Translate.TranslateAndSetText(
                                'ยอด',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.end,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (quotxSelectModels_Select.length == 0)
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Expanded(
                                flex: 1,
                                child: Translate.TranslateAndSetText(
                                    'ไม่พบข้อมูล',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    14,
                                    1),
                              ),
                            ]))),
                  for (int index2 = 0;
                      index2 < quotxSelectModels_Select.length;
                      index2++)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                '${quotxSelectModels_Select[index2].unit} / ${quotxSelectModels_Select[index2].term} (งวด)',
                                ReportScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                13,
                                1),
                            //     AutoSizeText(
                            //   maxLines:
                            //       2,
                            //   minFontSize:
                            //       8,
                            //   // maxFontSize: 15,
                            //   '${quotxSelectModels_Select[index2].unit} / ${quotxSelectModels_Select[index2].term} (งวด)',
                            //   textAlign:
                            //       TextAlign.start,
                            //   style: const TextStyle(
                            //       color: PeopleChaoScreen_Color.Colors_Text2_,
                            //       //fontWeight: FontWeight.bold,
                            //       fontFamily: Font_.Fonts_T),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              maxLines: 2,
                              minFontSize: 8,
                              // maxFontSize: 15,
                              '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels_Select[index2].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels_Select[index2].ldate!} 00:00:00'))}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Tooltip(
                              richMessage: TextSpan(
                                text:
                                    '${quotxSelectModels_Select[index2].expname}',
                                style: const TextStyle(
                                  color: HomeScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                  //fontSize: 10.0
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[200],
                              ),
                              child: AutoSizeText(
                                maxLines: 2,
                                minFontSize: 8,
                                // maxFontSize: 15,
                                '${quotxSelectModels_Select[index2].expname}',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                          quotxSelectModels_Select[index2].ele_ty == '0'
                              ? Expanded(
                                  flex: 1,
                                  child: Translate.TranslateAndSetText(
                                      quotxSelectModels_Select[index2].qty ==
                                              '0.00'
                                          ? '${nFormat.format(double.parse(quotxSelectModels_Select[index2].total!))} / งวด'
                                          : '${nFormat.format(double.parse(quotxSelectModels_Select[index2].qty!))} / หน่วย',
                                      PeopleChaoScreen_Color.Colors_Text2_,
                                      TextAlign.end,
                                      null,
                                      Font_.Fonts_T,
                                      14,
                                      1),
                                  //  AutoSizeText(
                                  //   maxLines: 2,
                                  //   minFontSize: 8,
                                  //   // maxFontSize: 15,
                                  //   quotxSelectModels_Select[index2].qty == '0.00' ? '${nFormat.format(double.parse(quotxSelectModels_Select[index2].total!))} / งวด' : '${nFormat.format(double.parse(quotxSelectModels_Select[index2].qty!))} / หน่วย',
                                  //   // '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
                                  //   textAlign: TextAlign.end,
                                  //   style: const TextStyle(
                                  //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //       //fontWeight: FontWeight.bold,
                                  //       fontFamily: Font_.Fonts_T),
                                  // ),
                                )
                              : Expanded(
                                  flex: 1,
                                  child: Translate.TranslateAndSetText(
                                      'อัตราพิเศษ',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.end,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      14,
                                      1),
                                ),
                          quotxSelectModels_Select[index2].ele_ty == '0'
                              ? Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    maxLines: 2,
                                    minFontSize: 8,
                                    // maxFontSize: 15,
                                    '${nFormat.format(int.parse(quotxSelectModels_Select[index2].term!) * double.parse(quotxSelectModels_Select[index2].total!))}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                )
                              : Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      showcountmiter(index2)
                                          .then((value) => showDialog(
                                              context: context,
                                              builder: (_) {
                                                return Dialog(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          15.0),
                                                                  child: Translate.TranslateAndSetText(
                                                                      'อัตราการคำนวณปัจจุบัน',
                                                                      ReportScreen_Color
                                                                          .Colors_Text1_,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .bold,
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitOne!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobOne!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ 0 - ${electricityModels[0].eleOne}',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitOne!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitOne!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobOne}'
                                                                            : '${electricityModels[0].eleMitOne}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitTwo!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobTwo!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ ${int.parse(electricityModels[0].eleOne!) + 1} - ${electricityModels[0].eleTwo}',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitTwo!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitTwo!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobTwo}'
                                                                            : '${electricityModels[0].eleMitTwo}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitThree!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobThree!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ ${int.parse(electricityModels[0].eleTwo!) + 1} - ${electricityModels[0].eleThree}',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitThree!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitThree!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobThree}'
                                                                            : '${electricityModels[0].eleMitThree}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitTour!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobTour!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ ${int.parse(electricityModels[0].eleThree!) + 1} - ${electricityModels[0].eleTour}',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitTour!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitTour!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobTour}'
                                                                            : '${electricityModels[0].eleMitTour}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitFive!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobFive!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ ${int.parse(electricityModels[0].eleTour!) + 1} - ${electricityModels[0].eleFive}',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitFive!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitFive!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobFive}'
                                                                            : '${electricityModels[0].eleMitFive}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          (double.parse(electricityModels[
                                                                              0]
                                                                          .eleMitSix!) +
                                                                      double.parse(
                                                                          electricityModels[0]
                                                                              .eleGobSix!)) ==
                                                                  0.00
                                                              ? SizedBox()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '')),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หน่วยที่ ${electricityModels[0].eleSix} ขึ้นไป',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Translate.TranslateAndSetText(
                                                                          double.parse(electricityModels[0].eleMitSix!) == 0.00
                                                                              ? 'เหมาจ่าย'
                                                                              : 'หน่วยละ',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Text(
                                                                        double.parse(electricityModels[0].eleMitSix!) ==
                                                                                0.00
                                                                            ? '${electricityModels[0].eleGobSix}'
                                                                            : '${electricityModels[0].eleMitSix}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บาท',
                                                                          ReportScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  ],
                                                                ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          15.0),
                                                                  child: Translate.TranslateAndSetText(
                                                                      '* อัตราคำนวณปัจจุบันอาจไม่ตรงกับยอดชำระ ณ วันที่บันทึก',
                                                                      Colors
                                                                          .red,
                                                                      TextAlign
                                                                          .end,
                                                                      FontWeight
                                                                          .bold,
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }));
                                    },
                                    child: Translate.TranslateAndSetText(
                                        'ดูอัตราคำนวณ',
                                        PeopleChaoScreen_Color.Colors_Text2_,
                                        TextAlign.end,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  ///---------------------------------------------------------------------->

  /////////////---------------------------------------------------->
  Dia_log1() {
    return showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext builderContext) {
          Timer(Duration(milliseconds: 150), () {
            Navigator.of(context).pop();
          });

          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }

  Future<Null> infomation() async {
    showDialog<String>(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: const Center(
                  child: Text(
                'Level ของคุณไม่สามารถเข้าถึงได้',
                style: TextStyle(
                  color: SettingScreen_Color.Colors_Text1_,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ));
  }
}
