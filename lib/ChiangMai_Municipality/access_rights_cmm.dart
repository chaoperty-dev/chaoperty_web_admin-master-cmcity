import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/Enum.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetPerMission_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/view_pagenow.dart';
import 'List_CMM/list_cmm.dart';
import 'Model/Payments_Model.dart';
import 'Model/Permission_Model.dart';
import 'Model/User_ModelCMM.dart';
import 'unity/API_permission.dart';
import 'unity/API_user.dart';
import 'unity/ReusableSignaturePad.dart';

class AccessRights_CMM extends StatefulWidget {
  const AccessRights_CMM({super.key});

  @override
  State<AccessRights_CMM> createState() => _AccessRights_CMMState();
}

class _AccessRights_CMMState extends State<AccessRights_CMM> {
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  var nFormat3 = NumberFormat("#,##0", "en_US");
  DateTime datex = DateTime.now();
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  // List<Map<String, String>> ac7 = [];

  List<int> Fix_data = [4, 5, 6];
  //-------------------------------------->
  List<Map<String, dynamic>> title_data = [];
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

  ScrollController _scrollController1 = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final FormName_text = TextEditingController();
  final FormLname_text = TextEditingController();
  final FormTel_text = TextEditingController();
  final FormEmail_text = TextEditingController();
  final FormTax_text = TextEditingController();
  List<Map<String, dynamic>> data_title = [];
  List<PermissionModelCMM> permissionModel = [];
  List<PositionsAll> positionsAllModel = [];
  int? positionsId;
  final selectedSer = <dynamic>[]; // 1. ประกาศ controller
  PositionsAll? Dropdown_initialItem;

  @override
  void initState() {
    read_GC_permission();
    addAcListTitle();
    Loading_Trans_bill();
    red_Permission();
    super.initState();
  }

  List<RolesAll> rolesAllModel = [];
  List<RolesAll> _list = [];
  ////////-------------------------------------------------------->
  Future<void> red_Permission() async {
    final positionsall = await readPositions(PermissionType.positions_all);
    final rolesall = await readRoles(PermissionType.roles_all);

    if (positionsall.isNotEmpty) {
      setState(() {
        positionsAllModel = positionsall;
      });
    } else {
      print('⚠️ ไม่มีข้อมูล positionsAllModel');
    }

    if (rolesall.isNotEmpty) {
      setState(() {
        rolesAllModel = rolesall;
        _list.addAll(rolesall); // ✅ Corrected this line
        checkedStates = List.filled(rolesall.length, false); // ✅ Safe setup
      });
    } else {
      print('⚠️ ไม่มีข้อมูล rolesAllModel');
      setState(() {
        rolesAllModel = [];
        _list = [];
        checkedStates = [];
      });
    }

    print('📥 positionsall Loaded: ${positionsAllModel.length} รายการ');
    print('📥 rolesall Loaded: ${rolesall.length} รายการ');
  }

  ////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1

      title_data.addAll(CMMListTitle().data_title_AccessRights);
    });
    setState(() {
      data_title = [
        {
          "ser": "1",
          "title": "คำนำหน้า",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.text,
        },
        {
          "ser": "2",
          "title": "ชื่อ",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.text,
        },
        {
          "ser": "3",
          "title": "นามสกุล",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.text,
        },
        {
          "ser": "4",
          "title": "เบอร์โทร",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.number,
        },
        {
          "ser": "5",
          "title": "อีเมล",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.text,
        },
        {
          "ser": "6",
          "title": "เลขบัตรประชาชน",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.number,
        },
        {
          "ser": "7",
          "title": "username",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.text,
        },
        {
          "ser": "8",
          "title": "password",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.number,
        },
        {
          "ser": "9",
          "title": "password",
          "controller": TextEditingController(),
          "keyboardType": TextInputType.number,
        },
      ];
    });
  }

  where_AccessRights(String ser) {
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
    red_User().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
        AddDaTa();
      });
    });
  }

  List<UserModelCMM> usermodel = [];
  List<UserModelCMM> userUuidData = [];
  ////////-------------------------------------------------------->
  Future<void> red_User() async {
    final result = await read_GC_UserCMM();
    print('📥 User Loaded: ${result.length} รายการ');
    print('📦 red_User: ${json.encode(result)}');
    if (result.isNotEmpty) {
      setState(() {
        usermodel = result;
      });
    } else {
      print('⚠️ ไม่มีข้อมูลUser');
    }
    print('length red_User: ${usermodel.length}');
  }

  ////////-------------------------------------------------------->

  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();
    print('transMeterModels.length');
    // print(transMeterModels.length);
    // Check if contractxPakanModels is not empty
    if (usermodel.isNotEmpty) {
      setState(() {
        data = List.generate(usermodel.length, (index) {
          final user = usermodel[index];

          return {
            "index": "$index",
            "ชื่อผู้ใช้": user.username ?? "-",
            "อีเมล": user.email ?? "-",
            "ตำแหน่ง": user.positions != null && user.positions!.isNotEmpty
                ? user.positions!.first.nameTh
                : "-",
            "สิทธิ์การเข้าถึง": user.roles != null && user.roles!.isNotEmpty
                ? user.roles!.first.nameTh
                : "-",
            "ลำดับการลงลายมือชื่อ": user.roles != null && user.roles!.isNotEmpty
                ? user.roles!.first.level.toString()
                : "-",
            // "จัดการ": "..."
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
            "ชื่อผู้ใช้": "",
            "อีเมล": "",
            "ตำแหน่ง": "",
            "สิทธิ์การเข้าถึง": "",
            "ลำดับการลงลายมือชื่อ": "",
            // "จัดการ": ""
          };
        });

        filteredData = data;
      });
    }
    // print('data.length');
    // print(data.length);
    // print("Data added: $data");
  }

  ////////--------------------------------------------------------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
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

  List<PerMissionModel> perMissionModels = [];
  late List<bool> checkedStates;
  // List<PerMissionModel> _list = [];
  Future<Null> read_GC_permission() async {
    if (perMissionModels.length != 0) {
      setState(() {
        perMissionModels.clear();
      });
    }

    String url = '${MyConstant().domain}/GC_permissionAll.php?isAdd=true';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      for (var map in result) {
        PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
        setState(() {
          perMissionModels.add(perMissionModel);
          // _list.add(PerMissionModel(
          //   ser: perMissionModel.ser,
          //   perm: perMissionModel.perm,
          // ));
        });
      }
    } catch (e) {}

    // for (var payment in perMissionModels) {
    //   _list.add(PerMissionModel(
    //     ser: payment.ser,
    //     perm: payment.perm,
    //   ));
    // }
  }
