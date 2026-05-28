import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../../Man_PDF/Man_Pay_Pakan.dart';
import '../../Model/GetFinnancetrans_Model.dart';
import '../../Model/GetPakan_Contractx_Model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/GetTrans_Kon_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../Ac_List/Ac_List_Title.dart';

class Account_RefundPakan extends StatefulWidget {
  @override
  _Account_RefundPakanState createState() => _Account_RefundPakanState();
}

class _Account_RefundPakanState extends State<Account_RefundPakan> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  //-------------------------------------->

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  //-------------------------------------->
  // List<ContractxPakanModel> contractxPakanModels = [];
  // List<ContractxPakanModel> _contractxPakanModels = <ContractxPakanModel>[];
  List<TransKonModel> transKonModels = [];
  List<TransKonModel> _transKonModels = <TransKonModel>[];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> ac10_2 = [];
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
  String sortColumn = "วันที่ชำระ";
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
  String? rtname,
      type,
      typex,
      renname,
      bill_name,
      bill_addr,
      bill_tax,
      bill_tel,
      bill_email,
      expbill,
      expbill_name,
      bill_default,
      bill_tser,
      foder,
      bills_name_,
      zone_Subser,
      zone_Subname,
      newValuePDFimg_QR;
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

////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1
      ac10_2.addAll(
          AcListTitle().ac10_2); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac10_2(String ser) {
    if (ac10_2
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

  ///////////--------------------------------------------->
  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var bill_namex = renTalModel.bill_name!.trim();
          var bill_addrx = renTalModel.bill_addr!.trim();
          var bill_taxx = renTalModel.bill_tax!.trim();
          var bill_telx = renTalModel.bill_tel!.trim();
          var bill_emailx = renTalModel.bill_email!.trim();
          var bill_defaultx = renTalModel.bill_default;
          var bill_tserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = bill_namex;
            bill_addr = bill_addrx;
            bill_tax = bill_taxx;
            bill_tel = bill_telx;
            bill_email = bill_emailx;
            bill_default = bill_defaultx;
            bill_tser = bill_tserx;

            tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
            if (bill_defaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {
      // print('Error-Dis(read_GC_rental) : ${e}');
    }
    // print('name>>>>>  $renname');
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    red_Trans_Kon().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

  ////////-------------------------------------------------------->(รับเงินประกัน)
  // Future<Null> tenant_Pakan() async {
  //   setState(() {
  //     isLoading_main = true;
  //     isLoading = true;
  //     contractxPakanModels.clear();
  //     data.clear();
  //     filteredData.clear();
  //   });
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var ren = preferences.getString('renTalSer');
  //   var zone = preferences.getString('zonePSer');
  //   String url = (zone == null || zone == '0')
  //       ? '${MyConstant().domain}/GC_PakanAll.php?isAdd=true&ren=$ren&zser=0&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=0'
  //       : '${MyConstant().domain}/GC_PakanAll.php?isAdd=true&ren=$ren&zser=$zone&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=0';

  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result != null) {
  //       for (var map in result) {
  //         ContractxPakanModel contractxPakanModelss =
  //             ContractxPakanModel.fromJson(map);

  //         setState(() {
  //           contractxPakanModels.add(contractxPakanModelss);
  //         });
  //       }
  //       setState(() {
  //         _contractxPakanModels = contractxPakanModels;
  //       });
  //       AddDaTa();
  //     } else {}
  //   } catch (e) {}
  // }
////////////------------------------------------------>(คืนเงินประกัน)
  Future<Null> red_Trans_Kon() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      transKonModels.clear();
      _transKonModels.clear();
      data.clear();
      filteredData.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_tran_Kon_pakanAll.php?isAdd=true&ren=$ren&zser_zone=0'
        : '${MyConstant().domain}/GC_tran_Kon_pakanAll.php?isAdd=true&ren=$ren&zser_zone=$zone';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransKonModel transKonModel = TransKonModel.fromJson(map);
          var sum_amtx = double.parse(transKonModel.total!);
          setState(() {
            transKonModels.add(transKonModel);
          });
        }
        setState(() {
          _transKonModels = transKonModels;
        });
        AddDaTa();
      }
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (transKonModels.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(transKonModels.length, (index) {
          // Ensure that docno exists and is not null
          final docno = transKonModels[index].docno;
          final cid = transKonModels[index].cid ?? "";
          final zn = transKonModels[index].zn ?? "";
          final ln = transKonModels[index].ln ?? "";
          final cname =
              transKonModels[index].cname ?? transKonModels[index].remark ?? "";
          final sname =
              transKonModels[index].sname ?? transKonModels[index].remark ?? "";

          final total = (transKonModels[index].total == null ||
                  transKonModels[index].total.toString() == '')
              ? '0.00'
              : nFormat.format(double.parse('${transKonModels[index].total}'));
          final pdatex = (transKonModels[index].pdate == null ||
                  transKonModels[index].pdate! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${transKonModels[index].pdate} 00:00:00'))}-${DateTime.parse('${transKonModels[index].pdate} 00:00:00').year + 0}';
          final type = transKonModels[index].type ?? "";
          return {
            "index": "$index",
            if (where_ac10_2("0") == false) "เลขที่ใบเสร็จ": "$docno",
            if (where_ac10_2("1") == false) "เลขที่สัญญา": "$cid",
            if (where_ac10_2("2") == false) "โซนพื้นที่": "$zn",
            if (where_ac10_2("3") == false) "รหัสพื้นที่": "$ln",
            if (where_ac10_2("4") == false) "ชื่อผู้เช่า": "$cname",
            if (where_ac10_2("5") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac10_2("6") == false) "วันที่ชำระ": "$pdatex",
            if (where_ac10_2("7") == false) "รูปแบบชำระ": "$type",
            if (where_ac10_2("8") == false) "ยอดสุทธิ": "$total",
            // if (where_ac10_2("8") == false) "วันที่รับชำระ": "$pdatex",
            // if (where_ac10_2("9") == false) "สถานะ": "$status",
            // if (where_ac10_2("10") == false) "ยอดสุทธิ": "$total",
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

  //-------------------------------------->
  ////////--------------------------------------------------------------->
  Future<Null> red_Trans_select(index) async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = transKonModels[index].ser;
    var qutser = transKonModels[index].ser_in;
    var docnoin = transKonModels[index].docno;
    String url =
        '${MyConstant().domain}/GC_bill_pay_PakanHistory.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);
          var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
          var numinvoiceent = _TransReBillHistoryModel.docno;
          // var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          // var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          // var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          // var sumAmtx = double.parse(_TransReBillHistoryModel.total!);

          var sum_pvatx = _TransReBillHistoryModel.pvat != null
              ? double.parse(_TransReBillHistoryModel.pvat!)
              : 0.0;
          var sum_vatx = _TransReBillHistoryModel.vat != null
              ? double.parse(_TransReBillHistoryModel.vat!)
              : 0.0;
          var sum_whtx = _TransReBillHistoryModel.wht != null
              ? double.parse(_TransReBillHistoryModel.wht!)
              : 0.0;
          var sum_amtx = _TransReBillHistoryModel.total != null
              ? double.parse(_TransReBillHistoryModel.total!)
              : 0.0;

          setState(() {
            numinvoice = _TransReBillHistoryModel.docno;
            numdoctax = _TransReBillHistoryModel.doctax;
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            paper_run = _TransReBillHistoryModel.paper_run;
            _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
    _ReportValue_type = (paper.toString() == '0')
        ? '${TitleType_Default_Receipt_[0]}'
        : (paper.toString() == '1')
            ? '${TitleType_Default_Receipt_[1]}'
            : (paper.toString() == '2')
                ? '${TitleType_Default_Receipt_[2]}'
                : (paper.toString() == '3')
                    ? '${TitleType_Default_Receipt_[3]}'
                    : (paper.toString() == '4')
                        ? '${TitleType_Default_Receipt_[4]}'
                        : '${TitleType_Default_Receipt_[0]}';

    TitleType_Default_Receipt_Name = (paper.toString() == '0')
        ? '${TitleType_Default_Receipt_[0]}'
        : (paper.toString() == '1')
            ? '${TitleType_Default_Receipt_[1]}'
            : (paper.toString() == '2')
                ? '${TitleType_Default_Receipt_[2]}'
                : (paper.toString() == '3')
                    ? '${TitleType_Default_Receipt_[3]}'
                    : (paper.toString() == '4')
                        ? '${TitleType_Default_Receipt_[4]}'
                        : '${TitleType_Default_Receipt_[0]}';
  }

  Future<Null> red_Finnan(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
        dis_sum_Matjum = 0.00;
        sum_duesbill = 0.00;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = transKonModels[index].ser;
    var qutser = transKonModels[index].ser_in;
    var docnoin = transKonModels[index].docno; //.toString().trim()
    // print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amtPakan.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            Slip_history = finnancetransModel.slip.toString();
            pdate = pdatex;
            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          if (finnancetransModel.dtype! == 'MM') {
            setState(() {
              dis_sum_Matjum =
                  dis_sum_Matjum + double.parse(finnancetransModel.amt!);
            });
          }

          if (finnancetransModel.dtype! == 'FTA') {
            setState(() {
              sum_duesbill = double.parse(finnancetransModel.amt!);
            });
          }
          // print(
          //     '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  ////////--------------------------------------------------------------->
  Widget Next_page_ComePakan() {
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
    double calculatedWidth = (ac10_2
                .where((item) => item["st"] == '1')
                .toList()
                .length <=
            7)
        ? (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.84
            : 1400
        : (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.84 +
                ((ac10_2.where((item) => item["st"] == '1').toList().length -
                        7) *
                    30)
            : 1400 +
                ((ac10_2.where((item) => item["st"] == '1').toList().length -
                        7) *
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
                            : (transKonModels.isEmpty)
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

                            items: ac10_2.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac10_2.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac10_2[selectedIndex]["st"] = '0';
                                          } else {
                                            ac10_2[selectedIndex]["st"] = '1';
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
                    Container(child: Next_page_ComePakan())
                  ],
                ),
                const Divider(),
                //${MONTH_Now}//${YEAR_Now}
                SizedBox(
                  width: (Responsive.isDesktop(context))
                      ? MediaQuery.of(context).size.width * 0.83
                      : MediaQuery.of(context).size.width,
                  child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                // border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Translate.TranslateAndSetText(
                                        'เดือนที่รับชำระ :',
                                        ReportScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        12,
                                        1),

                                    // Text(
                                    //   'เดือน :',
                                    //   style: TextStyle(
                                    //     color: ReportScreen_Color
                                    //         .Colors_Text2_,
                                    //     // fontWeight: FontWeight.bold,
                                    //     fontFamily:
                                    //         Font_.Fonts_T,
                                    //   ),
                                    // ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        // border: Border.all(color: Colors.grey, width: 1),
                                      ),
                                      width: 120,
                                      padding: const EdgeInsets.all(2.0),
                                      child: DropdownButtonFormField2(
                                        alignment: Alignment.center,
                                        focusColor: Colors.white,
                                        autofocus: false,
                                        decoration: InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.center,
                                          enabled: true,
                                          hoverColor: Colors.brown,
                                          prefixIconColor: Colors.blue,
                                          fillColor:
                                              Colors.white.withOpacity(0.05),
                                          filled: false,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 231, 227, 227),
                                            ),
                                          ),
                                        ),
                                        isExpanded: false,
                                        //value: MONTH_Now,
                                        hint: Translate.TranslateAndSetText(
                                            MONTH_Now == null
                                                ? 'เลือก'
                                                : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                            Colors.grey,
                                            TextAlign.start,
                                            null,
                                            Font_.Fonts_T,
                                            12,
                                            1),
                                        // Text(
                                        //   MONTH_Now == null
                                        //       ? 'เลือก'
                                        //       : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                        //   maxLines: 2,
                                        //   textAlign:
                                        //       TextAlign
                                        //           .center,
                                        //   style:
                                        //       const TextStyle(
                                        //     overflow:
                                        //         TextOverflow
                                        //             .ellipsis,
                                        //     fontSize: 12,
                                        //     color:
                                        //         Colors.grey,
                                        //   ),
                                        // ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        iconSize: 20,
                                        buttonHeight: 30,
                                        buttonWidth: 200,
                                        // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                        dropdownDecoration: BoxDecoration(
                                          // color: Colors
                                          //     .amber,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                        ),
                                        items: [
                                          for (int item = 1; item < 13; item++)
                                            DropdownMenuItem<String>(
                                              value: '${item}',
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      '${monthsInThai[item - 1]}',
                                                      Colors.grey,
                                                      TextAlign.start,
                                                      null,
                                                      Font_.Fonts_T,
                                                      12,
                                                      1),
                                            )
                                        ],

                                        onChanged: (value) async {
                                          MONTH_Now = value;
                                          Loading_Trans_bill();
                                          // red_Trans_bill();
                                          // if (Value_Chang_Zone_Income !=
                                          //     null) {
                                          //   red_Trans_billIncome();
                                          //   red_Trans_billMovemen();
                                          // }
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Translate.TranslateAndSetText(
                                        'ปีที่รับชำระ :',
                                        ReportScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        12,
                                        1),

                                    //  Text(
                                    //   'ปี :',
                                    //   style: TextStyle(
                                    //     color: ReportScreen_Color
                                    //         .Colors_Text2_,
                                    //     // fontWeight: FontWeight.bold,
                                    //     fontFamily:
                                    //         Font_.Fonts_T,
                                    //   ),
                                    // ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        // border: Border.all(color: Colors.grey, width: 1),
                                      ),
                                      width: 120,
                                      padding: const EdgeInsets.all(2.0),
                                      child: DropdownButtonFormField2(
                                        alignment: Alignment.center,
                                        focusColor: Colors.white,
                                        autofocus: false,
                                        decoration: InputDecoration(
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.center,
                                          enabled: true,
                                          hoverColor: Colors.brown,
                                          prefixIconColor: Colors.blue,
                                          fillColor:
                                              Colors.white.withOpacity(0.05),
                                          filled: false,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Color.fromARGB(
                                                  255, 231, 227, 227),
                                            ),
                                          ),
                                        ),
                                        isExpanded: false,
                                        // value: YEAR_Now,
                                        hint: Text(
                                          YEAR_Now == null
                                              ? 'เลือก-Select'
                                              : '$YEAR_Now',
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        iconSize: 20,
                                        buttonHeight: 30,
                                        buttonWidth: 200,
                                        // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                        dropdownDecoration: BoxDecoration(
                                          // color: Colors
                                          //     .amber,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                        ),
                                        items: YE_Th.map(
                                            (item) => DropdownMenuItem<String>(
                                                  value: '${item}',
                                                  child: Text(
                                                    '${item}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )).toList(),

                                        onChanged: (value) async {
                                          YEAR_Now = value;
                                          Loading_Trans_bill();
                                          // red_Trans_bill();
                                          // red_Trans_bill();
                                          // if (Value_Chang_Zone_Income !=
                                          //     null) {
                                          //   red_Trans_billIncome();
                                          //   red_Trans_billMovemen();
                                          // }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]))),
                )
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
          await Dia_log1();
          int index_x = int.parse('${row['index']}');
          setState(() {
            numinvoice = row['เลขที่ใบเสร็จ'].toString();
            tappedIndex_ = index.toString();
            red_Trans_select(index_x);
            red_Finnan(index_x);
          });

          Future.delayed(const Duration(milliseconds: 500), () async {
            checkshowDialog(index_x);
          });

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

  ///---------------------------------------------------------------------->
  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index) async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(10.0),
                actionsPadding: const EdgeInsets.all(6.0),
                title: Row(
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
                content: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      dragStartBehavior: DragStartBehavior.start,
                      child: Row(
                        children: [
                          Container(
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.85
                                  : 1200,
                              child: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        // padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Translate.TranslateAndSetText(
                                              'รายละเอียดบิล',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.start,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              1),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            // border: Border.all(
                                            //     color: Colors.grey, width: 1),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Translate
                                                        .TranslateAndSetText(
                                                            'เลขที่บิล : ',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                    Center(
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        '${transKonModels[index].docno}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (transKonModels[index]
                                                          .doctax !=
                                                      null &&
                                                  transKonModels[index]
                                                          .doctax
                                                          .toString() !=
                                                      '')
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Translate
                                                          .TranslateAndSetText(
                                                              'ใบกำกับภาษี : ',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.center,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                      Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 12,
                                                          '${transKonModels[index].doctax}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T
                                                              //fontSize: 10.0
                                                              //fontSize: 10.0
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Translate.TranslateAndSetText(
                                              //     'บิลเลขที่',
                                              //     AccountScreen_Color
                                              //         .Colors_Text1_,
                                              //     TextAlign.start,
                                              //     FontWeight.bold,
                                              //     FontWeight_.Fonts_T,
                                              //     14,
                                              //     1),
                                              // Center(
                                              //   child: AutoSizeText(
                                              //     minFontSize: 8,
                                              //     maxFontSize: 12,
                                              //     (transKonModels[index]
                                              //                     .docno ==
                                              //                 '' ||
                                              //             transKonModels[index]
                                              //                     .docno ==
                                              //                 null)
                                              //         ? '${transKonModels[index].doctax}'
                                              //         : '${transKonModels[index].docno}',
                                              //     textAlign: TextAlign.center,
                                              //     style: const TextStyle(
                                              //         color:
                                              //             PeopleChaoScreen_Color
                                              //                 .Colors_Text1_,
                                              //         fontWeight:
                                              //             FontWeight.bold,
                                              //         fontFamily:
                                              //             FontWeight_.Fonts_T
                                              //         //fontSize: 10.0
                                              //         //fontSize: 10.0
                                              //         ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  color: Colors.brown[200],
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'ลำดับ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'วันที่ชำระ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'กำหนดชำระ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Translate.TranslateAndSetText(
                                            'เลขตั้งหนี้',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Translate.TranslateAndSetText(
                                            'รายการ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'VAT',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'WHT',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'ยอดสุทธิ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.end,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    // height:
                                    //     MediaQuery.of(context).size.height / 4.8,
                                    decoration: const BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                      // border: Border.all(
                                      //     color: Colors.grey, width: 1),
                                    ),
                                    child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 0)),
                                      builder: (context, snapshot) {
                                        return ListView.builder(
                                          controller: _scrollController2,
                                          // itemExtent: 50,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              _TransReBillHistoryModels.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        '${index + 1}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .dateacc ==
                                                                null)
                                                            ? ''
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc} 00:00:00'))}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        // '${_TransReBillHistoryModels[index].duedate}',
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .date ==
                                                                null)
                                                            ? ''
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].date} 00:00:00'))}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .refno ==
                                                                null)
                                                            ? ''
                                                            : '${_TransReBillHistoryModels[index].refno}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .expname ==
                                                                null)
                                                            ? ''
                                                            : '${_TransReBillHistoryModels[index].expname}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .vat ==
                                                                null)
                                                            ? ''
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .wht ==
                                                                null)
                                                            ? ''
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .total ==
                                                                null)
                                                            ? ''
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.85
                                        : 1200,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 360,
                                          decoration: BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: const BorderRadius
                                                    .only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              if (transKonModels[index].ref1! !=
                                                      '' &&
                                                  transKonModels[index].ref1 !=
                                                      null)
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (transKonModels[index]
                                                                .ref1 ==
                                                            null)
                                                        ? 'อ้างอิง : -'
                                                        : 'อ้างอิง : ${transKonModels[index].ref1}',
                                                    maxLines: 2,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontSize: 10.0),
                                                  ),
                                                ),
                                              if (transKonModels[index].ref2! !=
                                                      '' &&
                                                  transKonModels[index].ref2 !=
                                                      null)
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (transKonModels[index]
                                                                .ref2 ==
                                                            null)
                                                        ? 'Ref1 : -'
                                                        : 'Ref1 : ${transKonModels[index].ref2}',
                                                    maxLines: 2,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontSize: 10.0),
                                                  ),
                                                ),
                                              if (transKonModels[index].ref4! !=
                                                      '' &&
                                                  transKonModels[index].ref4 !=
                                                      null)
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (transKonModels[index]
                                                                .ref4 ==
                                                            null)
                                                        ? 'Ref2 : -'
                                                        : 'Ref2 : ${transKonModels[index].ref4}',
                                                    maxLines: 2,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontSize: 10.0),
                                                  ),
                                                ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Translate.TranslateAndSetText(
                                                    (pdate == null)
                                                        ? 'รูปแบบการชำระ ( วันที่ชำระ : ?? )'
                                                        : 'รูปแบบการชำระ ( วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0} )',
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.end,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                              ),
                                              for (var i = 0;
                                                  i <
                                                      finnancetransModels
                                                          .length;
                                                  i++)
                                                if (finnancetransModels[i]
                                                        .dtype
                                                        .toString() !=
                                                    'FTA')
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Translate.TranslateAndSetText(
                                                            '${i + 1}. Total : ${nFormat.format((finnancetransModels[i].amt == null) ? 0.00 : double.parse(finnancetransModels[i].amt!))}  (${finnancetransModels[i].ptname})',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                        if (finnancetransModels[
                                                                    i]
                                                                .type
                                                                .toString() !=
                                                            'CASH')
                                                          AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 11,
                                                            '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[800],
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 350,
                                          // height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'รวมราคาสินค้า/Sub Total',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    //  const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'รวมราคาสินค้า/Sub Total',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,

                                                      // '${sum_pvat} // $dis_sum_Matjum',

                                                      '${nFormat.format(sum_pvat)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ภาษีมูลค่าเพิ่ม/Vat',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    //  const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ภาษีมูลค่าเพิ่ม/Vat',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      '${nFormat.format(sum_vat)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'หัก ณ ที่จ่าย',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    // const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'หัก ณ ที่จ่าย',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      '${nFormat.format(sum_wht)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ค่าทำเนียม',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    // const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ค่าทำเนียม',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      '${nFormat.format(sum_duesbill)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยอดรวม',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    //  const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดรวม',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      // '${sum_amt} // $dis_sum_Matjum ',

                                                      '${nFormat.format(sum_amt + sum_duesbill)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ส่วนลด/Discount $sum_disp %',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    //  AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ส่วนลด/Discount $sum_disp %',
                                                    //   style: const TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      '${nFormat.format(sum_disamt)}',
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (nFormat
                                                      .format(dis_sum_Matjum)
                                                      .toString() !=
                                                  '0.00')
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 120,
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'เงินมัดจำ(ตัดมัดจำ)',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.start,
                                                              null,
                                                              Font_.Fonts_T,
                                                              11,
                                                              1),
                                                      // AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 11,
                                                      //   'เงินมัดจำ(ตัดมัดจำ)',
                                                      //   style: const TextStyle(
                                                      //       color: PeopleChaoScreen_Color
                                                      //           .Colors_Text2_,
                                                      //       //fontWeight: FontWeight.bold,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                    ),
                                                    Expanded(
                                                      // flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 11,
                                                        '${nFormat.format(dis_sum_Matjum)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยอดชำระ',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    // const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดชำระ',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                      '${nFormat.format(((sum_amt - sum_disamt) - dis_sum_Matjum) + sum_duesbill)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยอดสุทธิ',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    // const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดสุทธิ',
                                                    //   style: TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                      '${nFormat.format((sum_amt - sum_disamt) + sum_duesbill)}',
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 2.0,
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 2.0,
                      ),
                      const SizedBox(
                        height: 2.0,
                      ),
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width * 0.85
                                : 1200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: 200,
                                  child: InkWell(
                                    onTap: () {
                                      List newValuePDFimg = [];
                                      for (int index = 0; index < 1; index++) {
                                        if (renTalModels[0].imglogo!.trim() ==
                                            '') {
                                          // newValuePDFimg.add(
                                          //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                        } else {
                                          newValuePDFimg.add(
                                              '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                        }
                                      }
                                      final tableData00 = [
                                        for (int index = 0;
                                            index <
                                                _TransReBillHistoryModels
                                                    .length;
                                            index++)
                                          [
                                            '${index + 1}',
                                            '${_TransReBillHistoryModels[index].date}',
                                            '${_TransReBillHistoryModels[index].expname}',
                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                          ],
                                      ];

                                      String sname = transKonModels[index]
                                                  .sname ==
                                              null
                                          ? '${transKonModels[index].remark}'
                                          : '${transKonModels[index].sname}';
                                      String cname =
                                          '${transKonModels[index].cname}';
                                      String addr =
                                          '${transKonModels[index].addr}';
                                      String tax =
                                          '${transKonModels[index].tax}';
                                      String room_number_BillHistory =
                                          '${transKonModels[index].room_number}';
                                      // print(
                                      //     'room_number ------> ${transKonModels[index].room_number}');

                                      _showMyDialog_SAVE(
                                          tableData00,
                                          newValuePDFimg,
                                          sname,
                                          cname,
                                          addr,
                                          tax,
                                          room_number_BillHistory);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.print,
                                                  color: Colors.black),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'พิมพ์',
                                                      AccountScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.start,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                              // Text(
                                              //   'พิมพ์',
                                              //   style: TextStyle(
                                              //     color: Colors.white,
                                              //     // fontWeight:
                                              //     //     FontWeight.bold,
                                              //     fontFamily:
                                              //         Font_.Fonts_T,
                                              //   ),
                                              // ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
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

  ////////////------------------------------------------------------>(Export file)
  Future<void> _showMyDialog_SAVE(tableData00, newValuePDFimg, sname, cname,
      addr, tax, room_number_BillHistory) async {
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    // String? TitleType_Default_Receipt_Name;
    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Translate.TranslateAndSetText(
                        'หัวบิล :',
                        AccountScreen_Color.Colors_Text1_,
                        TextAlign.center,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        1),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: RadioGroup<String>.builder(
                            direction: Axis.vertical,
                            groupValue: _ReportValue_type,
                            horizontalAlignment: MainAxisAlignment.center,
                            onChanged: (value) {
                              // setState(() {
                              //   FormNameFile_text.clear();
                              // });
                              setState(() {
                                _ReportValue_type = value ?? '';
                              });

                              if (value == 'ไม่ระบุ') {
                                setState(() {
                                  TitleType_Default_Receipt_Name = null;
                                });
                              } else {
                                setState(() {
                                  TitleType_Default_Receipt_Name = value;
                                });
                              }
                            },
                            items: <String>[
                              for (int index = 0;
                                  index < TitleType_Default_Receipt_.length;
                                  index++)
                                '${TitleType_Default_Receipt_[index]}',
                            ],
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: ReportScreen_Color.Colors_Text2_,
                              // fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                            itemBuilder: (item) => RadioButtonBuilder(
                              item,
                            ),
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 3, 2, 2),
                    child: Text(
                      '🖨 พิมพ์แล้ว : ${(paper_run == null) ? 0 : paper_run} ครั้ง',
                      style: TextStyle(
                        fontSize: 14,
                        color: ReportScreen_Color.Colors_Text2_,
                        // fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () {
                        Receipt_his_statusbill(
                            tableData00,
                            newValuePDFimg,
                            sname,
                            cname,
                            addr,
                            tax,
                            room_number_BillHistory,
                            TitleType_Default_Receipt_Name);
                      },
                      child: Container(
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'พิมพ์',
                              Colors.white,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // Text(
                          //   'พิมพ์',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     //fontWeight: FontWeight.bold, color:

                          //     // fontWeight: FontWeight.bold,
                          //     fontFamily: Font_.Fonts_T,
                          //   ),
                          // ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, 'OK'),
                      child: Container(
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'ปิด',
                              Colors.white,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          //  Text(
                          //   'ปิด',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     //fontWeight: FontWeight.bold, color:

                          //     // fontWeight: FontWeight.bold,
                          //     fontFamily: Font_.Fonts_T,
                          //   ),
                          // ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  //////////////-------------------------------------------------------------> ( รายการ ประวัติบิล )
  Future<Null> Receipt_his_statusbill(
      tableData00,
      newValuePDFimg,
      sname,
      cname,
      addr,
      tax,
      room_number_BillHistory,
      TitleType_Default_Receipt_Name) async {
    ManPay_Receipt_PakanPDF.ManPayReceipt_PakanPDF(
        numinvoice,
        context,
        foder,
        renTal_name,
        bill_addr,
        bill_email,
        bill_tel,
        bill_tax,
        bill_name,
        newValuePDFimg,
        TitleType_Default_Receipt_Name,
        tem_page_ser,
        bills_name_);
  }
}
