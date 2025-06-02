import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../Beam/Beam_apiPassw.dart';
import '../../Beam/Beam_api_disabled.dart';
import '../../Beam/webviewPay_beamcheckout.dart';
import '../../Constant/Myconstant.dart';
import '../../INSERT_Log/Insert_log.dart';
import '../../Man_PDF/Man_Receipt_Market_PDF.dart';
import '../../Model/GetFinnancetrans_Model.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/Get_easyslip_Model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../Model/trans_re_bill_model.dart';
import '../../Model/trans_re_chack_bill_model.dart';
import '../../PeopleChao/UP_Slip_Again.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../../Style/downloadImage.dart';
import '../Ac_List/Ac_List_Title.dart';

class Account_BillPayVerifi extends StatefulWidget {
  const Account_BillPayVerifi({super.key});

  @override
  State<Account_BillPayVerifi> createState() => _Account_BillPayVerifiState();
}

class _Account_BillPayVerifiState extends State<Account_BillPayVerifi> {
  DateTime datex = DateTime.now();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  final Pincontroller = TextEditingController();
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  final Formbecause_ = TextEditingController();
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];

  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  List<TransReBillModel> TransReBillModels = [];
  List<TransReBillModel> _TransReBillModels = <TransReBillModel>[];
  List<TransReChackBillModel> transReChackBillModels = [];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac5 = [];
  List<int> Fix_data = [4, 5];
  //-------------------------------------->

  // ตัวแปรสำหรับการค้นหา
  String searchQuery = "";
  //-------------------------------------->
  // Pagination
  int currentPage_1 = 0;
  int Fix_Expan1 = 2, Fix_Expan2 = 1;
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
  ///////////--------------------------------------------->
  String? MONTH_Now, YEAR_Now, Pay_Ke;
  String tappedIndex_ = '';
  String? renTal_user,
      renTal_Ser,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      fname_,
      pdate;

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
  String? api_key, time_check, Auto_cancel;
  String? ser_payby;
  String? numinvoice,
      paymentSer1,
      paymentName1,
      paymentSer2,
      paymentName2,
      cFinn,
      Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';
  String? base64_Slip, fileName_Slip, Slip_history;
  String? ref_1, ref_2, ref_3;
  ///////////--------------------------------------------->
  int renTal_lavel = 0;
  int Count_time_check = 0;
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
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
  String? email_login;
  String? seremail_login;

  String randomString = '';
  String Type_datex = '0';
////////////----------------------------------->
  @override
  void initState() {
    super.initState();
    red_payMent();
    // _startTimer();
    checkPreferance();
    // red_Trans_bill();
    read_GC_rental();
    addAcListTitle();
  }

