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
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../Beam/webviewPay_beamcheckout.dart';
import '../../Constant/Myconstant.dart';
import '../../INSERT_Log/Insert_log.dart';
import '../../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../../Model/GetFinnancetrans_Model.dart';
import '../../Model/GetPakan_Contractx_Model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/GetTrans_Kon_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../Model/trans_re_bill_model.dart';
import '../../PeopleChao/UP_Slip_Again.dart';
import '../../Responsive/responsive.dart';
import '../../Style/File_s.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../../Style/downloadImage.dart';
import '../Ac_List/Ac_List_Title.dart';

///BodyStatus3_Web
class Account_BillPay extends StatefulWidget {
  @override
  _Account_BillPayState createState() => _Account_BillPayState();
}

class _Account_BillPayState extends State<Account_BillPay> {
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  final new_dereee = TextEditingController();
  final Formbecause_ = TextEditingController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  //-------------------------------------->

  // List<TransReBillModel> limitedList_TransReBillModels = [];
  List<TransReBillModel> TransReBillModels = [];
  List<TransReBillModel> _TransReBillModels = <TransReBillModel>[];
  ///////////--------------------------------------------->
  List<String> TransReBill_select = [];
  List<String> transReBill_loade_Success = [];
  ///////////--------------------------------------------->
  List<String> transReBill_select_delete = [];
  List<String> transReBill_loade_Success_delete = [];
  int Type_doctax_ = 0;
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac7 = [];

