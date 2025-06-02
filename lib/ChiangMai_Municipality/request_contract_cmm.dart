import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AdminScaffold/AdminScaffold.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/view_pagenow.dart';
import 'List_CMM/list_cmm.dart';
import 'Model/Document_Model.dart';
import 'Model/Review_Model.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/EncryptText.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';
import 'unity/FormatPhone.dart';
import 'unity/SecurePrefs_helper.dart';

class RequestContract_CMM extends StatefulWidget {
  const RequestContract_CMM({super.key});

  @override
  State<RequestContract_CMM> createState() => _RequestContract_CMMState();
}

class _RequestContract_CMMState extends State<RequestContract_CMM> {
  //-------------------------------------->
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  var nFormat3 = NumberFormat("#,##0", "en_US");
  DateTime datex = DateTime.now();
  //-------------------------------------->
  final TextEditingController Dropdown_Controller_zone_Sub =
      TextEditingController();
  final TextEditingController Dropdown_Controller = TextEditingController();
  ////////////--------------------
  List<ZoneModel> zoneModels = [];
  List<SubZoneModel> subzoneModels = [];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> ac7 = [];

  List<int> Fix_data = [4, 5, 6];
  //-------------------------------------->

  // ตัวแปรสำหรับการค้นหา
  String searchQuery = "";
  //-------------------------------------->
  // Pagination
  int currentPage_1 = 0;
  bool firstRound = true;
  bool showDuplicatesOnly = false;
  bool showDubiousOnly = false;
  static const int rowsPerPage_1 = 50;
  //-------------------------------------->
  // ตัวแปรสำหรับการจัดเรียง
  bool sortAscending = true;
  String sortColumn = "รหัสพื้นที่";
  //-------------------------------------->
  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;
  //-------------------------------------->
  String Ser_nowpage = '3';
  String tappedIndex_ = '';
  String? zone_Subser, zone_Subname, zone_ser, zone_name;
  List<Map<String, dynamic>> title_data = [];
  int ser_tap = 1;
  ////////////--------------------->
  @override
  void initState() {
    super.initState();
    Loading_Trans_bill();
    addAcListTitle();
    read_GC_Sub_zone();
    read_GC_zone();
  }

  ////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1

