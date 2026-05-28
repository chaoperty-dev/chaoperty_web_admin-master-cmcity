import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../Model/GetArea_Model.dart';
import '../Model/Get_maintenance_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

class RepairsScreen extends StatefulWidget {
  const RepairsScreen({super.key});

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> {
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  //-------------------------------------->
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  //-------------------------------------->
  //-------------------------------------->
  List<MaintenanceModel> maintenanceModels = [];
  List<MaintenanceModel> _maintenanceModels = <MaintenanceModel>[];
  List<AreaModel> areaModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> ac7 = [];

  List<int> Fix_data = [4, 5, 6];
  //-------------------------------------->
  String? serarea,
      lncodearea,
      lnarea,
      Value_D_start,
      snamearea,
      custnoarea,
      zone_ser,
      zone_name,
      zone_Subser,
      zone_Subname;
  int renTal_lavel = 0;
  int Ser_Tap = 1;
  String tappedIndex_ = '';
  final Formbecause_ = TextEditingController();
  final Form_note = TextEditingController();
  //-------------------------------------->

  // ตัวแปรสำหรับการค้นหา
  String searchQuery = "";
  //-------------------------------------->
  // Pagination
  int currentPage_1 = 0;
  bool firstRound = true;
  bool showDuplicatesOnly = false;
  static const int rowsPerPage_1 = 50;
  //-------------------------------------->
  // ตัวแปรสำหรับการจัดเรียง
  bool sortAscending = true;
  String sortColumn = "วันที่แจ้งซ่อม";
  //-------------------------------------->
  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;

  ///------------------------>
  void initState() {
    super.initState();
    checkPreferance();
    Loading_Trans_bill();
    read_GC_areaSelect();
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      zone_ser = preferences.getString('zonePSer');
      zone_name = preferences.getString('zonesPName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

  Future<Null> read_GC_areaSelect() async {
    if (areaModels.length != 0) {
      areaModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    String url =
        '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          AreaModel areaModel = AreaModel.fromJson(map);
          setState(() {
            areaModels.add(areaModel);
          });
        }
        setState(() {
          _areaModels = areaModels;
        });
      }
    } catch (e) {}
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    red_Trans_c_maintenance().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }
  ////////-------------------------------------------------------->

  Future<Null> red_Trans_c_maintenance() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      maintenanceModels.clear();
      data.clear();
      filteredData.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    String url = zone_Sub == null || zone_Sub == '0'
        ? (zone_ser.toString() == 'null')
            ? '${MyConstant().domain}/GC_maintenance.php?isAdd=true&ren=$ren&serzone=0&status=$Ser_Tap'
            : '${MyConstant().domain}/GC_maintenance.php?isAdd=true&ren=$ren&serzone=$zone_ser&status=$Ser_Tap'
        : (zone_ser.toString() == 'null')
            ? '${MyConstant().domain}/GC_maintenance_sub.php?isAdd=true&ren=$ren&serzone=$zone_Sub&status=$Ser_Tap'
            : '${MyConstant().domain}/GC_maintenance.php?isAdd=true&ren=$ren&serzone=$zone_ser&status=$Ser_Tap';
    // print('result $url');
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          MaintenanceModel maintenanceModel = MaintenanceModel.fromJson(map);
          setState(() {
            maintenanceModels.add(maintenanceModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
      setState(() {
        _maintenanceModels = maintenanceModels;
      });
      AddDaTa();
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (maintenanceModels.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(maintenanceModels.length, (index) {
          // Ensure that docno exists and is not null
          final lncode = maintenanceModels[index].lncode ?? "";
          final ln = maintenanceModels[index].ln ?? "";
          final sname = maintenanceModels[index].sname ?? "";
          final cid = maintenanceModels[index].cid ?? "";
          final mdate = (maintenanceModels[index].mdate == null ||
                  maintenanceModels[index].mdate! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${maintenanceModels[index].mdate} 00:00:00'))}-${DateTime.parse('${maintenanceModels[index].mdate} 00:00:00').year + 0}';
          final rdate = (maintenanceModels[index].rdate == null ||
                  maintenanceModels[index].rdate! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${maintenanceModels[index].rdate} 00:00:00'))}-${DateTime.parse('${maintenanceModels[index].rdate} 00:00:00').year + 0}';
          final mdescr = maintenanceModels[index].mdescr ?? "";
          final mst = maintenanceModels[index].st == '0'
              ? 'ถูกยกเลิก'
              : maintenanceModels[index].mst == '0'
                  ? ' '
                  : maintenanceModels[index].mst == '1'
                      ? 'รอดำเนินการ'
                      : maintenanceModels[index].mst == '2'
                          ? 'กำลังดำเนินการ'
                          : 'เสร็จสิ้น';
          return {
            "index": "$index",
            // "ชื่อพื้นที่": "$ln",
            // "รหัสพื้นที่": "$lncode",
            "รหัสพื้นที่": "$ln",
            "ชื่อผู้แจ้ง": "$sname",
            "วันที่แจ้งซ่อม": "$mdate",
            "รายละเอียด": "$mdescr",

            "วันที่อัพเดต/เสร็จสิ้น": maintenanceModels[index].st == '0'
                ? 'ถูกยกเลิก'
                : maintenanceModels[index].mst == '0'
                    ? ' '
                    : maintenanceModels[index].mst == '1'
                        ? 'รอดำเนินการ'
                        : maintenanceModels[index].mst == '2'
                            ? "$rdate"
                            : "$rdate",
            "สถานะ": "$mst",
          };
        });
        filteredData = data;
      });
    } else {
      setState(() {
        data = List.generate(1, (index) {
          return {
            "index": "",
            // "ชื่อพื้นที่": "$ln",
            // "รหัสพื้นที่": "$lncode",
            "รหัสพื้นที่": "",
            "ชื่อผู้แจ้ง": "",
            "วันที่แจ้งซ่อม": "",
            "รายละเอียด": "",

            "วันที่อัพเดต/เสร็จสิ้น": "",
            "สถานะ": "",
          };
        });

        filteredData = data;
      });
    }

    // print("Data added: $data");
  }

  //-------------------------------------->
  // ฟังก์ชันค้นหา
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      isLoading = true; // กำหนดให้กำลังโหลด
    });
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

  ////////--------------------------------------------------------------->
  Widget Next_page_Billpay() {
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
                    Icon(
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

  ////////-------------------------->
  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  ////////-------------------------->
  var Value_selectDate;
  Future<Null> _select_Date(BuildContext context) async {
    final Future<DateTime?> picked = showDatePicker(
      locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่เริ่มต้น', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      // selectableDayPredicate: _decideWhichDayToEnable,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppBarColors.ABar_Colors, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    picked.then((result) {
      if (picked != null) {
        var formatter = DateFormat('y-MM-d');
        print("${formatter.format(result!)}");
        setState(() {
          Value_selectDate = "${formatter.format(result)}";
        });
        // red_Trans_c_maintenance();
      }
    });
  }

  ////------------------------------------------------->
  _searchBar_area() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: const BorderSide(color: Colors.white),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        // print(text);
        text = text.toLowerCase();
        setState(() {
          areaModels = _areaModels.where((areaModelss) {
            var notTitle = areaModelss.ln.toString().toLowerCase();
            var notTitle2 = areaModelss.lncode.toString().toLowerCase();
            // var notTitle3 = areaModelss.areatype.toString().toLowerCase();
            return notTitle.contains(text) || notTitle2.contains(text);
          }).toList();
        });
      },
    );
  }

  ////////-------------------------->
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cts) {
      final screenW = cts.maxWidth;
      final tableMinW = Responsive.isDesktop(context) ? screenW : 980.0;

      double calculatedWidth = Responsive.isDesktop(context) ? screenW : 980.0;
      // (Responsive.isDesktop(context))
      //     ? MediaQuery.of(context).size.width * 0.85
      //     : 1200;
      // (ac7
      //             .where((item) => item["st"] == '1')
      //             .toList()
      //             .length <=
      //         9)
      //     ? (Responsive.isDesktop(context))
      //         ? MediaQuery.of(context).size.width * 0.83
      //         : 1200
      //     : (Responsive.isDesktop(context))
      //         ? MediaQuery.of(context).size.width * 0.83 +
      //             ((ac7.where((item) => item["st"] == '1').toList().length - 9) *
      //                 30)
      //         : 1200 +
      //             ((ac7.where((item) => item["st"] == '1').toList().length - 9) *
      //                 30);
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
//////////---------------------------->

      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 8, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          Ser_Tap = 1;
                          tappedIndex_ = '';
                        });
                        // await Dia_log1();
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          Loading_Trans_bill();
                        });
                      },
                      child: Container(
                        // width: 130,
                        decoration: BoxDecoration(
                          color: (Ser_Tap == 1)
                              ? Colors.deepPurple[600]
                              : Colors.deepPurple[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSetText(
                            "รอดำเนินการ",
                            (Ser_Tap == 1) ? Colors.white : Colors.black,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            12,
                            1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          Ser_Tap = 2;
                          tappedIndex_ = '';
                        });
                        // await Dia_log1();
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          Loading_Trans_bill();
                        });
                      },
                      child: Container(
                        // width: 130,
                        decoration: BoxDecoration(
                          color: (Ser_Tap == 2)
                              ? Colors.deepPurple[600]
                              : Colors.deepPurple[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSetText(
                            "กำลังดำเนินการ",
                            (Ser_Tap == 2) ? Colors.white : Colors.black,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            12,
                            1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          Ser_Tap = 3;
                          tappedIndex_ = '';
                        });
                        // await Dia_log1();
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          Loading_Trans_bill();
                        });
                      },
                      child: Container(
                        // width: 130,
                        decoration: BoxDecoration(
                          color: (Ser_Tap == 3)
                              ? Colors.deepPurple[600]
                              : Colors.deepPurple[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSetText(
                            "ดำเนินการเสร็จสิ้น",
                            (Ser_Tap == 3) ? Colors.white : Colors.black,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            12,
                            1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          Ser_Tap = 4;
                          tappedIndex_ = '';
                        });
                        // await Dia_log1();
                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          Loading_Trans_bill();
                        });
                      },
                      child: Container(
                        // width: 130,
                        decoration: BoxDecoration(
                          color: (Ser_Tap == 3)
                              ? Colors.deepPurple[600]
                              : Colors.deepPurple[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSetText(
                            "ถูกยกเลิก",
                            (Ser_Tap == 4) ? Colors.white : Colors.black,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            12,
                            1),
                      ),
                    ),
                  )
                ],
              ),
            ),
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
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: (isLoading_main)
                              ? const Center(
                                  child: Text(
                                    'ดาวน์โหลดข้อมูล',
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T
                                        //fontSize: 10.0
                                        ),
                                  ),
                                )
                              : (maintenanceModels.isEmpty)
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
                                  : TextField(
                                      onChanged: onSearchChanged,
                                      decoration: const InputDecoration(
                                        // labelText:
                                        //     (isLoading_main) ? 'ดาวน์โหลดข้อมูล...' : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                          ),
                                        ),
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                      //   child: Container(
                      //     height: 30,
                      //     decoration: BoxDecoration(
                      //       color: AppbackgroundColor.Sub_Abg_Colors,
                      //       // .withOpacity(0.5),
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(0),
                      //           topRight: Radius.circular(6),
                      //           bottomLeft: Radius.circular(0),
                      //           bottomRight: Radius.circular(6)),
                      //       // border: Border.all(
                      //       //     color:
                      //       //         Colors.grey,
                      //       //     width: 1),
                      //     ),
                      //     width: 130,
                      //     // height: 30,
                      //     padding: const EdgeInsets.all(2.0),
                      //     child: DropdownButtonHideUnderline(
                      //       child: DropdownButton2<String>(
                      //         isExpanded: true,
                      //         hint: Center(
                      //           child: Text(
                      //             'หัวข้อ',
                      //             style: const TextStyle(
                      //               fontSize: 14,
                      //               color: AccountScreen_Color.Colors_Text1_,
                      //               fontWeight: FontWeight.bold,
                      //               fontFamily: Font_.Fonts_T,
                      //             ),
                      //           ),
                      //         ),

                      //         items: ac7.asMap().entries.map((entry) {
                      //           int index = entry.key; // Get the index
                      //           var item = entry.value;
                      //           return DropdownMenuItem<String>(
                      //             value: item["ser"], // Use "ser" as the value
                      //             enabled:
                      //                 false, // Set to true to allow selection
                      //             child: StatefulBuilder(
                      //               builder: (context, menuSetState) {
                      //                 // final isSelected = selectedItems.contains(item);
                      //                 return InkWell(
                      //                   onTap: () {
                      //                     int selectedIndex = ac7.indexWhere(
                      //                         (items) =>
                      //                             items["ser"] == item["ser"]);
                      //                     // print(ac1[selectedIndex]
                      //                     //     [
                      //                     //     "pn"]);
                      //                     // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                      //                     //This rebuilds the StatefulWidget to update the button's text
                      //                     setState(() {
                      //                       if (item["st"]! == '1') {
                      //                         ac7[selectedIndex]["st"] = '0';
                      //                       } else {
                      //                         ac7[selectedIndex]["st"] = '1';
                      //                       }
                      //                     });
                      //                     AddDaTa();
                      //                     //This rebuilds the dropdownMenu Widget to update the check mark
                      //                     menuSetState(() {});
                      //                   },
                      //                   child: Container(
                      //                     height: double.infinity,
                      //                     padding: const EdgeInsets.symmetric(
                      //                         horizontal: 4.0),
                      //                     child: Row(
                      //                       children: [
                      //                         if (item["st"]! == '1')
                      //                           Icon(
                      //                             Icons.check_box_outlined,
                      //                             color: Colors.green[400],
                      //                           )
                      //                         else
                      //                           const Icon(Icons
                      //                               .check_box_outline_blank),
                      //                         Expanded(
                      //                           child: Text(
                      //                             item["pn"]!,
                      //                             maxLines: 2,
                      //                             style: const TextStyle(
                      //                               fontSize: 12,
                      //                               color: AccountScreen_Color
                      //                                   .Colors_Text1_,
                      //                               fontWeight: FontWeight.w600,
                      //                               fontFamily: Font_.Fonts_T,
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           );
                      //         }).toList(),
                      //         //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                      //         // value: selectedItems.isEmpty ? null : selectedItems.last,
                      //         onChanged: (value) {},
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            Future.delayed(const Duration(milliseconds: 300),
                                () async {
                              showDialog<void>(
                                  context: context,
                                  barrierDismissible:
                                      false, // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: SizedBox(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    // red_Trans_c_maintenance();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Icon(
                                                        Icons.highlight_off,
                                                        size: 30,
                                                        color: Colors.red[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Text(
                                                'แจ้งซ่อมบำรุง',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ManageScreen_Color
                                                      .Colors_Text2_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: const Divider(
                                                color: Colors.grey,
                                                height: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      content: StreamBuilder(
                                          stream: Stream.periodic(
                                              const Duration(seconds: 0)),
                                          builder: (context, snapshot) {
                                            return SizedBox(
                                              width: (Responsive.isDesktop(
                                                      context))
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3
                                                  : MediaQuery.of(context)
                                                      .size
                                                      .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              child: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        //_select_Date
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                            'วันที่ :',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                DateTime?
                                                                    newDate =
                                                                    await showDatePicker(
                                                                  locale:
                                                                      const Locale(
                                                                          'th',
                                                                          'TH'),
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          1000,
                                                                          1,
                                                                          01),
                                                                  lastDate: DateTime
                                                                          .now()
                                                                      .add(const Duration(
                                                                          days:
                                                                              50)),
                                                                  builder:
                                                                      (context,
                                                                          child) {
                                                                    return Theme(
                                                                      data: Theme.of(
                                                                              context)
                                                                          .copyWith(
                                                                        colorScheme:
                                                                            const ColorScheme.light(
                                                                          primary:
                                                                              AppBarColors.ABar_Colors, // header background color
                                                                          onPrimary:
                                                                              Colors.white, // header text color
                                                                          onSurface:
                                                                              Colors.black, // body text color
                                                                        ),
                                                                        textButtonTheme:
                                                                            TextButtonThemeData(
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            primary:
                                                                                Colors.black, // button text color
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          child!,
                                                                    );
                                                                  },
                                                                );

                                                                if (newDate ==
                                                                    null) {
                                                                  return;
                                                                } else {
                                                                  // print('$newDate');

                                                                  String start =
                                                                      DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              newDate);

                                                                  // print('$start');
                                                                  setState(() {
                                                                    Value_D_start =
                                                                        start;
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                  // height: 5,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppbackgroundColor
                                                                        .Sub_Abg_Colors,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  // width: 120,
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child: Center(
                                                                    child: Text(
                                                                      Value_D_start ==
                                                                              null
                                                                          ? 'เลือกวันที่'
                                                                          : '$Value_D_start',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'พื้นที่ : ',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            0),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            0)),
                                                                // border: Border.all(
                                                                //     color: Colors.grey, width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: InkWell(
                                                                child:
                                                                    Container(
                                                                  width: 100,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppbackgroundColor
                                                                        .Sub_Abg_Colors,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    maxLines: 1,
                                                                    lncodearea ==
                                                                            null
                                                                        ? 'เลือกพื้นที่'
                                                                        : '$lncodearea',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text1_,
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  showDialog<
                                                                      String>(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AlertDialog(
                                                                      shape: const RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(20.0))),
                                                                      backgroundColor:
                                                                          AppbackgroundColor
                                                                              .Sub_Abg_Colors,
                                                                      titlePadding:
                                                                          const EdgeInsets.all(
                                                                              0.0),
                                                                      contentPadding:
                                                                          const EdgeInsets.all(
                                                                              10.0),
                                                                      actionsPadding:
                                                                          const EdgeInsets.all(
                                                                              6.0),
                                                                      title:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(4.0),
                                                                        child:
                                                                            Column(
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
                                                                            Center(
                                                                                child: Text(
                                                                              'เลือกพื้นที่',
                                                                              style: TextStyle(
                                                                                color: SettingScreen_Color.Colors_Text1_,
                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            )),
                                                                            Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.all(2.0),
                                                                                  child: Translate.TranslateAndSetText('ค้นหา', SettingScreen_Color.Colors_Text1_, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                  // Text(
                                                                                  //   'ค้นหา :',
                                                                                  //   style: TextStyle(
                                                                                  //     color: ReportScreen_Color
                                                                                  //         .Colors_Text2_,
                                                                                  //     fontWeight: FontWeight.bold,
                                                                                  //     fontFamily: Font_.Fonts_T,
                                                                                  //   ),
                                                                                  // ),
                                                                                ),
                                                                                Expanded(
                                                                                  // flex: 1,
                                                                                  child: Container(
                                                                                    height: 35, //Date_ser
                                                                                    // width: 150,
                                                                                    decoration: BoxDecoration(
                                                                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                                                      border: Border.all(color: Colors.grey, width: 1),
                                                                                    ),
                                                                                    child: _searchBar_area(),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(4.0),
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Text(
                                                                                      'ชื่อพื้นที่',
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: ManageScreen_Color.Colors_Text2_,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: Font_.Fonts_T,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Text(
                                                                                      'รหัสพื้นที่',
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: ManageScreen_Color.Colors_Text2_,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: Font_.Fonts_T,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            ListBody(
                                                                          children: <Widget>[
                                                                            StreamBuilder(
                                                                                stream: Stream.periodic(const Duration(seconds: 0)),
                                                                                builder: (context, snapshot) {
                                                                                  return Container(
                                                                                    width: MediaQuery.of(context).size.width * 0.3,
                                                                                    height: MediaQuery.of(context).size.height,
                                                                                    child: ListView.builder(
                                                                                      itemCount: areaModels.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return Container(
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border(
                                                                                              bottom: BorderSide(
                                                                                                color: Colors.black12,
                                                                                                width: 1,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          child: ListTile(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                serarea = areaModels[index].ser;
                                                                                                lncodearea = areaModels[index].lncode;
                                                                                                lnarea = areaModels[index].ln;
                                                                                                snamearea = areaModels[index].sname;
                                                                                                custnoarea = areaModels[index].custno;
                                                                                              });
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            contentPadding: const EdgeInsets.all(0.0),
                                                                                            title: Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  flex: 1,
                                                                                                  child: Text(
                                                                                                    '${areaModels[index].ln}',
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: const TextStyle(
                                                                                                      color: ManageScreen_Color.Colors_Text2_,
                                                                                                      // fontWeight:
                                                                                                      //     FontWeight.bold,
                                                                                                      fontFamily: Font_.Fonts_T,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  flex: 1,
                                                                                                  child: Text(
                                                                                                    '${areaModels[index].lncode}',
                                                                                                    textAlign: TextAlign.center,
                                                                                                    style: const TextStyle(
                                                                                                      color: ManageScreen_Color.Colors_Text2_,
                                                                                                      // fontWeight:
                                                                                                      //     FontWeight.bold,
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
                                                                                })
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextFormField(
                                                        readOnly: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller: Form_note,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                          }
                                                          // if (int.parse(value.toString()) < 13) {
                                                          //   return '< 13';
                                                          // }
                                                          return null;
                                                        },
                                                        maxLines: 10,
                                                        cursorColor:
                                                            Colors.green,
                                                        decoration:
                                                            InputDecoration(
                                                                fillColor: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.3),
                                                                filled: true,
                                                                // prefixIcon: const Icon(Icons.water,
                                                                //     color: Colors.blue),
                                                                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                focusedBorder:
                                                                    const OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            15),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            15),
                                                                  ),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                enabledBorder:
                                                                    const OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            15),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            15),
                                                                  ),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                labelText:
                                                                    'คำอธิบาย',
                                                                labelStyle:
                                                                    const TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight:
                                                                  //     FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                      actions: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional.center,
                                          child: InkWell(
                                            child: Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(6)),
                                                // border: Border.all(
                                                //     color: Colors.grey, width: 1),

                                                // border: Border.all(
                                                //     color: Colors.grey, width: 1),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Text(
                                                'บันทึก',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                            onTap: () async {
                                              var aser = serarea;

                                              var d_start = Value_D_start;
                                              var note_aser = Form_note.text;
                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              String? ren = preferences
                                                  .getString('renTalSer');
                                              String? ser_user =
                                                  preferences.getString('ser');
                                              if (Form_note.text == '' ||
                                                  note_aser.toString() == '' ||
                                                  d_start.toString() == '' ||
                                                  aser == null ||
                                                  aser.toString() == 'null') {
                                                PanaraInfoDialog
                                                    .showAnimatedGrow(
                                                  context,
                                                  title: "Oops",
                                                  message:
                                                      "กรุณากรอกข้อมูลให้ครบถ้วน...!",
                                                  buttonText: "รับทราบ",
                                                  onTapDismiss: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.error,
                                                  barrierDismissible:
                                                      false, // optional parameter (default is true)
                                                );
                                              } else {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                var seruser = preferences
                                                    .getString('ser');
                                                var fname = preferences
                                                    .getString('fname');
                                                var lname = preferences
                                                    .getString('lname');
                                                String url =
                                                    '${MyConstant().domain}/In_c_maintenance.php?isAdd=true&ren=$ren&ser_user=$seruser&aser=$aser&d_start=$d_start';
                                                try {
                                                  var response =
                                                      await httpClient.post(
                                                          Uri.parse(url),
                                                          body: {
                                                        'aser': aser.toString(),
                                                        'd_start':
                                                            d_start.toString(),
                                                        'note_aser': note_aser
                                                            .toString(),
                                                        'snamearea':
                                                            '$fname $lname',
                                                        'custnoarea': '',
                                                      }).then((value) async {
                                                    // print('11111111......>>${value.body}');
                                                    if (value.body.toString() ==
                                                        'true') {
                                                      setState(() {
                                                        serarea = null;
                                                        lncodearea = null;
                                                        lnarea = null;
                                                        Value_D_start = null;
                                                        snamearea = null;
                                                        custnoarea = null;
                                                        Form_note.clear();
                                                        // indexdelog = 0;
                                                      });
                                                    }
                                                  });
                                                } catch (e) {}
                                                Loading_Trans_bill();
                                                Navigator.pop(context, 'OK');
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            });
                          },
                          style: ButtonStyle(
                            //  backgroundColor:
                            // MaterialStateProperty.all<
                            //     Color>(Colors.green),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 184, 37, 135)),
                          ),
                          child: Center(
                            child: Translate.TranslateAndSetText(
                                '+ แจ้งซ่อม',
                                Colors.white,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                      ),
                      Container(child: Next_page_Billpay())
                    ],
                  ),
                  const Divider(),
                  //${MONTH_Now}//${YEAR_Now}
                  // SizedBox(
                  //   width: (Responsive.isDesktop(context))
                  //       ? MediaQuery.of(context).size.width * 0.83
                  //       : MediaQuery.of(context).size.width,
                  //   child: ScrollConfiguration(
                  //       behavior: ScrollConfiguration.of(context)
                  //           .copyWith(dragDevices: {
                  //         PointerDeviceKind.touch,
                  //         PointerDeviceKind.mouse,
                  //       }),
                  //       child: SingleChildScrollView(
                  //           scrollDirection: Axis.horizontal,
                  //           child: Row(children: [
                  //             Container(
                  //               decoration: BoxDecoration(
                  //                 color: AppbackgroundColor.Sub_Abg_Colors
                  //                     .withOpacity(0.5),
                  //                 borderRadius: BorderRadius.only(
                  //                     topLeft: Radius.circular(10),
                  //                     topRight: Radius.circular(10),
                  //                     bottomLeft: Radius.circular(10),
                  //                     bottomRight: Radius.circular(10)),
                  //                 // border: Border.all(color: Colors.white, width: 1),
                  //               ),
                  //               child: Row(
                  //                 children: [],
                  //               ),
                  //             ),
                  //           ]))),
                  // ),

                  // const Divider(),
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
                            ...columnHeaders
                                .skip(1)
                                .map((column) => Expanded(
                                      flex: (column.toString() == 'รายละเอียด')
                                          ? 3
                                          : 1,
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
                                          mainAxisAlignment: ([
                                            9
                                          ].contains(columnHeaders.indexWhere(
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
                                                      TextAlign.left,
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
                            Container(
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
                                  ? Center(
                                      child: const Text(
                                        'ไม่พบข้อมูล',
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    )
                                  : (maintenanceModels.isEmpty)
                                      ? Center(
                                          child: const Text(
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
                                          controller: _scrollController2,
                                          itemCount: displayedData.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final row = displayedData[index];
                                            final columnToCheck =
                                                'เลขที่ใบวางบิล';
                                            return List_Material(
                                                index,
                                                columnHeaders,
                                                row,
                                                columnToCheck);
                                          },
                                        ),
                        ),
                      ],
                    )),
              ),
            ),
            Container(
                width: (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.85
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
                                _scrollController2.animateTo(
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
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
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
                              if (_scrollController2.hasClients) {
                                final position =
                                    _scrollController2.position.maxScrollExtent;
                                _scrollController2.animateTo(
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
                            onTap: _moveUp2,
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
                                border:
                                    Border.all(color: Colors.grey, width: 1),
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
                            onTap: _moveDown2,
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
    });
  }

  /////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Material(
      // surfaceTintColor: tappedIndex_Color
      //     .tappedIndex_Colors,
      color: tappedIndex_ == index.toString()
          ? tappedIndex_Color.tappedIndex_Colors
          : AppbackgroundColor.Sub_Abg_Colors,
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
          ...columnHeaders
              .skip(1)
              .map((column) => (columnHeaders.any((columnx) {
                    return column.toString() == 'รายละเอียด';
                  }))
                      ? Expanded(
                          flex: 3,
                          child: Row(children: [
                            (row[column]?.toString() == '' ||
                                    row[column] == null)
                                ? SizedBox()
                                : Copy_Text(
                                    context, row[column]?.toString() ?? ''),
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
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            )
                          ]))
                      : Expanded(
                          flex: 1,
                          child: AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            row[column]?.toString() ?? '',
                            textAlign: (columnHeaders.any((columnx) {
                              return column.toString() == 'จำนวนเงิน';
                            }))
                                ? TextAlign.right
                                : (columnHeaders.any((columnx) {
                                    return column.toString() == 'ช่องทางชำระ' ||
                                        column.toString() == 'เหตุผล';
                                  }))
                                    ? TextAlign.center
                                    : TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: (columnHeaders.any((columnx) {
                                  return column.toString() == 'เหตุผล';
                                }))
                                    ? Colors.red[600]
                                    : PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ))
              .toList(),
          (maintenanceModels[int.parse('${row['index']}')].st.toString() == '0')
              ? Container(
                  width: 120,
                  child: Center(
                    child: Translate.TranslateAndSet_TextAutoSize(
                        '${maintenanceModels[int.parse('${row['index']}')].data_update.toString()}',
                        // 'SCAN',
                        Colors.red,
                        TextAlign.center,
                        null,
                        Font_.Fonts_T,
                        11,
                        14,
                        1),
                  ))
              : Container(
                  width: 120,
                  child: Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            // (maintenanceModels[int.parse('${row['index']}')]
                            //             .mst
                            //             .toString() ==
                            //         '3')
                            //     ? MaterialStateProperty.all<Color>(Colors.green)
                            //     :
                            MaterialStateProperty.all<Color>(Colors.deepPurple),
                      ),
                      onPressed: (maintenanceModels[
                                      int.parse('${row['index']}')]
                                  .st
                                  .toString() ==
                              '0')
                          ? null
                          : () async {
                              await Dia_log1();
                              int index_x = int.parse('${row['index']}');
                              String Ser_ =
                                  maintenanceModels[index_x].ser.toString();

                              String because_ = Formbecause_.text.toString();
                              var formatter = DateFormat('y-MM-d');

                              setState(() {
                                tappedIndex_ = index.toString();
                                Value_selectDate = "${formatter.format(datex)}";
                                Formbecause_.text = maintenanceModels[index_x]
                                    .rdescr
                                    .toString();
                              });

                              Future.delayed(const Duration(milliseconds: 300),
                                  () async {
                                if (maintenanceModels[index_x].mst.toString() ==
                                    '3') {
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          titlePadding:
                                              const EdgeInsets.all(0.0),
                                          contentPadding:
                                              const EdgeInsets.all(10.0),
                                          actionsPadding:
                                              const EdgeInsets.all(6.0),
                                          title: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        // red_Trans_c_maintenance();
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Icon(
                                                            Icons.highlight_off,
                                                            size: 30,
                                                            color: Colors
                                                                .red[700]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'พื้นที่ : ${maintenanceModels[index_x].ln}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: ManageScreen_Color
                                                        .Colors_Text2_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                                Text(
                                                  'ผู้แจ้ง: ${maintenanceModels[index_x].sname}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: ManageScreen_Color
                                                        .Colors_Text2_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: const Divider(
                                                    color: Colors.grey,
                                                    height: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          content: SizedBox(
                                            width:
                                                (Responsive.isDesktop(context))
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.41,
                                            child: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'วันที่ดำเนินการเสร็จสิ้น : ${maintenanceModels[index_x].rdate}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          color:
                                                              ManageScreen_Color
                                                                  .Colors_Text2_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      // controller: Formbecause_,
                                                      initialValue:
                                                          maintenanceModels[
                                                                  index_x]
                                                              .rdescr
                                                              .toString(),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                        }
                                                        // if (int.parse(value.toString()) < 13) {
                                                        //   return '< 13';
                                                        // }
                                                        return null;
                                                      },
                                                      onChanged: (value) {
                                                        setState(() {
                                                          Formbecause_.text =
                                                              value.toString();
                                                        });
                                                      },
                                                      maxLines: 10,
                                                      cursorColor: Colors.green,
                                                      decoration:
                                                          InputDecoration(
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.3),
                                                              filled: true,
                                                              // prefixIcon: const Icon(Icons.water,
                                                              //     color: Colors.blue),
                                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              enabledBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              labelText:
                                                                  'คำอธิบาย',
                                                              labelStyle:
                                                                  const TextStyle(
                                                                color: ManageScreen_Color
                                                                    .Colors_Text2_,
                                                                // fontWeight:
                                                                //     FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              )),
                                                      // inputFormatters: <TextInputFormatter>[
                                                      //   // for below version 2 use this
                                                      //   FilteringTextInputFormatter.allow(
                                                      //       RegExp(r'[0-9]')),
                                                      //   // for version 2 and greater youcan also use this
                                                      //   FilteringTextInputFormatter.digitsOnly
                                                      // ],
                                                    ),
                                                  ),
                                                  // Center(
                                                  //   child: Padding(
                                                  //     padding: const EdgeInsets.all(8.0),
                                                  //     child: Text(
                                                  //       'คำอธิบาย : ${maintenanceModels[index_x].rdescr}',
                                                  //       textAlign: TextAlign.center,
                                                  //       style: const TextStyle(
                                                  //         color: ManageScreen_Color
                                                  //             .Colors_Text2_,
                                                  //         fontWeight: FontWeight.bold,
                                                  //         fontFamily: Font_.Fonts_T,
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }

                                ////////////////////-------------------------------------------------------------->
                                if (maintenanceModels[index_x].mst.toString() ==
                                        '1' ||
                                    maintenanceModels[index_x].mst.toString() ==
                                        '2')
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          titlePadding:
                                              const EdgeInsets.all(0.0),
                                          contentPadding:
                                              const EdgeInsets.all(10.0),
                                          actionsPadding:
                                              const EdgeInsets.all(6.0),
                                          title: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Icon(
                                                            Icons.highlight_off,
                                                            size: 30,
                                                            color: Colors
                                                                .red[700]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'พื้นที่ : ${maintenanceModels[index_x].ln}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: ManageScreen_Color
                                                        .Colors_Text2_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                                Text(
                                                  'ผู้แจ้ง: ${maintenanceModels[index_x].sname}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: ManageScreen_Color
                                                        .Colors_Text2_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          content: StreamBuilder(
                                              stream: Stream.periodic(
                                                  const Duration(seconds: 0)),
                                              builder: (context, snapshot) {
                                                return Container(
                                                  width: (Responsive.isDesktop(
                                                          context))
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3
                                                      : MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.41,
                                                  child: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        Row(
                                                          children: [
                                                            //_select_Date
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'วันที่ ดำเนินการ / แก้ไข :',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    _select_Date(
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: AppbackgroundColor
                                                                            .Sub_Abg_Colors,
                                                                        borderRadius: const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            topRight: Radius.circular(10),
                                                                            bottomLeft: Radius.circular(10),
                                                                            bottomRight: Radius.circular(10)),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
                                                                      ),
                                                                      // width: 120,
                                                                      padding: const EdgeInsets.all(2.0),
                                                                      child: Center(
                                                                        child:
                                                                            Text(
                                                                          (Value_selectDate == null)
                                                                              ? 'เลือก'
                                                                              : '$Value_selectDate',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                ReportScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            // controller: Formbecause_,
                                                            initialValue:
                                                                maintenanceModels[
                                                                        index_x]
                                                                    .rdescr
                                                                    .toString(),
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                              }
                                                              // if (int.parse(value.toString()) < 13) {
                                                              //   return '< 13';
                                                              // }
                                                              return null;
                                                            },
                                                            onChanged: (value) {
                                                              setState(() {
                                                                Formbecause_
                                                                        .text =
                                                                    value
                                                                        .toString();
                                                              });
                                                            },
                                                            maxLines: 10,
                                                            cursorColor:
                                                                Colors.green,
                                                            decoration:
                                                                InputDecoration(
                                                                    fillColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                    filled:
                                                                        true,
                                                                    // prefixIcon: const Icon(Icons.water,
                                                                    //     color: Colors.blue),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(15),
                                                                        topLeft:
                                                                            Radius.circular(15),
                                                                        bottomRight:
                                                                            Radius.circular(15),
                                                                        bottomLeft:
                                                                            Radius.circular(15),
                                                                      ),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(15),
                                                                        topLeft:
                                                                            Radius.circular(15),
                                                                        bottomRight:
                                                                            Radius.circular(15),
                                                                        bottomLeft:
                                                                            Radius.circular(15),
                                                                      ),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    labelText:
                                                                        'คำอธิบาย',
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    )),
                                                            // inputFormatters: <TextInputFormatter>[
                                                            //   // for below version 2 use this
                                                            //   FilteringTextInputFormatter.allow(
                                                            //       RegExp(r'[0-9]')),
                                                            //   // for version 2 and greater youcan also use this
                                                            //   FilteringTextInputFormatter.digitsOnly
                                                            // ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: const Divider(
                                                            color: Colors.grey,
                                                            height: 0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (maintenanceModels[index_x]
                                                        .mst
                                                        .toString() ==
                                                    '1')
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(4, 2, 4, 2),
                                                    child: Container(
                                                      width: 180,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          String Ser_ =
                                                              maintenanceModels[
                                                                      index]
                                                                  .ser
                                                                  .toString();

                                                          String because_ =
                                                              Formbecause_.text
                                                                  .toString();

                                                          SharedPreferences
                                                              preferences =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          var ren = preferences
                                                              .getString(
                                                                  'renTalSer');
                                                          String url =
                                                              '${MyConstant().domain}/UpC_Sta_maintenance.php?isAdd=true&ren=$ren&Ser=$Ser_&because=$because_&datex=$Value_selectDate&type=cancel';
                                                          try {
                                                            var response =
                                                                await httpClient
                                                                    .get(Uri
                                                                        .parse(
                                                                            url));
                                                            var result = json
                                                                .decode(response
                                                                    .body);
                                                            // print('-------->>>> $result');
                                                            if (result
                                                                    .toString() ==
                                                                'true') {
                                                              setState(() {
                                                                Formbecause_
                                                                    .clear();
                                                                Value_selectDate =
                                                                    null;
                                                              });
                                                            }

                                                            Loading_Trans_bill();
                                                          } catch (e) {}
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        },
                                                        child: Text(
                                                          'ยกเลิก/ปฎิเสธ',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          4, 2, 4, 2),
                                                  child: Container(
                                                    width: 180,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.orange,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        String Ser_ =
                                                            maintenanceModels[
                                                                    index]
                                                                .ser
                                                                .toString();

                                                        String because_ =
                                                            Formbecause_.text
                                                                .toString();

                                                        // print(
                                                        //   '$Ser_ //// $because_ //$Value_selectDate',
                                                        // );
                                                        if (Value_selectDate ==
                                                                null &&
                                                            because_ == '') {
                                                          PanaraInfoDialog
                                                              .showAnimatedGrow(
                                                            context,
                                                            title: "Oops",
                                                            message:
                                                                "กรุณากรอกข้อมูลให้ครบถ้วน...!",
                                                            buttonText:
                                                                "รับทราบ",
                                                            onTapDismiss:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            panaraDialogType:
                                                                PanaraDialogType
                                                                    .error,
                                                            barrierDismissible:
                                                                false, // optional parameter (default is true)
                                                          );
                                                        } else {
                                                          SharedPreferences
                                                              preferences =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          var ren = preferences
                                                              .getString(
                                                                  'renTalSer');
                                                          String url =
                                                              '${MyConstant().domain}/UpC_Sta_maintenance.php?isAdd=true&ren=$ren&Ser=$Ser_&because=$because_&datex=$Value_selectDate&type=2';
                                                          try {
                                                            var response =
                                                                await httpClient
                                                                    .get(Uri
                                                                        .parse(
                                                                            url));
                                                            var result = json
                                                                .decode(response
                                                                    .body);
                                                            // print('-------->>>> $result');
                                                            if (result
                                                                    .toString() ==
                                                                'true') {
                                                              setState(() {
                                                                Formbecause_
                                                                    .clear();
                                                                Value_selectDate =
                                                                    null;
                                                              });
                                                            }

                                                            Loading_Trans_bill();
                                                          } catch (e) {}
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        }
                                                      },
                                                      child: Text(
                                                        (maintenanceModels[
                                                                        index_x]
                                                                    .mst
                                                                    .toString() ==
                                                                '2')
                                                            ? 'อัพเดตข้อมูล'
                                                            : 'แจ้งกำลังดำเนินการ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (maintenanceModels[index_x]
                                                        .mst
                                                        .toString() ==
                                                    '2')
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(4, 2, 4, 2),
                                                    child: Container(
                                                      width: 180,
                                                      decoration: BoxDecoration(
                                                        color: (maintenanceModels[
                                                                        index_x]
                                                                    .mst
                                                                    .toString() ==
                                                                '2')
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextButton(
                                                        onPressed: (maintenanceModels[
                                                                        index_x]
                                                                    .mst
                                                                    .toString() ==
                                                                '1')
                                                            ? null
                                                            : () async {
                                                                String Ser_ =
                                                                    maintenanceModels[
                                                                            index]
                                                                        .ser
                                                                        .toString();

                                                                String
                                                                    because_ =
                                                                    Formbecause_
                                                                        .text
                                                                        .toString();

                                                                // print(
                                                                //   '$Ser_ //// $because_ //$Value_selectDate',
                                                                // );
                                                                if (Value_selectDate ==
                                                                        null &&
                                                                    because_ ==
                                                                        '') {
                                                                  PanaraInfoDialog
                                                                      .showAnimatedGrow(
                                                                    context,
                                                                    title:
                                                                        "Oops",
                                                                    message:
                                                                        "กรุณากรอกข้อมูลให้ครบถ้วน...!",
                                                                    buttonText:
                                                                        "รับทราบ",
                                                                    onTapDismiss:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    panaraDialogType:
                                                                        PanaraDialogType
                                                                            .error,
                                                                    barrierDismissible:
                                                                        false, // optional parameter (default is true)
                                                                  );
                                                                } else {
                                                                  SharedPreferences
                                                                      preferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  var ren = preferences
                                                                      .getString(
                                                                          'renTalSer');
                                                                  String url =
                                                                      '${MyConstant().domain}/UpC_Sta_maintenance.php?isAdd=true&ren=$ren&Ser=$Ser_&because=$because_&datex=$Value_selectDate&type=3';
                                                                  try {
                                                                    var response =
                                                                        await httpClient
                                                                            .get(Uri.parse(url));
                                                                    var result =
                                                                        json.decode(
                                                                            response.body);
                                                                    // print('-------->>>> $result');
                                                                    if (result
                                                                            .toString() ==
                                                                        'true') {
                                                                      setState(
                                                                          () {
                                                                        Formbecause_
                                                                            .clear();
                                                                        Value_selectDate =
                                                                            null;
                                                                      });
                                                                    }
                                                                    red_Trans_c_maintenance();
                                                                    Navigator.pop(
                                                                        context,
                                                                        'OK');
                                                                  } catch (e) {}
                                                                }
                                                              },
                                                        child: const Text(
                                                          'ยืนยันการแก้ไข/ปิดงาน',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          ],
                                        );
                                      });
                              });
                            },
                      child: Translate.TranslateAndSet_TextAutoSize(
                          (maintenanceModels[int.parse('${row['index']}')]
                                      .mst
                                      .toString() ==
                                  '3')
                              ? 'เรียกดูข้อมูล'
                              : (maintenanceModels[int.parse('${row['index']}')]
                                          .mst
                                          .toString() ==
                                      '2')
                                  ? 'อัพเดตข้อมูล'
                                  : (maintenanceModels[
                                                  int.parse('${row['index']}')]
                                              .st
                                              .toString() ==
                                          '0')
                                      ? 'ถูกยกเลิก'
                                      : 'แจ้งดำเดินการ',
                          // 'SCAN',
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
        ]),
      ),
    );
  }

  /////////////---------------------------------------------------->

  Dia_log1() {
    return showDialog(
        barrierDismissible: false,
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
}