////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1
      ac5.addAll(
          AcListTitle().ac_5); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac5(String ser) {
    if (ac5
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
      fname_ = preferences.getString('fname');
      email_login = preferences.getString('email');
      seremail_login = preferences.getString('ser');
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
    // Loading_Trans_bill();
  }

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
          var api = renTalModel.api_key;
          setState(() {
            renTal_Ser = preferences.getString('renTalSer');
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
            api_key = api;
            time_check = renTalModel.time_check;
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
      setState(() {
        ac5[2]["st"] = (ac5[2]["st"]! == '1') ? '0' : '1';
      });
    } else {
      setState(() {
        ac5[12]["st"] = (ac5[12]["st"]! == '1') ? '0' : '1';
      });
    }
  }

  //////////////----------------------------------------->
  Future<Null> red_payMent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);

          var paykey = _PayMentModel.key_b;
          setState(() {
            Pay_Ke = paykey.toString();
          });
        }
        // Future.delayed(Duration(seconds: 100), () async {});

        if (Pay_Ke.toString() == '' ||
            Pay_Ke == null ||
            Pay_Ke.toString() == 'null') {
          Loading_Trans_bill();
        } else {
          Loading_Trans_bill();
          //ใช้ read_CheckBeamAll_true(ren, Pay_Ke, context);
        }
        // RecheckAuto(ren, Pay_Ke);
      }
    } catch (e) {}
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

  Future<Null> red_Trans_bill() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      TransReBillModels.clear();
      _TransReBillModels.clear();
      data.clear();
      filteredData.clear();
    });
    // if (TransReBillModels.length != 0) {
    //   setState(() {
    //     TransReBillModels.clear();
    //     _TransReBillModels.clear();
    //   });
    // }

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

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&type_datex=$Type_datex';
    try {
      var response = await http.get(Uri.parse(url));
      // print('GC_bill_pay_BC_Verifi $url');
      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            TransReBillModels.add(transReBillModel);
          });
        }
        setState(() {
          _TransReBillModels = TransReBillModels;
        });
        AddDaTa();
      }
      // read_TransReBill_limit();
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

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
          final date = (_TransReBillModels[index].pay_by.toString() == 'LP')
              ? (_TransReBillModels[index].date == null)
                  ? '-'
                  : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 0}'
              : '-';
          final pdate = (TransReBillModels[index].pdate == null ||
                  TransReBillModels[index].pdate! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels[index].pdate} 00:00:00').year + 0}';

          final docno = TransReBillModels[index].docno ?? "";
          // final doctax = TransReBillModels[index].doctax ?? "";
          final doc_inv = TransReBillModels[index].inv2 ?? "";

          final zn = _TransReBillModels[index].zn == null
              ? '${_TransReBillModels[index].znn}'
              : '${_TransReBillModels[index].zn}';
          final ln = _TransReBillModels[index].ln == null
              ? '${_TransReBillModels[index].room_number}'
              : '${_TransReBillModels[index].ln}';

          final cname = TransReBillModels[index].cname ??
              TransReBillModels[index].remark ??
              "";
          final sname = TransReBillModels[index].sname ??
              TransReBillModels[index].remark ??
              "";
          // final refno = TransReBillModels[index].refno ?? "";
          // final expname = TransReBillModels[index].expname ?? "";
          final total = TransReBillModels[index].total_dis == null
              ? (TransReBillModels[index].total_bill == null)
                  ? '0.00'
                  : '${nFormat.format(double.parse(TransReBillModels[index].total_bill!))}'
              : '${nFormat.format(double.parse(TransReBillModels[index].total_dis!))}';

          final type = TransReBillModels[index].type ?? "-";
          final ref1 = TransReBillModels[index].ref1 ?? "";
          final ref2 = TransReBillModels[index].ref2 ?? "";
          // final ref3 = TransReBillModels[index].ref3 ?? "";
          final ref4 = TransReBillModels[index].ref4 ?? "";

          final pay_by = (TransReBillModels[index].pay_by.toString() == 'W')
              ? 'Web Admin(W)'
              : (TransReBillModels[index].pay_by.toString() == 'U')
                  ? 'Web User(U)'
                  : (TransReBillModels[index].pay_by.toString() == 'LP')
                      ? 'Web Market(LP)'
                      : (TransReBillModels[index].pay_by.toString() == 'H')
                          ? 'Handheld(H)'
                          : 'UnKnow ??';
          final type_pay = (_TransReBillModels[index].pay_by.toString() == 'W')
              ? 'ชำระค่าบริการ'
              : (_TransReBillModels[index].pay_by.toString() == 'U')
                  ? 'ชำระค่าบริการ'
                  : (_TransReBillModels[index].pay_by.toString() == 'LP')
                      ? 'จองล็อกเสียบ'
                      : (_TransReBillModels[index].pay_by.toString() == 'LP')
                          ? 'ชำระค่าบริการ'
                          : 'ไม่ทราบ ??';
          return {
            "index": "$index",
            if (where_ac5("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac5("1") == false) "วันที่ทำรายการ": "$daterec",
            if (where_ac5("2") == false) "ล็อกเสียบ(วันแรก)": "$date",
            if (where_ac5("3") == false) "วันที่รับชำระ": "$pdate",
            if (where_ac5("4") == false) "เลขที่ใบเสร็จ": "$docno",
            if (where_ac5("5") == false) "เลขที่ใบวางบิล": "$doc_inv",
            if (where_ac5("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac5("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac5("8") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac5("9") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac5("10") == false) "จำนวนเงิน": "$total",
            if (where_ac5("11") == false) "รูปแบบชำระ": "$type",
            if (where_ac5("12") == false) "รหัสอ้างอิง": "$ref1",
            if (where_ac5("13") == false) "Ref1": "$ref2",
            if (where_ac5("14") == false) "Ref2": "$ref4",
            if (where_ac5("15") == false) "ทำรายการ": "$pay_by",
            if (where_ac5("16") == false) "ประเภท": "$type_pay",
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

  ///////////--------------------------------------------->
  Future<void> read_CheckBeamAll_true(Ser_, Pay_Ke, context) async {
    var ren = Ser_;

    try {
      /////////------------------------------------------------>
      String decodedPassword = retrieveDecodedPassword(Pay_Ke.toString());
      String basicAuth = generateBasicAuth(decodedPassword);
      // print(basicAuth);
      /////////------------------------------------------------>

      String url =
          '${MyConstant().domain}/UP_Beam_CompleteAll.php?isAdd=true&serren=$ren';
      var response = await http.post(
        Uri.parse(url),
        body: {'Basic_pass': basicAuth.toString()},
      );

      if (response.statusCode == 200) {
        // Request was successful
        // print('Response: successful');
        return PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "ตรวจเช็คการรับชำระ เสร็จสิ้น ...!!",
          buttonText: "รับทราบ",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            // red_Trans_bill();
            read_GC_rental();
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.success,
          barrierDismissible: false, // optional parameter (default is true)
        );
        // print('Response: ${response.body}');
      } else {
        // print('Response: failed');
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "ตรวจเช็คการรับชำระ ล้มเหลว ...!!",
          buttonText: "ลองอีกครั้งภายหลัง",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            // red_Trans_bill();
            read_GC_rental();
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false, // optional parameter (default is true)
        );
        // Request failed
        // print('Failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // print('Response: error');
      PanaraInfoDialog.showAnimatedGrow(
        context,
        title: "Oops",
        message: "ตรวจเช็คการรับชำระ ล้มเหลว ...!!",
        buttonText: "ลองอีกครั้งภายหลัง",
        onTapDismiss: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          Navigator.pop(context);
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false, // optional parameter (default is true)
      );
      // Error occurred during the request
      // print('Error: $error');
    }
  }

  //-------------------------------------->
  Future<Null> red_Chack_Trans_bill() async {
    if (transReChackBillModels.length != 0) {
      setState(() {
        transReChackBillModels.clear();
      });
    }

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
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_chack.php?isAdd=true&ren=$ren&user=$user&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&type_datex=$Type_datex';
    print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReChackBillModel transReChackBillModel =
              TransReChackBillModel.fromJson(map);
          setState(() {
            transReChackBillModels.add(transReChackBillModel);
          });
        }
      }
      // print('result ${transReChackBillModels.map((e) => e)}');
    } catch (e) {}
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

  ////////--------------------------------------------------------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }
  ///////////------------------------>

  bool checkTimeDifference(date_x, time_x) {
    // Parse the date and time into a DateTime object
    DateTime inputDateTime = DateTime.parse('$date_x $time_x');

    // Get the current time
    DateTime currentDateTime = DateTime.now();

    // Calculate the difference
    Duration difference = currentDateTime.difference(inputDateTime);

    // Check if the difference is greater than 15 minutes
    if (difference.inMinutes > int.parse('${time_check}')) {
      // print('เกิน กำหนด.');
      // Count_time_check = Count_time_check + 1;
      return true;
    } else {
      return false;
    }
  }

  ///////////--------------------------------------------->
  Future<Null> pPC_finantIbill_TimeCheck(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    // print(url); //ทดพลาดทดสอบระบบยอดเงินไม่ตรง
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          // _InvoiceModels.clear();
          // _InvoiceHistoryModels.clear();
          // _TransReBillHistoryModels.clear();
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
          // finnancetransModels.clear();
          // Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    double calculatedWidth = (ac5
                .where((item) => item["st"] == '1')
                .toList()
                .length <=
            10)
        ? (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.83
            : 1200
        : (Responsive.isDesktop(context))
            ? MediaQuery.of(context).size.width * 0.83 +
                ((ac5.where((item) => item["st"] == '1').toList().length - 10) *
                    30)
            : 1200 +
                ((ac5.where((item) => item["st"] == '1').toList().length - 10) *
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
              borderRadius: const BorderRadius.only(
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

                            items: ac5.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac5.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac5[selectedIndex]["st"] = '0';
                                          } else {
                                            ac5[selectedIndex]["st"] = '1';
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
                                    padding: EdgeInsets.all(2.0),
                                    child: Translate.TranslateAndSetText(
                                        'ประเภท :',
                                        AccountScreen_Color.Colors_Text1_,
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
                                        // value: '0',
                                        hint: Translate.TranslateAndSetText(
                                            Type_datex == null ||
                                                    Type_datex.toString() == '0'
                                                ? 'ทั้งหมด'
                                                : 'ประจำเดือน',
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
                                        buttonWidth: 160,
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
                                                    14,
                                                    1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '1',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ประจำเดือน',
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
                                            if (value.toString() == '0') {
                                              Type_datex = '0';
                                            } else {
                                              Type_datex = '1';
                                            }
                                          });
                                          Loading_Trans_bill();
                                        },
                                      ),
                                    ),
                                  ),
                                  (Type_datex.toString() == '0')
                                      ? SizedBox()
                                      : Padding(
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
                                  (Type_datex.toString() == '0')
                                      ? SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
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
                                                    FloatingLabelAlignment
                                                        .center,
                                                enabled: true,
                                                hoverColor: Colors.brown,
                                                prefixIconColor: Colors.blue,
                                                fillColor: Colors.white
                                                    .withOpacity(0.05),
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
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
                                                    color: Colors.white,
                                                    width: 1),
                                              ),
                                              items: [
                                                for (int item = 1;
                                                    item < 13;
                                                    item++)
                                                  DropdownMenuItem<String>(
                                                    value: '${item}',
                                                    child: Translate
                                                        .TranslateAndSetText(
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
                                  (Type_datex.toString() == '0')
                                      ? SizedBox()
                                      : Padding(
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
                                  (Type_datex.toString() == '0')
                                      ? SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
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
                                                    FloatingLabelAlignment
                                                        .center,
                                                enabled: true,
                                                hoverColor: Colors.brown,
                                                prefixIconColor: Colors.blue,
                                                fillColor: Colors.white
                                                    .withOpacity(0.05),
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                    color: Colors.white,
                                                    width: 1),
                                              ),
                                              items: YE_Th.map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: '${item}',
                                                    child: Text(
                                                      '${item}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                        AccountScreen_Color.Colors_Text1_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        12,
                                        1),

                                    // Text(
                                    //   'ระบบ :',
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
                                            'ทั้งหมด',
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
                                        //       ? 'ทั้งหมด-All'
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
                                        buttonWidth: 160,
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
                                                    14,
                                                    1),
                                            //  Text(
                                            //   'ทั้งหมด',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '1',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'Web Admin(W)',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                            // Text(
                                            //   'เว็ป หลักแอดมิน(W)',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '2',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'Web User(U)',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                            //  Text(
                                            //   'เว็ป User(U)',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '3',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'Web Market(LP)',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                            //  Text(
                                            //   'เว็ป Market(LP)',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: '4',
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'Handheld(H)',
                                                    Colors.grey,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    1),
                                            // Text(
                                            //   'เครื่อง Handheld(H)',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          )
                                        ],

                                        onChanged: (value) async {
                                          setState(() {
                                            ser_payby = value;
                                          });
                                          Loading_Trans_bill();

                                          // // print(value);
                                          // red_Trans_bill();
                                          // // if (Value_Chang_Zone_Income !=
                                          // //     null) {
                                          // //   red_Trans_billIncome();
                                          // //   red_Trans_billMovemen();
                                          // // }
                                        },
                                      ),
                                    ),
                                  ),
                                  if (time_check.toString() != '0' &&
                                      time_check.toString() != '' &&
                                      time_check != null &&
                                      renTal_Ser.toString() != '106')
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(4, 2, 4, 2),
                                      child: Container(
                                        width: 140,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            //  backgroundColor:
                                            // MaterialStateProperty.all<
                                            //     Color>(Colors.green),
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Color.fromARGB(
                                                        255, 211, 147, 50)),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              Count_time_check = 0;
                                            });
                                            for (int index1 = 0;
                                                index1 <
                                                    TransReBillModels.length;
                                                index1++) {
                                              var date_x =
                                                  '${TransReBillModels[index1].dateacc}';
                                              var time_x =
                                                  '${TransReBillModels[index1].timex}';
                                              if (TransReBillModels[index1]
                                                          .slip ==
                                                      null ||
                                                  TransReBillModels[index1]
                                                          .slip
                                                          .toString() ==
                                                      'null' ||
                                                  TransReBillModels[index1]
                                                          .slip
                                                          .toString() ==
                                                      '') {
                                                // checkTimeDifference(
                                                //     date_x,
                                                //     time_x);
                                                if (checkTimeDifference(
                                                        date_x, time_x) ==
                                                    true) {
                                                  setState(() {
                                                    Count_time_check =
                                                        Count_time_check + 1;
                                                  });
                                                }
                                              }
                                            }
                                            generateRandomString();
                                            showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
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
                                                          title: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        Formbecause_
                                                                            .clear();
                                                                      });
                                                                      Navigator.pop(
                                                                          context,
                                                                          'OK');
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
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
                                                              Translate.TranslateAndSetText(
                                                                  'ยกเลิกรายการ ที่เกิน ${time_check} นาที',
                                                                  AdminScafScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .center,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                              Translate.TranslateAndSetText(
                                                                  '( รายการ ที่ไม่พบ Slip )',
                                                                  Colors.grey,
                                                                  TextAlign
                                                                      .center,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                              Translate.TranslateAndSetText(
                                                                  '# พบทั้งหมด ${Count_time_check} จาก ${TransReBillModels.length} รายการ',
                                                                  Colors.deepOrange[
                                                                      400],
                                                                  TextAlign
                                                                      .center,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                              const Divider(),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                child: Translate.TranslateAndSetText(
                                                                    'ผู้ตรวจสอบ/ยกเลิก ',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                                // Text(
                                                                //   'ผู้ตรวจสอบ/ยกเลิก ',
                                                                //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                // ),
                                                              ),
                                                            ],
                                                          ),
                                                          content:
                                                              StreamBuilder(
                                                                  stream: Stream.periodic(
                                                                      const Duration(
                                                                          seconds:
                                                                              1)),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          ListBody(
                                                                        children: <Widget>[
                                                                          Text(
                                                                            '- ${email_login}($seremail_login)',
                                                                            style: const TextStyle(
                                                                                fontSize: 14,
                                                                                color: AccountScreen_Color.Colors_Text2_,
                                                                                // fontWeight:
                                                                                //     FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Container(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  const Text(
                                                                                    'CODE : ',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(2),
                                                                                    child: Container(
                                                                                      decoration: const BoxDecoration(
                                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                        color: Color.fromARGB(255, 179, 177, 170),
                                                                                        // image:
                                                                                        //     const DecorationImage(
                                                                                        //   image: AssetImage(
                                                                                        //       "assets/pngegg2.png"),
                                                                                        //   fit: BoxFit
                                                                                        //       .cover,
                                                                                        // ),
                                                                                      ),
                                                                                      width: 65,
                                                                                      // color: Colors.black,
                                                                                      padding: const EdgeInsets.all(2.0),
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          '${randomString}',
                                                                                          style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(4.0),
                                                                            child:
                                                                                Center(
                                                                              child: Container(
                                                                                height: 40,
                                                                                width: 90,
                                                                                child: PinCode(
                                                                                  keyboardType: TextInputType.number,
                                                                                  numberOfFields: 2,
                                                                                  fieldWidth: 40.0,
                                                                                  style: const TextStyle(
                                                                                    fontFamily: Font_.Fonts_T,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                  fieldStyle: PinCodeStyle.box,
                                                                                  onChanged: (value) {
                                                                                    setState(() {
                                                                                      Pincontroller.text = value.trim();
                                                                                    });
                                                                                  },
                                                                                  onCompleted: (text) {
                                                                                    setState(() {
                                                                                      Pincontroller.text = text.trim();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                          actions: <Widget>[
                                                            Column(
                                                              children: [
                                                                Translate.TranslateAndSetText(
                                                                    '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนยกเลิก',
                                                                    Colors.red[
                                                                        800],
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                                StreamBuilder(
                                                                    stream: Stream.periodic(const Duration(
                                                                        seconds:
                                                                            1)),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                5.0,
                                                                          ),
                                                                          const Divider(
                                                                            color:
                                                                                Colors.grey,
                                                                            height:
                                                                                1.0,
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5.0,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Container(
                                                                                  width: 150,
                                                                                  height: 40,
                                                                                  // ignore: deprecated_member_use
                                                                                  child: ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: (Pincontroller.text != "$randomString") ? Colors.grey : Colors.green,
                                                                                    ),
                                                                                    onPressed: (Pincontroller.text != "$randomString" || Count_time_check == 0)
                                                                                        ? null
                                                                                        : () async {
                                                                                            showDialog(
                                                                                                barrierDismissible: false,
                                                                                                context: context,
                                                                                                builder: (_) {
                                                                                                  // Timer(Duration(milliseconds: 3600), () {
                                                                                                  //   Navigator.of(context).pop();
                                                                                                  // });
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
                                                                                            for (int index1 = 0; index1 < TransReBillModels.length; index1++) {
                                                                                              var date_x = '${TransReBillModels[index1].dateacc}';
                                                                                              var time_x = '${TransReBillModels[index1].timex}';
                                                                                              if (TransReBillModels[index1].slip == null || TransReBillModels[index1].slip.toString() == 'null' || TransReBillModels[index1].slip.toString() == '') {
                                                                                                // checkTimeDifference(
                                                                                                //     date_x,
                                                                                                //     time_x);
                                                                                                if (checkTimeDifference(date_x, time_x) == true) {
                                                                                                  setState(() {
                                                                                                    numinvoice = TransReBillModels[index1].docno!;
                                                                                                  });
                                                                                                  String Formbe_cause = (int.parse('${time_check}') < 60)
                                                                                                      ? 'ยกเลิก: $numinvoice เกินกำหนด $time_check นาที(ไม่แนบสลิป)'
                                                                                                      : (int.parse('${time_check}') == 60)
                                                                                                          ? 'ยกเลิก: $numinvoice เกินกำหนด 1 ชั่วโมง(ไม่แนบสลิป)'
                                                                                                          : (int.parse('${time_check}') == 90)
                                                                                                              ? 'ยกเลิก: $numinvoice เกินกำหนด 1.3 ชั่วโมง(ไม่แนบสลิป)'
                                                                                                              : (int.parse('${time_check}') == 120)
                                                                                                                  ? 'ยกเลิก: $numinvoice เกินกำหนด 2 ชั่วโมง(ไม่แนบสลิป)'
                                                                                                                  : (int.parse('${time_check}') == 1440)
                                                                                                                      ? 'ยกเลิก: $numinvoice เกินกำหนด 1 วัน(ไม่แนบสลิป)'
                                                                                                                      : (int.parse('${time_check}') == 2880)
                                                                                                                          ? 'ยกเลิก: $numinvoice เกินกำหนด 2 วัน(ไม่แนบสลิป)'
                                                                                                                          : 'ยกเลิก: $numinvoice เกินกำหนด $time_check นาที(ไม่แนบสลิป)';
                                                                                                  // print(Formbe_cause);
                                                                                                  // 'ยกเลิกรับชำระ : $numinvoice  เกินกำหนด(ไม่แนบสลิป)';
                                                                                                  await pPC_finantIbill_TimeCheck(Formbe_cause).then((value) => {
                                                                                                        // print('index1 + 1'),
                                                                                                        // print(index1 + 1),
                                                                                                      });
                                                                                                }
                                                                                              }
                                                                                              Future.delayed(const Duration(milliseconds: 800));
                                                                                              if (index1 + 1 == TransReBillModels.length) {
                                                                                                Future.delayed(const Duration(seconds: 1));
                                                                                                // print('+++index1 + 1');
                                                                                                // print(index1 + 1);
                                                                                                Navigator.of(context).pop();
                                                                                                Future.delayed(const Duration(milliseconds: 200));
                                                                                                Navigator.pop(context);
                                                                                                Future.delayed(const Duration(milliseconds: 600), () async {
                                                                                                  Dialog_cancellock();
                                                                                                });
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                    child: Text(
                                                                                      'ยืนยัน-Confirm',
                                                                                      style: TextStyle(
                                                                                        // fontSize: 20.0,
                                                                                        // fontWeight: FontWeight.bold,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                    ),
                                                                                    // color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }),
                                                              ],
                                                            ),
                                                          ],
                                                        ));
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.lock_clock,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              Expanded(
                                                child: Translate
                                                    .TranslateAndSet_TextAutoSize(
                                                        "Time Check  ",
                                                        Colors.black,
                                                        TextAlign.center,
                                                        null,
                                                        FontWeight_.Fonts_T,
                                                        11,
                                                        12,
                                                        1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (api_key == 'Y')
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(4, 2, 4, 2),
                                      child: Container(
                                        width: 140,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            //  backgroundColor:
                                            // MaterialStateProperty.all<
                                            //     Color>(Colors.green),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    const Color.fromARGB(
                                                        255, 175, 180, 43)),
                                          ),
                                          onPressed: () async {
                                            PanaraConfirmDialog
                                                .showAnimatedGrow(
                                              context,
                                              title: "Check Payment",
                                              message: "เช็คการชำระเงิน",
                                              confirmButtonText: "Confirm",
                                              cancelButtonText: "Cancel",
                                              onTapConfirm: () async {
                                                Dia_log();
                                                Loading_Trans_bill();
                                                // red_Trans_bill();
                                                red_Chack_Trans_bill()
                                                    .then((value) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                });
                                              },
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.success,
                                            );
                                            // red_Trans_bill();
                                            // red_Chack_Trans_bill();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.payments,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              Expanded(
                                                child: Translate
                                                    .TranslateAndSet_TextAutoSize(
                                                        "Check Payment ",
                                                        Colors.black,
                                                        TextAlign.center,
                                                        null,
                                                        FontWeight_.Fonts_T,
                                                        11,
                                                        12,
                                                        1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  // Container(height: 30,
                                  //   // color: Colors.green,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.green,
                                  //     borderRadius: const BorderRadius.only(
                                  //         topLeft: Radius.circular(10),
                                  //         topRight: Radius.circular(10),
                                  //         bottomLeft: Radius.circular(10),
                                  //         bottomRight: Radius.circular(10)),
                                  //     // border: Border.all(color: Colors.white, width: 1),
                                  //   ),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(4.0),
                                  //     child: TextButton(
                                  //       onPressed: () async {
                                  //         PanaraConfirmDialog
                                  //             .showAnimatedGrow(
                                  //           context,
                                  //           title: "Check Payment",
                                  //           message: "เช็คการชำระเงิน",
                                  //           confirmButtonText: "Confirm",
                                  //           cancelButtonText: "Cancel",
                                  //           onTapConfirm: () async {
                                  //             Dia_log();
                                  //             red_Trans_bill();
                                  //             red_Chack_Trans_bill()
                                  //                 .then((value) {
                                  //               Navigator.pop(context);
                                  //               Navigator.pop(context);
                                  //             });
                                  //           },
                                  //           onTapCancel: () {
                                  //             Navigator.pop(context);
                                  //           },
                                  //           panaraDialogType:
                                  //               PanaraDialogType.success,
                                  //         );
                                  //         // red_Trans_bill();
                                  //         // red_Chack_Trans_bill();
                                  //       },
                                  //       child: const Text(
                                  //         "Check Payment ",
                                  //         maxLines: 1,
                                  //         style: TextStyle(fontSize: 12,
                                  //           color: Colors.white,
                                  //           fontFamily: Font_.Fonts_T,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
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
                            // InkWell(
                            //   onTap: (renTal_user.toString() != '50')
                            //       ? null
                            //       : () async {
                            //           red_Trans_billTest();
                            //           _easyslipDialog();
                            //         },
                            //   child: const Icon(
                            //     Icons.align_vertical_center,
                            //     color: Colors.grey,
                            //     size: 20,
                            //   ),
                            // ),
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
                          // (renTal_Ser.toString() == '106')
                          //     ? SizedBox()
                          //     :
                          SizedBox(
                            width: 50,
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
                                                          'จำนวนเงิน';
                                                    }))
                                                        ? TextAlign.right
                                                        : (columnHeaders
                                                                .any((columnx) {
                                                            return column
                                                                    .toString() ==
                                                                'รูปแบบชำระ';
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
                          if (renTal_Ser.toString() == '50')
                            SizedBox(
                              width: 110,
                              height: 20,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '...',
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.bold
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
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
                                      final columnToCheck = 'เลขที่ใบวางบิล';
                                      int index_x = int.parse(
                                          '${displayedData[index]['index']}');
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
                                          : (transReChackBillModels.length != 0)
                                              ? Container(
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
                                                        child:
                                                            List_Material_TransReChackBill(
                                                                index_x,
                                                                columnHeaders,
                                                                row,
                                                                columnToCheck,
                                                                calculatedWidth),
                                                      ),
                                                      if (index_Test == index)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 8),
                                                          child: ResultChackSlip(
                                                              index,
                                                              columnHeaders,
                                                              row,
                                                              columnToCheck),
                                                        ),
                                                      if (index_Test == index)
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                      if (index_Test == index)
                                                        const Divider(
                                                          color: Colors.grey,
                                                          height: 1.5,
                                                        ),
                                                      if (index_Test == index)
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              : SizedBox(
                                                  child: Column(
                                                    children: [
                                                      List_Material(
                                                          index,
                                                          columnHeaders,
                                                          row,
                                                          columnToCheck),
                                                      if (index_Test == index)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 8),
                                                          child: ResultChackSlip(
                                                              index,
                                                              columnHeaders,
                                                              row,
                                                              columnToCheck),
                                                        ),
                                                      if (index_Test == index)
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                      if (index_Test == index)
                                                        const Divider(
                                                          color: Colors.grey,
                                                          height: 1.5,
                                                        ),
                                                      if (index_Test == index)
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                    ],
                                                  ),
                                                );
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

          generateRandomString();
          setState(() {
            tappedIndex_ = index.toString();
            red_Trans_select(index_x);
            red_Invoice(index_x);
          });
          Future.delayed(const Duration(milliseconds: 300), () async {
            checkshowDialog(
              index_x,
            );
          });
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
              // color: Colors.orange,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (_TransReBillModels[int.parse('${row['index']}')]
                              .type
                              .toString() ==
                          'CASH')
                      ? const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Center(child: SizedBox()),
                        )
                      : (_TransReBillModels[int.parse('${row['index']}')]
                                      .slip ==
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
                              child: Center(child: SizedBox()),
                            ),
                  (checkTimeDifference('${_TransReBillModels[index].dateacc}',
                                  '${_TransReBillModels[index].timex}') ==
                              true &&
                          renTal_Ser.toString() != '106')
                      ? const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Center(
                              child: Icon(
                            Icons.lock_clock,
                            size: 16,
                            color: Colors.blueGrey,
                          )),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(child: SizedBox()),
                        ),
                ],
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
                                      return column.toString() == 'จำนวนเงิน';
                                    }))
                                        ? TextAlign.right
                                        : (columnHeaders.any((columnx) {
                                            return column.toString() ==
                                                'รูปแบบชำระ';
                                          }))
                                            ? TextAlign.center
                                            : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: (row['จำนวนเงิน'].toString() ==
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
                                  column.toString() == 'เลขที่ใบกำกับภาษี' ||
                                  column.toString() == 'เลขที่ใบวางบิล';
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
                                return column.toString() == 'จำนวนเงิน';
                              }))
                                  ? TextAlign.right
                                  : (columnHeaders.any((columnx) {
                                      return column.toString() == 'รูปแบบชำระ';
                                    }))
                                      ? TextAlign.center
                                      : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: (row['จำนวนเงิน'].toString() == '0.00')
                                      ? Colors.red[600]
                                      : PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ))
                .toList(),
            // Container(
            //   width: 100,
            //   height: 25,
            //   child:

            //  InkWell(
            //                                                                         onTap: () {
            //                                                                           print('red_easyslip_data');
            //                                                                           red_easyslip_data(index);
            //                                                                         },
            //                                                                         // => downloadImage_slip('${MyConstant().domain}/files/$foder/slip/${Slip_history}', '${_TransReBillModels[index].docno}'),
            //                                                                         child: Icon(
            //                                                                           Icons.download,
            //                                                                           color: Colors.blue,
            //                                                                           size: 20,
            //                                                                         ),
            //
            //
            if (renTal_Ser.toString() == '50')
              SizedBox(
                width: 120,
                child: Center(
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                      onPressed: () async {
                        await Dia_log1();

                        int index_x = int.parse('${row['index']}');

                        generateRandomString();
                        setState(() {
                          tappedIndex_ = index.toString();
                          red_Trans_select(index_x);
                          red_Invoice(index_x);
                        });

                        Future.delayed(const Duration(milliseconds: 300),
                            () async {
                          red_easyslip_data(index_x);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.developer_board_outlined,
                            color: CustomerScreen_Color.Colors_Text3_,
                          ),
                          Translate.TranslateAndSet_TextAutoSize(
                              'ตรวจสอบ',
                              // 'SCAN',
                              CustomerScreen_Color.Colors_Text3_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              8,
                              14,
                              1),
                        ],
                      )
                      // child: Icon(Icons.saved_search)
                      // Translate.TranslateAndSet_TextAutoSize(
                      //     'ตรวจสอบ',
                      //     CustomerScreen_Color.Colors_Text3_,
                      //     TextAlign.center,
                      //     null,
                      //     Font_.Fonts_T,
                      //     8,
                      //     14,
                      //     1),
                      ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget List_Material_TransReChackBill(
      index, columnHeaders, row, columnToCheck, calculatedWidth) {
    return Container(
      width: calculatedWidth,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: transReChackBillModels[index].status == 'payment confirm success'
            ? Colors.green.shade100
            : transReChackBillModels[index].status == 'billing_not_found'
                ? Colors.purple.shade100
                : Colors.orange.shade100,
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
          Icon(
            Icons.warning_sharp,
            size: 15,
            color: Colors.amber[800],
          ),
          // Expanded(
          //   flex: 1,
          //   child: Text(
          //     '${transReChackBillModels[index].cid}',
          //     maxLines: 1,
          //     overflow: TextOverflow.ellipsis,
          //     style: TextStyle(
          //         fontSize: 12,
          //         fontStyle: FontStyle.italic,
          //         color: Colors.grey[600],
          //         fontFamily: Font_.Fonts_T
          //         //fontSize: 10.0
          //         ),
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Text(
              (transReChackBillModels[index].transDate == null)
                  ? ''
                  : '${transReChackBillModels[index].transDate}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              (transReChackBillModels[index].transTime == null)
                  ? ''
                  : '${transReChackBillModels[index].transTime}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${transReChackBillModels[index].docno}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${transReChackBillModels[index].cname}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${transReChackBillModels[index].ref1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${transReChackBillModels[index].ref2}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${transReChackBillModels[index].ref4}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transReChackBillModels[index].transDate == null ? '' : 'Pay by',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transReChackBillModels[index].transDate == null
                  ? ''
                  : '${transReChackBillModels[index].fromName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transReChackBillModels[index].transDate == null
                  ? ''
                  : '${transReChackBillModels[index].amount}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          Text(
            transReChackBillModels[index].status == 'payment confirm success'
                ? 'Payment confirm success : ชำระเงินสำเร็จ'
                : transReChackBillModels[index].status ==
                        'require data is missing'
                    ? 'Require data is missing : ข้อมูลไม่ครบ'
                    : transReChackBillModels[index].status ==
                            'billing_not_found'
                        ? 'Billing not found : ไม่พบเอกสารการจ่ายเงิน หรือ จำนวนเงินไม่ถูกต้อง'
                        : 'Payment confirm not found : จ่ายเงินไม่สำเร็จ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
              fontFamily: Font_.Fonts_T,
              //fontSize: 10.0
            ),
          ),
        ],
      ),
    );

    // Material(
    //     // surfaceTintColor: tappedIndex_Color
    //     //     .tappedIndex_Colors,
    //     color: tappedIndex_ == index.toString()
    //         ? tappedIndex_Color.tappedIndex_Colors
    //         : AppbackgroundColor.Sub_Abg_Colors,
    //     child: InkWell(
    //         hoverColor: Colors.grey[350]!.withOpacity(0.5),
    //         onTap: () {
    //           // int index_x = int.parse('${row['index']}');

    //           // setState(() {
    //           //   tappedIndex_ = index.toString();
    //           //   red_Trans_select2(index_x);
    //           //   red_Finnan2(index_x);
    //           // });

    //           // Future.delayed(const Duration(milliseconds: 500), () {
    //           //   checkshowDialog(index_x);
    //           // });
    //         },
    //         child: Container(
    //             padding:
    //                 const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    //             decoration: BoxDecoration(
    //               // color: Colors.green[100]!
    //               //     .withOpacity(0.5),
    //               border: const Border(
    //                 bottom: BorderSide(
    //                   color: Colors.black12,
    //                   width: 1,
    //                 ),
    //               ),
    //             ),
    //             child: Container(
    //               width: 100,
    //               decoration: BoxDecoration(
    // color: transReChackBillModels[index].status ==
    //         'payment confirm success'
    //     ? Colors.green.shade100
    //     : transReChackBillModels[index].status ==
    //             'billing_not_found'
    //         ? Colors.purple.shade100
    //         : Colors.orange.shade100,
    //                 borderRadius: const BorderRadius.only(
    //                     topLeft: Radius.circular(10),
    //                     topRight: Radius.circular(10),
    //                     bottomLeft: Radius.circular(10),
    //                     bottomRight: Radius.circular(10)),
    //                 border: Border.all(color: Colors.white, width: 1),
    //               ),
    //               child: Column(
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Expanded(
    //                         flex: 1,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].cid}',
    //                           textAlign: TextAlign.left,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       transReChackBillModels[index].transDate == null
    //                           ? SizedBox()
    //                           : Expanded(
    //                               flex: 1,
    //                               child: AutoSizeText(
    //                                 minFontSize: 10,
    //                                 maxFontSize: 25,
    //                                 maxLines: 1,
    //                                 transReChackBillModels[index].transDate ==
    //                                         null
    //                                     ? ''
    //                                     : '${transReChackBillModels[index].transDate}',
    //                                 textAlign: TextAlign.center,
    //                                 style: TextStyle(
    //                                     color:
    //                                         AccountScreen_Color.Colors_Text2_,
    //                                     fontFamily: Font_.Fonts_T),
    //                               ),
    //                             ),
    //                       transReChackBillModels[index].transDate == null
    //                           ? SizedBox()
    //                           : Expanded(
    //                               flex: 1,
    //                               child: AutoSizeText(
    //                                 minFontSize: 10,
    //                                 maxFontSize: 25,
    //                                 maxLines: 1,
    //                                 transReChackBillModels[index].transTime ==
    //                                         null
    //                                     ? ''
    //                                     : '${transReChackBillModels[index].transTime}',
    //                                 textAlign: TextAlign.center,
    //                                 style: TextStyle(
    //                                     color:
    //                                         AccountScreen_Color.Colors_Text2_,
    //                                     fontFamily: Font_.Fonts_T),
    //                               ),
    //                             ),
    //                       Expanded(
    //                         flex:
    //                             transReChackBillModels[index].transDate == null
    //                                 ? 6
    //                                 : 2,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].docno}',
    //                           textAlign: TextAlign.left,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         flex: 1,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].cname}',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         flex: 4,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         flex: 4,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].ref1}',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         flex: 4,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].ref2}',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(
    //                               color: Colors.amber.shade900,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         flex: 4,
    //                         child: AutoSizeText(
    //                           minFontSize: 10,
    //                           maxFontSize: 25,
    //                           maxLines: 1,
    //                           '${transReChackBillModels[index].ref4}',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(
    //                               color: AccountScreen_Color.Colors_Text2_,
    //                               fontFamily: Font_.Fonts_T),
    //                         ),
    //                       ),
    //                       transReChackBillModels[index].transDate == null
    //                           ? SizedBox()
    //                           : Expanded(
    //                               flex: 1,
    //                               child: AutoSizeText(
    //                                 minFontSize: 10,
    //                                 maxFontSize: 25,
    //                                 maxLines: 1,
    //                                 'Pay by',
    //                                 textAlign: TextAlign.center,
    //                                 style: TextStyle(
    //                                     color:
    //                                         AccountScreen_Color.Colors_Text2_,
    //                                     fontFamily: Font_.Fonts_T),
    //                               ),
    //                             ),
    //                       transReChackBillModels[index].transDate == null
    //                           ? SizedBox()
    //                           : Expanded(
    //                               flex: 1,
    //                               child: AutoSizeText(
    //                                 minFontSize: 10,
    //                                 maxFontSize: 25,
    //                                 maxLines: 1,
    //                                 '${transReChackBillModels[index].fromName}',
    //                                 textAlign: TextAlign.center,
    //                                 style: TextStyle(
    //                                     color:
    //                                         AccountScreen_Color.Colors_Text2_,
    //                                     fontFamily: Font_.Fonts_T),
    //                               ),
    //                             ),
    //                       transReChackBillModels[index].transDate == null
    //                           ? SizedBox()
    //                           : Expanded(
    //                               flex: 1,
    //                               child: AutoSizeText(
    //                                 minFontSize: 10,
    //                                 maxFontSize: 25,
    //                                 maxLines: 1,
    //                                 transReChackBillModels[index].amount == null
    //                                     ? ''
    //                                     : '${nFormat.format(double.parse(transReChackBillModels[index].amount.toString()))}',
    //                                 textAlign: TextAlign.center,
    //                                 style: TextStyle(
    //                                     color:
    //                                         AccountScreen_Color.Colors_Text2_,
    //                                     fontFamily: Font_.Fonts_T),
    //                               ),
    //                             ),
    //                       Expanded(
    //                         flex: 1,
    //                         child: Translate.TranslateAndSetText(
    //                             '',
    //                             AccountScreen_Color.Colors_Text1_,
    //                             TextAlign.right,
    //                             null,
    //                             Font_.Fonts_T,
    //                             14,
    //                             1),
    //                       ),
    //                     ],
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       children: [
    //                         Translate.TranslateAndSetText(
    //                             transReChackBillModels[index].status ==
    //                                     'payment confirm success'
    //                                 ? 'Payment confirm success : ชำระเงินสำเร็จ'
    //                                 : transReChackBillModels[index].status ==
    //                                         'require data is missing'
    //                                     ? 'Require data is missing : ข้อมูลไม่ครบ'
    //                                     : transReChackBillModels[index]
    //                                                 .status ==
    //                                             'billing_not_found'
    //                                         ? 'Billing not found : ไม่พบเอกสารการจ่ายเงิน หรือ จำนวนเงินไม่ถูกต้อง'
    //                                         : 'Payment confirm not found : จ่ายเงินไม่สำเร็จ',
    //                             AccountScreen_Color.Colors_Text1_,
    //                             TextAlign.right,
    //                             null,
    //                             Font_.Fonts_T,
    //                             14,
    //                             1),
    //                       ],
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ))));
  }
  ////////////----------------------------------->

  generateRandomString() {
    setState(() {
      randomString = '';
    });
    final random = Random();
    const characters = '0123456789';
    final length = 2; // Change this to the desired length

    for (int i = 0; i < length; i++) {
      final index = random.nextInt(characters.length);
      randomString += characters[index];
    }

    // return randomString;
  }

//////////////----------------------------->
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
    // var ren = preferences.getString('renTalSer');
    // var user = preferences.getString('ser');
    // var ciddoc = _TransReBillModels[index].ser;
    // var qutser = _TransReBillModels[index].ser_in;
    // var docnoin = _TransReBillModels[index].docno;
    // String url =
    //     '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _TransReBillModels[index].cid;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno;
    String url =
        '${MyConstant().domain}/GC_bill_payVerifi_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // print('GC_bill_payVerifi_history>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);

          var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          // var sumPvatx = double.parse(_TransReBillHistoryModel.dis!) != 0
          //     ? double.parse(_TransReBillHistoryModel.pvat!) -
          //         double.parse(_TransReBillHistoryModel.dis!)
          //     : double.parse(_TransReBillHistoryModel.pvat!);

          var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          var sumAmtx = double.parse(_TransReBillHistoryModel.total!);
          //  var sumAmtx = double.parse(_TransReBillHistoryModel.dis!) != 0
          //         ? double.parse(_TransReBillHistoryModel.pvat!) +
          //             double.parse(_TransReBillHistoryModel.vat!) -
          //             double.parse(_TransReBillHistoryModel.wht!) -
          //             double.parse(_TransReBillHistoryModel.disendbill!)
          //         : double.parse(_TransReBillHistoryModel.total!)
          //     ;
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var numinvoiceent = _TransReBillHistoryModel.docno;
          setState(() {
            sum_pvat = sum_pvat + sumPvatx;
            sum_vat = sum_vat + sumVatx;
            sum_wht = sum_wht + sumWhtx;
            sum_amt = sum_amt + sumAmtx;
            // sum_disamt = sum_disamtx;
            // sum_disp = sum_dispx;
            numinvoice = _TransReBillHistoryModel.docno;
            _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
  }

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno; //.toString().trim()
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
            ref_1 = finnancetransModel.ref1.toString();
            ref_2 = finnancetransModel.ref2.toString();
            ref_3 = finnancetransModel.ref3.toString();

            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
              pdate = pdatex;
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          // print(
          //     '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
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
                                          //  AutoSizeText(
                                          //   minFontSize: 8,
                                          //   maxFontSize: 14,
                                          //   'รายละเอียดบิล', //numinvoice
                                          //   textAlign: TextAlign.center,
                                          //   style: TextStyle(
                                          //       color: PeopleChaoScreen_Color
                                          //           .Colors_Text1_,
                                          //       fontWeight: FontWeight.bold,
                                          //       fontFamily: FontWeight_.Fonts_T
                                          //       //fontSize: 10.0
                                          //       //fontSize: 10.0
                                          //       ),
                                          // ),
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
                                              Translate.TranslateAndSetText(
                                                  'บิลเลขที่ : ',
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
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //  Center(
                                          //   child: Translate.TranslateAndSetText(
                                          //       'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                          //       AccountScreen_Color
                                          //           .Colors_Text1_,
                                          //       TextAlign.center,
                                          //       FontWeight.bold,
                                          //       FontWeight_.Fonts_T,
                                          //       14,
                                          //       1),
                                          //   //  AutoSizeText(
                                          //   //   minFontSize: 8,
                                          //   //   maxFontSize: 12,
                                          //   //   'บิลเลขที่ ${_TransReBillModels[index].docno}', //
                                          //   //   textAlign: TextAlign.center,
                                          //   //   style: const TextStyle(
                                          //   //       color: PeopleChaoScreen_Color
                                          //   //           .Colors_Text1_,
                                          //   //       fontWeight: FontWeight.bold,
                                          //   //       fontFamily:
                                          //   //           FontWeight_.Fonts_T
                                          //   //       //fontSize: 10.0
                                          //   //       //fontSize: 10.0
                                          //   //       ),
                                          //   // ),
                                          // ),
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
                                      Container(
                                        width: 80,
                                        child: Translate.TranslateAndSetText(
                                            'ลำดับ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        //  const AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'ลำดับ',
                                        //   textAlign: TextAlign.center,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
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
                                        //  AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'วันที่ชำระ',
                                        //   textAlign: TextAlign.start,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
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
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //  Translate.TranslateAndSetText(
                                        //     'วันที่ชำระ',
                                        //     AccountScreen_Color.Colors_Text1_,
                                        //     TextAlign.start,
                                        //     FontWeight.bold,
                                        //     FontWeight_.Fonts_T,
                                        //     14,
                                        //     1),
                                        //   textAlign: TextAlign.start,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
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
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'เลขตั้งหนี้',
                                        //   textAlign: TextAlign.start,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
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
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'รายการ',
                                        //   textAlign: TextAlign.start,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'VAT(฿)',
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
                                          'WHT(฿)',
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
                                          'ส่วนลด',
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
                                        //  AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'ยอดสุทธิ',
                                        //   textAlign: TextAlign.end,
                                        //   style: TextStyle(
                                        //       color: PeopleChaoScreen_Color
                                        //           .Colors_Text1_,
                                        //       fontWeight: FontWeight.bold,
                                        //       fontFamily: FontWeight_.Fonts_T
                                        //       //fontSize: 10.0
                                        //       //fontSize: 10.0
                                        //       ),
                                        // ),
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
                                                    Container(
                                                      width: 80,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        '${index + 1}',
                                                        textAlign:
                                                            TextAlign.center,
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
                                                        _TransReBillHistoryModels[
                                                                        index]
                                                                    .ln ==
                                                                null
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
                                                            : _TransReBillHistoryModels[
                                                                            index]
                                                                        .refno ==
                                                                    null
                                                                ? '${_TransReBillHistoryModels[index].inv}'
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
                                                        '${_TransReBillHistoryModels[index].expname}',
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
                                                            ? '0.00'
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
                                                            ? '0.00'
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
                                                                    .dis ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].dis!))}',
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
                                                                    .total ==
                                                                null)
                                                            ? '0.00'
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
                                  padding: const EdgeInsets.all(2.0),
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
                                              // Align(
                                              //   alignment: Alignment.topLeft,
                                              //   child: Translate
                                              //       .TranslateAndSetText(
                                              //           'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0}',
                                              //           AccountScreen_Color
                                              //               .Colors_Text1_,
                                              //           TextAlign.end,
                                              //           null,
                                              //           Font_.Fonts_T,
                                              //           12,
                                              //           1),
                                              // ),
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
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Translate.TranslateAndSetText(
                                                          '${i + 1}. จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท (${finnancetransModels[i].ptname})',
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.start,
                                                          null,
                                                          Font_.Fonts_T,
                                                          12,
                                                          1),
                                                      // AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 13,
                                                      //   '${i + 1}. จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท (${finnancetransModels[i].ptname})',
                                                      //   style: const TextStyle(
                                                      //       color: PeopleChaoScreen_Color
                                                      //           .Colors_Text2_,
                                                      //       fontWeight:
                                                      //           FontWeight.w500,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                      if (finnancetransModels[i]
                                                              .type
                                                              .toString() !=
                                                          'CASH')
                                                        Translate
                                                            .TranslateAndSetText(
                                                                '  ** ${i + 1}.1. ธนาคาร : ${finnancetransModels[i].bank} , เลขบช. : ${finnancetransModels[i].bno}',
                                                                Colors
                                                                    .grey[800],
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                11,
                                                                2),
                                                      // AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 11,
                                                      //   '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                                      //   style: TextStyle(
                                                      //       color:
                                                      // Colors
                                                      //           .grey[800],
                                                      //       //fontWeight: FontWeight.bold,
                                                      //       fontFamily: Font_
                                                      //           .Fonts_T),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                            width: 350,
                                            decoration: const BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  topRight: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    color: Colors.grey.shade300,
                                                    // height: 100,
                                                    width: 300,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'รวม(บาท)',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    11,
                                                                    1),

                                                            //  AutoSizeText(
                                                            //   minFontSize: 8,
                                                            //   maxFontSize: 11,
                                                            //   'รวม(บาท)',
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
                                                              textAlign:
                                                                  TextAlign.end,
                                                              '${nFormat.format(sum_pvat)}',
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'ภาษีมูลค่าเพิ่ม(vat)',
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
                                                            //   'ภาษีมูลค่าเพิ่ม(vat)',
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
                                                              textAlign:
                                                                  TextAlign.end,
                                                              '${nFormat.format(sum_vat)}',
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'หัก ณ ที่จ่าย',
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
                                                            flex: 1,
                                                            child: AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 11,
                                                              textAlign:
                                                                  TextAlign.end,
                                                              '${nFormat.format(sum_wht)}',
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ยอดรวม',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    11,
                                                                    1),
                                                            //  AutoSizeText(
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
                                                              textAlign:
                                                                  TextAlign.end,
                                                              '${nFormat.format(sum_amt)}',
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Row(
                                                              children: [
                                                                Translate.TranslateAndSetText(
                                                                    'ส่วนลด',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    11,
                                                                    1),
                                                                // const AutoSizeText(
                                                                //   minFontSize:
                                                                //       8,
                                                                //   maxFontSize:
                                                                //       11,
                                                                //   'ส่วนลด',
                                                                //   style: TextStyle(
                                                                //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                //       //fontWeight: FontWeight.bold,
                                                                //       fontFamily: Font_.Fonts_T),
                                                                // ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                SizedBox(
                                                                  width: 60,
                                                                  height: 20,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        8,
                                                                    maxFontSize:
                                                                        11,
                                                                    '$sum_disp  %',
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                        //fontWeight: FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 11,
                                                              '${nFormat.format(sum_disamt)}',
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
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ยอดชำระ',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    11,
                                                                    1),

                                                            // AutoSizeText(
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
                                                            flex: 1,
                                                            child: AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 11,
                                                              textAlign:
                                                                  TextAlign.end,
                                                              '${nFormat.format(sum_amt - sum_disamt)}',
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ],
                                            ))
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
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (finnancetransModels.any((transaction) {
                                  return transaction.ptser.toString().trim() ==
                                      '7';
                                }) ==
                                false)
                              if (transReChackBillModels.length != 0)
                                if (transReChackBillModels[index].status ==
                                    'payment confirm success')
                                  SizedBox()
                                else
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    width: 180,
                                    child: InkWell(
                                      onTap: () {
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
                                                      title: Column(
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
                                                          Center(
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    '123ถูกต้อง/อนุมัติ การรับชำระ',
                                                                    Colors
                                                                        .orange,
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
                                                      content:
                                                          SingleChildScrollView(
                                                              child: ListBody(
                                                                  children: <Widget>[
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Translate.TranslateAndSetText(
                                                                'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // color: Colors.grey,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
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
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Translate.TranslateAndSetText(
                                                                        'ยอดชำระ ',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    // const Text(
                                                                    //   'ยอดชำระ ',
                                                                    //   style: TextStyle(
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       fontWeight: FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                    Text(
                                                                      '- ${nFormat.format(sum_amt - sum_disamt)}',
                                                                      style: const TextStyle(
                                                                          fontSize: 14,
                                                                          color: AccountScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              4,
                                                                              0,
                                                                              0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หลักฐานการชำระ ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text2_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //     Text(
                                                                      //   'หลักฐานการชำระ ',
                                                                      //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                      // ),
                                                                    ),
                                                                    Translate.TranslateAndSetText(
                                                                        (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                                            ? '- ไม่พบหลักฐาน ✖️'
                                                                            : '- พบหลักฐาน ✔️',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        null,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    // Text(
                                                                    //   (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                                    //       ? '- ไม่พบหลักฐาน ✖️'
                                                                    //       : '- พบหลักฐาน ✔️',
                                                                    //   style: const TextStyle(
                                                                    //       fontSize: 14,
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       //(Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? Colors.red : Colors.green,
                                                                    //       // fontWeight:
                                                                    //       //     FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                    Text(
                                                                      (Slip_history.toString() == '' ||
                                                                              Slip_history == null ||
                                                                              Slip_history.toString() == 'null')
                                                                          ? ''
                                                                          : '($Slip_history)',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontFamily:
                                                                              Font_.Fonts_T),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              4,
                                                                              0,
                                                                              0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'ผู้ตรวจสอบ/อนุมัติ ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text2_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //     Text(
                                                                      //   'ผู้ตรวจสอบ/อนุมัติ ',
                                                                      //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                      // ),
                                                                    ),
                                                                    Text(
                                                                      '- ${email_login}($seremail_login)',
                                                                      style: const TextStyle(
                                                                          fontSize: 14,
                                                                          color: AccountScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                    StreamBuilder(
                                                                        stream: Stream.periodic(const Duration(
                                                                            seconds:
                                                                                0)),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          return Column(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Container(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      const Text(
                                                                                        'CODE : ',
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.all(2),
                                                                                        child: Container(
                                                                                          decoration: const BoxDecoration(
                                                                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            color: Color.fromARGB(255, 179, 177, 170),
                                                                                            // image:
                                                                                            //     const DecorationImage(
                                                                                            //   image: AssetImage(
                                                                                            //       "assets/pngegg2.png"),
                                                                                            //   fit: BoxFit
                                                                                            //       .cover,
                                                                                            // ),
                                                                                          ),
                                                                                          width: 65,
                                                                                          // color: Colors.black,
                                                                                          padding: const EdgeInsets.all(2.0),
                                                                                          child: Center(
                                                                                            child: Text(
                                                                                              '${randomString}',
                                                                                              style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(4.0),
                                                                                child: Center(
                                                                                  child: Container(
                                                                                    height: 40,
                                                                                    width: 90,
                                                                                    child: PinCode(
                                                                                      keyboardType: TextInputType.number,
                                                                                      numberOfFields: 2,
                                                                                      fieldWidth: 40.0,
                                                                                      style: const TextStyle(
                                                                                        fontFamily: Font_.Fonts_T,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                      fieldStyle: PinCodeStyle.box,
                                                                                      onChanged: (value) {
                                                                                        setState(() {
                                                                                          Pincontroller.text = value.trim();
                                                                                        });
                                                                                      },
                                                                                      onCompleted: (text) {
                                                                                        setState(() {
                                                                                          Pincontroller.text = text.trim();
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ])),
                                                      actions: <Widget>[
                                                        Column(
                                                          children: [
                                                            Translate.TranslateAndSetText(
                                                                '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                                Colors.red[800],
                                                                TextAlign
                                                                    .center,
                                                                FontWeight.bold,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            // Text(
                                                            //   '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                            //   style: TextStyle(
                                                            //       color: Colors.red[
                                                            //           800],
                                                            //       fontFamily:
                                                            //           Font_.Fonts_T),
                                                            // ),
                                                            const SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            const Divider(
                                                              color:
                                                                  Colors.grey,
                                                              height: 1.0,
                                                            ),
                                                            const SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                StreamBuilder(
                                                                    stream: Stream.periodic(const Duration(
                                                                        seconds:
                                                                            0)),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              150,
                                                                          height:
                                                                              40,
                                                                          // ignore: deprecated_member_use
                                                                          child:
                                                                              ElevatedButton(
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: (Pincontroller.text != "$randomString") ? Colors.grey : Colors.green,
                                                                            ),
                                                                            onPressed: (Pincontroller.text != "$randomString")
                                                                                ? null
                                                                                : () async {
                                                                                    SharedPreferences preferences = await SharedPreferences.getInstance();

                                                                                    var ren = preferences.getString('renTalSer');
                                                                                    var Remark = _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}';
                                                                                    var ser_userVerifi = '$seremail_login';
                                                                                    // '${email_login}($seremail_login)';
                                                                                    var docno = _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}';

                                                                                    // '${_TransReBillModels[index].docno}';

                                                                                    String url = '${MyConstant().domain}/OK_Verifi_Payment_con.php?isAdd=true&ren=$ren&ciddoc=$docno&Re_mark=$Remark&ser_user=$ser_userVerifi';

                                                                                    try {
                                                                                      var response = await http.get(Uri.parse(url));

                                                                                      var result = json.decode(response.body);
                                                                                      if (result.toString() == 'true') {
                                                                                        Insert_log.Insert_logs('บัญชี', 'ประวัติบิลรอตรวจสอบ>>อนุมัติ($docno,ผู้อนุมัตื:${Remark})');
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(backgroundColor: Colors.green, content: Text('$docno อนุมัติเสร็จสิ้น!', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                        );
                                                                                        Navigator.pop(context, 'OK');
                                                                                        Navigator.pop(context, 'OK');
                                                                                        setState(() {
                                                                                          Pincontroller.clear;
                                                                                          Loading_Trans_bill();
                                                                                          // checkPreferance();
                                                                                          // red_Trans_bill();
                                                                                          // read_GC_rental();
                                                                                        });
                                                                                      }
                                                                                    } catch (e) {
                                                                                      Pincontroller.clear;
                                                                                    }
                                                                                  },
                                                                            child:
                                                                                const Text(
                                                                              'ยืนยัน-Confirm',
                                                                              style: TextStyle(
                                                                                // fontSize: 20.0,
                                                                                // fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            // color: Colors.black,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    width: 150,
                                                                    height: 40,
                                                                    // ignore: deprecated_member_use
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.black,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          Formbecause_
                                                                              .clear();
                                                                        });
                                                                        Navigator.pop(
                                                                            context,
                                                                            'OK');
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'ปิด-Close',
                                                                        style:
                                                                            TextStyle(
                                                                          // fontSize: 20.0,
                                                                          // fontWeight: FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      // color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green[400],
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    topRight:
                                                        Radius.circular(6),
                                                    bottomLeft:
                                                        Radius.circular(6),
                                                    bottomRight:
                                                        Radius.circular(6)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.check,
                                                    color: Colors.black),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ถูกต้อง/อนุมัติ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        null,
                                                        Font_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'ถูกต้อง/อนุมัติ',
                                                //   style: TextStyle(
                                                //     color: Colors.black,
                                                //     // fontWeight:
                                                //     //     FontWeight.bold,
                                                //     fontFamily: Font_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  )
                              else
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  width: 180,
                                  child: InkWell(
                                    onTap: () {
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
                                                backgroundColor:
                                                    AppbackgroundColor
                                                        .Sub_Abg_Colors,
                                                titlePadding:
                                                    const EdgeInsets.all(0.0),
                                                contentPadding:
                                                    const EdgeInsets.all(10.0),
                                                actionsPadding:
                                                    const EdgeInsets.all(6.0),
                                                title: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Icon(
                                                                Icons
                                                                    .highlight_off,
                                                                size: 30,
                                                                color: Colors
                                                                    .red[700]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Center(
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ถูกต้อง/อนุมัติ การรับชำระ',
                                                              Colors.orange,
                                                              TextAlign.center,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                    ),
                                                  ],
                                                ),
                                                content: SingleChildScrollView(
                                                    child: ListBody(
                                                        children: <Widget>[
                                                      const SizedBox(
                                                        height: 2.0,
                                                      ),
                                                      Translate.TranslateAndSetText(
                                                          'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          null,
                                                          Font_.Fonts_T,
                                                          14,
                                                          1),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            // color: Colors.grey,
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                topRight: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            6)),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Translate.TranslateAndSetText(
                                                                  'ยอดชำระ ',
                                                                  AccountScreen_Color
                                                                      .Colors_Text2_,
                                                                  TextAlign
                                                                      .center,
                                                                  FontWeight
                                                                      .bold,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                              // const Text(
                                                              //   'ยอดชำระ ',
                                                              //   style: TextStyle(
                                                              //       color: AccountScreen_Color.Colors_Text2_,
                                                              //       fontWeight: FontWeight.bold,
                                                              //       fontFamily: Font_.Fonts_T),
                                                              // ),
                                                              Text(
                                                                '- ${nFormat.format(sum_amt - sum_disamt)}',
                                                                style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: AccountScreen_Color.Colors_Text2_,
                                                                    // fontWeight:
                                                                    //     FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                child: Translate.TranslateAndSetText(
                                                                    'หลักฐานการชำระ ',
                                                                    AccountScreen_Color
                                                                        .Colors_Text2_,
                                                                    TextAlign
                                                                        .center,
                                                                    FontWeight
                                                                        .bold,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                                //     Text(
                                                                //   'หลักฐานการชำระ ',
                                                                //   style: TextStyle(
                                                                //       color: AccountScreen_Color.Colors_Text2_,
                                                                //       fontWeight: FontWeight.bold,
                                                                //       fontFamily: Font_.Fonts_T),
                                                                // ),
                                                              ),
                                                              Translate.TranslateAndSetText(
                                                                  (Slip_history.toString() == '' ||
                                                                          Slip_history ==
                                                                              null ||
                                                                          Slip_history.toString() ==
                                                                              'null')
                                                                      ? '- ไม่พบหลักฐาน ✖️'
                                                                      : '- พบหลักฐาน ✔️',
                                                                  AccountScreen_Color
                                                                      .Colors_Text2_,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                              // Text(
                                                              //   (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                              //       ? '- ไม่พบหลักฐาน ✖️'
                                                              //       : '- พบหลักฐาน ✔️',
                                                              //   style: const TextStyle(
                                                              //       fontSize: 14,
                                                              //       color: AccountScreen_Color.Colors_Text2_,
                                                              //       //(Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? Colors.red : Colors.green,
                                                              //       // fontWeight:
                                                              //       //     FontWeight.bold,
                                                              //       fontFamily: Font_.Fonts_T),
                                                              // ),
                                                              Text(
                                                                (Slip_history
                                                                                .toString() ==
                                                                            '' ||
                                                                        Slip_history ==
                                                                            null ||
                                                                        Slip_history.toString() ==
                                                                            'null')
                                                                    ? ''
                                                                    : '($Slip_history)',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .grey,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                child: Translate.TranslateAndSetText(
                                                                    'ผู้ตรวจสอบ/อนุมัติ ',
                                                                    AccountScreen_Color
                                                                        .Colors_Text2_,
                                                                    TextAlign
                                                                        .center,
                                                                    FontWeight
                                                                        .bold,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                                //     Text(
                                                                //   'ผู้ตรวจสอบ/อนุมัติ ',
                                                                //   style: TextStyle(
                                                                //       color: AccountScreen_Color.Colors_Text2_,
                                                                //       fontWeight: FontWeight.bold,
                                                                //       fontFamily: Font_.Fonts_T),
                                                                // ),
                                                              ),
                                                              Text(
                                                                '- ${email_login}($seremail_login)',
                                                                style: const TextStyle(
                                                                    fontSize: 14,
                                                                    color: AccountScreen_Color.Colors_Text2_,
                                                                    // fontWeight:
                                                                    //     FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                              StreamBuilder(
                                                                  stream: Stream.periodic(
                                                                      const Duration(
                                                                          seconds:
                                                                              0)),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    return Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                const Text(
                                                                                  'CODE : ',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(2),
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(
                                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                      color: Color.fromARGB(255, 179, 177, 170),
                                                                                      // image:
                                                                                      //     const DecorationImage(
                                                                                      //   image: AssetImage(
                                                                                      //       "assets/pngegg2.png"),
                                                                                      //   fit: BoxFit
                                                                                      //       .cover,
                                                                                      // ),
                                                                                    ),
                                                                                    width: 65,
                                                                                    // color: Colors.black,
                                                                                    padding: const EdgeInsets.all(2.0),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        '${randomString}',
                                                                                        style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(4.0),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Container(
                                                                              height: 40,
                                                                              width: 90,
                                                                              child: PinCode(
                                                                                keyboardType: TextInputType.number,
                                                                                numberOfFields: 2,
                                                                                fieldWidth: 40.0,
                                                                                style: const TextStyle(
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                  color: Colors.black,
                                                                                ),
                                                                                fieldStyle: PinCodeStyle.box,
                                                                                onChanged: (value) {
                                                                                  setState(() {
                                                                                    Pincontroller.text = value.trim();
                                                                                  });
                                                                                },
                                                                                onCompleted: (text) {
                                                                                  setState(() {
                                                                                    Pincontroller.text = text.trim();
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                                actions: <Widget>[
                                                  Column(
                                                    children: [
                                                      Translate.TranslateAndSetText(
                                                          '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                          Colors.red[800],
                                                          TextAlign.center,
                                                          null,
                                                          Font_.Fonts_T,
                                                          14,
                                                          1),
                                                      // Text(
                                                      //   '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                      //   style: TextStyle(
                                                      //       color: Colors
                                                      //               .red[
                                                      //           800],
                                                      //       fontFamily:
                                                      //           Font_
                                                      //               .Fonts_T),
                                                      // ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      const Divider(
                                                        color: Colors.grey,
                                                        height: 1.0,
                                                      ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          StreamBuilder(
                                                              stream: Stream.periodic(
                                                                  const Duration(
                                                                      seconds:
                                                                          0)),
                                                              builder: (context,
                                                                  snapshot) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    width: 150,
                                                                    height: 40,
                                                                    // ignore: deprecated_member_use
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor: (Pincontroller.text !=
                                                                                "$randomString")
                                                                            ? Colors.grey
                                                                            : Colors.green,
                                                                      ),
                                                                      onPressed: (Pincontroller.text !=
                                                                              "$randomString")
                                                                          ? null
                                                                          : () async {
                                                                              SharedPreferences preferences = await SharedPreferences.getInstance();

                                                                              var ren = preferences.getString('renTalSer');
                                                                              var Remark = _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}';
                                                                              var ser_userVerifi = '$seremail_login';
                                                                              // '${email_login}($seremail_login)';
                                                                              var docno = _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}';

                                                                              // '${_TransReBillModels[index].docno}';

                                                                              String url = '${MyConstant().domain}/OK_Verifi_Payment_con.php?isAdd=true&ren=$ren&ciddoc=$docno&Re_mark=$Remark&ser_user=$ser_userVerifi';
                                                                              print(url);
                                                                              try {
                                                                                var response = await http.get(Uri.parse(url));

                                                                                var result = json.decode(response.body);

                                                                                print(result.toString());
                                                                                if (result.toString() == 'true') {
                                                                                  Navigator.pop(context, 'OK');
                                                                                  Navigator.pop(context, 'OK');
                                                                                  Insert_log.Insert_logs('บัญชี', 'ประวัติบิลรอตรวจสอบ>>อนุมัติ($docno,ผู้อนุมัติ:${Remark})');
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(backgroundColor: Colors.green, content: Text('$docno อนุมัติเสร็จสิ้น!', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                  );
                                                                                  setState(() {
                                                                                    Pincontroller.clear;
                                                                                    Loading_Trans_bill();
                                                                                    // checkPreferance();
                                                                                    // red_Trans_bill();
                                                                                    // read_GC_rental();
                                                                                  });
                                                                                }
                                                                              } catch (e) {
                                                                                Pincontroller.clear;
                                                                              }
                                                                            },
                                                                      child:
                                                                          const Text(
                                                                        'ยืนยัน-Confirm',
                                                                        style:
                                                                            TextStyle(
                                                                          // fontSize: 20.0,
                                                                          // fontWeight: FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      // color: Colors.black,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              width: 150,
                                                              height: 40,
                                                              // ignore: deprecated_member_use
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black,
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
                                                                    const Text(
                                                                  'ปิด-Close',
                                                                  style:
                                                                      TextStyle(
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
                                                    ],
                                                  ),
                                                ],
                                              ));
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green[400],
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
                                              child: Icon(Icons.check,
                                                  color: Colors.black),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ถูกต้อง/อนุมัติ',
                                                      AccountScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.center,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                              // Text(
                                              //   'ถูกต้อง/อนุมัติ',
                                              //   style: TextStyle(
                                              //     color: Colors.black,
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
                            (Slip_history.toString() == '' ||
                                    Slip_history == null ||
                                    Slip_history.toString() == 'null')
                                ? Row(
                                    children: [
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
                                              await uploadFile_Slip_Again(
                                                      context,
                                                      '${_TransReBillModels[index].docno}',
                                                      '${_TransReBillModels[index].pdate}',
                                                      'รอตรวจสอบ',
                                                      '${_TransReBillModels[index].slip}',
                                                      foder)
                                                  .then((_) {
                                                // Dia_log1();
                                                Timer(Duration(seconds: 1), () {
                                                  Loading_Trans_bill();
                                                });
                                              });
                                            },
                                            child:
                                                Translate.TranslateAndSetText(
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
                                      Container(
                                        padding: const EdgeInsets.all(4.0),
                                        width: 180,
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              numinvoice =
                                                  _TransReBillModels[index]
                                                      .docno!;
                                            });
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
                                                          'ยกเลิกการรับชำระ',
                                                          Colors.red,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
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
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          null,
                                                          Font_.Fonts_T,
                                                          14,
                                                          1),
                                                      // Text(
                                                      //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                      //   style: const TextStyle(
                                                      //       color:
                                                      //           AccountScreen_Color
                                                      //               .Colors_Text2_,
                                                      //       // fontWeight:
                                                      //       //     FontWeight.bold,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              Formbecause_,
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
                                                          // maxLength: 13,
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
                                                                      topRight:
                                                                          Radius.circular(
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
                                                                      topRight:
                                                                          Radius.circular(
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
                                                                      'หมายเหตุ-Note',
                                                                  labelStyle:
                                                                      const TextStyle(
                                                                    color: AccountScreen_Color
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
                                                          String Formbecause =
                                                              Formbecause_.text
                                                                  .toString();
                                                          if (Formbecause ==
                                                              '') {
                                                            showDialog<String>(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AlertDialog(
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20.0))),
                                                                title: Center(
                                                                  child: Translate.TranslateAndSetText(
                                                                      'กรุณากรอกเหตุผล !!',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
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
                                                                  //       fontWeight:
                                                                  //           FontWeight
                                                                  //               .bold,
                                                                  //       fontFamily:
                                                                  //           FontWeight_
                                                                  //               .Fonts_T),
                                                                  // )
                                                                ),
                                                                actions: <Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              100,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.redAccent,
                                                                            borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10)),
                                                                          ),
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context, 'OK'),
                                                                            child: Translate.TranslateAndSetText(
                                                                                'ปิด',
                                                                                Colors.white,
                                                                                TextAlign.center,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            //     const Text(
                                                                            //   'ปิด',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors.white,
                                                                            //       fontWeight: FontWeight.bold,
                                                                            //       fontFamily: FontWeight_.Fonts_T),
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
                                                            if (finnancetransModels
                                                                    .any(
                                                                        (transaction) {
                                                                  return transaction
                                                                          .ptser
                                                                          .toString()
                                                                          .trim() ==
                                                                      '7';
                                                                }) ==
                                                                false) {
                                                              pPC_finantIbill(
                                                                      Formbecause)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Navigator.pop(context),
                                                                            Future.delayed(const Duration(milliseconds: 600),
                                                                                () async {
                                                                              Dialog_cancellock();
                                                                            }),
                                                                          });

                                                              // setState(() {
                                                              //   Formbecause_
                                                              //       .clear();
                                                              // });
                                                              // Navigator.pop(
                                                              //     context,
                                                              //     'OK');
                                                            } else {
                                                              Beam_purchase_disabled(
                                                                      ref_1,
                                                                      Pay_Ke,
                                                                      renTal_user,
                                                                      _TransReBillModels[
                                                                              index]
                                                                          .docno,
                                                                      Formbecause)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            // _timer.cancel(),
                                                                            Navigator.pop(context),
                                                                            Navigator.pop(context),
                                                                            Future.delayed(Duration(milliseconds: 600),
                                                                                () async {
                                                                              Dialog_cancellock();
                                                                            }),
                                                                          });
                                                            }
                                                          }
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ยืนยัน',
                                                                Colors.white,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  const Text(
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
                                                          setState(() {
                                                            Formbecause_
                                                                .clear();
                                                          });
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปิด',
                                                                Colors.white,
                                                                TextAlign
                                                                    .center,
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
                                                color: Colors.red[200],
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
                                                    child: Icon(
                                                        Icons
                                                            .cancel_presentation,
                                                        color: Colors.black),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยกเลิกการรับชำระ',
                                                            AccountScreen_Color
                                                                .Colors_Text2_,
                                                            TextAlign.center,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                    // Text(
                                                    //   'ยกเลิกการรับชำระ',
                                                    //   style: TextStyle(
                                                    //     color:
                                                    //      AccountScreen_Color
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
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(4.0),
                                    // width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        (Slip_history.toString() == '' ||
                                                Slip_history == null ||
                                                Slip_history.toString() ==
                                                    'null')
                                            ? const SizedBox()
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                // width: 210,
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        bool
                                                            hasNonCashTransaction =
                                                            finnancetransModels
                                                                .any(
                                                                    (transaction) {
                                                          return transaction
                                                                  .ptser
                                                                  .toString()
                                                                  .trim() ==
                                                              '7';
                                                        });

                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
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
                                                                    child:
                                                                        Column(
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
                                                                                padding: const EdgeInsets.all(4.0),
                                                                                child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Translate.TranslateAndSetText(
                                                                            'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                                                            AccountScreen_Color.Colors_Text1_,
                                                                            TextAlign.start,
                                                                            FontWeight.bold,
                                                                            FontWeight_.Fonts_T,
                                                                            14,
                                                                            1),
                                                                        // Text(
                                                                        //   'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                                                        //   maxLines: 1,
                                                                        //   textAlign:
                                                                        //       TextAlign
                                                                        //           .start,
                                                                        //   style: const TextStyle(
                                                                        //       color: Colors
                                                                        //           .black,
                                                                        //       fontWeight:
                                                                        //           FontWeight
                                                                        //               .bold,
                                                                        //       fontFamily:
                                                                        //           FontWeight_
                                                                        //               .Fonts_T,
                                                                        //       fontSize:
                                                                        //           12.0),
                                                                        // ),
                                                                        (hasNonCashTransaction ==
                                                                                true)
                                                                            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                                                                                    final String url = '${ref_2}';
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
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    '${Slip_history}',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () => downloadImage_slip('${MyConstant().domain}/files/$foder/slip/${Slip_history}', '${_TransReBillModels[index].docno}'),
                                                                                    child: Icon(
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
                                                                          stream: Stream.periodic(const Duration(seconds: 0)),
                                                                          builder: (context, snapshot) {
                                                                            return SingleChildScrollView(
                                                                              child: ListBody(
                                                                                children: <Widget>[
                                                                                  Container(
                                                                                    // height: 600,
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    child: WebViewX2Pagebeamcheck(id_ser: (Slip_history == '' || Slip_history == null) ? ref_2 : Slip_history),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          })
                                                                      : SingleChildScrollView(
                                                                          child: ListBody(children: <Widget>[
                                                                          SizedBox(
                                                                            width:
                                                                                300,
                                                                            child:
                                                                                Image.network('${MyConstant().domain}/files/$foder/slip/${Slip_history}'),
                                                                          )
                                                                        ])),
                                                                  actions: <Widget>[
                                                                (hasNonCashTransaction ==
                                                                        true)
                                                                    ? SizedBox()
                                                                    : SizedBox(
                                                                        // width: 300,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Translate.TranslateAndSetText(
                                                                                '*** วิธีตรวจสอบ "สลิป" เบื้องต้น',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                FontWeight.bold,
                                                                                FontWeight_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '*** วิธีตรวจสอบ "สลิป" เบื้องต้น',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           13,
                                                                            //       fontWeight:
                                                                            //           FontWeight
                                                                            //               .bold,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '1. สังเกตความละเอียดของ ตัวเลข หรือ ตัวหนังสือ',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '1. สังเกตความละเอียดของ ตัวเลข หรือ ตัวหนังสือ',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '2. เปิดแอปฯ ธนาคารขึ้นมา สแกน QR CODE บนสลิปโอนเงิน',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '2. เปิดแอปฯ ธนาคารขึ้นมา สแกน QR CODE บนสลิปโอนเงิน',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '3. ใช้  Mobile Banking เช็ก ยอดเงิน วัน-เวลาที่โอน ตรงกับในสลิปที่ได้มาหรือไม่',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '3. ใช้  Mobile Banking เช็ก ยอดเงิน วัน-เวลาที่โอน ตรงกับในสลิปที่ได้มาหรือไม่',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '4. ควรตรวจสอบสลิปทันทีที่ได้รับมา เพราะ QR code บนสลิปของบางธนาคารจะมีอายุจำกัด ตั้งเเต่ 7 วัน ถึง 60 วัน ',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '4. ควรตรวจสอบสลิปทันทีที่ได้รับมา เพราะ QR code บนสลิปของบางธนาคารจะมีอายุจำกัด ตั้งเเต่ 7 วัน ถึง 60 วัน ',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            const SizedBox(
                                                                              height: 5.0,
                                                                            ),
                                                                            const Divider(
                                                                              color: Colors.grey,
                                                                              height: 4.0,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5.0,
                                                                            ),
                                                                            // Row(
                                                                            //   mainAxisAlignment:
                                                                            //       MainAxisAlignment.end,
                                                                            //   children: [
                                                                            //     Padding(
                                                                            //       padding: const EdgeInsets.all(8.0),
                                                                            //       child: Container(
                                                                            //         width: 100,
                                                                            //         decoration: const BoxDecoration(
                                                                            //           color: Colors.black,
                                                                            //           borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                            //         ),
                                                                            //         padding: const EdgeInsets.all(8.0),
                                                                            //         child: TextButton(
                                                                            //           onPressed: () => Navigator.pop(context, 'OK'),
                                                                            //           child: const Text(
                                                                            //             'ปิด',
                                                                            //             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            //           ),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ),
                                                                            //   ],
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ]),
                                                        );
                                                      },
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue[200],
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                topRight: (renTal_lavel <=
                                                                        2)
                                                                    ? Radius.circular(
                                                                        6)
                                                                    : Radius.circular(
                                                                        0),
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                        6),
                                                                bottomRight: (renTal_lavel <=
                                                                        2)
                                                                    ? Radius
                                                                        .circular(
                                                                            6)
                                                                    : Radius
                                                                        .circular(
                                                                            0)),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1),
                                                          ),
                                                          child: (finnancetransModels
                                                                      .any(
                                                                          (transaction) {
                                                                    return transaction
                                                                            .ptser
                                                                            .toString()
                                                                            .trim() ==
                                                                        '7';
                                                                  }) ==
                                                                  false)
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child: Icon(
                                                                          Icons
                                                                              .image,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หลักฐานการชำระ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text1_,
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
                                                                      //     color: AccountScreen_Color
                                                                      //         .Colors_Text2_,
                                                                      //     // fontWeight:
                                                                      //     //     FontWeight.bold,
                                                                      //     fontFamily: Font_
                                                                      //         .Fonts_T,
                                                                      //   ),
                                                                      // ),
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
                                                                          const EdgeInsets.fromLTRB(
                                                                              4,
                                                                              0,
                                                                              4,
                                                                              0),
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            12.0,
                                                                        backgroundImage:
                                                                            AssetImage('images/LogoBank/BEAM.png'),
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'ชำระ/ตรวจสอบ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          null,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //  Text(
                                                                      //   'ชำระ/ตรวจสอบ',
                                                                      //   style: TextStyle(
                                                                      //     color: AccountScreen_Color
                                                                      //         .Colors_Text2_,
                                                                      //     // fontWeight:
                                                                      //     //     FontWeight.bold,
                                                                      //     fontFamily: Font_
                                                                      //         .Fonts_T,
                                                                      //   ),
                                                                      // ),
                                                                    ),
                                                                  ],
                                                                )),
                                                    ),
                                                    (renTal_lavel <= 2)
                                                        ? Container()
                                                        : Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Colors
                                                                  .blueGrey,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6)),
                                                              // border: Border.all(
                                                              //     color: Colors.grey,
                                                              //     width: 1),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4.0),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  uploadFile_Slip_Again(
                                                                      context,
                                                                      '${_TransReBillModels[index].docno}',
                                                                      '${_TransReBillModels[index].pdate}',
                                                                      'รอตรวจสอบ',
                                                                      '${_TransReBillModels[index].slip}',
                                                                      foder);
                                                                },
                                                                child: Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                            .grey[
                                                                        300]),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          width: 180,
                                          child: InkWell(
                                            onTap: () async {
                                              setState(() {
                                                numinvoice =
                                                    _TransReBillModels[index]
                                                        .docno!;
                                              });
                                              showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
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
                                                            'ยกเลิกการรับชำระ',
                                                            Colors.red,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
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
                                                                .Colors_Text2_,
                                                            TextAlign.center,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                        // Text(
                                                        //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                        //   style: const TextStyle(
                                                        //       color:
                                                        //           AccountScreen_Color
                                                        //               .Colors_Text2_,
                                                        //       // fontWeight:
                                                        //       //     FontWeight.bold,
                                                        //       fontFamily:
                                                        //           Font_.Fonts_T),
                                                        // ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                Formbecause_,
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
                                                                        'หมายเหตุ-Note',
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: AccountScreen_Color
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
                                                            String Formbecause =
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
                                                                          BorderRadius.all(
                                                                              Radius.circular(20.0))),
                                                                  title: Center(
                                                                    child: Translate.TranslateAndSetText(
                                                                        'กรุณากรอกเหตุผล !!',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
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
                                                                    //       fontWeight:
                                                                    //           FontWeight
                                                                    //               .bold,
                                                                    //       fontFamily:
                                                                    //           FontWeight_
                                                                    //               .Fonts_T),
                                                                    // )
                                                                  ),
                                                                  actions: <Widget>[
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                100,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors.redAccent,
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                            ),
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                TextButton(
                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                              child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                                                                              //     const Text(
                                                                              //   'ปิด',
                                                                              //   style: TextStyle(
                                                                              //       color: Colors.white,
                                                                              //       fontWeight: FontWeight.bold,
                                                                              //       fontFamily: FontWeight_.Fonts_T),
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
                                                              if (finnancetransModels
                                                                      .any(
                                                                          (transaction) {
                                                                    return transaction
                                                                            .ptser
                                                                            .toString()
                                                                            .trim() ==
                                                                        '7';
                                                                  }) ==
                                                                  false) {
                                                                pPC_finantIbill(
                                                                        Formbecause)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Navigator.pop(context),
                                                                              Future.delayed(const Duration(milliseconds: 600), () async {
                                                                                Dialog_cancellock();
                                                                              }),
                                                                            });

                                                                // setState(() {
                                                                //   Formbecause_
                                                                //       .clear();
                                                                // });
                                                                // Navigator.pop(
                                                                //     context,
                                                                //     'OK');
                                                              } else {
                                                                Beam_purchase_disabled(
                                                                        ref_1,
                                                                        Pay_Ke,
                                                                        renTal_user,
                                                                        _TransReBillModels[index]
                                                                            .docno,
                                                                        Formbecause)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              // _timer.cancel(),
                                                                              Navigator.pop(context),
                                                                              Navigator.pop(context),
                                                                              Future.delayed(Duration(milliseconds: 600), () async {
                                                                                Dialog_cancellock();
                                                                              }),
                                                                            });
                                                              }
                                                            }
                                                          },
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ยืนยัน',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  const Text(
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
                                                            setState(() {
                                                              Formbecause_
                                                                  .clear();
                                                            });
                                                            Navigator.pop(
                                                                context, 'OK');
                                                          },
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ปิด',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
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
                                                  color: Colors.red[200],
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
                                                      child: Icon(
                                                          Icons
                                                              .cancel_presentation,
                                                          color: Colors.black),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ยกเลิกการรับชำระ',
                                                              AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),
                                                      // Text(
                                                      //   'ยกเลิกการรับชำระ',
                                                      //   style: TextStyle(
                                                      //     color:
                                                      //      AccountScreen_Color
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
                                        if (_TransReBillModels[index]
                                                .pay_by
                                                .toString() ==
                                            'LP')
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            width: 180,
                                            child: InkWell(
                                              onTap: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                var ren = preferences
                                                    .getString('renTalSer');
                                                var cFinn_now = _TransReBillModels[
                                                                index]
                                                            .doctax ==
                                                        ''
                                                    ? '${_TransReBillModels[index].docno}'
                                                    : '${_TransReBillModels[index].doctax}';
                                                // print(cFinn_now);
                                                ManPay_ReceiptMarket_PDF
                                                    .ManPayReceiptMarket_PDF(
                                                  context,
                                                  ren,
                                                  foder,
                                                  cFinn_now,
                                                  bill_addr,
                                                  bill_email,
                                                  bill_tel,
                                                  bill_tax,
                                                  bill_name,
                                                );
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[200],
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
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(Icons.print,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'พิมพ์(Web Market)',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                13,
                                                                1),
                                                        //  Text(
                                                        //   'พิมพ์',
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
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  /////////////---------------------------------------------------->
  Future<Null> pPC_finantIbill(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    // print(url); //ทดพลาดทดสอบระบบยอดเงินไม่ตรง
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
          red_Trans_bill();
          finnancetransModels.clear();
          Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
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

  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
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

  Dialog_cancellock() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ยกเลิกการรับชำระ เสร็จสิ้น ...!!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        Navigator.pop(context);

        Loading_Trans_bill();
        // red_Trans_bill();

        // String? _route = preferences.getString('route');
        // MaterialPageRoute materialPageRoute = MaterialPageRoute(
        //     builder: (BuildContext context) => AdminScafScreen(route: _route));
        // Navigator.pushAndRemoveUntil(
        //     context, materialPageRoute, (route) => false);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
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

////////-------------------------------------->
  int ser_adddata = 0;
  String? indexTest;
  int? index_Test;
  final _formKey = GlobalKey<FormState>();
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  final myController4 = TextEditingController();
  final myController5 = TextEditingController();
  final myController6 = TextEditingController();
  List<TransReBillModel> _TransReBillModelsTest = [];
  List<easyslipModel> easyslipModels_ = [];
  /////////////------------------------------------>
  Future<Null> _select_Date_Daily(BuildContext context, ser) async {
    final Future<DateTime?> picked = showDatePicker(
      // locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่', confirmText: 'ตกลง',
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
        // TransReBillModels = [];

        var formatter = DateFormat('yyyy-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          if (ser == 2) {
            myController2.text = "${formatter.format(result)}";
          } else {
            myController3.text = "${formatter.format(result)}";
          }
        });
      }
    });
  }

  // String? base64_Slip, fileName_Slip; In_finance_testSlip
  var extension_;
  var file_;
  Future<void> uploadFile_Slip() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // print('User canceled image selection');
      return print(pickedFile);
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
      });
      // print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // print(extension_);
      // print(extension_);
    }
    OKuploadFile_Slip();
    // OKuploadFile_Slip();
    // OKuploadFile_Slip(extension, file);
  }

  Future<void> OKuploadFile_Slip() async {
    if (base64_Slip != null) {
      String Path_foder = 'slip';
      String dateTimeNow = DateTime.now().toString();
      String date = DateFormat('ddMMyyyy')
          .format(DateTime.parse('${dateTimeNow}'))
          .toString();
      final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
      final formatter2 = DateFormat('HHmmss');
      final formattedTime2 = formatter2.format(dateTimeNow2);
      String Time_ = formattedTime2.toString();
      var fileName_Slip_ = 'PaymentQR_${date.toString()}_$Time_';
      setState(() {
        fileName_Slip = 'Testeasyslip_${date.toString()}_$Time_.$extension_';
      });
      final url =
          '${MyConstant().domain}/Test_Upeasyslip.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'Foder': foder,
          'name': fileName_Slip,
          'ex': extension_.toString()
        }, // Send the image as a form field named 'image'
      );
    }
  }

////////--------------------------------------------->
  Future<Null> red_Trans_billTest() async {
    if (_TransReBillModelsTest.length != 0) {
      setState(() {
        _TransReBillModelsTest.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_finance_testSlip.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            _TransReBillModelsTest.add(transReBillModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> Select_Trans_billTest(cid_doc) async {
    if (easyslipModels_.length != 0) {
      setState(() {
        easyslipModels_.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_easyslip.php?isAdd=true&ren=$ren&ciddoc=$cid_doc';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          easyslipModel easyslipModelss = easyslipModel.fromJson(map);
          setState(() {
            easyslipModels_.add(easyslipModelss);
          });
        }
      }
    } catch (e) {}
  }

  /////////////------------------------------------>

  red_easyslip_data(index) async {
    setState(() {
      easyslipModels_.clear();
      index_Test = null;
    });
    //var result = json.decode(datadata);
    var fileName = 'files/$foder/slip/${Slip_history}';
    String url = '${MyConstant().domain}/easyslip.php?file=$fileName';
    // print(url);

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result != null && result.containsKey("sender")) {
          print(result["sender"]);
        } else {
          print("Invalid response format: $result");
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
      }
      // print('fileName_Slip');
      // print(fileName_Slip);
      var daterec = '';
      var date = '';
      var dateacc = '';
      var dtype = '';
      var shopno = '';
      var pos = '';
      var docno = '';
      var custno = '';
      var supno = '';
      var refno = '';
      ///////------------------------------------------->
      var status = result?['status'];
      var payload = result?['data']?['payload'];
      var trans_ref = result?['data']?['transRef'];
      var slip_date = result?['data']?['date'];
      var country_code = result?['data']?['countryCode'];
      var amount = result?['data']?['amount']?['amount'];
      var currency = result?['data']?['amount']?['local']?['currency'];
      var fee = result?['data']?['fee'];
      var ref1 = result?['data']?['ref1'];
      var ref2 = result?['data']?['ref2'];
      var ref3 = result?['data']?['ref3'];
      // print('**** 1');
      ///////------------------------------------------->
      var sender = result['data']['sender'];
      var sendername = result['data']['sender']['account']['name'];
      ///////-----------**************----------->
      var sen_bankid = sender?['bank']?['id'];

      var sen_bankname = sender?['bank']?['name'];
      var sen_bankshort = sender?['bank']?['short'];

      var sen_accnameTh = (sendername is List) ? '' : sendername?['th'] ?? '';
      var sen_accnameEn = (sendername is List) ? '' : sendername?['en'] ?? '';

      var sen_banktype = sender?['account']?['bank']?['type'];
      var sen_accnumber = sender?['account']?['bank']?['account'];
      var sen_proxy_type = sender?['account']?['proxy']?['type'];
      var sen_proxy_accnumber = sender?['account']?['proxy']?['account'];

      // print('**** 2');
      ///////------------------------------------------->
      var recei_bankid = result?['data']?['receiver']?['bank']?['id'];
      var recei_bankname = result?['data']?['receiver']?['bank']?['name'];
      var recei_bankshort = result?['data']?['receiver']?['bank']?['short'];
      var recei_accnameTh =
          result?['data']?['receiver']?['account']?['name']?['th'];
      var recei_accnameEn =
          result?['data']?['receiver']?['account']?['name']?['en'];
      var recei_banktype =
          result?['data']?['receiver']?['account']?['bank']?['type'];
      var recei_accnumber =
          result?['data']?['receiver']?['account']?['bank']?['account'];
      var recei_proxy_type =
          result?['data']?['receiver']?['account']?['proxy']?['type'];
      var recei_proxy_accnumber =
          result?['data']?['receiver']?['account']?['proxy']?['account'];
      // print('**** 3');
      ///////------------------------------------------->
      var merchant_Id = result?['data']?['receiver']?['merchantId'];
      var slip_img = '';

      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['isAdd'] = 'true';
      map['ren'] = '50';
      map['user'] = '0';
      map['daterec'] = '';
      map['date'] = '';
      map['dateacc'] = '';
      map['dtype'] = 'KP';
      map['shopno'] = '1';
      map['pos'] = '1';
      map['docno'] = '';
      map['supno'] = '';
      map['refno'] = '';
      map['status'] = (status == null) ? '' : status.toString();
      map['payload'] = (payload == null) ? '' : payload.toString();
      map['trans_ref'] = (trans_ref == null) ? '' : trans_ref.toString();
      map['slip_date'] = (slip_date == null) ? '' : slip_date.toString();
      map['country_code'] =
          (country_code == null) ? '' : country_code.toString();
      map['amount'] = (amount == null) ? '' : amount.toString();
      map['currency'] = (currency == null) ? '' : currency.toString();
      map['fee'] = (fee == null) ? '' : fee.toString();
      map['ref1'] = (ref1 == null) ? '' : ref1.toString();
      map['ref2'] = (ref2 == null) ? '' : ref2.toString();
      map['ref3'] = (ref3 == null) ? '' : ref3.toString();
      map['sen_bankname'] =
          (sen_bankname == null) ? '' : sen_bankname.toString();
      map['sen_bankshort'] =
          (sen_bankshort == null) ? '' : sen_bankshort.toString();
      map['sen_accnameTh'] =
          (sen_accnameTh == null) ? '' : sen_accnameTh.toString();
      map['sen_accnameEn'] =
          (sen_accnameEn == null) ? '' : sen_accnameEn.toString();
      map['sen_banktype'] =
          (sen_banktype == null) ? '' : sen_banktype.toString();
      map['sen_accnumber'] =
          (sen_accnumber == null) ? '' : sen_accnumber.toString();
      map['sen_proxy_type'] =
          (sen_proxy_type == null) ? '' : sen_proxy_type.toString();
      map['sen_proxy_accnumber'] =
          (sen_proxy_accnumber == null) ? '' : sen_proxy_accnumber.toString();
      map['recei_bankid'] =
          (recei_bankid == null) ? '' : recei_bankid.toString();
      map['recei_bankname'] =
          (recei_bankname == null) ? '' : recei_bankname.toString();
      map['recei_bankshort'] =
          (recei_bankshort == null) ? '' : recei_bankshort.toString();
      map['recei_accnameTh'] =
          (recei_accnameTh == null) ? '' : recei_accnameTh.toString();
      map['recei_accnameEn'] =
          (recei_accnameEn == null) ? '' : recei_accnameEn.toString();
      (recei_banktype == null) ? '' : recei_banktype.toString();
      map['recei_accnumber'] =
          (recei_accnumber == null) ? '' : recei_accnumber.toString();
      map['recei_proxy_type'] =
          (recei_proxy_type == null) ? '' : recei_proxy_type.toString();
      map['recei_proxy_accnumber'] = (recei_proxy_accnumber == null)
          ? ''
          : recei_proxy_accnumber.toString();
      map['merchant_Id'] = (merchant_Id == null) ? '' : merchant_Id.toString();
      map['slip_img'] = '$fileName_Slip';
      map['directions'] = '1';

      try {
        easyslipModel easyslipModelss = easyslipModel.fromJson(map);

        setState(() {
          easyslipModels_.add(easyslipModelss);
        });
      } catch (e) {}
      setState(() {
        index_Test = index;
      });
    } catch (e) {
      setState(() {
        index_Test = index;
      });
    }

    // print('**** ');
    // print('**** ${easyslipModels_.length}');
    // setState(() {
    //   index_Test = index;
    // });
    // await InC_easyslip(
    //     daterec,
    //     date,
    //     dateacc,
    //     dtype,
    //     shopno,
    //     pos,
    //     docno,
    //     custno,
    //     supno,
    //     refno,
    //     status,
    //     payload,
    //     trans_ref,
    //     slip_date,
    //     country_code,
    //     amount,
    //     currency,
    //     fee,
    //     ref1,
    //     ref2,
    //     ref3,
    //     sen_bankid,
    //     sen_bankname,
    //     sen_bankshort,
    //     sen_accnameTh,
    //     sen_accnameEn,
    //     sen_banktype,
    //     sen_accnumber,
    //     sen_proxy_type,
    //     sen_proxy_accnumber,
    //     recei_bankid,
    //     recei_bankname,
    //     recei_bankshort,
    //     recei_accnameTh,
    //     recei_accnameEn,
    //     recei_banktype,
    //     recei_accnumber,
    //     recei_proxy_type,
    //     recei_proxy_accnumber,
    //     merchant_Id,
    //     slip_img);
  }

///////////////////--------------------------------------------------->

  Future<void> InC_easyslip(
      daterec,
      date,
      dateacc,
      dtype,
      shopno,
      pos,
      docno,
      custno,
      supno,
      refno,
      status,
      payload,
      trans_ref,
      slip_date,
      country_code,
      amount,
      currency,
      fee,
      ref1,
      ref2,
      ref3,
      sen_bankid,
      sen_bankname,
      sen_bankshort,
      sen_accnameTh,
      sen_accnameEn,
      sen_banktype,
      sen_accnumber,
      sen_proxy_type,
      sen_proxy_accnumber,
      recei_bankid,
      recei_bankname,
      recei_bankshort,
      recei_accnameTh,
      recei_accnameEn,
      recei_banktype,
      recei_accnumber,
      recei_proxy_type,
      recei_proxy_accnumber,
      merchant_Id,
      slip_img) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    String url = '${MyConstant().domain}/In_c_easyslip.php?isAdd=true&ren=$ren';
    String Date_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String Time_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var response = await http.post(Uri.parse(url), body: {
      'isAdd': 'true',
      'ren': '$ren',
      'user': '$user',
      'daterec': Date_now,
      'date': Date_now,
      'dateacc': Date_now,
      'dtype': 'KP',
      'shopno': '1',
      'pos': '1',
      'docno': '',
      'custno': '',
      'supno': '',
      'refno': '',
      'status': (status == null) ? '' : status.toString(),
      'payload': (payload == null) ? '' : payload.toString(),
      'trans_ref': (trans_ref == null) ? '' : trans_ref.toString(),
      'slip_date': (slip_date == null) ? '' : slip_date.toString(),
      'country_code': (country_code == null) ? '' : country_code.toString(),
      'amount': (amount == null) ? '' : amount.toString(),
      'currency': (currency == null) ? '' : currency.toString(),
      'fee': (fee == null) ? '' : fee.toString(),
      'ref1': (ref1 == null) ? '' : ref1.toString(),
      'ref2': (ref2 == null) ? '' : ref2.toString(),
      'ref3': (ref3 == null) ? '' : ref3.toString(),
      'sen_bankname': (sen_bankname == null) ? '' : sen_bankname.toString(),
      'sen_bankshort': (sen_bankshort == null) ? '' : sen_bankshort.toString(),
      'sen_accnameTh': (sen_accnameTh == null) ? '' : sen_accnameTh.toString(),
      'sen_accnameEn': (sen_accnameEn == null) ? '' : sen_accnameEn.toString(),
      'sen_banktype': (sen_banktype == null) ? '' : sen_banktype.toString(),
      'sen_accnumber': (sen_accnumber == null) ? '' : sen_accnumber.toString(),
      'sen_proxy_type':
          (sen_proxy_type == null) ? '' : sen_proxy_type.toString(),
      'sen_proxy_accnumber':
          (sen_proxy_accnumber == null) ? '' : sen_proxy_accnumber.toString(),
      'recei_bankid': (recei_bankid == null) ? '' : recei_bankid.toString(),
      'recei_bankname':
          (recei_bankname == null) ? '' : recei_bankname.toString(),
      'recei_bankshort':
          (recei_bankshort == null) ? '' : recei_bankshort.toString(),
      'recei_accnameTh':
          (recei_accnameTh == null) ? '' : recei_accnameTh.toString(),
      'recei_accnameEn':
          (recei_accnameEn == null) ? '' : recei_accnameEn.toString(),
      'recei_banktype':
          (recei_banktype == null) ? '' : recei_banktype.toString(),
      'recei_accnumber':
          (recei_accnumber == null) ? '' : recei_accnumber.toString(),
      'recei_proxy_type':
          (recei_proxy_type == null) ? '' : recei_proxy_type.toString(),
      'recei_proxy_accnumber': (recei_proxy_accnumber == null)
          ? ''
          : recei_proxy_accnumber.toString(),
      'merchant_Id': (merchant_Id == null) ? '' : merchant_Id.toString(),
      'slip_img': '$fileName_Slip',
      'directions': '1',
    }).then((value) async {
      if (value.toString() != 'No') {
        var result = json.decode(value.body);
        var payload, Sernow;
        for (var map in result) {
          easyslipModel easyslipModelss = easyslipModel.fromJson(map);
          // print(easyslipModelss.payload);
          setState(() {
            payload = easyslipModelss.payload!;
            Sernow = easyslipModelss.ser!;
          });
        }
        await InC_financetestSlip(
          payload,
          Sernow,
        );
      }
    });
  }

  Future<void> InC_financetestSlip(
    payload,
    Sernow,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/In_finance_testSlip.php?isAdd=true&ren=$ren';
    String Date_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String Time_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // daterec,pdate
    var response = await http.post(Uri.parse(url), body: {
      'isAdd': 'true',
      'ren': '$ren',
      'user': '$user',
      'daterec': '${myController2.text}',
      'pdate': '${myController3.text}',
      'docno': '${myController4.text}',
      'remark': '${myController5.text}',
      'refno': '${myController1.text}',
      'payload': payload.toString(),
      'slip_img': '$fileName_Slip',
      'amount': '${myController6.text}',
      'sernow': '$Sernow',
    }).then((value) async {
      var result = json.decode(value.body);
      // print(result);
      setState(() {
        ser_adddata = 0;
        index_Test = null;
        myController1.clear();
        myController2.clear();
        myController3.clear();
        myController4.clear();
        myController5.clear();
        myController6.clear();
        fileName_Slip = null;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[50],
          content: Translate.TranslateAndSetText(
              'ทำรายการเสร็จสิ้น !!!!',
              AccountScreen_Color.Colors_Text1_,
              TextAlign.start,
              null,
              Font_.Fonts_T,
              14,
              1),
          // Text('ทำรายการเสร็จสิ้น !!!!')
        ),
      );
    });
  }

  String maskAccount(String? account) {
    if (account == null || account.isEmpty || account.length < 6) {
      return account ?? ''; // Return original if too short or null
    }
    return '${account.substring(0, 3)}';
  }

  // String maskAccount_Af(String? account) {
  //   if (account == null || account.isEmpty || account.length < 6) {
  //     return account ?? ''; // Return original if too short or null
  //   }
  //   return '${account.substring(account.length - 4)}';
  // }

  Widget ResultChackSlip(index, columnHeaders, row, columnToCheck) {
    String rawDate =
        (easyslipModels_.length == 0) ? '' : easyslipModels_[0].slip_date ?? "";
    try {
      DateTime dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(rawDate);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      rawDate = formattedDate;
      print(formattedDate);
    } catch (e) {
      print("Custom date parsing failed: $e");
    }
//////////------------------------->
    String rawTotal =
        (easyslipModels_.length == 0) ? '0' : easyslipModels_[0].amount ?? "0";

    try {
      // Clean the string — remove commas or unwanted symbols
      rawTotal = rawTotal.replaceAll(',', '').replaceAll(' ', '').trim();

      double total = double.parse(rawTotal);
      String formattedTotal = nFormat.format(total);

      print("Formatted Total: $formattedTotal");
      rawTotal = formattedTotal; // Update rawTotal with the formatted value
    } catch (e) {
      print("Number parsing failed: $e");
      rawTotal = "0.00"; // Fallback to a default safe value
    }
    //////////------------------------->
    String bno_s = (easyslipModels_.length == 0)
        ? ''
        : (easyslipModels_[index].recei_accnumber == null ||
                easyslipModels_[index].recei_accnumber == '')
            ? (easyslipModels_[index].recei_proxy_accnumber.toString().length ==
                    0)
                ? ''
                : '${easyslipModels_[index].recei_proxy_accnumber.toString().substring(0, 3)}'
            : (easyslipModels_[index].recei_accnumber.toString().length == 0)
                ? ''
                : '${easyslipModels_[index].recei_accnumber.toString().substring(0, 3)}';

    //////////------------------------->
    return (easyslipModels_.length == 0)
        ? Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              width: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.85
                  : 1200,
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'ไม่สามารถ ตรวจสอบสลิปได้ / สลิปปลอม',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AccountScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.w600,
                      fontFamily: Font_.Fonts_T,
                      //fontSize: 10.0
                    ),
                  ),
                ),
              ),
            ),
          )
        : StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 0)),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  width: (Responsive.isDesktop(context))
                      ? MediaQuery.of(context).size.width * 0.85
                      : 1200,
                  color: (easyslipModels_.length == 0)
                      ? Colors.red[50]
                      : (row['วันที่รับชำระ'].toString().toString() !=
                                  rawDate.toString() ||
                              row['จำนวนเงิน'].toString().toString() !=
                                  rawTotal.toString())
                          ? Colors.red[50]
                          : Colors.green[50],
                  // padding: EdgeInsets.all(6.0),
                  child: Column(
                    children: [
                      const Text(
                        '',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AccountScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.w600,
                          fontFamily: Font_.Fonts_T,
                          //fontSize: 10.0
                        ),
                      ),

                      Text(
                        (easyslipModels_.length == 0)
                            ? 'วันที่สลิป: ไม่ทราบ  (จำนวนเงินในสลิป: ไม่ทราบ  )'
                            : 'วันที่สลิป: ${DateFormat('dd-MM-yyyy').format(DateTime.parse("${easyslipModels_[0].slip_date}"))}  (จำนวนเงินในสลิป: ${easyslipModels_[0].amount}) ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AccountScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.w600,
                          fontFamily: Font_.Fonts_T,
                          //fontSize: 10.0
                        ),
                      ),

                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              (easyslipModels_.length == 0)
                                  ? 'วันที่รับชำระ : ไม่ถูกต้อง✖️ || '
                                  : (row['วันที่รับชำระ'].toString() ==
                                          rawDate.toString())
                                      ? 'วันที่รับชำระ : ถูกต้อง✔️ || '
                                      : 'วันที่รับชำระ : ไม่ถูกต้อง✖️ || ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AccountScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.w600,
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              (easyslipModels_.length == 0)
                                  ? 'จำนวนเงิน : ไม่ถูกต้อง✖️ || '
                                  : (row['จำนวนเงิน'].toString().toString() ==
                                          rawTotal.toString())
                                      ? 'จำนวนเงิน : ถูกต้อง✔️ || '
                                      : 'จำนวนเงิน : ไม่ถูกต้อง✖️ || ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AccountScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.w600,
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              // (easyslipModels_.length == 0)
                              //     ? 'บัญชีผู้รับ : ไม่ถูกต้อง✖️ '
                              //     : (row['วันที่รับชำระ'].toString().toString() ==
                              //             rawTotal.toString())
                              //         ? 'บัญชีผู้รับ : ถูกต้อง✔️ '
                              //         :
                              // '${account.substring(0, 3)} : ',
                              (easyslipModels_.length == 0)
                                  ? 'บัญชีผู้รับ : ไม่ถูกต้อง✖️ '
                                  : (bno_s.toString() ==
                                          '${TransReBillModels[index].bno.toString().substring(0, 3)}')
                                      ? 'บัญชีผู้รับ : ถูกต้อง✔️ '
                                      : 'บัญชีผู้รับ : ไม่ถูกต้อง✖️ ',
                              // '${easyslipModels_[index].recei_accnumber.toString().substring(0, 3)}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AccountScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.w600,
                                fontFamily: Font_.Fonts_T,
                                //fontSize: 10.0
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: (easyslipModels_.length == 0)
                            ? Colors.red[200]
                            : Colors.green[200],
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    'ประเภทข้อมูลจากสลิป',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Text(
                                    'ชื่อธนาคาร',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Text(
                                    'เลขบช.ธนาคาร',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Text(
                                    'ชื่อ TH',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Text(
                                    'ชื่อ EN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.green[200],
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      top: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      right: BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Text(
                                    '...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,

                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      if (easyslipModels_.length == 0)
                        Center(
                          child: Text(
                            'ไม่สามารถ ตรวจสอบสลิปได้ / สลิปปลอม',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AccountScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.w600,
                              fontFamily: Font_.Fonts_T,
                              //fontSize: 10.0
                            ),
                          ),
                        ),

                      ///easyslipModels_
                      for (int index = 0;
                          index < easyslipModels_.length;
                          index++)
                        SizedBox(
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: const Text(
                                          'ข้อมูลผู้ส่ง/ผู้โอน',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                      .sen_bankname !=
                                                  null)
                                              ? '${easyslipModels_[index].sen_bankname} (${easyslipModels_[index].sen_bankshort})'
                                              : '',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                      .sen_accnumber !=
                                                  null)
                                              ? '${easyslipModels_[index].sen_accnumber}'
                                              : '${easyslipModels_[index].sen_proxy_accnumber}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          '${easyslipModels_[index].sen_accnameTh}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          '${easyslipModels_[index].sen_accnameEn}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                      .sen_banktype !=
                                                  null)
                                              ? '${easyslipModels_[index].sen_banktype}'
                                              : '${easyslipModels_[index].sen_proxy_type}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: const Text(
                                          'ข้อมูลผู้รับ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                          .recei_bankname ==
                                                      null ||
                                                  easyslipModels_[index]
                                                          .recei_bankname ==
                                                      '')
                                              ? ''
                                              : '${easyslipModels_[index].recei_bankname} (${easyslipModels_[index].recei_bankshort})',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                          .recei_accnumber ==
                                                      null ||
                                                  easyslipModels_[index]
                                                          .recei_accnumber ==
                                                      '')
                                              ? '${easyslipModels_[index].recei_proxy_accnumber}'
                                              : '${easyslipModels_[index].recei_accnumber}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          '${easyslipModels_[index].recei_accnameTh}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          '${easyslipModels_[index].recei_accnameEn}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                            right: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          (easyslipModels_[index]
                                                          .recei_banktype ==
                                                      null ||
                                                  easyslipModels_[index]
                                                          .recei_banktype ==
                                                      '')
                                              ? '${easyslipModels_[index].recei_proxy_type}'
                                              : '${easyslipModels_[index].recei_banktype}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontFamily: Font_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
  }
}