      title_data.addAll(CMMListTitle().data_tap);
    });
  }

  where_ac7(String ser) {
    if (title_data
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    loadClientReviews().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
        AddDaTa();
      });
    });
  }

  List<ReviewModel> reviewModels = [];

  Future<void> loadClientReviews() async {
    print('loadClientReviews');
    final response = await read_GC_Reviews();
    if (response != null && response.statusCode == 200) {
      final jsonMap = json.decode(response.body);

      if (jsonMap['data'] is List) {
        final List<dynamic> dataList = jsonMap['data'];

        setState(() {
          reviewModels = dataList.map((e) => ReviewModel.fromJson(e)).toList();
        });
      } else {
        print('❌ "data" ไม่ใช่ List');
      }
    }
  }

  ////////-------------------------------------------------------->

  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();
    print('${reviewModels.length}');
    // print(transMeterModels.length);
    // Check if contractxPakanModels is not empty
    if (reviewModels.isNotEmpty) {
      setState(() {
        data = List.generate(reviewModels.length, (index) {
          final review = reviewModels[index];
          return {
            "index": "$index",
            // "โซนพื้นที่": zn,
            "เลขที่สัญญา-เดิม": review.newRequest.leaseNumber ?? "-",
            "บริเวณ": review.newRequest.zn ?? "",
            "โซนพื้นที่": review.newRequest.zn ?? "",
            "รหัสพื้นที่": review.newRequest.ln ?? "",
            "ชื่อผู้ติดต่อ": review.client.scname ?? "",
            "เบอร์โทรติดต่อ": formatPhoneNumber('${review.client.tel}'),
            // review.client.tel ?? "",
            "วันที่สิ้นสุดสัญญา": formatDate(review.newRequest.ldate ?? "",
                type: DateFormatType.dmy),
            "สถานะ": review.status ?? "",
          };
        });

        filteredData = data;
      });
    } else {
      setState(() {
        // final prevMonthDate = DateTime(
        //   datex.year,
        //   datex.month - 1,
        //   datex.day,
        // );

        // final prevMonthLabel = DateFormat.MMM('th_TH').format(prevMonthDate);
        // final currMonthLabel = DateFormat.MMM('th_TH').format(datex);
        data = List.generate(1, (index) {
          return {
            "index": "",
            // "โซนพื้นที่": zn,
            "เลขที่สัญญา-เดิม": "",
            "บริเวณ": "",
            "โซนพื้นที่": "",
            "รหัสพื้นที่": "",
            "ชื่อผู้ติดต่อ": "",
            "เบอร์โทรติดต่อ": "",
            "วันที่สิ้นสุดสัญญา": "",
            "สถานะ": "",
          };
        });

        filteredData = data;
      });
    }
    // print('data.length');
    // print(data.length);
    // print("Data added: $data");
  }

  ////////////----------------------------------->
  Future<Null> read_GC_Sub_zone() async {
    if (subzoneModels.length != 0) {
      setState(() {
        subzoneModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      Map<String, dynamic> map = Map();
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
    } catch (e) {}
  }

  ///////////------------------------------------>
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      zoneModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var zoneSubSer = preferences.getString('zoneSubSer');
    var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['rser'] = '0';
      map['zn'] = 'ทั้งหมด';
      map['qty'] = '0';
      map['img'] = '0';
      map['data_update'] = '0';

      ZoneModel zoneModelx = ZoneModel.fromJson(map);

      setState(() {
        zoneModels.add(zoneModelx);
      });

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        var sub = zoneModel.sub_zone;
        setState(() {
          if (zoneSubSer == null || zoneSubSer == '0') {
            zoneModels.add(zoneModel);
          } else {
            if (sub == zoneSubSer) {
              zoneModels.add(zoneModel);
            }
          }
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
    } catch (e) {}
    setState(() {
      zone_ser = preferences.getString('zonePSer');
      zone_name = preferences.getString('zonesPName');
      zone_Subser = preferences.getString('zoneSubSer');
      zone_Subname = preferences.getString('zonesSubName');
    });
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
  Widget Next_page_Miter() {
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
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

/////////////----------------------------------------------------------->

  @override
  Widget build(BuildContext context) {
    double calculatedWidth = (Responsive.isDesktop(context))
        ? MediaQuery.of(context).size.width * 0.85
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
//////////---------------------------->
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: viewpage(context, '$Ser_nowpage'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppbackgroundColor.TiTile_Box,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        // border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        children: [
                          subzoneModels.length == 1
                              ? SizedBox()
                              : MediaQuery.of(context).size.shortestSide <
                                      MediaQuery.of(context).size.width * 1
                                  ? Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Translate.TranslateAndSetText(
                                          'โซน:',
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                          TextAlign.center,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          16,
                                          1),
                                    )
                                  : const SizedBox(),
                          subzoneModels.length == 1
                              ? SizedBox()
                              : Expanded(
                                  flex: MediaQuery.of(context)
                                              .size
                                              .shortestSide <
                                          MediaQuery.of(context).size.width * 1
                                      ? 2
                                      : 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      width: 200,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                            isExpanded: true,
                                            searchController:
                                                Dropdown_Controller_zone_Sub,
                                            searchInnerWidget: Container(
                                              // width: 200,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[100]!
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              child: TextFormField(
                                                expands: true,
                                                maxLines: null,
                                                controller:
                                                    Dropdown_Controller_zone_Sub,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                                  hintText: 'Search...',
                                                  // fillColor: Colors.red[300],
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            hint: (zone_Subname == null)
                                                ? Translate.TranslateAndSetText(
                                                    'ทั้งหมด',
                                                    SettingScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    null,
                                                    Font_.Fonts_T,
                                                    14,
                                                    1)
                                                : Text(
                                                    zone_Subname == null
                                                        ? 'ทั้งหมด'
                                                        : '$zone_Subname',
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TextHome_Color
                                                  .TextHome_Colors,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontFamily: Font_.Fonts_T),
                                            iconSize: 30,
                                            buttonHeight: 35,
                                            dropdownDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            items: subzoneModels
                                                .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          '${item.ser},${item.zn}',
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.zn!,
                                                            maxLines: 2,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          Divider(
                                                            color: Colors
                                                                .grey[300],
                                                            height: 4.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),

                                            // value: selectedValue,
                                            onChanged: (value) async {
                                              var zones = value!.indexOf(',');
                                              var zoneSer =
                                                  value.substring(0, zones);
                                              var zonesName =
                                                  value.substring(zones + 1);
                                              // print(
                                              //     'mmmmm ${zoneSer.toString()} $zonesName');

                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              preferences.setString(
                                                  'zoneSubSer',
                                                  zoneSer.toString());
                                              preferences.setString(
                                                  'zonesSubName',
                                                  zonesName.toString());
                                              preferences.remove("zoneSer");
                                              preferences.remove("zonesName");
                                              preferences.remove("zonePSer");
                                              preferences.remove("zonesPName");

                                              String? _route = preferences
                                                  .getString('route');
                                              MaterialPageRoute
                                                  materialPageRoute =
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          AdminScafScreen(
                                                              route: _route));
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  materialPageRoute,
                                                  (route) => false);
                                            },
                                            searchMatchFn: (item, searchValue) {
                                              return item.value
                                                  .toString()
                                                  .contains(searchValue);
                                            },
                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                Dropdown_Controller_zone_Sub
                                                    .clear();
                                              }
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Translate.TranslateAndSetText(
                                'โซนพื้นที่เช่า:',
                                PeopleChaoScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                16,
                                1),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                width: 150,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                      isExpanded: true,
                                      searchController: Dropdown_Controller,
                                      searchInnerWidget: Container(
                                        // width: 200,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red[100]!.withOpacity(0.5),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: Dropdown_Controller,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search...',
                                            // fillColor: Colors.red[300],
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      hint: (zone_name == null)
                                          ? Translate.TranslateAndSetText(
                                              'ทั้งหมด',
                                              PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              16,
                                              1)
                                          : Text(
                                              zone_name == null
                                                  ? 'ทั้งหมด'
                                                  : '$zone_name',
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: TextHome_Color.TextHome_Colors,
                                      ),
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontFamily: Font_.Fonts_T),
                                      iconSize: 30,
                                      buttonHeight: 35,
                                      dropdownDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      items: zoneModels
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: '${item.ser},${item.zn}',
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.zn!,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                    Divider(
                                                      color: Colors.grey[300],
                                                      height: 4.0,
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),

                                      // value: selectedValue,

                                      onChanged: (value) async {
                                        var zones = value!.indexOf(',');
                                        var zoneSer = value.substring(0, zones);
                                        var zonesName =
                                            value.substring(zones + 1);
                                        // print(
                                        //     'mmmmm ${zoneSer.toString()} $zonesName');

                                        SharedPreferences preferences =
                                            await SharedPreferences
                                                .getInstance();
                                        preferences.setString(
                                            'zonePSer', zoneSer.toString());
                                        preferences.setString(
                                            'zonesPName', zonesName.toString());

                                        preferences.setString(
                                            'zoneSer', zoneSer.toString());
                                        preferences.setString(
                                            'zonesName', zonesName.toString());

                                        String? _route =
                                            preferences.getString('route');
                                        MaterialPageRoute materialPageRoute =
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        AdminScafScreen(
                                                            route: _route));
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            materialPageRoute,
                                            (route) => false);
                                      },
                                      searchMatchFn: (item, searchValue) {
                                        return item.value
                                            .toString()
                                            .contains(searchValue);
                                      },
                                      onMenuStateChange: (isOpen) {
                                        if (!isOpen) {
                                          Dropdown_Controller.clear();
                                        }
                                      }),
                                ),
                              ),
                            ),
                          ),
                          if (subzoneModels.length == 1 &&
                              (Responsive.isDesktop(context)))
                            Expanded(flex: 6, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                        // color: AppbackgroundColor.TiTile_Box,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        // border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Translate.TranslateAndSetText(
                              'สถานะ : ',
                              AccountScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              16,
                              1),
                          // for (var item in title_data)
                          for (var entry in title_data.asMap().entries)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                              child: SizedBox(
                                height: 30,
                                // width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        topRight: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                        bottomRight: Radius.circular(7),
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                    ),
                                    backgroundColor: (ser_tap == entry.key + 1)
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade300,
                                  ),
                                  onPressed: () async {
                                    int index = entry.key;
                                    setState(() {
                                      ser_tap = index + 1;
                                    });
                                    // SharedPreferences preferences =
                                    //     await SharedPreferences.getInstance();
                                    // String? _route =
                                    //     preferences.getString('route');
                                    // MaterialPageRoute materialPageRoute =
                                    //     MaterialPageRoute(
                                    //         builder: (BuildContext context) =>
                                    //             AdminScafScreen(
                                    //                 route:
                                    //                     '${entry.value['page']}'));
                                    // Navigator.pushAndRemoveUntil(context,
                                    //     materialPageRoute, (route) => false);
                                  },
                                  child: Translate.TranslateAndSet_TextAutoSize(
                                      '${entry.value['title']} (${entry.value['total']})' ??
                                          '',
                                      (ser_tap == entry.key + 1)
                                          ? Colors.white
                                          : Colors.black,
                                      TextAlign.center,
                                      null,
                                      FontWeight_.Fonts_T,
                                      11,
                                      13,
                                      1),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  // if ((item['title'] as List).isNotEmpty) ...[
                  //   Row(
                  //     children: [
                  //       Text(item['title'] ?? '',
                  //           style: TextStyle(fontWeight: FontWeight.bold)),
                  //     ],
                  //   ),
                  //   for (var sub in item['detailsub'] as List)
                  //     Row(
                  //       children: [
                  //         Text((sub as Map<String, dynamic>)['titlesub'] ?? '')
                  //       ],
                  //     ),
                  // ]
                ],
              ),
            ), // ช่องค้นหา
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
                              : (1 != 1)
                                  // (filteredData.isEmpty)
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
                      Container(child: Next_page_Miter())
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
                    height: MediaQuery.of(context).size.height / 1.35,
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
                            ...columnHeaders
                                .skip(1)
                                .map((column) => Expanded(
                                      flex: (column.toString() == 'รายละเอียด')
                                          ? 1
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
                                              child: Translate.TranslateAndSetText(
                                                  column,
                                                  AccountScreen_Color
                                                      .Colors_Text1_,
                                                  (column.toString() ==
                                                              'หน่วยที่ใช้' ||
                                                          column.toString() ==
                                                              'ราคาต่อหน่วย' ||
                                                          column.toString() ==
                                                              'รวม Vat')
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  13.8,
                                                  1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
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
                                  : (filteredData.isEmpty)
                                      // (transMeterModels.isEmpty)
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
                                            final columnToCheck = 'รายการ';
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
                            onTap: _moveUp1,
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
          ],
        ),
      ),
    );
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
          border: (showDuplicatesOnly == true || showDubiousOnly == true)
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
        ),
        child: Row(children: [
          Container(
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
                      MaterialStateProperty.all<Color>(
                    Colors.grey.shade900,
                  ),
                ),
                onPressed: () async {
                  // await dotenv.load();
                  await Dia_log1();
                  int index_x = int.parse('${row['index']}');
                  // ✅ บันทึก (เข้ารหัสก่อน)

                  await SecurePrefs.setEncrypted(SecurePrefsType.UuidRequest,
                      '${reviewModels[index_x].newRequest.requestUuid}');

                  MaterialPageRoute materialPageRoute = MaterialPageRoute(
                      builder: (BuildContext context) => AdminScafScreen(
                          route: '${title_data[ser_tap - 1]['page']}'));
                  Navigator.pushAndRemoveUntil(
                      context, materialPageRoute, (route) => false);
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
          ...columnHeaders
              .skip(1)
              .map((column) => (columnHeaders.any((columnx) {
                    return column.toString() == 'เลขที่สัญญา-เดิม' &&
                        row[column]?.toString() != 'new';
                  }))
                      ? Expanded(
                          flex: 1,
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
                                  minFontSize: 11,
                                  maxFontSize: 15,
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
                          flex: ([6, 7].contains(columnHeaders
                                  .indexWhere((item) => item == column)))
                              ? 1
                              : 1,
                          child: AutoSizeText(
                            minFontSize: 11,
                            maxFontSize: 15,
                            maxLines: 1,
                            row[column]?.toString() ?? '',
                            textAlign:
                                //  (columnHeaders.any((columnx) {
                                //   return column.toString() == '';
                                // }))
                                //     ? TextAlign.right
                                //     :
                                TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color:
                                    // (columnHeaders.any((columnx) {
                                    //   return column.toString() == 'สถานะ';
                                    // }))
                                    //     ? Colors.red[600]
                                    //     :
                                    PeopleChaoScreen_Color.Colors_Text2_,
                                fontWeight:
                                    //  (columnHeaders.any((columnx) {
                                    //   return column.toString() == 'สถานะ';
                                    // }))
                                    //     ? FontWeight.bold
                                    //     :
                                    null,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ))
              .toList(),
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

  Dia_log2() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          return Dialog(
            child: SizedBox(
              height: 20,
              width: 80,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset(
                  "images/gif-LOGOchao.gif",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 80,
                ),
              ),
            ),
          );
        });
  }

  ///////////--------------------------------->
}