  List<int> Fix_data = [4, 5, 6];
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'คู่ฉบับ',
    'สำเนา',
    'สำเนาคู่ฉบับ',
  ];
  ///////////--------------------------------------------->

  int TitleType_Default_Receipt = 0;
  int Fix_Expan1 = 2, Fix_Expan2 = 1;
  ///////////--------------------------------------------->
  String? numinvoice;
  String _ReportValue_type = "ไม่ระบุ";
  String? TitleType_Default_Receipt_Name;
  String? base64_Imgmap, tem_page_ser;
  ///////////--------------------------------------------->
  var round_p, paper, paper_run;

  //-------------------------------------->
  int Ser_Tap = 0;
  int Status_ = 1;
  int renTal_lavel = 0;
  int type_docx = 0, Date_Typepay = 1;
  int? Cancell_bill = 0, Day_Cancell_bill = 0;

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
  String sortColumn = "เลขที่ใบเสร็จ";
  //-------------------------------------->
  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;

  ///------------------------>
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      dis_sum_Matjum = 0.00,
      sum_duesbill = 0.00,
      sum_dislist = 0;
  ///////////--------------------------------------------->

  String? base64_Slip, fileName_Slip, Slip_history, pdate;
  String? MONTH_Now, YEAR_Now;
  String tappedIndex_ = '';
  String? ser_payby, numdoctax;
  String? renTal_user, rental_ser, renTal_name, zone_ser, zone_name;
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
      newValuePDFimg_QR,
      rental_degree_up;
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
  ///////////--------------------------------------------->
  @override
  void initState() {
    super.initState();
    checkPreferance();
    read_GC_rental();
    addAcListTitle();
  }

  ////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1

      ac7.addAll(AcListTitle().ac_7);
    });
  }

  where_ac7(String ser) {
    if (ac7
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
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
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
          var billNamex = renTalModel.bill_name!.trim();
          var billAddrx = renTalModel.bill_addr!.trim();
          var billTaxx = renTalModel.bill_tax!.trim();
          var billTelx = renTalModel.bill_tel!.trim();
          var billEmailx = renTalModel.bill_email!.trim();
          var billDefaultx = renTalModel.bill_default;
          var billTserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          var serx = renTalModel.ser;
          var degree_upx = renTalModel.degree_up;
          setState(() {
            rental_degree_up = degree_upx;
            rental_ser = serx;
            Cancell_bill = int.parse(renTalModel.cancell_bill!);
            Day_Cancell_bill = int.parse(renTalModel.day_cancell_bill!);

            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = billNamex;
            bill_addr = billAddrx;
            bill_tax = billTaxx;
            bill_tel = billTelx;
            bill_email = billEmailx;
            bill_default = billDefaultx;
            bill_tser = billTserx;
            tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
            if (billDefaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    if (ren.toString() == '106') {
      // setState(() {
      //   ac7[2]["st"] = (ac7[2]["st"]! == '1') ? '0' : '1';
      // });
    } else {
      setState(() {
        ac7[15]["st"] = (ac7[15]["st"]! == '1') ? '0' : '1';
        // ac7[16]["st"] = (ac7[16]["st"]! == '1') ? '0' : '1';
        // ac7[17]["st"] = (ac7[17]["st"]! == '1') ? '0' : '1';
      });
    }
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    red_Trans_bill().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }
  ////////-------------------------------------------------------->

  Future<Null> red_Trans_bill() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      TransReBillModels.clear();
      data.clear();
      filteredData.clear();
    });

    var sertype = (ser_payby == '0' || ser_payby == null)
        ? '0'
        : (ser_payby == '1')
            ? 'W'
            : (ser_payby == '2')
                ? 'U'
                : (ser_payby == '3')
                    ? 'LP'
                    : (ser_payby == '4')
                        ? 'H'
                        : '0';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    String url =
        '${MyConstant().domain}/GC_bill_pay_BC.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&typedocx=$type_docx&date_type=$Date_Typepay';
    // String url =
    //     '${MyConstant().domain}/GC_bill_pay_BC.php?isAdd=true&ren=$ren';
    // print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          if (transReBillModel.pos != '1') {
            setState(() {
              TransReBillModels.add(transReBillModel);

              // _TransBillModels.add(_TransBillModel);
            });
          }
        }
        setState(() {
          _TransReBillModels = TransReBillModels;
        });
        // print('result ${_TransReBillModels.length}');
        AddDaTa();
      }

      // read_TransReBill_limit();
    } catch (e) {}
  }

  // Future<Null> read_TransReBill_limit() async {
  //   setState(() {
  //     endIndex = offset + limit;
  //     _TransReBillModels = limitedList_TransReBillModels_.sublist(
  //         offset, // Start index
  //         (endIndex <= limitedList_TransReBillModels_.length)
  //             ? endIndex
  //             : limitedList_TransReBillModels_.length // End index
  //         );
  //   });
  // }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (TransReBillModels.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(TransReBillModels.length, (index) {
          // Ensure that docno exists and is not null
          final cid = TransReBillModels[index].cid ?? "";
          final daterec = (TransReBillModels[index].daterec == null ||
                  TransReBillModels[index].daterec! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${TransReBillModels[index].daterec} 00:00:00').year + 0}';

          final pdate = (TransReBillModels[index].pdate == null ||
                  TransReBillModels[index].pdate! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels[index].pdate} 00:00:00').year + 0}';

          final docno = TransReBillModels[index].docno ?? "";
          final doctax = TransReBillModels[index].doctax ?? "";
          final doc_inv = TransReBillModels[index].inv2 ?? "";

          final zn =
              TransReBillModels[index].zn ?? TransReBillModels[index].znn ?? "";
          final ln = TransReBillModels[index].ln ??
              TransReBillModels[index].room_number ??
              "";
          final cname = TransReBillModels[index].cname ??
              TransReBillModels[index].remark ??
              "";
          final sname = TransReBillModels[index].sname ??
              TransReBillModels[index].remark ??
              "";
          final refno = TransReBillModels[index].refno ?? "";
          final expname = TransReBillModels[index].expname ?? "";
          final total = TransReBillModels[index].total_dis == null
              ? (TransReBillModels[index].total_bill == null)
                  ? '0.00'
                  : '${nFormat.format(double.parse(TransReBillModels[index].total_bill!))}'
              : '${nFormat.format(double.parse(TransReBillModels[index].total_dis!))}';
          final bill_duedate = (_TransReBillModels[index].date == null ||
                  TransReBillModels[index].date! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${TransReBillModels[index].date} 00:00:00').year + 0}';
          final pay_type = '${TransReBillModels[index].type}' ?? "";
          final pay_by = (TransReBillModels[index].pay_by.toString() == 'W')
              ? 'Web Admin(W)'
              : (TransReBillModels[index].pay_by.toString() == 'U')
                  ? 'Web User(U)'
                  : (TransReBillModels[index].pay_by.toString() == 'LP')
                      ? 'Web Market(LP)'
                      : (TransReBillModels[index].pay_by.toString() == 'H')
                          ? 'Handheld(H)'
                          : 'UnKnow ??';
          final type_bill =
              TransReBillModels[index].doctax == '' ? '' : 'ใบกำกับภาษี';
          final Ref1 = TransReBillModels[index].ref1 ?? "";

          final Ref2 = TransReBillModels[index].ref2 ?? "";
          final Ref4 = TransReBillModels[index].ref4 ?? "";
          return {
            "index": "$index",
            if (where_ac7("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac7("1") == false) "วันที่ทำรายการ": "$daterec",
            if (where_ac7("2") == false) "วันที่รับชำระ": "$pdate",
            if (where_ac7("3") == false) "เลขที่ใบเสร็จ": "$docno",
            if (where_ac7("4") == false) "เลขที่ใบกำกับภาษี": "$doctax",
            if (where_ac7("5") == false) "เลขที่ใบวางบิล": "$doc_inv",
            if (where_ac7("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac7("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac7("8") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac7("9") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac7("10") == false) "จำนวนเงิน": "$total",
            if (where_ac7("11") == false) "กำหนดชำระ": "$bill_duedate",
            if (where_ac7("12") == false) "ช่องทางชำระ": "$pay_type",
            if (where_ac7("13") == false) "ทำรายการ": "$pay_by",
            if (where_ac7("14") == false) "สถานะ": "$type_bill",
            if (where_ac7("15") == false) "รหัสอ้างอิง": "$Ref1",
            if (where_ac7("16") == false) "Ref1": "$Ref2",
            if (where_ac7("17") == false) "Ref2": "$Ref4",
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
  Future<Null> red_Trans_select2(index_x) async {
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

    var ciddoc = TransReBillModels[index_x].cid;
    // var qutser = contractxPakanModels[index].ser_in;
    var docnoin = TransReBillModels[index_x].docno;
    String url =
        '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    //print('red_Trans_select2 $url');

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

          var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.dis!) != 0
                  ? double.parse(_TransReBillHistoryModel.pvat!) -
                      double.parse(_TransReBillHistoryModel.dis!)
                  : double.parse(_TransReBillHistoryModel.pvat!)
              : 0.0;
          var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.vat!)
              : 0.0;
          var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.wht!)
              : 0.0;
          var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.dis!) != 0
                  ? double.parse(_TransReBillHistoryModel.pvat!) +
                      double.parse(_TransReBillHistoryModel.vat!) -
                      double.parse(_TransReBillHistoryModel.wht!) -
                      ((_TransReBillHistoryModel.disendbill == null)
                          ? 0.00
                          : double.parse(_TransReBillHistoryModel.disendbill!))
                  : double.parse(_TransReBillHistoryModel.total!)
              : 0.0;
          var sum_dislistx = double.parse(_TransReBillHistoryModel.dis!);
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          // var numinvoiceent = _TransReBillHistoryModel.docno;
          // setState(() {
          //   sum_pvat = sum_pvat + sumPvatx;
          //   sum_vat = sum_vat + sumVatx;
          //   sum_wht = sum_wht + sumWhtx;
          //   sum_amt = sum_amt + sumAmtx;
          //   // sum_disamt = sum_disamtx;
          //   // sum_disp = sum_dispx;
          //   numinvoice = _TransReBillHistoryModel.docno;
          //   numdoctax = _TransReBillHistoryModel.doctax;
          //   _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          // });

          setState(() {
            if (dtypeinvoiceent == 'KP') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else if (dtypeinvoiceent == '!Z') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else {
              // total_amt = total_amt + total_amtx;
              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            }
            paper_run = _TransReBillHistoryModel.paper_run;
          });
        }
      }
      // print(_TransReBillHistoryModels.length);
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
    //('red_Trans_select2 ${_TransReBillHistoryModels.length}');
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

  Future<Null> red_Finnan2(index_x) async {
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
    var ciddoc = TransReBillModels[index_x].ser;
    // var qutser = contractxPakanModels[index].ser_in;
    var docnoin = TransReBillModels[index_x].docno; //.toString().trim()
    // print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
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
                                      _scrollController2.animateTo(
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
                                      _scrollController2.animateTo(
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
// ฟังก์ชันตรวจสอบข้อมูลซ้ำ
  bool hasDuplicate(Map<String, dynamic> row) {
    // ตรวจสอบว่ามีข้อมูลซ้ำใน _TransReBillModels หรือไม่
    return _TransReBillModels.where(
                (e) => e.inv2.toString() == row['เลขที่ใบวางบิล'].toString())
            .length >
        1;
  }

  // ฟังก์ชันกรองข้อมูลซ้ำ
  void filterDuplicates() {
    setState(() {
      tappedIndex_ = '';
      if (showDuplicatesOnly) {
        // แสดงข้อมูลทั้งหมด
        filteredData = List.from(data);
      } else {
        // ใช้ Map เพื่อตรวจสอบความถี่ของค่าใน เลขที่ใบวางบิล
        final seen = <String, int>{};
        for (var row in data) {
          final key = row["เลขที่ใบวางบิล"]?.toString() ??
              ''; // ใช้ เลขที่ใบวางบิล เป็น key

          // ตรวจสอบว่า key ไม่เป็นค่าว่างก่อนที่จะนับ
          if (key != '') {
            seen[key] = (seen[key] ?? 0) + 1; // นับจำนวนครั้งที่พบ
          }
        }

        // กรองเฉพาะข้อมูลที่ซ้ำ
        filteredData = data.where((row) {
          final key = row["เลขที่ใบวางบิล"]?.toString() ??
              ''; // ใช้ เลขที่ใบวางบิล เป็น key
          return key != '' &&
              seen[key]! >
                  1; // เงื่อนไข: key ไม่เป็นค่าว่างและมีมากกว่า 1 ครั้ง
        }).toList();

        // แจ้งเตือนหากไม่มีข้อมูลซ้ำ
        if (filteredData.isEmpty) {
          Dialog_duplicates();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('No duplicates found')),
          // );
          filteredData = List.from(data); // คืนค่าข้อมูลทั้งหมด
        }
      }

      // สลับสถานะการแสดงผล
      showDuplicatesOnly = !showDuplicatesOnly;
    });
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
  @override
  Widget build(BuildContext context) {
    double calculatedWidth = (ac7
                .where((item) => item["st"] == '1')
                .toList()
                .length <=
            9)
        ? (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.83
            : 1400
        : (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.83 +
                ((ac7.where((item) => item["st"] == '1').toList().length - 9) *
                    30)
            : 1400 +
                ((ac7.where((item) => item["st"] == '1').toList().length - 9) *
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
//////////---------------------------->

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
                            : (TransReBillModels.isEmpty)
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
                            hint: Center(
                              child: Text(
                                'หัวข้อ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AccountScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),

                            items: ac7.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac7.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac7[selectedIndex]["st"] = '0';
                                          } else {
                                            ac7[selectedIndex]["st"] = '1';
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
                    Container(child: Next_page_Billpay())
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
                                      width: 125,
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
                                        hint: Translate.TranslateAndSetText(
                                            'วันที่ทำรายการ',
                                            Colors.grey,
                                            TextAlign.start,
                                            null,
                                            Font_.Fonts_T,
                                            12,
                                            1),

                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        iconSize: 20,
                                        buttonHeight: 30,
                                        buttonWidth: 120,
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
                                          DropdownMenuItem<String>(
                                            value: '1',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'วันที่ทำรายการ',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '2',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'วันที่รับชำระ',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                        ],

                                        onChanged: (value) async {
                                          setState(() {
                                            Date_Typepay = int.parse(value!);
                                          });
                                          Loading_Trans_bill();
                                          // red_Trans_bill();
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Translate.TranslateAndSetText(
                                        'เดือน :',
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
                                        'ปี :',
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
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Translate.TranslateAndSetText(
                                        'ระบบ :',
                                        ReportScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        12,
                                        1),
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
                                      width: 160,
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
                                        hint: Translate.TranslateAndSetText(
                                            (ser_payby == null ||
                                                    ser_payby == '0')
                                                ? 'ทั้งหมด'
                                                : '$ser_payby',
                                            Colors.grey,
                                            TextAlign.start,
                                            null,
                                            Font_.Fonts_T,
                                            12,
                                            1),

                                        // Text(
                                        //   (ser_payby ==
                                        //               null ||
                                        //           ser_payby ==
                                        //               '0')
                                        //       ? 'ทั้งหมด'
                                        //       : '$ser_payby',
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
                                          DropdownMenuItem<String>(
                                            value: '0',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ทั้งหมด',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '1',
                                            child: Text(
                                              'Web Admin(W)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '2',
                                            child: Text(
                                              'Web User(U)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '3',
                                            child: Text(
                                              'Web Market(LP)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '4',
                                            child: Text(
                                              'Handheld(H)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        ],

                                        onChanged: (value) async {
                                          setState(() {
                                            ser_payby = value;
                                          });
                                          Loading_Trans_bill();
                                          // print(value);
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
                                        'สถานะใบเสร็จ :',
                                        ReportScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        12,
                                        1),
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
                                      width: 160,
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
                                        hint: Translate.TranslateAndSetText(
                                            (ser_payby == null ||
                                                    ser_payby == '0')
                                                ? 'ทั้งหมด'
                                                : '$ser_payby',
                                            Colors.grey,
                                            TextAlign.start,
                                            null,
                                            Font_.Fonts_T,
                                            12,
                                            1),

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
                                          DropdownMenuItem<String>(
                                            value: '0',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ทั้งหมด',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '1',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ใบเสร็จธรรมดา',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '2',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ใบกำกับภาษี',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                          ),
                                        ],

                                        onChanged: (value) async {
                                          setState(() {
                                            type_docx = int.parse(value!);
                                          });
                                          Loading_Trans_bill();
                                          // print(value);
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                              child: Container(
                                height: 30,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors
                                      .withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  // border: Border.all(color: Colors.white, width: 1),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: InkWell(
                                  onTap: filterDuplicates,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors
                                          .withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Translate.TranslateAndSetText(
                                              showDuplicatesOnly
                                                  ? 'ข้อมูลทั้งหมด'
                                                  : 'กรองข้อมูลซ้ำ',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              12,
                                              1),
                                        ),
                                        Center(
                                          child: Icon(
                                            showDuplicatesOnly
                                                ? Icons.list
                                                : Icons.filter_alt_outlined,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          // IconButton(
                                          //   icon: Icon(
                                          //     showDuplicatesOnly
                                          //         ? Icons.list
                                          //         : Icons.filter_alt,
                                          //     size: 16,
                                          //   ),
                                          //   onPressed: filterDuplicates,
                                          // ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]))),
                ),

                const Divider(),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 200,
                      child: PopupMenuButton(
                        tooltip: (Type_doctax_ == 1)
                            ? 'ปิด-การเปลี่ยนเป็นใบกำกับภาษีแบบหลายรายการ'
                            : 'การเปลี่ยนเป็นใบกำกับภาษี แบบหลายรายการ',
                        child: Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.orange[700],
                          //   borderRadius: const BorderRadius.only(
                          //       topLeft: Radius.circular(6),
                          //       topRight: Radius.circular(6),
                          //       bottomLeft: Radius.circular(6),
                          //       bottomRight: Radius.circular(6)),
                          //   border:
                          //       Border.all(color: Colors.white, width: 1),
                          // ),
                          padding: const EdgeInsets.all(0),
                          child: Text(
                            (Type_doctax_ == 1)
                                ? 'ปิด-การเปลี่ยนเป็นใบกำกับภาษี'
                                : 'การเปลี่ยนสถานะบิล( หลายรายการ ):',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              decoration: TextDecoration.underline,
                              color: (Type_doctax_ == 1)
                                  ? Colors.blue[600]
                                  : Colors.red[600],
                              // color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                            ),
                          ),
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                              onTap: () async {
                                setState(() {
                                  TransReBill_select.clear();
                                  transReBill_select_delete.clear();
                                  Type_doctax_ = (Type_doctax_ == 1) ? 0 : 1;
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  // color: Colors.green[100]!
                                  //     .withOpacity(0.5),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black12,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                // width: 200,
                                child: Text(
                                  (Type_doctax_ == 1)
                                      ? 'ยกเลิก-การเลือกทั้งหมด'
                                      : 'เลือกรายการ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (Type_doctax_ == 1)
                                        ? Colors.blue[600]
                                        : Colors.red,
                                    // fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          (Type_doctax_ == 1)
                              ? (TransReBill_select.length != 0 &&
                                      _TransReBillModels.length != 0)
                                  ? Container(
                                      width: 55,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: PopupMenuButton(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[700],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    6),
                                                            topRight:
                                                                Radius.circular(
                                                                    6),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6)),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        // 'Save',
                                                        'ภาษี :',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          // color: Colors.grey[800],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                        ),
                                                      ),
                                                      Text(
                                                        // 'Save',
                                                        '( ${TransReBill_select.length} )',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          // color: Colors.grey[800],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  //  const Icon(
                                                  //   Icons.download,
                                                  //   color: Colors.white,
                                                  //   size: 18,
                                                  // ),
                                                ),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                  PopupMenuItem(
                                                      onTap: () async {
                                                        Future.delayed(
                                                            const Duration(
                                                                microseconds:
                                                                    800),
                                                            () async {
                                                          pPC_finantIbillREbill_All();
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          // color: Colors.green[100]!
                                                          //     .withOpacity(0.5),
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: Colors
                                                                  .black12,
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        // width: 200,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'เปลี่ยนสถานะบิล( ${TransReBill_select.length} ) : กำกับภาษี ',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 13,
                                                                color: ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                            const Icon(
                                                                Icons
                                                                    .receipt_long,
                                                                color: AppBarColors
                                                                    .ABar_Colors)
                                                          ],
                                                        ),
                                                      )),
                                                  PopupMenuItem(
                                                      onTap: () async {
                                                        setState(() {
                                                          TransReBill_select
                                                              .clear();
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          // color: Colors.green[100]!
                                                          //     .withOpacity(0.5),
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: Colors
                                                                  .black12,
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        // width: 200,
                                                        child: Row(
                                                          children: [
                                                            Translate.TranslateAndSetText(
                                                                'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                13,
                                                                1),
                                                            // Text(
                                                            //   'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                                            //   style:
                                                            //       const TextStyle(
                                                            //     fontSize: 14,
                                                            //     color: ReportScreen_Color.Colors_Text2_,
                                                            //     // fontWeight: FontWeight.bold,
                                                            //     fontFamily: Font_.Fonts_T,
                                                            //   ),
                                                            // ),
                                                            const Icon(
                                                              Icons
                                                                  .check_box_outline_blank,
                                                              color: Colors.red,
                                                              size: 22,
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      width: 80,
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            //  TransReBill_select_delete
                                            //       .clear();
                                            TransReBill_select.clear();
                                          });
                                          // print(InvoiceModels
                                          //     .length);
                                          for (int index = 0;
                                              index < displayedData.length;
                                              index++) {
                                            int index_x = int.parse(
                                                '${displayedData[index]['index']}');
                                            if (_TransReBillModels[index_x]
                                                        .doctax ==
                                                    null ||
                                                _TransReBillModels[index_x]
                                                        .doctax
                                                        .toString() ==
                                                    '') {
                                              setState(() {
                                                TransReBill_select.add(
                                                    '${_TransReBillModels[index_x].docno}');
                                              });
                                            } else {}
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            // const Text(
                                            //   'All: ',
                                            //   textAlign: TextAlign.center,
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     color: Colors.green,
                                            //     // fontWeight:
                                            //     //     FontWeight.bold,
                                            //     fontFamily: Font_.Fonts_T,
                                            //   ),
                                            // ),
                                            Text(
                                              '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()} [✔]',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                                // fontWeight:
                                                //     FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                              : Container(
                                  width: 55,
                                  child: (displayedData.length == 0)
                                      ? SizedBox()
                                      : (TransReBill_select.length != 0 &&
                                              _TransReBillModels.length != 0)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: PopupMenuButton(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange[700],
                                                          borderRadius: const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          6)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 1),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: Column(
                                                          children: [
                                                            const Text(
                                                              // 'Save',
                                                              'Save :',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white,
                                                                // color: Colors.grey[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                              ),
                                                            ),
                                                            Text(
                                                              // 'Save',
                                                              '( ${TransReBill_select.length} )',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white,
                                                                // color: Colors.grey[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //  const Icon(
                                                        //   Icons.download,
                                                        //   color: Colors.white,
                                                        //   size: 18,
                                                        // ),
                                                      ),
                                                      itemBuilder: (BuildContext
                                                              context) =>
                                                          [
                                                        PopupMenuItem(
                                                            onTap: () async {
                                                              Future.delayed(
                                                                  const Duration(
                                                                      microseconds:
                                                                          800),
                                                                  () async {
                                                                List
                                                                    newValuePDFimg =
                                                                    [];

                                                                for (int index =
                                                                        0;
                                                                    index < 1;
                                                                    index++) {
                                                                  if (renTalModels[
                                                                              0]
                                                                          .imglogo!
                                                                          .trim() ==
                                                                      '') {
                                                                    // newValuePDFimg.add(
                                                                    //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                  } else {
                                                                    newValuePDFimg
                                                                        .add(
                                                                            '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                  }
                                                                }

                                                                _showMyDialog_SAVE_All(
                                                                    newValuePDFimg,
                                                                    'Folder');
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                // color: Colors.green[100]!
                                                                //     .withOpacity(0.5),
                                                                border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              // width: 200,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Save( ${TransReBill_select.length} ) : Folder ',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: ReportScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                      Icons
                                                                          .folder,
                                                                      color: Colors
                                                                              .amber[
                                                                          600])
                                                                ],
                                                              ),
                                                            )),
                                                        PopupMenuItem(
                                                            onTap: () async {
                                                              Future.delayed(
                                                                  const Duration(
                                                                      microseconds:
                                                                          800),
                                                                  () async {
                                                                List
                                                                    newValuePDFimg =
                                                                    [];

                                                                for (int index =
                                                                        0;
                                                                    index < 1;
                                                                    index++) {
                                                                  if (renTalModels[
                                                                              0]
                                                                          .imglogo!
                                                                          .trim() ==
                                                                      '') {
                                                                    // newValuePDFimg.add(
                                                                    //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                  } else {
                                                                    newValuePDFimg
                                                                        .add(
                                                                            '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                  }
                                                                }

                                                                _showMyDialog_SAVE_All(
                                                                    newValuePDFimg,
                                                                    'File');
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                // color: Colors.green[100]!
                                                                //     .withOpacity(0.5),
                                                                border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              // width: 200,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Save( ${TransReBill_select.length} ) : File ',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: ReportScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                  const Icon(
                                                                      Icons
                                                                          .file_copy,
                                                                      color: AppBarColors
                                                                          .ABar_Colors)
                                                                ],
                                                              ),
                                                            )),
                                                        PopupMenuItem(
                                                            onTap: () async {
                                                              setState(() {
                                                                TransReBill_select
                                                                    .clear();
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                // color: Colors.green[100]!
                                                                //     .withOpacity(0.5),
                                                                border: Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              // width: 200,
                                                              child: Row(
                                                                children: [
                                                                  Translate.TranslateAndSetText(
                                                                      'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .start,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      13,
                                                                      1),
                                                                  // Text(
                                                                  //   'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                                                  //   style:
                                                                  //       const TextStyle(
                                                                  //     fontSize: 14,
                                                                  //     color: ReportScreen_Color.Colors_Text2_,
                                                                  //     // fontWeight: FontWeight.bold,
                                                                  //     fontFamily: Font_.Fonts_T,
                                                                  //   ),
                                                                  // ),
                                                                  const Icon(
                                                                    Icons
                                                                        .check_box_outline_blank,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 22,
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
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
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              width: 80,
                                              child: InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    //  TransReBill_select_delete
                                                    //       .clear();
                                                    TransReBill_select.clear();
                                                  });
                                                  // print(InvoiceModels
                                                  //     .length);
                                                  for (int index = 0;
                                                      index <
                                                          displayedData.length;
                                                      index++) {
                                                    int index_x = int.parse(
                                                        '${displayedData[index]['index']}');
                                                    if (_TransReBillModels[
                                                                    index_x]
                                                                .type ==
                                                            null ||
                                                        _TransReBillModels[
                                                                    index_x]
                                                                .type
                                                                .toString() ==
                                                            '') {
                                                    } else {
                                                      setState(() {
                                                        TransReBill_select.add(
                                                            '${_TransReBillModels[index_x].docno}');
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Column(
                                                  children: [
                                                    // const Text(
                                                    //   'All: ',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: TextStyle(
                                                    //     fontSize: 12,
                                                    //     color: Colors.green,
                                                    //     // fontWeight:
                                                    //     //     FontWeight.bold,
                                                    //     fontFamily: Font_.Fonts_T,
                                                    //   ),
                                                    // ),
                                                    Text(
                                                      '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()} [✔]',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.green,
                                                        // fontWeight:
                                                        //     FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                ),
                          ...columnHeaders
                              .skip(1)
                              .map((column) => Expanded(
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'เลขที่ใบเสร็จ' ||
                                          column.toString() ==
                                              'เลขที่ใบกำกับภาษี' ||
                                          column.toString() == 'เลขที่ใบวางบิล';
                                    }))
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
                                                          'จำนวนเงิน';
                                                    }))
                                                        ? TextAlign.right
                                                        : (columnHeaders
                                                                .any((columnx) {
                                                            return column
                                                                    .toString() ==
                                                                'ช่องทางชำระ';
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
                          // Container(
                          //   width: 100,
                          //   child: Translate.TranslateAndSetText(
                          //       '...',
                          //       AccountScreen_Color.Colors_Text1_,
                          //       TextAlign.center,
                          //       FontWeight.bold,
                          //       FontWeight_.Fonts_T,
                          //       14,
                          //       1),
                          // ),
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
                                : ListView.builder(
                                    controller: _scrollController2,
                                    itemCount: displayedData.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final row = displayedData[index];
                                      final columnToCheck = 'เลขที่ใบวางบิล';
                                      return (hasDuplicate(row) &&
                                              row[columnToCheck]?.toString() !=
                                                  '')
                                          ? SizedBox(
                                              width: calculatedWidth,
                                              child: Column(
                                                children: [
                                                  List_Material(
                                                      index,
                                                      columnHeaders,
                                                      row,
                                                      columnToCheck),
                                                  Container(
                                                    width: calculatedWidth,
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                    decoration: BoxDecoration(
                                                      color: tappedIndex_ ==
                                                              index.toString()
                                                          ? tappedIndex_Color
                                                              .tappedIndex_Colors
                                                          : (hasDuplicate(
                                                                      row) &&
                                                                  row[columnToCheck]
                                                                          ?.toString() !=
                                                                      '')
                                                              ? Colors.red[200]!
                                                                  .withOpacity(
                                                                      0.6)
                                                              : AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                      border: const Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black12,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.warning_sharp,
                                                          size: 15,
                                                          color:
                                                              Colors.amber[800],
                                                        ),
                                                        Text(
                                                          'ตรวจพบข้อมูลที่อาจซ้ำ..!! ( ${row[columnToCheck]} )',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontFamily:
                                                                  Font_.Fonts_T
                                                              //fontSize: 10.0
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : List_Material(index, columnHeaders,
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
                  ? MediaQuery.of(context).size.width * 0.83
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
  }

/////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Material(
      // surfaceTintColor: tappedIndex_Color
      //     .tappedIndex_Colors,
      color: tappedIndex_ == index.toString()
          ? tappedIndex_Color.tappedIndex_Colors
          : (hasDuplicate(row) && row[columnToCheck]?.toString() != '')
              ? Colors.red[200]!.withOpacity(0.6)
              : AppbackgroundColor.Sub_Abg_Colors,
      child: InkWell(
        hoverColor: Colors.grey[350]!.withOpacity(0.5),
        onTap: () async {
          int index_x = int.parse('${row['index']}');
          var ciddoc = TransReBillModels[index_x].cid;
          var docnoin = TransReBillModels[index_x].docno;
          // print(ciddoc);
          // print(docnoin);
          setState(() {
            tappedIndex_ = index.toString();
            red_Trans_select2(index_x);
            red_Finnan2(index_x);
          });
          await Dia_log1();
          Future.delayed(const Duration(milliseconds: 500), () {
            checkshowDialog(index_x);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            // color: Colors.green[100]!
            //     .withOpacity(0.5),
            border: (hasDuplicate(row) && row[columnToCheck]?.toString() != '')
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
          ),
          child: Row(children: [
            (_TransReBillModels[int.parse('${row['index']}')].type.toString() ==
                    'CASH')
                ? const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                        child: SizedBox(
                      width: 16,
                    )),
                  )
                : (_TransReBillModels[int.parse('${row['index']}')].slip ==
                            null ||
                        _TransReBillModels[int.parse('${row['index']}')]
                                .slip
                                .toString() ==
                            'null' ||
                        _TransReBillModels[int.parse('${row['index']}')]
                                .slip
                                .toString() ==
                            '')
                    ? Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                            child: Icon(
                          Icons.image_not_supported,
                          size: 16,
                          color: Colors.blueGrey[600],
                        )),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                            child: SizedBox(
                          width: 16,
                        )),
                      ),
            ((TransReBillModels[int.parse('${row['index']}')].type == null ||
                        TransReBillModels[int.parse('${row['index']}')]
                                .type
                                .toString() ==
                            '') &&
                    Type_doctax_ != 1)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                    child: Container(
                      width: 70,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50]!.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      width: 55,
                      padding: const EdgeInsets.all(1),
                      child: (Type_doctax_ == 1 &&
                              TransReBillModels[int.parse('${row['index']}')]
                                      .doctax
                                      .toString() !=
                                  '')
                          ? SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('ใบภาษี',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T))
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: (TransReBill_select.contains(
                                              '${TransReBillModels[int.parse('${row['index']}')].docno}') ==
                                          true)
                                      ? const Icon(Icons.check_box,
                                          size: 20,
                                          color: AppBarColors.ABar_Colors)
                                      : const Icon(
                                          Icons.check_box_outline_blank,
                                          size: 20,
                                          color: Colors.grey),
                                  onTap: () async {
                                    int index_x = int.parse('${row['index']}');
                                    setState(() {
                                      transReBill_select_delete.clear();
                                    });
                                    if (TransReBill_select.length >= 50) {
                                      setState(() {
                                        TransReBill_select.remove(
                                            '${TransReBillModels[index_x].docno}');
                                      });
                                      // Dialog_notimax(50);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'เลือกได้สูงสุด 50 รายการ...!!',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T))),
                                      );
                                    } else {
                                      setState(() {
                                        if (TransReBill_select.contains(
                                                '${TransReBillModels[index_x].docno}') ==
                                            true) {
                                          TransReBill_select.remove(
                                              '${TransReBillModels[index_x].docno}');
                                        } else {
                                          TransReBill_select.add(
                                              '${TransReBillModels[index_x].docno}');
                                        }
                                      });
                                    }
                                  },
                                ),

                                ///invoice_loade_Success

                                (Type_doctax_ == 1)
                                    ? Icon(
                                        Icons.repeat_on,
                                        // Icons.rebase_edit,
                                        // Icons.receipt_long,
                                        // Icons.auto_mode,
                                        size: 20,
                                        color: (transReBill_loade_Success.contains(
                                                    '${TransReBillModels[int.parse('${row['index']}')].docno}') ==
                                                true)
                                            ? Colors.orange[600]
                                            : Colors.grey[800],
                                      )
                                    : Icon(
                                        Icons.download,
                                        size: 20,
                                        color: (transReBill_loade_Success.contains(
                                                    '${TransReBillModels[int.parse('${row['index']}')].docno}') ==
                                                true)
                                            ? Colors.orange[600]
                                            : null,
                                      )
                              ],
                            ),
                    ),
                  ),
            ...columnHeaders
                .skip(1)
                .map((column) => (columnHeaders.any((columnx) {
                      return column.toString() == 'เลขที่สัญญา' ||
                          column.toString() == 'เลขที่ใบเสร็จ' ||
                          column.toString() == 'เลขที่ใบกำกับภาษี' ||
                          column.toString() == 'เลขที่ใบวางบิล' ||
                          column.toString() == 'รหัสอ้างอิง' ||
                          column.toString() == 'Ref1' ||
                          column.toString() == 'Ref2';
                    }))
                        ? Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่ใบเสร็จ' ||
                                  column.toString() == 'เลขที่ใบกำกับภาษี' ||
                                  column.toString() == 'เลขที่ใบวางบิล';
                            }))
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
                                      return column.toString() == 'จำนวนเงิน';
                                    }))
                                        ? TextAlign.right
                                        : (columnHeaders.any((columnx) {
                                            return column.toString() ==
                                                'ช่องทางชำระ';
                                          }))
                                            ? TextAlign.center
                                            : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              )
                            ]))
                        : Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่ใบเสร็จ' ||
                                  column.toString() == 'เลขที่ใบกำกับภาษี' ||
                                  column.toString() == 'เลขที่ใบวางบิล';
                            }))
                                ? Fix_Expan1
                                : Fix_Expan2,
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
                                      return column.toString() == 'ช่องทางชำระ';
                                    }))
                                      ? TextAlign.center
                                      : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ))
                .toList(),
            // Container(
            //   width: 100,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       // );
            //       int index_x = int.parse(
            //           '${row['index']}');

            //       setState(() {
            //         tappedIndex_ =
            //             index.toString();
            //         red_Trans_select2(index_x);
            //         red_Finnan2(index_x);
            //       });

            //       Future.delayed(
            //           const Duration(
            //               milliseconds: 500),
            //           () {
            //         checkshowDialog(index_x);
            //       });
            //     },
            //     child: Translate
            //         .TranslateAndSet_TextAutoSize(
            //             'เรียกดู',
            //             CustomerScreen_Color
            //                 .Colors_Text3_,
            //             TextAlign.center,
            //             null,
            //             Font_.Fonts_T,
            //             8,
            //             14,
            //             1),
            //   ),
            // )
          ]),
        ),
      ),
    );
  }

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
                    if (_TransReBillModels[index].inv != null &&
                        _TransReBillModels[index].inv.toString() != '')
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Row(
                          children: [
                            Translate.TranslateAndSetText(
                                'อ้างอิงใบวางบิลเลขที่ : ',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                            Text(
                              '${_TransReBillModels[index].inv2}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                  fontSize: 12.0
                                  //fontSize: 10.0
                                  ),
                            ),
                          ],
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
                                              TextAlign.center,
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
                                                        '${_TransReBillModels[index].docno}',
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
                                              if (_TransReBillModels[index]
                                                          .doctax !=
                                                      null &&
                                                  _TransReBillModels[index]
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
                                                          '${_TransReBillModels[index].doctax}',
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
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'รหัสพื้นที่',
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
                                      const Expanded(
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
                                            'ส่วนลด',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.end,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
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
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .ln ==
                                                                null)
                                                            ? ''
                                                            : '${_TransReBillHistoryModels[index].ln}',
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
                                                                    .dtype_tex
                                                                    .toString() ==
                                                                'INV')
                                                            ? '${_TransReBillHistoryModels[index].cid}'
                                                            : (_TransReBillHistoryModels[
                                                                            index]
                                                                        .refno ==
                                                                    null)
                                                                ? '-'
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
                                                                        .fine
                                                                        .toString() ==
                                                                    '1.00' &&
                                                                _TransReBillHistoryModels[
                                                                            index]
                                                                        .expname
                                                                        .toString()
                                                                        .trim() ==
                                                                    'null')
                                                            ? 'ค่าปรับ [${_TransReBillHistoryModels[index].inv}]'
                                                            : '${_TransReBillHistoryModels[index].expname}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: (_TransReBillHistoryModels[index]
                                                                            .fine
                                                                            .toString() ==
                                                                        '1.00' &&
                                                                    _TransReBillHistoryModels[index]
                                                                            .expname
                                                                            .toString()
                                                                            .trim() ==
                                                                        'null')
                                                                ? Colors.red
                                                                : PeopleChaoScreen_Color
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
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                                                        // '${_TransReBillHistoryModels[index].vat}',
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
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                        // '${_TransReBillHistoryModels[index].wht}',
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
                                                                    .dis ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].dis!))}',
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
                                                      child: double.parse(
                                                                  _TransReBillHistoryModels[
                                                                          index]
                                                                      .dis!) ==
                                                              0
                                                          ? AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 12,
                                                              maxLines: 1,
                                                              (_TransReBillHistoryModels[
                                                                              index]
                                                                          .total ==
                                                                      null)
                                                                  ? '0.00'
                                                                  : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            )
                                                          : Column(
                                                              children: [
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  (_TransReBillHistoryModels[index]
                                                                              .pvat ==
                                                                          null)
                                                                      ? '0.00'
                                                                      : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].pvat!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                      decorationColor:
                                                                          Colors
                                                                              .red,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  (_TransReBillHistoryModels[index]
                                                                              .total_t ==
                                                                          null)
                                                                      ? '0.00'
                                                                      : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total_t!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ],
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
                                              if (_TransReBillModels[index]
                                                      .ref1! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (_TransReBillModels[index]
                                                                .ref1 ==
                                                            null)
                                                        ? 'อ้างอิง : -'
                                                        : 'อ้างอิง : ${_TransReBillModels[index].ref1}',
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
                                              if (_TransReBillModels[index]
                                                      .ref2! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (_TransReBillModels[index]
                                                                .ref2 ==
                                                            null)
                                                        ? 'Ref1 : -'
                                                        : 'Ref1 : ${_TransReBillModels[index].ref2}',
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
                                              if (_TransReBillModels[index]
                                                      .ref4! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (_TransReBillModels[index]
                                                                .ref4 ==
                                                            null)
                                                        ? 'Ref2 : -'
                                                        : 'Ref2 : ${_TransReBillModels[index].ref4}',
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
                                                            '${i + 1}. Total : ${nFormat.format(double.parse(finnancetransModels[i].amt!))}  (${finnancetransModels[i].ptname})',
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
                                                  Expanded(
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
                                                    // Container(
                                                    //   width: 120,
                                                    //   child: Translate
                                                    //       .TranslateAndSetText(
                                                    //           'รวมราคาสินค้า/Sub Total',
                                                    //           AccountScreen_Color
                                                    //               .Colors_Text1_,
                                                    //           TextAlign.start,
                                                    //           null,
                                                    //           Font_.Fonts_T,
                                                    //           12,
                                                    //           1),
                                                    //   //   const AutoSizeText(
                                                    //   //   minFontSize: 8,
                                                    //   //   maxFontSize: 11,
                                                    //   //   'รวมราคาสินค้า/Sub Total',
                                                    //   //   style: TextStyle(
                                                    //   //       color: PeopleChaoScreen_Color
                                                    //   //           .Colors_Text2_,
                                                    //   //       //fontWeight: FontWeight.bold,
                                                    //   //       fontFamily: Font_
                                                    //   //           .Fonts_T),
                                                    //   // ),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        rental_ser != '106'
                                                            ? SizedBox()
                                                            : IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  // print(_TransReBillModels[
                                                                  //         index]
                                                                  //     .docno);
                                                                  if (renTal_lavel >
                                                                      3) {
                                                                    if (rental_degree_up ==
                                                                        '1') {
                                                                      new_dereee.text = sum_pvat
                                                                          .toString()
                                                                          .substring(sum_pvat.toString().indexOf('.') +
                                                                              1);
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (context) => AlertDialog(
                                                                            title: Center(
                                                                              child: Text(
                                                                                'ปรับจุดทศนิยม',
                                                                                maxLines: 1,
                                                                                textAlign: TextAlign.start,
                                                                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 20),
                                                                              ),
                                                                            ),
                                                                            content: Stack(
                                                                              alignment: Alignment.center,
                                                                              children: <Widget>[
                                                                                Container(
                                                                                    width: 250,
                                                                                    decoration: const BoxDecoration(
                                                                                      // color: Colors.black,
                                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                    ),
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          flex: 3,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.all(8.0),
                                                                                                child: Text('${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}'),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          flex: 2,
                                                                                          child: TextFormField(
                                                                                            //keyboardType: TextInputType.none,
                                                                                            controller: new_dereee,
                                                                                            // onChanged: (value) => value.trim(),
                                                                                            onFieldSubmitted: (value) async {
                                                                                              var new_amt = sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

                                                                                              //  print(_TransReBillModels[index].docno);
                                                                                              SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                              var ren = preferences.getString('renTalSer');
                                                                                              var docno = _TransReBillModels[index].docno;
                                                                                              var sum_amt_up = double.parse(new_amt);
                                                                                              var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

                                                                                              String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                                              try {
                                                                                                var response = await http.get(Uri.parse(url));

                                                                                                var result = json.decode(response.body);
                                                                                                if (result.toString() == 'true') {
                                                                                                  setState(() {
                                                                                                    sum_pvat = double.parse(new_amt);
                                                                                                    sum_vat = double.parse(new_amt.toString()) * 7 / 100;
                                                                                                    sum_amt = sum_pvat + sum_vat;

                                                                                                    // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
                                                                                                  });
                                                                                                }
                                                                                              } catch (e) {}

                                                                                              Navigator.pop(context, 'OK');
                                                                                            },
                                                                                            // maxLength: 13,
                                                                                            cursorColor: Colors.green,
                                                                                            decoration: InputDecoration(
                                                                                              fillColor: Colors.white.withOpacity(0.3),
                                                                                              filled: true,
                                                                                              // prefixIcon: const Icon(Icons.person, color: Colors.black),
                                                                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                              focusedBorder: const OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(15),
                                                                                                  topLeft: Radius.circular(15),
                                                                                                  bottomRight: Radius.circular(15),
                                                                                                  bottomLeft: Radius.circular(15),
                                                                                                ),
                                                                                                borderSide: BorderSide(
                                                                                                  width: 1,
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                              errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                              enabledBorder: const OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.only(
                                                                                                  topRight: Radius.circular(15),
                                                                                                  topLeft: Radius.circular(15),
                                                                                                  bottomRight: Radius.circular(15),
                                                                                                  bottomLeft: Radius.circular(15),
                                                                                                ),
                                                                                                borderSide: BorderSide(
                                                                                                  width: 1,
                                                                                                  color: Colors.black,
                                                                                                ),
                                                                                              ),
                                                                                              // labelText: 'USERNAME',
                                                                                              labelStyle: const TextStyle(
                                                                                                fontSize: 14,
                                                                                                color: Colors.black54,
                                                                                                fontFamily: Font_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                              //   // for below version 2 use this
                                                                                              //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
                                                                                              //       allow: true),
                                                                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                                                              //for version 2 and greater youcan also use this
                                                                                              FilteringTextInputFormatter.digitsOnly
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                            actions: <Widget>[
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Container(
                                                                                      width: 100,
                                                                                      decoration: const BoxDecoration(
                                                                                        color: Colors.black,
                                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: TextButton(
                                                                                        onPressed: () => Navigator.pop(context, 'OK'),
                                                                                        child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ]),
                                                                      );
                                                                    } else if (rental_degree_up ==
                                                                        '2') {
                                                                      // print(_TransReBillModels[
                                                                      //         index]
                                                                      //     .docno);
                                                                      SharedPreferences
                                                                          preferences =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      var ren =
                                                                          preferences
                                                                              .getString('renTalSer');
                                                                      var docno =
                                                                          _TransReBillModels[index]
                                                                              .docno;
                                                                      var sum_amt_up =
                                                                          sum_pvat
                                                                              .toPrecision(1);
                                                                      var sum_vat_up =
                                                                          sum_pvat.toPrecision(1) *
                                                                              7 /
                                                                              100;

                                                                      String
                                                                          url =
                                                                          '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                      try {
                                                                        var response =
                                                                            await http.get(Uri.parse(url));

                                                                        var result =
                                                                            json.decode(response.body);
                                                                        if (result.toString() ==
                                                                            'true') {
                                                                          setState(
                                                                              () {
                                                                            sum_pvat =
                                                                                sum_pvat.toPrecision(1);
                                                                            sum_vat = sum_pvat.toPrecision(1) *
                                                                                7 /
                                                                                100;
                                                                            sum_amt =
                                                                                sum_pvat + sum_vat;
                                                                          });
                                                                        }
                                                                      } catch (e) {}
                                                                    }
                                                                  } else {
                                                                    Dialog_updegree();
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .unfold_more,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                        AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          textAlign:
                                                              TextAlign.end,

                                                          // '${sum_pvat} // $dis_sum_Matjum',

                                                          _TransReBillModels[
                                                                          index]
                                                                      .round_p ==
                                                                  '1'
                                                              ? '${nFormat.format(double.parse(_TransReBillModels[index].amt_up!))}'
                                                              : '${nFormat.format(sum_pvat)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ],
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ภาษีมูลค่าเพิ่ม/Vat',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      _TransReBillModels[index]
                                                                  .round_p ==
                                                              '1'
                                                          ? (_TransReBillModels[
                                                                          index]
                                                                      .vat_up ==
                                                                  null)
                                                              ? '0.00'
                                                              : '${nFormat.format(double.parse(_TransReBillModels[index].vat_up!))}'
                                                          : (sum_vat == null)
                                                              ? '0.00'
                                                              : '${nFormat.format(sum_vat)}',
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'หัก ณ ที่จ่าย',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ค่าทำเนียม',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดรวม',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
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
                                              sum_dislist != 0
                                                  ? Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            children: [
                                                              Translate.TranslateAndSetText(
                                                                  'ส่วนลดรายการ',
                                                                  AccountScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  11,
                                                                  1),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 11,
                                                            '${nFormat.format(sum_dislist)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          // AutoSizeText(
                                                          //   minFontSize: 10,
                                                          //   maxFontSize: 15,
                                                          //   textAlign: TextAlign.end,
                                                          //   '${nFormat.format(0.00)}',
                                                          //   style: TextStyle(
                                                          //       color: PeopleChaoScreen_Color
                                                          //           .Colors_Text2_,
                                                          //       //fontWeight: FontWeight.bold,
                                                          //       fontFamily: Font_.Fonts_T),
                                                          // ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
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
                                                    //   style:
                                                    //       const TextStyle(
                                                    //           color: PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //           //fontWeight: FontWeight.bold,
                                                    //           fontFamily: Font_
                                                    //               .Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      '${nFormat.format(sum_disamt - sum_dislist)}',
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
                                                      //  AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 11,
                                                      //   'เงินมัดจำ(ตัดมัดจำ)',
                                                      //   style:
                                                      //       const TextStyle(
                                                      //           color: PeopleChaoScreen_Color
                                                      //               .Colors_Text2_,
                                                      //           //fontWeight: FontWeight.bold,
                                                      //           fontFamily:
                                                      //               Font_
                                                      //                   .Fonts_T),
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดชำระ',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                      '${nFormat.format((sum_amt - dis_sum_Matjum) + sum_duesbill)}',
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
                                                    //     const AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 11,
                                                    //   'ยอดสุทธิ',
                                                    //   style: TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       //fontWeight: FontWeight.bold,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
                                                    // ),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 11,
                                                      textAlign: TextAlign.end,
                                                      //  '${sum_amt - sum_disamt} // $dis_sum_Matjum',

                                                      // '${nFormat.format(sum_amt + sum_duesbill)}',
                                                      '${nFormat.format(sum_amt + sum_duesbill - (sum_disamt - sum_dislist))}',
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (Slip_history.toString() == '' ||
                                    Slip_history == null ||
                                    Slip_history.toString() == 'null')
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 150,
                                      height: 40,
                                      // ignore: deprecated_member_use
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        onPressed: () async {
                                          uploadFile_Slip_Again(
                                              context,
                                              '${_TransReBillModels[index].docno}',
                                              '${_TransReBillModels[index].pdate}',
                                              'ประวัติชำระ',
                                              '${_TransReBillModels[index].slip}',
                                              foder);
                                        },
                                        child: Translate.TranslateAndSetText(
                                            ' + เพิ่มหลักฐาน',
                                            Colors.grey[300],
                                            // Colors.white,
                                            TextAlign.start,
                                            null,
                                            Font_.Fonts_T,
                                            14,
                                            1),
                                      ),
                                    ),
                                  ),
                                (Slip_history.toString() == '' ||
                                        Slip_history == null ||
                                        Slip_history.toString() == 'null')
                                    ? const SizedBox()
                                    : Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: 200,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                bool hasNonCashTransaction =
                                                    finnancetransModels
                                                        .any((transaction) {
                                                  return transaction.ptser
                                                          .toString()
                                                          .trim() ==
                                                      '7';
                                                });

                                                ///finnancetransModels
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
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
                                                    title: Center(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          4.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .highlight_off,
                                                                      size: 30,
                                                                      color: Colors
                                                                              .red[
                                                                          700]),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            '${_TransReBillModels[index].docno} ',
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                fontSize: 12.0),
                                                          ),
                                                          (hasNonCashTransaction ==
                                                                  true)
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(2.0),
                                                                        child:
                                                                            Text(
                                                                          '${Slip_history}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: Colors.grey,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                              fontSize: 12.0),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          final String
                                                                              url =
                                                                              '${Slip_history}';
                                                                          if (await canLaunch(
                                                                              url)) {
                                                                            await launch(url);
                                                                          } else {
                                                                            throw 'Could not launch $url';
                                                                          }
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .open_in_browser,
                                                                          color:
                                                                              Colors.blue,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ])
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      '${Slip_history}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontFamily: FontWeight_
                                                                              .Fonts_T,
                                                                          fontSize:
                                                                              12.0),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () => downloadImage_slip(
                                                                          '${MyConstant().domain}/files/$foder/slip/${Slip_history}',
                                                                          '${_TransReBillModels[index].docno}'),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .download,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    content: (hasNonCashTransaction ==
                                                            true)
                                                        ? StreamBuilder(
                                                            stream:
                                                                Stream.periodic(
                                                                    const Duration(
                                                                        seconds:
                                                                            0)),
                                                            builder: (context,
                                                                snapshot) {
                                                              return SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: <Widget>[
                                                                    Container(
                                                                      // height: 600,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child: WebViewX2Pagebeamcheck(
                                                                          id_ser:
                                                                              Slip_history),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            })
                                                        : Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: <Widget>[
                                                              Image.network(
                                                                  '${MyConstant().domain}/files/$foder/slip/${Slip_history}')
                                                            ],
                                                          ),
                                                    //     actions: <Widget>[
                                                    //   Column(
                                                    //     children: [
                                                    //       const SizedBox(
                                                    //         height: 5.0,
                                                    //       ),
                                                    //       const Divider(
                                                    //         color:
                                                    //             Colors.grey,
                                                    //         height: 4.0,
                                                    //       ),
                                                    //       const SizedBox(
                                                    //         height: 5.0,
                                                    //       ),
                                                    //       Row(
                                                    //         mainAxisAlignment:
                                                    //             MainAxisAlignment
                                                    //                 .center,
                                                    //         children: [
                                                    //           Padding(
                                                    //             padding:
                                                    //                 const EdgeInsets.all(
                                                    //                     8.0),
                                                    //             child:
                                                    //                 Container(
                                                    //               width:
                                                    //                   100,
                                                    //               decoration:
                                                    //                   const BoxDecoration(
                                                    //                 color: Colors
                                                    //                     .black,
                                                    //                 borderRadius: BorderRadius.only(
                                                    //                     topLeft:
                                                    //                         Radius.circular(10),
                                                    //                     topRight: Radius.circular(10),
                                                    //                     bottomLeft: Radius.circular(10),
                                                    //                     bottomRight: Radius.circular(10)),
                                                    //               ),
                                                    //               padding:
                                                    //                   const EdgeInsets.all(
                                                    //                       8.0),
                                                    //               child:
                                                    //                   TextButton(
                                                    //                 onPressed: () => Navigator.pop(
                                                    //                     context,
                                                    //                     'OK'),
                                                    //                 child:
                                                    //                     const Text(
                                                    //                   'ปิด',
                                                    //                   style: TextStyle(
                                                    //                       color: Colors.white,
                                                    //                       fontWeight: FontWeight.bold,
                                                    //                       fontFamily: FontWeight_.Fonts_T),
                                                    //                 ),
                                                    //               ),
                                                    //             ),
                                                    //           ),
                                                    //         ],
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ]
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[200],
                                                        borderRadius: BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    6),
                                                            topRight: (renTal_lavel <=
                                                                    2)
                                                                ? Radius
                                                                    .circular(6)
                                                                : Radius.circular(
                                                                    0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                (renTal_lavel <=
                                                                        2)
                                                                    ? Radius
                                                                        .circular(
                                                                            6)
                                                                    : Radius
                                                                        .circular(
                                                                            0)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Icon(
                                                                Icons.image,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Translate.TranslateAndSetText(
                                                                'หลักฐานการชำระ',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            //  Text(
                                                            //   'หลักฐานการชำระ',
                                                            //   style: TextStyle(
                                                            //     color:
                                                            //         AccountScreen_Color
                                                            //             .Colors_Text2_,
                                                            //     // fontWeight:
                                                            //     //     FontWeight.bold,
                                                            //     fontFamily:
                                                            //         Font_.Fonts_T,
                                                            //   ),
                                                            // ),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                            (renTal_lavel <= 2)
                                                ? Container()
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(0),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          6)),
                                                      // border: Border.all(
                                                      //     color: Colors.grey,
                                                      //     width: 1),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          uploadFile_Slip_Again(
                                                              context,
                                                              '${_TransReBillModels[index].docno}',
                                                              '${_TransReBillModels[index].pdate}',
                                                              'ประวัติชำระ',
                                                              '${_TransReBillModels[index].slip}',
                                                              foder);
                                                        },
                                                        child: Icon(Icons.edit,
                                                            color: Colors
                                                                .grey[300]),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: 250,
                                  child: InkWell(
                                    onTap: (Cancell_bill.toString() == '1')
                                        ? null
                                        : (DateTime.parse(
                                                        '${_TransReBillModels[index].datex} 00:00:00')
                                                    .add(Duration(
                                                        days: int.parse(
                                                            '${Day_Cancell_bill}')))
                                                    .isBefore(datex) &&
                                                Day_Cancell_bill.toString() !=
                                                    '0')
                                            ? null
                                            : () {
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                    title: Center(
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ยกเลิกการรับชำระ',
                                                              Colors.red,
                                                              TextAlign.start,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                    ),
                                                    content: Container(
                                                      height: 120,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 2.0,
                                                          ),
                                                          Translate.TranslateAndSetText(
                                                              'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.start,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),
                                                          // Text(
                                                          //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                          //   style:
                                                          //       const TextStyle(
                                                          //           color: AccountScreen_Color
                                                          //               .Colors_Text2_,
                                                          //           // fontWeight:
                                                          //           //     FontWeight.bold,
                                                          //           fontFamily:
                                                          //               Font_
                                                          //                   .Fonts_T),
                                                          // ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  Formbecause_,
                                                              validator:
                                                                  (value) {
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
                                                              // maxLength: 13,
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
                                                                            BorderRadius.only(
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
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      enabledBorder:
                                                                          const OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.only(
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
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      labelText:
                                                                          'หมายเหตุ-Note',
                                                                      labelStyle:
                                                                          const TextStyle(
                                                                        color: AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
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
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          // ignore: deprecated_member_use
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                            ),
                                                            onPressed: () {
                                                              String
                                                                  Formbecause =
                                                                  Formbecause_
                                                                      .text
                                                                      .toString();
                                                              if (Formbecause ==
                                                                  '') {
                                                                showDialog<
                                                                    String>(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      AlertDialog(
                                                                    shape: const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(20.0))),
                                                                    title:
                                                                        Center(
                                                                      child: Translate.TranslateAndSetText(
                                                                          'กรุณากรอกเหตุผล !!',
                                                                          AccountScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          null,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //     Text(
                                                                      //   'กรุณากรอกเหตุผล !!',
                                                                      //   style: TextStyle(
                                                                      //       color: AdminScafScreen_Color
                                                                      //           .Colors_Text1_,
                                                                      //       fontWeight: FontWeight
                                                                      //           .bold,
                                                                      //       fontFamily:
                                                                      //           FontWeight_.Fonts_T),
                                                                      // )
                                                                    ),
                                                                    actions: <Widget>[
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              width: 100,
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.redAccent,
                                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                              ),
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: TextButton(
                                                                                onPressed: () => Navigator.pop(context, 'OK'),
                                                                                child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                                                                                //  const Text(
                                                                                //   'ปิด',
                                                                                //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                // ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                pPC_finantIbill(
                                                                    Formbecause);
                                                                setState(() {
                                                                  Formbecause_
                                                                      .clear();
                                                                });
                                                                Navigator.pop(
                                                                    context,
                                                                    'OK');
                                                              }
                                                            },
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ยืนยัน',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .center,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),

                                                            // color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          // ignore: deprecated_member_use
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.black,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                Formbecause_
                                                                    .clear();
                                                              });
                                                              Navigator.pop(
                                                                  context,
                                                                  'OK');
                                                            },
                                                            child:
                                                                // Translate.TranslateAndSetText(
                                                                //     'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                                //     AccountScreen_Color
                                                                //         .Colors_Text2_,
                                                                //     TextAlign.start,
                                                                //     null,
                                                                //     Font_.Fonts_T,
                                                                //     14,
                                                                //     1),
                                                                const Text(
                                                              'ปิด',
                                                              style: TextStyle(
                                                                // fontSize: 20.0,
                                                                // fontWeight: FontWeight.bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            // color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (Cancell_bill.toString() ==
                                                  '1')
                                              ? Colors.grey[200]
                                              : (DateTime.parse(
                                                              '${_TransReBillModels[index].datex} 00:00:00')
                                                          .add(Duration(
                                                              days: int.parse(
                                                                  '${Day_Cancell_bill}')))
                                                          .isBefore(datex) &&
                                                      Day_Cancell_bill
                                                              .toString() !=
                                                          '0')
                                                  ? Colors.grey[200]
                                                  : Colors.orange[200],
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: (Cancell_bill.toString() == '1')
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Icon(
                                                        Icons
                                                            .cancel_presentation,
                                                        color: Colors.grey),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                            AccountScreen_Color
                                                                .Colors_Text2_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                    //  Text(
                                                    //   'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                    //   style: TextStyle(
                                                    //     color:
                                                    //         AccountScreen_Color
                                                    //             .Colors_Text2_,
                                                    //     // fontWeight:
                                                    //     //     FontWeight.bold,
                                                    //     fontFamily:
                                                    //         Font_.Fonts_T,
                                                    //   ),
                                                    // )
                                                  ),
                                                ],
                                              )
                                            : (DateTime.parse(
                                                            '${_TransReBillModels[index].datex} 00:00:00')
                                                        .add(Duration(
                                                            days: int.parse(
                                                                '${Day_Cancell_bill}')))
                                                        .isBefore(datex) &&
                                                    Day_Cancell_bill
                                                            .toString() !=
                                                        '0')
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(
                                                            Icons
                                                                .cancel_presentation,
                                                            color: Colors.grey),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  Text(
                                                        //   'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                        //   style: TextStyle(
                                                        //     color: AccountScreen_Color
                                                        //         .Colors_Text2_,
                                                        //     // fontWeight:
                                                        //     //     FontWeight.bold,
                                                        //     fontFamily:
                                                        //         Font_.Fonts_T,
                                                        //   ),
                                                        // )
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(
                                                            Icons
                                                                .cancel_presentation,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ยกเลิกการรับชำระ',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  Text(
                                                        //   'ยกเลิกการรับชำระ',
                                                        //   style: TextStyle(
                                                        //     color: AccountScreen_Color
                                                        //         .Colors_Text2_,
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
                                _TransReBillModels[index].doctax == ''
                                    ? Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: 250,
                                        child: InkWell(
                                          onTap: () {
                                            List newValuePDFimg = [];
                                            for (int index = 0;
                                                index < 1;
                                                index++) {
                                              if (renTalModels[0]
                                                      .imglogo!
                                                      .trim() ==
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
                                                  '${_TransReBillHistoryModels[index].nvat}',
                                                  '${_TransReBillHistoryModels[index].vtype}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                ],
                                            ];
                                            String sname = _TransReBillModels[
                                                            index]
                                                        .sname ==
                                                    null
                                                ? '${_TransReBillModels[index].remark}'
                                                : '${_TransReBillModels[index].sname}';
                                            String cname =
                                                '${_TransReBillModels[index].cname}';
                                            String addr =
                                                '${_TransReBillModels[index].addr}';
                                            String tax =
                                                '${_TransReBillModels[index].tax}';

                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                title: Center(
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'เปลี่ยนเป็นใบกำกับภาษีหรือไม่',
                                                          Colors.red,
                                                          TextAlign.start,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                  //     Text(
                                                  //   'เปลี่ยนเป็นใบกำกับภาษีหรือไม่',
                                                  //   style: TextStyle(
                                                  //       color: Colors.red,
                                                  //       fontWeight:
                                                  //           FontWeight.bold,
                                                  //       fontFamily:
                                                  //           FontWeight_.Fonts_T),
                                                  // )
                                                ),
                                                content: Container(
                                                  height: 120,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 2.0,
                                                      ),
                                                      Translate.TranslateAndSetText(
                                                          'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.start,
                                                          null,
                                                          Font_.Fonts_T,
                                                          14,
                                                          1),
                                                      // Text(
                                                      //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                      //   style: const TextStyle(
                                                      //       color: AccountScreen_Color
                                                      //           .Colors_Text2_,
                                                      //       // fontWeight:
                                                      //       //     FontWeight.bold,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width: 150,
                                                      height: 40,
                                                      // ignore: deprecated_member_use
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                        onPressed: () {
                                                          // Navigator.pop(
                                                          //     context,
                                                          //     'OK');
                                                          pPC_finantIbillREbill(
                                                              tableData00,
                                                              sname,
                                                              cname,
                                                              addr,
                                                              tax,
                                                              newValuePDFimg,
                                                              finnancetransModels);
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ยืนยัน',
                                                                Colors.white,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        // const Text(
                                                        //   'ยืนยัน',
                                                        //   style: TextStyle(
                                                        //     // fontSize: 20.0,
                                                        //     // fontWeight: FontWeight.bold,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        // color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width: 150,
                                                      height: 40,
                                                      // ignore: deprecated_member_use
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.black,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปิด',
                                                                Colors.white,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  const Text(
                                                        //   'ปิด',
                                                        //   style: TextStyle(
                                                        //     // fontSize: 20.0,
                                                        //     // fontWeight: FontWeight.bold,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        // color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green[200],
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
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Icon(Icons.refresh,
                                                        color: Colors.black),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'เปลี่ยนสถานะบิล',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                    //  Text(
                                                    //   'เปลี่ยนสถานะบิล',
                                                    //   style: TextStyle(
                                                    //     color:
                                                    //         AccountScreen_Color
                                                    //             .Colors_Text2_,
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
                                      )
                                    : const SizedBox(),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: 200,
                                  child: InkWell(
                                    onTap: () {
                                      Insert_log.Insert_logs('บัญชี',
                                          'ประวัติบิล>>ลดหนี้(${_TransReBillModels[index].docno})');
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red[200],
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
                                              child: Icon(Icons.cancel_outlined,
                                                  color: Colors.black),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ลดหนี้',
                                                      AccountScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.start,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                              //  Text(
                                              //   'ลดหนี้',
                                              //   style: TextStyle(
                                              //     color: AccountScreen_Color
                                              //         .Colors_Text2_,
                                              //     // fontWeight:
                                              //     //     FontWeight.bold,
                                              //     fontFamily: Font_.Fonts_T,
                                              //   ),
                                              // ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: 200,
                                  child: InkWell(
                                    onTap: () async {
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
                                      // final tableData00 = [
                                      //   for (int index = 0;
                                      //       index <
                                      //           _TransReBillHistoryModels
                                      //               .length;
                                      //       index++)
                                      //     [
                                      //       '${index + 1}',
                                      //       '${_TransReBillHistoryModels[index].date}',
                                      //       '${_TransReBillHistoryModels[index].expname}',
                                      //       '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                      //       '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                      //       '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                      //       '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                      //     ],
                                      // ];

                                      String sname = _TransReBillModels[index]
                                                  .sname ==
                                              null
                                          ? '${_TransReBillModels[index].remark}'
                                          : '${_TransReBillModels[index].sname}';
                                      String cname =
                                          '${_TransReBillModels[index].cname}';
                                      String addr =
                                          '${_TransReBillModels[index].addr}';
                                      String tax =
                                          '${_TransReBillModels[index].tax}';
                                      String room_number_BillHistory =
                                          '${_TransReBillModels[index].room_number}';
                                      // print(
                                      //     'room_number ------> ${_TransReBillModels[index].room_number}');

                                      _showMyDialog_SAVE(
                                          // tableData00,
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
                                            const Padding(
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
                                              //  Text(
                                              //   'พิมพ์',
                                              //   style: TextStyle(
                                              //     color: Colors.white,
                                              //     // fontWeight:
                                              //     //     FontWeight.bold,
                                              //     fontFamily: Font_.Fonts_T,
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
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  ////////////------------------------------------------------------>
  Future<Null> pPC_finantIbill(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    // print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          // _InvoiceModels.clear();
          // _InvoiceHistoryModels.clear();
          _TransReBillHistoryModels.clear();
          // numinvoice = null;
          // sum_disamtx.text = '0.00';
          // sum_dispx.text = '0.00';
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;
          // select_page = 0;
          // red_Trans_bill();
          Loading_Trans_bill();
          finnancetransModels.clear();
          Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ////////////------------------------------------------------------>

  Future<Null> pPC_finantIbillREbill(tableData00, sname, cname, addr, tax,
      newValuePDFimg, finnancetransModels) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var numin = numinvoice;
    var doctax;
    String room_number_BillHistory = '';

    String url =
        '${MyConstant().domain}/UPC_finant_billREbill.php?isAdd=true&ren=$ren&user=$user&numin=$numin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'No') {
        for (var map in result) {
          TransReBillModel cFinnancetransModel = TransReBillModel.fromJson(map);
          setState(() {
            doctax = cFinnancetransModel.doctax;
            numdoctax = cFinnancetransModel.doctax;
          });
          if (cFinnancetransModel.room_number != '' ||
              cFinnancetransModel.room_number != null) {
            setState(() {
              room_number_BillHistory =
                  cFinnancetransModel.room_number.toString();
            });
          }
        }
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>เปลี่ยนสถานะบิล(ร้าน:$sname,${numinvoice}-->$doctax)');

        setState(() async {
          _TransReBillHistoryModels.clear();

          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;
          Loading_Trans_bill();
          // red_Trans_bill();

          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    } catch (e) {}
  }

  Future<Null> pPC_finantIbillREbill2(docno_for) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var numin_s = docno_for;

    String url =
        '${MyConstant().domain}/UPC_finant_billREbill.php?isAdd=true&ren=$ren&user=$user&numin=$numin_s';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      if (result.toString() != 'No') {
        //    print('result : Yes');
      }
    } catch (e) {}
  }

  ////////////------------------------------------------------------>
  Future<void> pPC_finantIbillREbill_All() async {
    TransReBill_select.sort((a, b) => a.compareTo(b));
    int invoice_select_Ser = 0;
    String invoice_Now = '';

    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
    bool innerloop = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
            return Form(
              key: _formKey,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: SingleChildScrollView(
                  child: (invoice_select_Ser == 1)
                      ? ListBody(children: <Widget>[
                          Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      innerloop = false;
                                      TransReBill_select.clear();
                                    });

                                    Future.delayed(const Duration(seconds: 2));
                                    Navigator.pop(context, 'OK');
                                  },
                                  child: Icon(Icons.cancel_outlined,
                                      color: Colors.red))),
                          Center(
                              child: SizedBox(
                            height: 80,
                            width: 200,
                            child: Image.asset(
                              "images/chaoperty_dark.png",
                              fit: BoxFit.fill,
                              height: 80,
                              width: 200,
                            ),
                            // CircularProgressIndicator()
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                (innerloop == false)
                                    ? 'กำลังหยุดดำเนินการ...'
                                    : '${invoice_Now} ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (innerloop == false)
                                      ? Colors.red
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ])
                      : ListBody(
                          children: <Widget>[
                            Text(
                              'ดำเนินการ ทั้งหมด : ${TransReBill_select.length} รายการ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                          ],
                        ),
                ),
                actions: (invoice_select_Ser == 1)
                    ? null
                    : <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    invoice_select_Ser = 1;
                                  });
                                  try {
                                    for (int index = 0;
                                        index < TransReBill_select.length;
                                        index++) {
                                      innerloop_for:
                                      try {
                                        if (index == 0) {
                                          setState(() {
                                            preferences.setString(
                                                'Select_UP_Success', 'Not_OK');
                                          });
                                        }
                                        if (innerloop == false) {
                                          // print('stop/break ');
                                          setState(() {
                                            preferences.setString('name_page',
                                                '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()}');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   Navigator.pop(context, 'OK');
                                          // });
                                          break innerloop_for;
                                        }
                                        var docno = TransReBill_select[index]
                                            .toString();
                                        setState(() {
                                          numinvoice =
                                              TransReBill_select[index];
                                          invoice_Now =
                                              'กำลังดำเนินการ (${index + 1} / ${TransReBill_select.length}) : ${TransReBill_select[index]}';
                                        });

                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        await pPC_finantIbillREbill2(docno);

                                        setState(() {
                                          transReBill_loade_Success.add(
                                              TransReBill_select[index]
                                                  .toString());
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (index + 1 ==
                                            TransReBill_select.length) {
                                          await Future.delayed(const Duration(
                                              milliseconds: 400));
                                          setState(() {
                                            preferences.setString('name_page',
                                                'ใบเสร็จ_${currentPage_1 + 1}of${(filteredData.length / rowsPerPage_1).ceil()}($MONTH_Now-$YEAR_Now)');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            Insert_log.Insert_logs('บัญชี',
                                                'ประวัติบิล>>เปลี่ยนสถานะบิล(แบบหลายรายการ)');
                                            setState(() async {
                                              _TransReBillHistoryModels.clear();

                                              sum_pvat = 0.00;
                                              sum_vat = 0.00;
                                              sum_wht = 0.00;
                                              sum_amt = 0.00;
                                              sum_dis = 0.00;
                                              sum_disamt = 0.00;
                                              sum_disp = 0;
                                              Loading_Trans_bill();
                                              // red_Trans_bill();

                                              Navigator.pop(context, 'OK');
                                            });
                                          });
                                          await Future.delayed(
                                              const Duration(seconds: 3));
                                          break innerloop_for;
                                        }
                                      } catch (e) {
                                        break innerloop_for;
                                      }
                                    }
                                  } catch (e) {
                                    Navigator.pop(context, 'OK');
                                  }
                                },
                                child: Container(
                                  width: 110,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                    child: Text(
                                      'เปลี่ยนสถานะ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold, color:

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () => Navigator.pop(context, 'OK'),
                                child: Container(
                                  width: 110,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                    child: Text(
                                      'ปิด',
                                      style: TextStyle(
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold, color:

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
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
      },
    );
  }

  ////////////------------------------------------------------------>(Export file All)
  Future<void> _showMyDialog_SAVE_All(newValuePDFimg, Folder_File) async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    // String? TitleType_Default_Receipt_Name;
    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
    bool innerloop = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
            return Form(
              key: _formKey,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: SingleChildScrollView(
                  child: (invoice_select_Ser == 1)
                      ? ListBody(children: <Widget>[
                          Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      innerloop = false;
                                      TransReBill_select.clear();
                                    });

                                    Future.delayed(const Duration(seconds: 2));
                                    Deleted_foder(context).then((value) {
                                      Future.delayed(
                                          const Duration(seconds: 2));
                                      Navigator.pop(context, 'OK');
                                    });
                                  },
                                  child: Icon(Icons.cancel_outlined,
                                      color: Colors.red))),
                          Center(
                              child: SizedBox(
                            height: 80,
                            width: 200,
                            child: Image.asset(
                              "images/chaoperty_dark.png",
                              fit: BoxFit.fill,
                              height: 80,
                              width: 200,
                            ),
                            // CircularProgressIndicator()
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                (innerloop == false)
                                    ? 'กำลังหยุดดำเนินการ...'
                                    : '${invoice_Now} ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (innerloop == false)
                                      ? Colors.red
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ])
                      : ListBody(
                          children: <Widget>[
                            Text(
                              'ดำเนินการ ทั้งหมด : ${TransReBill_select.length} รายการ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                            const Text(
                              'หัวบิล :',
                              style: TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
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
                                  // print(TitleType_Default_Receipt_Name);
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
                            ),
                          ],
                        ),
                ),
                actions: (invoice_select_Ser == 1)
                    ? null
                    : <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    invoice_select_Ser = 1;
                                  });
                                  try {
                                    for (int index = 0;
                                        index < TransReBill_select.length;
                                        index++) {
                                      innerloop_for:
                                      try {
                                        if (index == 0) {
                                          setState(() {
                                            preferences.setString(
                                                'Select_UP_Success', 'Not_OK');
                                          });
                                        }
                                        if (innerloop == false) {
                                          // print('stop/break ');
                                          setState(() {
                                            preferences.setString('name_page',
                                                '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()}');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   Navigator.pop(context, 'OK');
                                          // });
                                          break innerloop_for;
                                        }
                                        var docno = TransReBill_select[index]
                                            .toString();
                                        setState(() {
                                          numinvoice =
                                              TransReBill_select[index];
                                          invoice_Now =
                                              'กำลังดำเนินการ (${index + 1} / ${TransReBill_select.length}) : ${TransReBill_select[index]}';
                                        });
                                        var namenew = '';

                                        String sname = TransReBillModels[index]
                                                    .sname ==
                                                null
                                            ? '${TransReBillModels[index].remark}'
                                            : '${TransReBillModels[index].sname}';
                                        String cname =
                                            '${TransReBillModels[index].cname}';
                                        String addr =
                                            '${TransReBillModels[index].addr}';
                                        String tax =
                                            '${TransReBillModels[index].tax}';
                                        String room_number_BillHistory =
                                            '${TransReBillModels[index].room_number}';
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        await Receipt_his_statusbill(
                                            // tableData00,
                                            newValuePDFimg,
                                            sname,
                                            cname,
                                            addr,
                                            tax,
                                            room_number_BillHistory,
                                            TitleType_Default_Receipt_Name,
                                            '$Folder_File');

                                        setState(() {
                                          transReBill_loade_Success.add(
                                              TransReBill_select[index]
                                                  .toString());
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (index + 1 ==
                                            TransReBill_select.length) {
                                          await Future.delayed(const Duration(
                                              milliseconds: 400));
                                          setState(() {
                                            preferences.setString('name_page',
                                                'ใบเสร็จ_${currentPage_1 + 1}of${(filteredData.length / rowsPerPage_1).ceil()}($MONTH_Now-$YEAR_Now)');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            // print('')

                                            Navigator.pop(context, 'OK');
                                            if (Folder_File! == 'Folder') {
                                              Dialog_Download_Foder(context);
                                            }
                                          });
                                          await Future.delayed(
                                              const Duration(seconds: 3));
                                          break innerloop_for;
                                        }
                                      } catch (e) {
                                        break innerloop_for;
                                      }
                                    }
                                  } catch (e) {
                                    Navigator.pop(context, 'OK');
                                  }
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
                                  child: const Center(
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold, color:

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
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
                                  child: const Center(
                                    child: Text(
                                      'ปิด',
                                      style: TextStyle(
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold, color:

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
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
      },
    );
  }

  ////////////------------------------------------------------------>(Export file)
  Future<void> _showMyDialog_SAVE(
      newValuePDFimg, sname, cname, addr, tax, room_number_BillHistory) async {
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
                      onTap: () async {
                        Dia_log2();
                        Receipt_his_statusbill(
                            // tableData00,
                            newValuePDFimg,
                            sname,
                            cname,
                            addr,
                            tax,
                            room_number_BillHistory,
                            TitleType_Default_Receipt_Name,
                            '0');
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
                          child: Text(
                            'พิมพ์',
                            style: TextStyle(
                              color: Colors.white,
                              //fontWeight: FontWeight.bold, color:

                              // fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
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
                          child: Text(
                            'ปิด',
                            style: TextStyle(
                              color: Colors.white,
                              //fontWeight: FontWeight.bold, color:

                              // fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
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

/////////////---------------------------------------------------->
  Dia_log1() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext builderContext) {
          Timer(Duration(milliseconds: 230), () {
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
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext builderContext) {
          Timer(Duration(milliseconds: 400), () {
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

  ////////////------------------------------------------------------>
  Dialog_updegree() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "User ของท่านไม่สามารถทำการปรับจุดทศนิยมได้ !!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

///////////--------------------------------->
  Dialog_duplicates() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ไม่พบรายการที่ชำระใบวางบิลที่ซ้ำกัน (No duplicates found) !!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        setState(() {
          // สลับสถานะการแสดงผล
          showDuplicatesOnly = !showDuplicatesOnly;
        });
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

///////////--------------------------------->
  Future<Null> Receipt_his_statusbill(
      // tableData00,
      newValuePDFimg,
      sname,
      cname,
      addr,
      tax,
      room_number_BillHistory,
      TitleType_Default_Receipt_Name,
      Preview_ser) async {
    ManPay_Receipt_PDF.ManPayReceipt_PDF(
        numinvoice,
        context,
        foder,
        renTal_name,
        // sname,
        // cname,
        // addr,
        // tax,
        bill_addr,
        bill_email,
        bill_tel,
        bill_tax,
        bill_name,
        newValuePDFimg,
        TitleType_Default_Receipt_Name,
        tem_page_ser,
        bills_name_,
        '$Preview_ser');
  }
}
