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
import '../../Model/GetTeNant_Model.dart';
import '../../Model/GetTrans_Kon_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../PeopleChao/PeopleChao_Screen2.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../Ac_List/Ac_List_Title.dart';

///BodyStatus1_Web
///
// class Account_Overdue extends StatefulWidget {
//   @override
//   _Account_OverdueState createState() => _Account_OverdueState();
// }
class Account_Overdue extends StatefulWidget {
  final updateMessage;
  const Account_Overdue({
    super.key,
    this.updateMessage,
  });

  @override
  State<Account_Overdue> createState() => _Account_OverdueState();
}

class _Account_OverdueState extends State<Account_Overdue> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  String ReturnBodyPeople = 'PeopleChaoScreen';
  String? resultqr;
  //--------------------------------------->

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];

  //-------------------------------------->
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  // List<TransKonModel> transKonModels = [];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> ac2 = [];
  List<int> Fix_data = [4, 5];
  ///////////--------------------------------------------->
  String? numinvoice;

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
  int Status_ = 1;

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
  String sortColumn = "วันที่รับชำระ";
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
    checkPreferance();
    addAcListTitle();
  }

////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1
      ac2.addAll(
          AcListTitle().ac_2); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac2(String ser) {
    if (ac2
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
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
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
    Loading_Trans_bill();
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    GC_tenant_overdue().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

  ////////-------------------------------------------------------->(ค้างชำระ)
  Future<Null> GC_tenant_overdue() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      teNantModels.clear();
      _teNantModels.clear();
      data.clear();
      filteredData.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    String url = zone_Sub == null || zone_Sub == '0'
        ? zone == null
            ? '${MyConstant().domain}/GC_tenantAll_setring.php?isAdd=true&ren=$ren&zone=$zone'
            : zone == '0'
                ? '${MyConstant().domain}/GC_tenantAll_setring.php?isAdd=true&ren=$ren&zone=$zone'
                : '${MyConstant().domain}/GC_tenant_setring.php?isAdd=true&ren=$ren&zone=$zone'
        : zone == null
            ? '${MyConstant().domain}/GC_tenantAll_setring_sub.php?isAdd=true&ren=$ren&zone=$zone_Sub'
            : zone == '0'
                ? '${MyConstant().domain}/GC_tenantAll_setring_sub.php?isAdd=true&ren=$ren&zone=$zone_Sub'
                : '${MyConstant().domain}/GC_tenant_setring.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            if (teNantModel.cid != '') {
              var daterx = teNantModel.ldate;
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

                var daterxNow = DateTime.now();

                var daterxLdate = DateTime.parse('$daterx 00:00:00.000');

                final now = DateTime.now();
                final earlier = daterxLdate.subtract(const Duration(days: 0));
                var daterxA = now.isAfter(earlier);
                // print(now.isAfter(earlier)); // true
                // print(now.isBefore(earlier)); // true

                if (daterxA != true) {
                  setState(() {
                    teNantModels.add(teNantModel);
                  });
                }
              }

              // setState(() {
              //   teNantModels.add(teNantModel);
              // });
            }
            // teNantModels.add(teNantModel);
          });
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
        _teNantModels = teNantModels;

        zone_ser = preferences.getString('zonePSer');
        zone_name = preferences.getString('zonesPName');
      });
      AddDaTa();
    } catch (e) {}
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
          final cid = teNantModels[index].cid ?? "";
          final docno = teNantModels[index].docno;
          final invoice = teNantModels[index].invoice ?? "";

          final zn = teNantModels[index].zn ?? "";
          final ln = teNantModels[index].ln_c ?? "";

          final cname =
              teNantModels[index].cname ?? teNantModels[index].remark ?? "";
          final sname =
              teNantModels[index].sname ?? teNantModels[index].remark ?? "";
          final expname = teNantModels[index].expname ?? "";
          final date = (teNantModels[index].date == null ||
                  teNantModels[index].date! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].date} 00:00:00'))}-${DateTime.parse('${teNantModels[index].date} 00:00:00').year + 0}';

          final total = (teNantModels[index].total == null ||
                  teNantModels[index].total.toString() == '')
              ? '0.00'
              : nFormat.format(double.parse('${teNantModels[index].total}'));

          return {
            "index": "$index",
            if (where_ac2("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac2("1") == false) "เลขตั้งหนี้": "$docno",
            if (where_ac2("2") == false) "เลขที่วางบิล": "$invoice",
            if (where_ac2("3") == false) "โซนพื้นที่": "$zn",
            if (where_ac2("4") == false) "รหัสพื้นที่": "$ln",
            if (where_ac2("5") == false) "ชื่อผู้เช่า": "$cname",
            if (where_ac2("6") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac2("7") == false) "รายการ": "$expname",
            if (where_ac2("8") == false) "กำหนดชำระ": "$date",
            if (where_ac2("9") == false) "ค้างชำระ": "$total",
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
  Widget Next_page_overdue() {
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

  void updateMessage(newMessage, Value_cid, ReturnBodyPeople2) async {
    setState(() {
      resultqr = Value_cid;
      ReturnBodyPeople = ReturnBodyPeople2;
      Status_ = int.parse(newMessage);
    });
    Loading_Trans_bill();
  }

  ////////--------------------------------------------------------------->
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
    double calculatedWidth = (ac2
                .where((item) => item["st"] == '1')
                .toList()
                .length <=
            7)
        ? (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.84
            : 1200
        : (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.84 +
                ((ac2.where((item) => item["st"] == '1').toList().length - 7) *
                    30)
            : 1200 +
                ((ac2.where((item) => item["st"] == '1').toList().length - 7) *
                    30);
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
      child:
          // (ReturnBodyPeople == 'PeopleChaoScreen2')
          //     ? Column(
          //         children: [
          //           Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.all(8.0),
          //                 child: InkWell(
          //                   onTap: () {
          //                     setState(() {
          //                       ReturnBodyPeople = 'PeopleChaoScreen';
          //                     });
          //                   },
          //                   child: Container(
          //                     decoration: const BoxDecoration(
          //                       color: Colors.white,
          //                       borderRadius: BorderRadius.only(
          //                           topLeft: Radius.circular(10),
          //                           topRight: Radius.circular(10),
          //                           bottomLeft: Radius.circular(10),
          //                           bottomRight: Radius.circular(10)),
          //                     ),
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: const Icon(
          //                       Icons.arrow_back,
          //                       color: Colors.black,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           PeopleChaoScreen2(
          //             Get_Value_cid: resultqr,
          //             Get_Value_NameShop_index: '1',
          //             Get_Value_status: '1',
          //             Get_Value_indexpage: '4',
          //             updateMessage: updateMessage,
          //           ),
          //         ],
          //       )
          //     :
          Column(
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
                            ? const Center(
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
                            hint: const Center(
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

                            items: ac2.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac2.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac2[selectedIndex]["st"] = '0';
                                          } else {
                                            ac2[selectedIndex]["st"] = '1';
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
                    Container(child: Next_page_overdue())
                  ],
                ),
                const Divider(),
                //${MONTH_Now}//${YEAR_Now}
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
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'เลขที่ใบเสร็จ' ||
                                          column.toString() == 'เลขที่สัญญา';
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
                                                          'ค้างชำระ';
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

  /////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Material(
      // surfaceTintColor: tappedIndex_Color
      //     .tappedIndex_Colors,
      color: tappedIndex_ == index.toString()
          ? tappedIndex_Color.tappedIndex_Colors
          : AppbackgroundColor.Sub_Abg_Colors,
      child: InkWell(
        hoverColor: Colors.grey[350]!.withOpacity(0.5),
        onTap: () async {
          int index_x = int.parse('${row['index']}');

          setState(() {
            tappedIndex_ = index.toString();
            // deall_Trans_select();

            resultqr = teNantModels[index_x].cid!;
          });
          await Dia_log1();
          if (teNantModels[index_x].invoice != null) {
            // red_Trans_select_inv(index);

            // setState(() {
            //   ReturnBodyPeople = 'PeopleChaoScreen2';
            // });
            // setState(() {
            //   ReturnBodyPeople = 'PeopleChaoScreen2';
            // });
            widget.updateMessage('0', '$resultqr', 'PeopleChaoScreen2');
          } else {
            // in_Trans_select(index);

            // setState(() {
            //   ReturnBodyPeople = 'PeopleChaoScreen2';
            // });
            widget.updateMessage('0', '$resultqr', 'PeopleChaoScreen2');
          }
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
                                : (Fix_data.contains(columnHeaders
                                        .indexWhere((item) => item == column)))
                                    ? Fix_Expan1
                                    : Fix_Expan2,
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
                                      return column.toString() == 'ค้างชำระ';
                                    }))
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            (column.toString() == 'ค้างชำระ' &&
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
                                : (Fix_data.contains(columnHeaders
                                        .indexWhere((item) => item == column)))
                                    ? Fix_Expan1
                                    : Fix_Expan2,
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              row[column]?.toString() ?? '',
                              textAlign: (columnHeaders.any((columnx) {
                                return column.toString() == 'ค้างชำระ';
                              }))
                                  ? TextAlign.right
                                  : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: (column.toString() == 'ค้างชำระ' &&
                                          row[column]?.toString() == '0.00')
                                      ? Colors.red[600]
                                      : PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ))
                .toList(),
            // Container(
            //   width: 100,
            //   height: 25,
            //   child: ElevatedButton(
            //     style: ButtonStyle(
            //       backgroundColor:
            //           MaterialStateProperty.all<Color>(Colors.orange),
            //     ),
            //     onPressed: () async {
            //       await Dia_log1();

            //       int index_x = int.parse('${row['index']}');

            //       generateRandomString();
            //       setState(() {
            //         tappedIndex_ = index.toString();
            //         red_Trans_select(index_x);
            //         red_Invoice(index_x);
            //       });
            //       Future.delayed(const Duration(milliseconds: 300), () async {
            //         checkshowDialog(
            //           index_x,
            //         );
            //       });
            //     },
            //     child: Row(
            //       children: [
            //         if (_TransReBillModels[int.parse('${row['index']}')].slip ==
            //                 null ||
            //             _TransReBillModels[int.parse('${row['index']}')]
            //                     .slip
            //                     .toString() ==
            //                 'null' ||
            //             _TransReBillModels[int.parse('${row['index']}')]
            //                     .slip
            //                     .toString() ==
            //                 '')
            //           Icon(
            //             Icons.image_not_supported,
            //             size: 16,
            //           ),
            //         Expanded(
            //           child: Translate.TranslateAndSet_TextAutoSize(
            //               'ตรวจสอบ',
            //               CustomerScreen_Color.Colors_Text3_,
            //               TextAlign.center,
            //               null,
            //               Font_.Fonts_T,
            //               8,
            //               14,
            //               1),
            //         ),
            //       ],
            //     ),
            //   ),
            // )
          ]),
        ),
      ),
    );
  }

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
}