// List<PerMissionModel> perMissionModels = []; // ข้อมูลของคุณ

  @override
  Widget build(BuildContext context) {
    double calculatedWidth = MediaQuery.of(context).size.width * 0.84;
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
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Translate.TranslateAndSetText(
                    'ผู้ใช้งานระบบ',
                    SettingScreen_Color.Colors_Text1_,
                    TextAlign.left,
                    FontWeight.bold,
                    FontWeight_.Fonts_T,
                    16,
                    1),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    Edit_userAcess('เพิ่มผู้ใช้', 0, 1, 'UsersUuid');
                    // // print('000 >>> $pkuser >>> $countarae');
                    // if (countarae! < pkuser!) {
                    //   Add_userAcess();
                    //   // print('1111 >>> $pkuser >>> $countarae');
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Translate.TranslateAndSetText(
                    //           'จำนวนผู้ใช้งานสูงสุดแล้วหากต้องการเพิ่มผู้ใช้งานกรุณา ซื้อ Package เพิ่ม !!!',
                    //           Colors.white,
                    //           TextAlign.left,
                    //           FontWeight.bold,
                    //           FontWeight_.Fonts_T,
                    //           16,
                    //           1),
                    //     ),
                    //   );
                    //   // print('2222 >>> $pkuser >>> $countarae');
                    // }
                    // // Add_userAcess();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      // border: Border.all(
                      //     color: Colors.grey, width: 1),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSetText(
                        '+ เพิ่ม',
                        Colors.white,
                        TextAlign.left,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        16,
                        1),
                  ),
                ),
              ),
              // Container(
              //   width: 150,
              //   child: _searchBar(),
              // )
            ],
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
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'เลขที่ใบเสร็จ' ||
                                          column.toString() == 'เลขที่สัญญา';
                                    }))
                                        ? 2
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
                                                          'ยอดสุทธิ';
                                                    }))
                                                        ? TextAlign.right
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
                            width: 80,
                            child: Translate.TranslateAndSetText(
                                'จัดการ',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                          SizedBox(
                            width: 80,
                            child: Translate.TranslateAndSetText(
                                'ลายเซ็นต์',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                          // SizedBox(
                          //   width: 110,
                          //   height: 20,
                          // )
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
                                      final columnToCheck = 'เลขที่ใบเสร็จ';
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

  String signaturesUrl = '';
  /////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Material(
      // surfaceTintColor: tappedIndex_Color
      //     .tappedIndex_Colors,
      color: AppbackgroundColor.Sub_Abg_Colors,
      child: InkWell(
        hoverColor: Colors.grey[350]!.withOpacity(0.5),
        // onTap: () async {
        //   await Dia_log1(context);
        //   final indexX = int.tryParse('${row['index']}');
        //   if (indexX == null) return;

        //   final user = usermodel[indexX];
        //   final usersUuid = user.profile?.usersUuid;
        //   if (usersUuid == null) return;

        //   final response = await read_GC_UserUuidCMM(usersUuid);
        //   final jsonRes = json.decode(response!.body);
        //   final data = jsonRes['data'];

        //   final profile = data['profile'] ?? {};
        //   final email = data['email'] ?? '';
        //   final username = data['username'] ?? '';
        //   final positionId =
        //       int.tryParse(data['positions'][0]['id'].toString());

        //   if (positionId == null) return;

        //   final selectedPosition = positionsAllModel.firstWhere(
        //     (e) => e.id == positionId,
        //     orElse: () => positionsAllModel.first,
        //   );

        //   /// 📝 อัปเดตฟอร์มข้อมูลผู้ใช้
        //   final controller =
        //       (int i) => data_title[i]['controller'] as TextEditingController;
        //   setState(() {
        //     controller(0).text = profile['prefix'] ?? '';
        //     controller(1).text = profile['first_name'] ?? '';
        //     controller(2).text = profile['last_name'] ?? '';
        //     controller(3).text = profile['phone'] ?? '';
        //     controller(4).text = email;
        //     controller(5).text = profile['citizen_id'] ?? '';
        //     controller(6).text = username;
        //     controller(7).text = '';
        //     controller(8).text = '';

        //     positionsId = positionId;
        //     Dropdown_initialItem = selectedPosition;

        //     /// 🧩 อัปเดตสิทธิ์ที่เปิดใช้งาน (st = 1)
        //     for (var role in selectedPosition.roles ?? []) {
        //       final match = rolesAllModel.firstWhere(
        //         (r) => r.id == role.id,
        //         orElse: () => RolesAll(),
        //       );
        //       match.st = role.enabled == true ? 1 : 0;
        //       print('🎯 Role: ${role.nameTh}, enabled: ${role.enabled}');
        //     }

        //     rolesAllModel.sort((a, b) => (b.st ?? 0).compareTo(a.st ?? 0));
        //   });
        //   final roleList = data['roles'] as List;

        //   setState(() {
        //     checkedStates = List.filled(rolesAllModel.length, false);

        //     for (var role in roleList) {
        //       final roleId = role['id'];
        //       final index = rolesAllModel.indexWhere((r) => r.id == roleId);
        //       if (index != -1) {
        //         checkedStates[index] = true;
        //       }
        //     }
        //     signaturesUrl = (jsonRes['data']['signatures'] != null &&
        //             jsonRes['data']['signatures'].isNotEmpty &&
        //             jsonRes['data']['signatures'][0]['uuid'] != null)
        //         ? '${MyConstant().domain_v1}/admin/users/signatures/${jsonRes['data']['signatures'][0]['uuid']}/preview'
        //         : '';
        //   });

        //   /// 📋 แสดงหน้าฟอร์มแก้ไข
        //   Future.delayed(const Duration(milliseconds: 300), () {
        //     Edit_userAcess('แก้ไขข้อมูลผู้ใช้', indexX);
        //   });
        // },
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
                      return column.toString() == 'เลขที่สัญญา' ||
                          column.toString() == 'เลขที่ใบเสร็จ';
                    }))
                        ? Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่ใบเสร็จ' ||
                                  column.toString() == 'เลขที่สัญญา';
                            }))
                                ? 2
                                : 1,
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
                                    textAlign: (columnHeaders.any((columnx) {
                                      return column.toString() == 'ยอดสุทธิ';
                                    }))
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            (column.toString() == 'ยอดสุทธิ' &&
                                                    row[column]?.toString() ==
                                                        '0.00')
                                                ? Colors.red[600]
                                                : PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              )
                            ]))
                        : Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่ใบเสร็จ' ||
                                  column.toString() == 'เลขที่ใบเสร็จ';
                            }))
                                ? 2
                                : 1,
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              row[column]?.toString() ?? '',
                              textAlign: (columnHeaders.any((columnx) {
                                return column.toString() == 'ยอดสุทธิ';
                              }))
                                  ? TextAlign.right
                                  : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: (column.toString() == 'ยอดสุทธิ' &&
                                          row[column]?.toString() == '0.00')
                                      ? Colors.red[600]
                                      : PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ))
                .toList(),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: 80,
                height: 25,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green.shade400,
                    ),
                  ),
                  onPressed: () async {
                    await Dia_log1(context);
                    final indexX = int.tryParse('${row['index']}');
                    if (indexX == null) return;

                    final user = usermodel[indexX];
                    final usersUuid = user.profile?.usersUuid;
                    if (usersUuid == null) return;

                    final response = await read_GC_UserUuidCMM(usersUuid);
                    final jsonRes = json.decode(response!.body);
                    final data = jsonRes['data'];

                    final profile = data['profile'] ?? {};
                    final email = data['email'] ?? '';
                    final username = data['username'] ?? '';
                    final positionId =
                        int.tryParse(data['positions'][0]['id'].toString());

                    if (positionId == null) return;

                    final selectedPosition = positionsAllModel.firstWhere(
                      (e) => e.id == positionId,
                      orElse: () => positionsAllModel.first,
                    );

                    /// 📝 อัปเดตฟอร์มข้อมูลผู้ใช้
                    final controller = (int i) =>
                        data_title[i]['controller'] as TextEditingController;
                    setState(() {
                      controller(0).text = profile['prefix'] ?? '';
                      controller(1).text = profile['first_name'] ?? '';
                      controller(2).text = profile['last_name'] ?? '';
                      controller(3).text = profile['phone'] ?? '';
                      controller(4).text = email;
                      controller(5).text = profile['citizen_id'] ?? '';
                      controller(6).text = username;
                      controller(7).text = '';
                      controller(8).text = '';

                      positionsId = positionId;
                      Dropdown_initialItem = selectedPosition;

                      /// 🧩 อัปเดตสิทธิ์ที่เปิดใช้งาน (st = 1)
                      for (var role in selectedPosition.roles ?? []) {
                        final match = rolesAllModel.firstWhere(
                          (r) => r.id == role.id,
                          orElse: () => RolesAll(),
                        );
                        match.st = role.enabled == true ? 1 : 0;
                        print(
                            '🎯 Role: ${role.nameTh}, enabled: ${role.enabled}');
                      }

                      rolesAllModel
                          .sort((a, b) => (b.st ?? 0).compareTo(a.st ?? 0));
                    });
                    final roleList = data['roles'] as List;

                    setState(() {
                      checkedStates = List.filled(rolesAllModel.length, false);

                      for (var role in roleList) {
                        final roleId = role['id'];
                        final index =
                            rolesAllModel.indexWhere((r) => r.id == roleId);
                        if (index != -1) {
                          checkedStates[index] = true;
                        }
                      }
                      signaturesUrl = (jsonRes['data']['signatures'] != null &&
                              jsonRes['data']['signatures'].isNotEmpty &&
                              jsonRes['data']['signatures'][0]['uuid'] != null)
                          ? '${MyConstant().domain_v1}/admin/users/signatures/${jsonRes['data']['signatures'][0]['uuid']}/preview'
                          : '';
                    });
                    print(signaturesUrl);

                    /// 📋 แสดงหน้าฟอร์มแก้ไข
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Edit_userAcess('แก้ไขข้อมูลผู้ใช้', indexX, 2, usersUuid);
                    });
                  },
                  child: Translate.TranslateAndSet_TextAutoSize(
                      'แก้ไข',
                      Colors.black,
                      TextAlign.center,
                      null,
                      Font_.Fonts_T,
                      10,
                      14,
                      1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: 80,
                height: 25,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green.shade400,
                    ),
                  ),
                  onPressed: () async {
                    await Dia_log1(context);
                    final indexX = int.tryParse('${row['index']}');
                    if (indexX == null) return;

                    final user = usermodel[indexX];
                    final usersUuid = user.profile?.usersUuid;
                    if (usersUuid == null) return;

                    final response = await read_GC_UserUuidCMM(usersUuid);
                    final jsonRes = json.decode(response!.body);
                    final data = jsonRes['data'];

                    final profile = data['profile'] ?? {};
                    final email = data['email'] ?? '';
                    final username = data['username'] ?? '';
                    final positionId =
                        int.tryParse(data['positions'][0]['id'].toString());

                    if (positionId == null) return;

                    final selectedPosition = positionsAllModel.firstWhere(
                      (e) => e.id == positionId,
                      orElse: () => positionsAllModel.first,
                    );

                    /// 📝 อัปเดตฟอร์มข้อมูลผู้ใช้
                    final controller = (int i) =>
                        data_title[i]['controller'] as TextEditingController;
                    setState(() {
                      controller(0).text = profile['prefix'] ?? '';
                      controller(1).text = profile['first_name'] ?? '';
                      controller(2).text = profile['last_name'] ?? '';
                      controller(3).text = profile['phone'] ?? '';
                      controller(4).text = email;
                      controller(5).text = profile['citizen_id'] ?? '';
                      controller(6).text = username;
                      controller(7).text = '';
                      controller(8).text = '';

                      positionsId = positionId;
                      Dropdown_initialItem = selectedPosition;

                      /// 🧩 อัปเดตสิทธิ์ที่เปิดใช้งาน (st = 1)
                      for (var role in selectedPosition.roles ?? []) {
                        final match = rolesAllModel.firstWhere(
                          (r) => r.id == role.id,
                          orElse: () => RolesAll(),
                        );
                        match.st = role.enabled == true ? 1 : 0;
                        print(
                            '🎯 Role: ${role.nameTh}, enabled: ${role.enabled}');
                      }

                      rolesAllModel
                          .sort((a, b) => (b.st ?? 0).compareTo(a.st ?? 0));
                    });
                    final roleList = data['roles'] as List;

                    setState(() {
                      checkedStates = List.filled(rolesAllModel.length, false);

                      for (var role in roleList) {
                        final roleId = role['id'];
                        final index =
                            rolesAllModel.indexWhere((r) => r.id == roleId);
                        if (index != -1) {
                          checkedStates[index] = true;
                        }
                      }
                      signaturesUrl = (jsonRes['data']['signatures'] != null &&
                              jsonRes['data']['signatures'].isNotEmpty &&
                              jsonRes['data']['signatures'][0]['uuid'] != null)
                          ? '${MyConstant().domain_v1}/admin/users/signatures/${jsonRes['data']['signatures'][0]['uuid']}/preview'
                          : '';
                    });

                    /// 📋 แสดงหน้าฟอร์มแก้ไข
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Edit_userSignatures(
                          'แก้ไขลายเซ็นต์ผู้ใช้', indexX, 1, usersUuid);
                    });
                  },
                  child: Translate.TranslateAndSet_TextAutoSize(
                      'แก้ไข',
                      Colors.black,
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
      ),
    );
  }

  final GlobalKey<SfSignaturePadState> signatureKey1 = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureKey2 = GlobalKey();
  List<Widget> buildFormRows() {
    List<Widget> rows = [];

    for (int i = 0; i < data_title.length; i += 2) {
      final left = data_title[i];
      final right = (i + 1 < data_title.length) ? data_title[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                // ซ้าย
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: left['controller'] as TextEditingController,
                      keyboardType: left['keyboardType'] ?? TextInputType.text,
                      validator: (value) {
                        if (left['ser'] == '3') {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอก ${left['title']}';
                          }

                          // เช็คเฉพาะกรณีช่อง email
                          if (left['title'].toString().contains('อีเมล')) {
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'The email field must be a valid email address.';
                            }
                          }

                          return null;
                        } else {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอก ${left['title']}';
                          }
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: left['title'],
                        labelStyle: TextStyle(fontSize: 13),
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters:
                          left['keyboardType'] == TextInputType.number
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : [],
                    ),
                  ),
                ),
                // ขวา (ถ้ามี)
                if (right != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller:
                            right['controller'] as TextEditingController,
                        keyboardType:
                            right['keyboardType'] ?? TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอก ${right['title']}';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: right['title'],
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters:
                            right['keyboardType'] == TextInputType.number
                                ? [FilteringTextInputFormatter.digitsOnly]
                                : [],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return rows;
  }

  Future<void> Edit_userAcess(
      String texts, int index, int type, String UsersUuid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
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
                      child: Icon(Icons.highlight_off,
                          size: 30, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
              Center(
                child: Translate.TranslateAndSetText(
                    '$texts',
                    SettingScreen_Color.Colors_Text1_,
                    TextAlign.center,
                    FontWeight.bold,
                    FontWeight_.Fonts_T,
                    16,
                    1),
              ),
            ],
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  child: Row(children: [
                    Container(
                      width: (Responsive.isDesktop(context))
                          ? MediaQuery.of(context).size.width * 0.85
                          : 1200,
                      // height: MediaQuery.of(context).size.height * 0.95,
                      child: Column(children: [
                        // Column(
                        //   children: data_title.map((item) {
                        //     return
                        // Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(vertical: 8.0),
                        //       child: TextField(
                        //         controller: item['detail'],
                        //         decoration:
                        //             InputDecoration(labelText: item['title']),
                        //       ),
                        //     );
                        //   }).toList(),
                        // ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          // height: 45,
                          child: Column(
                            children: buildFormRows(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'ลำดับการลงลายมือชื่อ',
                                  PeopleChaoScreen_Color.Colors_Text2_,
                                  TextAlign.left,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  16,
                                  1),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Translate.TranslateAndSetText(
                            //         'ลำดับการลงลายมือชื่อ',
                            //         PeopleChaoScreen_Color.Colors_Text2_,
                            //         TextAlign.left,
                            //         FontWeight.bold,
                            //         FontWeight_.Fonts_T,
                            //         16,
                            //         1),
                            //   ),
                            // ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Translate.TranslateAndSetText(
                            //         '',
                            //         PeopleChaoScreen_Color.Colors_Text2_,
                            //         TextAlign.left,
                            //         FontWeight.bold,
                            //         FontWeight_.Fonts_T,
                            //         16,
                            //         1),
                            //   ),
                            // ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: 600,
                                height: 60,
                                decoration: BoxDecoration(
                                  // color: Colors.grey[400],r
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border:
                                      Border.all(color: Colors.red, width: 1),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: CustomDropdown<PositionsAll>(
                                  // controller: positionController,
                                  decoration: CustomDropdownDecoration(
                                      hintStyle: TextStyle(
                                    fontSize: 13,
                                  )),
                                  overlayHeight: 300,
                                  items: positionsAllModel,
                                  hintText: 'เลือกลำดับการลงลายมือชื่อ',
                                  initialItem:
                                      Dropdown_initialItem, // ✅ ต้องเป็น object ที่อยู่ใน items

                                  onChanged: (PositionsAll? selectedItem) {
                                    if (selectedItem != null) {
                                      setState(() {
                                        positionsId = selectedItem.id;
                                        checkedStates = List.filled(
                                            rolesAllModel.length, false);
                                      });

                                      print(
                                          '✅ เลือก: ${selectedItem.nameTh} (${selectedItem.id})');

                                      if (selectedItem.roles != null &&
                                          selectedItem.roles!.isNotEmpty) {
                                        setState(() {
                                          for (var role
                                              in selectedItem.roles!) {
                                            final match =
                                                rolesAllModel.firstWhere(
                                              (element) =>
                                                  element.id == role.id,
                                              orElse: () =>
                                                  RolesAll(), // ป้องกัน null
                                            );

                                            match.st =
                                                role.enabled == true ? 1 : 0;

                                            print(
                                                '🎯 Role: ${role.nameTh}, enabled: ${role.enabled}');
                                          }

                                          // ✅ เรียงลำดับ DESC โดย st (enabled ก่อน)
                                          rolesAllModel.sort((a, b) =>
                                              (b.st ?? 0).compareTo(a.st ?? 0));
                                        });
                                      } else {
                                        print(
                                            '⚠️ No roles found for selected position');
                                      }
                                    }
                                  },

                                  // แสดงชื่อธนาคารใน header
                                  headerBuilder: (context, item, isExpanded) =>
                                      Text(
                                    item.nameTh ?? '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  // แสดงชื่อในรายการ dropdown
                                  listItemBuilder:
                                      (context, item, isSelected, onTap) =>
                                          SizedBox(
                                    height: 35,
                                    child: InkWell(
                                      onTap: onTap,
                                      child: Text(
                                        '${item.id}. ${item.nameTh}',
                                        // item.nameTh ?? '',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    // ListTile(
                                    //   contentPadding: EdgeInsets.all(4.0),
                                    //   title: Text(
                                    //     '${item.id}. ${item.nameTh}',
                                    //     // item.nameTh ?? '',
                                    //     style: TextStyle(fontSize: 13),
                                    //   ),
                                    //   // subtitle: item.meta != null &&
                                    //   //         item.meta!.isNotEmpty
                                    //   //     ? Text(
                                    //   //         item.meta!.first.bank_account ??
                                    //   //             '')
                                    //   //     : null,
                                    //   onTap: onTap,
                                    // ),
                                  ),
                                  // validator: (PerMissionModel? item) =>
                                  //     item == null
                                  //         ? 'กรุณาเลือกรูปแบบชำระ'
                                  //         : null,
                                  // validateOnChange: true,
                                ),
                              ),
                            )
                            // Expanded(
                            //     flex: 1,
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(4.0),
                            //       child: Container(
                            //         height: 60,
                            //         decoration: BoxDecoration(
                            //           // color: Colors.grey[400],r
                            //           borderRadius:
                            //               BorderRadius.all(Radius.circular(8)),
                            //           border: Border.all(
                            //               color: Colors.red, width: 1),
                            //         ),
                            //         padding: const EdgeInsets.all(2.0),
                            //         child: CustomDropdown<PositionsAll>(
                            //           // controller: positionController,
                            //           decoration: CustomDropdownDecoration(
                            //               hintStyle: TextStyle(
                            //             fontSize: 13,
                            //           )),
                            //           overlayHeight: 300,
                            //           items: positionsAllModel,
                            //           hintText: 'เลือกลำดับการลงลายมือชื่อ',
                            //           initialItem:
                            //               Dropdown_initialItem, // ✅ ต้องเป็น object ที่อยู่ใน items

                            //           onChanged: (PositionsAll? selectedItem) {
                            //             if (selectedItem != null) {
                            //               setState(() {
                            //                 positionsId = selectedItem.id;
                            //                 checkedStates = List.filled(
                            //                     rolesAllModel.length, false);
                            //               });

                            //               print(
                            //                   '✅ เลือก: ${selectedItem.nameTh} (${selectedItem.id})');

                            //               if (selectedItem.roles != null &&
                            //                   selectedItem.roles!.isNotEmpty) {
                            //                 setState(() {
                            //                   for (var role
                            //                       in selectedItem.roles!) {
                            //                     final match =
                            //                         rolesAllModel.firstWhere(
                            //                       (element) =>
                            //                           element.id == role.id,
                            //                       orElse: () =>
                            //                           RolesAll(), // ป้องกัน null
                            //                     );

                            //                     match.st = role.enabled == true
                            //                         ? 1
                            //                         : 0;

                            //                     print(
                            //                         '🎯 Role: ${role.nameTh}, enabled: ${role.enabled}');
                            //                   }

                            //                   // ✅ เรียงลำดับ DESC โดย st (enabled ก่อน)
                            //                   rolesAllModel.sort((a, b) =>
                            //                       (b.st ?? 0)
                            //                           .compareTo(a.st ?? 0));
                            //                 });
                            //               } else {
                            //                 print(
                            //                     '⚠️ No roles found for selected position');
                            //               }
                            //             }
                            //           },

                            //           // แสดงชื่อธนาคารใน header
                            //           headerBuilder:
                            //               (context, item, isExpanded) => Text(
                            //             item.nameTh ?? '',
                            //             style: TextStyle(fontSize: 14),
                            //           ),
                            //           // แสดงชื่อในรายการ dropdown
                            //           listItemBuilder:
                            //               (context, item, isSelected, onTap) =>
                            //                   SizedBox(
                            //             height: 35,
                            //             child: InkWell(
                            //               onTap: onTap,
                            //               child: Text(
                            //                 '${item.id}. ${item.nameTh}',
                            //                 // item.nameTh ?? '',
                            //                 style: TextStyle(fontSize: 13),
                            //               ),
                            //             ),
                            //             // ListTile(
                            //             //   contentPadding: EdgeInsets.all(4.0),
                            //             //   title: Text(
                            //             //     '${item.id}. ${item.nameTh}',
                            //             //     // item.nameTh ?? '',
                            //             //     style: TextStyle(fontSize: 13),
                            //             //   ),
                            //             //   // subtitle: item.meta != null &&
                            //             //   //         item.meta!.isNotEmpty
                            //             //   //     ? Text(
                            //             //   //         item.meta!.first.bank_account ??
                            //             //   //             '')
                            //             //   //     : null,
                            //             //   onTap: onTap,
                            //             // ),
                            //           ),
                            //           // validator: (PerMissionModel? item) =>
                            //           //     item == null
                            //           //         ? 'กรุณาเลือกรูปแบบชำระ'
                            //           //         : null,
                            //           // validateOnChange: true,
                            //         ),
                            //       ),
                            //     )
                            //     ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Translate.TranslateAndSetText(
                            //         '',
                            //         const Color.fromARGB(255, 173, 41, 41),
                            //         TextAlign.left,
                            //         FontWeight.bold,
                            //         FontWeight_.Fonts_T,
                            //         16,
                            //         1),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'สิทธิการเข้าถึง( *กรุณากำหนดสิทธิ )',
                                    PeopleChaoScreen_Color.Colors_Text2_,
                                    TextAlign.left,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    16,
                                    1),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'ลายมือชื่อ',
                                    PeopleChaoScreen_Color.Colors_Text2_,
                                    TextAlign.left,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    16,
                                    1),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(4.0),
                            //   child: Translate.TranslateAndSetText(
                            //       'วาด',
                            //       Colors.blue,
                            //       TextAlign.left,
                            //       null,
                            //       Font_.Fonts_T,
                            //       16,
                            //       1),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(4.0),
                            //   child: Translate.TranslateAndSetText(
                            //       'นำเข้ารูปภาพ',
                            //       Colors.blue,
                            //       TextAlign.left,
                            //       null,
                            //       Font_.Fonts_T,
                            //       16,
                            //       1),
                            // ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1)),
                                    builder: (context, snapshot) {
                                      return (positionsId == null)
                                          ? SizedBox(
                                              width: 100,
                                              height: 260,
                                              child: Center(
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        ' ** กรุณาระบบลำดับรายมือชื่อก่อน..!!',
                                                        Colors.red,
                                                        TextAlign.left,
                                                        null,
                                                        Font_.Fonts_T,
                                                        16,
                                                        1),
                                              ),
                                            )
                                          : SizedBox(
                                              width: 100,
                                              height: 260,
                                              child: Center(
                                                child: GridView.count(
                                                    shrinkWrap:
                                                        true, // ให้แสดงผลในพื้นที่จำกัด (เช่นใน Column)
                                                    crossAxisCount:
                                                        2, // ✅ แถวละ 2 ช่อง
                                                    crossAxisSpacing:
                                                        0, // ช่องว่างแนวนอน
                                                    mainAxisSpacing:
                                                        1, // ช่องว่างแนวตั้ง
                                                    childAspectRatio:
                                                        7, // อัตราส่วนกว้าง:สูง ปรับให้เหมาะกับ CheckboxListTile
                                                    // physics:
                                                    //     NeverScrollableScrollPhysics(), // ไม่ให้ GridView scroll แยก
                                                    children: List.generate(
                                                      rolesAllModel.length,
                                                      (index) {
                                                        // final nameTh = 'error';
                                                        // try {
                                                        //   final nameTh =
                                                        //       rolesAllModel[index]
                                                        //               .nameTh ??
                                                        //           'error';
                                                        //   print(nameTh);
                                                        // } catch (e) {
                                                        //   print('catch');
                                                        // }

                                                        return CheckboxListTile(
                                                          dense: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          title: Text(
                                                            rolesAllModel[index]
                                                                    .nameTh
                                                                    .toString() ??
                                                                'error',
                                                            style: TextStyle(
                                                              color: (rolesAllModel[
                                                                              index]
                                                                          .st ==
                                                                      0)
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .black,
                                                              decoration: (rolesAllModel[
                                                                              index]
                                                                          .st ==
                                                                      0)
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : null,
                                                            ),
                                                          ),
                                                          value: (index <
                                                                  checkedStates
                                                                      .length)
                                                              ? checkedStates[
                                                                  index]
                                                              : false,
                                                          onChanged:
                                                              (rolesAllModel[index]
                                                                          .st ==
                                                                      0)
                                                                  ? null
                                                                  : (bool?
                                                                      value) {
                                                                      setState(
                                                                          () {
                                                                        checkedStates[index] =
                                                                            value ??
                                                                                false;
                                                                      });

// ✅ ล้างค่าเก่าก่อนเริ่ม
                                                                      selectedSer
                                                                          .clear();

                                                                      for (int i =
                                                                              0;
                                                                          i < checkedStates.length;
                                                                          i++) {
                                                                        if (checkedStates[
                                                                            i]) {
                                                                          selectedSer
                                                                              .add(rolesAllModel[i].id);
                                                                        }
                                                                      }

                                                                      selectedSer
                                                                          .sort();
                                                                      print(
                                                                          '✅ Checked ser list: ${selectedSer.join(',')}');
                                                                    },
                                                          controlAffinity:
                                                              ListTileControlAffinity
                                                                  .leading,
                                                        );
                                                      },
                                                    )),
                                              ));
                                    }),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: (signaturesUrl.toString() != '')
                                      ? Container(
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            // color: AppbackgroundColor
                                            //     .TiTile_Colors.withOpacity(0.8),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight:
                                                    Radius.circular(8)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          padding: const EdgeInsets.all(20.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8.0),
                                              topRight: Radius.circular(8.0),
                                              bottomLeft: Radius.circular(8.0),
                                              bottomRight: Radius.circular(8.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: FittedBox(
                                                // fit: BoxFit.cover,
                                                child: Image.network(
                                                  '$signaturesUrl',
                                                  // height: 180,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : ReusableSignaturePad(
                                          height: 150,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          signatureKey: signatureKey1,
                                          onSave: () => handleSave(
                                              'uuid_Request',
                                              8,
                                              signatureKey1,
                                              SignatureActionType.saveToFile),
                                          onClear: () => signatureKey1
                                              .currentState
                                              ?.clear(),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    )
                  ])),
            ),
            SizedBox(
              height: 100,
            )
          ])),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: Translate.TranslateAndSet_TextAutoSize(
                          'ลบ',
                          Colors.white,
                          TextAlign.center,
                          null,
                          Font_.Fonts_T,
                          10,
                          14,
                          1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green,
                        ),
                      ),
                      onPressed: () async {
                        final prefix = data_title[0]['controller'].text.trim();
                        final firstName =
                            data_title[1]['controller'].text.trim();
                        final lastName =
                            data_title[2]['controller'].text.trim();
                        final phone = data_title[3]['controller'].text.trim();
                        final email = data_title[4]['controller'].text.trim();
                        final citizenId =
                            data_title[5]['controller'].text.trim();
                        final username =
                            data_title[6]['controller'].text.trim();
                        final passwordText = data_title[7]['controller'].text;

                        // ✅ ตรวจสอบข้อมูลเบื้องต้น
                        if (username.isEmpty || email.isEmpty) {
                          print('❌ ข้อมูลไม่ครบถ้วนหรือรหัสผ่านสั้นเกินไป');
                          return;
                        }

                        // ✅ แปลงลายเซ็น
                        final signedData = await handleSave(
                          '',
                          0,
                          signatureKey1,
                          SignatureActionType.upload_admin,
                        ) as Uint8List?;

                        if (signedData == null && type == 1) {
                          print('❌ ไม่สามารถแปลงลายเซ็นเป็นไฟล์ได้');
                          return;
                        }

                        final roleIdList = selectedSer
                            .map((e) => int.tryParse(e.toString()))
                            .where((e) => e != null)
                            .cast<int>()
                            .toList();

                        final fileToUpload = signedData ?? Uint8List(0);

                        // ✅ ส่งข้อมูล
                        final response = (type == 1)
                            ? await Post_Permission(
                                fileData: fileToUpload,
                                userName: username,
                                eMail: email,
                                passWord: passwordText,
                                preFix: prefix,
                                firstName: firstName,
                                lastName: lastName,
                                citizenId: citizenId,
                                phone: phone,
                                roleId: roleIdList,
                                positionId: positionsId!,
                              )
                            : await Put_Permission(
                                fileData: fileToUpload,
                                userName: username,
                                eMail: email,
                                passWord: passwordText,
                                preFix: prefix,
                                firstName: firstName,
                                lastName: lastName,
                                citizenId: citizenId,
                                phone: phone,
                                roleId: roleIdList,
                                positionId: positionsId!,
                                userUuid: UsersUuid.toString(),
                              );

                        if (response?.statusCode == 201 ||
                            response?.statusCode == 200) {
                          final responseBody =
                              await response!.stream.bytesToString();
                          Dialog_success(context, responseBody);
                          Navigator.of(context).pop();
                        } else {
                          print('❌ ล้มเหลว: ${response?.statusCode}');
                          final body = await response?.stream.bytesToString();
                          print('📦 Response body: $body');
                        }
                      },
                      child: Translate.TranslateAndSet_TextAutoSize(
                          'ตกลง',
                          Colors.white,
                          TextAlign.center,
                          null,
                          Font_.Fonts_T,
                          10,
                          14,
                          1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  ////////-------------------->
  Future<void> Edit_userSignatures(
      String texts, int index, int type, String UsersUuid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
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
                      child: Icon(Icons.highlight_off,
                          size: 30, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
              Center(
                child: Translate.TranslateAndSetText(
                    '$texts',
                    SettingScreen_Color.Colors_Text1_,
                    TextAlign.center,
                    FontWeight.bold,
                    FontWeight_.Fonts_T,
                    16,
                    1),
              ),
            ],
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  child: Row(children: [
                    Container(
                      width: 600,
                      // height: MediaQuery.of(context).size.height * 0.95,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'ลายมือชื่อ',
                                  PeopleChaoScreen_Color.Colors_Text2_,
                                  TextAlign.left,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  16,
                                  1),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: ReusableSignaturePad(
                                  height: 150,
                                  width: 500,
                                  signatureKey: signatureKey1,
                                  onSave: () => handleSave(
                                      'uuid_Request',
                                      8,
                                      signatureKey1,
                                      SignatureActionType.saveToFile),
                                  onClear: () =>
                                      signatureKey1.currentState?.clear(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    )
                  ])),
            ),
            SizedBox(
              height: 20,
            )
          ])),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(4.0),
                //   child: SizedBox(
                //     width: 120,
                //     height: 40,
                //     child: ElevatedButton(
                //       style: ButtonStyle(
                //         backgroundColor: MaterialStateProperty.all<Color>(
                //           Colors.red,
                //         ),
                //       ),
                //       onPressed: () async {
                //         Navigator.of(context).pop();
                //       },
                //       child: Translate.TranslateAndSet_TextAutoSize(
                //           'ลบ',
                //           Colors.white,
                //           TextAlign.center,
                //           null,
                //           Font_.Fonts_T,
                //           10,
                //           14,
                //           1),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green,
                        ),
                      ),
                      onPressed: () async {
                        if (UsersUuid == null || UsersUuid.toString().isEmpty) {
                          print('❌ ไม่พบ UsersUuid');
                          Dialog_error(context, 'ไม่พบ UUID : $UsersUuid');
                          return;
                        }

                        final signedData = await handleSave(
                          '',
                          0,
                          signatureKey1,
                          SignatureActionType.upload_admin,
                        ) as Uint8List?;

                        if (signedData == null) {
                          print('❌ ไม่สามารถแปลงลายเซ็นเป็นไฟล์ได้');
                          Dialog_error(
                              context, 'ไม่สามารถแปลงลายเซ็นเป็นไฟล์ได้');
                          return;
                        }

                        final response = await Post_Signatures_Permission(
                          fileData: signedData,
                          userUuid: UsersUuid.toString(),
                        );

                        if (response == null) {
                          print('❌ ไม่สามารถส่งคำขอได้');
                          Dialog_error(context, 'ไม่สามารถส่งคำขอได้');
                          return;
                        }

                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            Navigator.of(context).pop();
                            // Dialog_success(context, 'แก้ไขลายเซ็นสำเร็จ');
                          } else {
                            Dialog_error(context, 'แก้ไขลายเซ็นล้มเหลว');
                          }
                        });
                      },
                      child: Translate.TranslateAndSet_TextAutoSize(
                          'ตกลง',
                          Colors.white,
                          TextAlign.center,
                          null,
                          Font_.Fonts_T,
                          10,
                          14,
                          1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
