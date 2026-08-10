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

///bill_payCancel_BC()
class Account_Cancel_BillPay extends StatefulWidget {
  @override
  _Account_Cancel_BillPayState createState() => _Account_Cancel_BillPayState();
}

class _Account_Cancel_BillPayState extends State<Account_Cancel_BillPay> {
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();

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
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac9_1 = [];

  List<int> Fix_data = [4, 5, 6];

  ///////////--------------------------------------------->

  int Fix_Expan1 = 2, Fix_Expan2 = 1;
  ///////////--------------------------------------------->
  String? numinvoice;

  ///////////--------------------------------------------->
  var round_p, paper, paper_run;

  //-------------------------------------->
  int Ser_Tap = 0;
  int Status_ = 1;
  int renTal_lavel = 0;
  int type_docx = 0, Date_Typepay = 1;

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
  String sortColumn = "วันที่รับชำระ";
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

      ac9_1.addAll(AcListTitle().ac9_1);
    });
  }

  where_ac9_1(String ser) {
    if (ac9_1
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

            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    red_Trans_billCancel().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

  ////////-------------------------------------------------------->
  Future<Null> red_Trans_billCancel() async {
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
    var zone = preferences.getString('zonePSer');
    // var qutser = widget.Get_Value_NameShop_index; ***GC_billZone_payCancel_BC
    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_bill_payCancel_BC.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone&date_type=$Date_Typepay'
        : '${MyConstant().domain}/GC_billZone_payCancel_BC.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone&date_type=$Date_Typepay';
    // String url =
    //     '${MyConstant().domain}/GC_bill_pay_BC.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          // if (transReBillModel.pos != '1') {
          setState(() {
            TransReBillModels.add(transReBillModel);

            // _TransBillModels.add(_TransBillModel);
          });
          // }
        }
        setState(() {
          _TransReBillModels = TransReBillModels;
        });
        // print('result ${_TransReBillModels.length}');
      }
      AddDaTa();
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
          final remark = TransReBillModels[index].remark ?? "";
          return {
            "index": "$index",
            if (where_ac9_1("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac9_1("1") == false) "วันที่ทำรายการ": "$daterec",
            if (where_ac9_1("2") == false) "วันที่รับชำระ": "$pdate",
            if (where_ac9_1("3") == false) "เลขที่ใบเสร็จ": "$docno",
            if (where_ac9_1("4") == false) "เลขที่ใบกำกับภาษี": "$doctax",
            if (where_ac9_1("5") == false) "เลขที่ใบวางบิล": "$doc_inv",
            if (where_ac9_1("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac9_1("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac9_1("8") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac9_1("9") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac9_1("10") == false) "จำนวนเงิน": "$total",
            if (where_ac9_1("11") == false) "กำหนดชำระ": "$bill_duedate",
            if (where_ac9_1("12") == false) "ช่องทางชำระ": "$pay_type",
            if (where_ac9_1("13") == false) "ทำรายการ": "$pay_by",
            if (where_ac9_1("14") == false) "สถานะ": "$type_bill",
            if (where_ac9_1("15") == false) "เหตุผล": "$remark",
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
    // print('red_Trans_select2 $url');

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
        '${MyConstant().domain}/GC_bill_pay_amtCancel.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
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
    double calculatedWidth =
        (ac9_1.where((item) => item["st"] == '1').toList().length <= 9)
            ? (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.85
                : 1400
            : (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.85 +
                    ((ac9_1.where((item) => item["st"] == '1').toList().length -
                            9) *
                        30)
                : 1400 +
                    ((ac9_1.where((item) => item["st"] == '1').toList().length -
                            9) *
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

                            items: ac9_1.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac9_1.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac9_1[selectedIndex]["st"] = '0';
                                          } else {
                                            ac9_1[selectedIndex]["st"] = '1';
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
                                          //  print(Date_Typepay);
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
                )

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
                                    flex: (Fix_data.contains(
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
                                                          'จำนวนเงิน';
                                                    }))
                                                        ? TextAlign.right
                                                        : (columnHeaders
                                                                .any((columnx) {
                                                            return column
                                                                        .toString() ==
                                                                    'ช่องทางชำระ' ||
                                                                column.toString() ==
                                                                    'เหตุผล';
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
                                                          maxLines: 2,
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
          await Dia_log1();
          int index_x = int.parse('${row['index']}');
          // var ciddoc = TransReBillModels[index_x].cid;
          // var docnoin = TransReBillModels[index_x].docno;
          // print(ciddoc);
          // print(docnoin);
          setState(() {
            tappedIndex_ = index.toString();
            red_Trans_select2(index_x);
            red_Finnan2(index_x);
          });

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
            ...columnHeaders
                .skip(1)
                .map((column) => (columnHeaders.any((columnx) {
                      return column.toString() == 'เลขที่สัญญา' ||
                          column.toString() == 'เลขที่ใบเสร็จ' ||
                          column.toString() == 'เลขที่ใบกำกับภาษี' ||
                          column.toString() == 'เลขที่ใบวางบิล';
                    }))
                        ? Expanded(
                            flex: (Fix_data.contains(columnHeaders
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
                                      return column.toString() == 'จำนวนเงิน';
                                    }))
                                        ? TextAlign.right
                                        : (columnHeaders.any((columnx) {
                                            return column.toString() ==
                                                    'ช่องทางชำระ' ||
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
                                            : PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              )
                            ]))
                        : Expanded(
                            flex: (Fix_data.contains(columnHeaders
                                    .indexWhere((item) => item == column)))
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
                                      return column.toString() ==
                                              'ช่องทางชำระ' ||
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
                                12,
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
                                              'รายละเอียดบิล(ถูกยกเลิก)',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.center,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              12,
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
                                                            12,
                                                            1),
                                                    Center(
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        '${_TransReBillModels[index].docno} (ถูกยกเลิก)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red[600],
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
                                                              12,
                                                              1),
                                                      Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 12,
                                                          '${_TransReBillModels[index].doctax} (ถูกยกเลิก)',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .red[600],
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
                                            12,
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
                                            12,
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
                                            12,
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
                                            12,
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
                                            12,
                                            1),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 12,
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
                                          maxFontSize: 12,
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
                                            12,
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
                                            12,
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
                                                          ? '${nFormat.format(double.parse(_TransReBillModels[index].amt_up!))}'
                                                          : '${nFormat.format(sum_pvat)}',
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
                  Column(children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'เหตุผล :${_TransReBillModels[index].remark}',
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                            fontSize: 11.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    // Container(
                    //     padding: const EdgeInsets.all(8.0),
                    //     width: (Responsive.isDesktop(context))
                    //         ? MediaQuery.of(context).size.width * 0.85
                    //         : 1200,
                    //     child: Row(children: [
                    //       AutoSizeText(
                    //         minFontSize: 8,
                    //         maxFontSize: 11,
                    //         'เหตุผล :${_TransReBillModels[index].remark}',
                    //         textAlign: TextAlign.left,
                    //         maxLines: 1,
                    //         style: TextStyle(
                    //             color: Colors.red[600],
                    //             fontWeight: FontWeight.bold,
                    //             fontFamily: FontWeight_.Fonts_T
                    //             //fontSize: 10.0
                    //             //fontSize: 10.0
                    //             ),
                    //       ),
                    //     ])),

                    Divider(
                      color: Colors.grey,
                      height: 2.0,
                    ),
                    SizedBox(
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
                                padding: const EdgeInsets.all(4.0),
                                width: (Responsive.isDesktop(context))
                                    ? MediaQuery.of(context).size.width * 0.85
                                    : 1200,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      (Slip_history.toString() == '' ||
                                              Slip_history == null ||
                                              Slip_history.toString() == 'null')
                                          ? const SizedBox()
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              width: 200,
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      bool
                                                          hasNonCashTransaction =
                                                          finnancetransModels
                                                              .any(
                                                                  (transaction) {
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
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20.0))),
                                                          backgroundColor:
                                                              AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          titlePadding:
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          actionsPadding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          title: Center(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(4.0),
                                                                        child: Icon(
                                                                            Icons
                                                                                .highlight_off,
                                                                            size:
                                                                                30,
                                                                            color:
                                                                                Colors.red[700]),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  '${_TransReBillModels[index].docno} ',
                                                                  maxLines: 1,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                      fontSize:
                                                                          12.0),
                                                                ),
                                                                (hasNonCashTransaction ==
                                                                        true)
                                                                    ? Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(2.0),
                                                                              child: Text(
                                                                                '${Slip_history}',
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                final String url = '${Slip_history}';
                                                                                if (await canLaunch(url)) {
                                                                                  await launch(url);
                                                                                } else {
                                                                                  throw 'Could not launch $url';
                                                                                }
                                                                              },
                                                                              child: Icon(
                                                                                Icons.open_in_browser,
                                                                                color: Colors.blue,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          ])
                                                                    : Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
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
                                                                          InkWell(
                                                                            onTap: () =>
                                                                                downloadImage_slip('${MyConstant().domain}/files/$foder/slip/${Slip_history}', '${_TransReBillModels[index].docno}'),
                                                                            child:
                                                                                Icon(
                                                                              Icons.download,
                                                                              color: Colors.blue,
                                                                              size: 20,
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
                                                                  stream: Stream.periodic(
                                                                      const Duration(
                                                                          seconds:
                                                                              0)),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          ListBody(
                                                                        children: <Widget>[
                                                                          Container(
                                                                            // height: 600,
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            child:
                                                                                WebViewX2Pagebeamcheck(id_ser: Slip_history),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  })
                                                              : Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: <Widget>[
                                                                    Image.network(
                                                                        '${MyConstant().domain}/files/$foder/slip/${Slip_history}')
                                                                  ],
                                                                ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[200],
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          6),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6)),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4.0),
                                                                  child: Icon(
                                                                      Icons
                                                                          .image,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4.0),
                                                                  child: Translate.TranslateAndSetText(
                                                                      'หลักฐานการชำระ',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
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
                                                ],
                                              ),
                                            )
                                    ]))))
                  ])
                ],
              ),
            ));
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
}
