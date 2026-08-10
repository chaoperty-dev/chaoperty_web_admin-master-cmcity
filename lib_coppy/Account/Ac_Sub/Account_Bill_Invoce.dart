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
import 'package:group_radio_button/group_radio_button.dart';
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
import '../../Man_PDF/Man_BillingNoteInvlice_PDF.dart';
import '../../Man_PDF/Man_Receipt_Market_PDF.dart';
import '../../Model/GetCFinnancetrans_Model.dart';
import '../../Model/GetExp_Model.dart';
import '../../Model/GetFinnancetrans_Model.dart';
import '../../Model/GetInvoiceRe_Model.dart';
import '../../Model/GetInvoice_history_Model.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../Model/GetRegis_model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/chack_pay_invoice_model.dart';
import '../../Model/trans_re_bill_history_model.dart';
import '../../Model/trans_re_bill_model.dart';
import '../../Model/trans_re_chack_bill_model.dart';
import '../../PeopleChao/UP_Slip_Again.dart';
import '../../Responsive/responsive.dart';
import '../../Style/File_s.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../../Style/downloadImage.dart';
import '../Ac_List/Ac_List_Title.dart';

class Account_Bill_Invoce extends StatefulWidget {
  const Account_Bill_Invoce({super.key});

  @override
  State<Account_Bill_Invoce> createState() => _Account_Bill_InvoceState();
}

class _Account_Bill_InvoceState extends State<Account_Bill_Invoce> {
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

  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];

  List<InvoiceReModel> InvoiceModels = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];

  List<PayMentModel> payMentModels = [];
  List<ExpModel> expModels = [];
  List<Regis_model> regis_models = [];

  ///////////--------------------------------------------->
  List<String> invoice_select_delete = [];
  List<String> invoice_loade_Success_delete = [];
  List<String> invoice_select = [];
  List<String> invoice_loade_Success = [];

  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac4_1 = [];
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
  int Type_delete = 0;
  //-------------------------------------->
  // ตัวแปรสำหรับการจัดเรียง
  bool sortAscending = true;
  String sortColumn = "กำหนดชำระ";
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
      doctax,
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
  String? paymentSer1,
      paymentName1,
      paymentSer2,
      paymentName2,
      cFinn,
      Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '',
      selectedValue,
      bname1;
  String? base64_Slip, fileName_Slip, Slip_history, Datex_invoice;
  String? ref_1, ref_2, ref_3;
  String? payment_Ptser1,
      payment_Ptname1,
      payment_Bno1,
      payment_type1,
      payment_bank1;
  String? payment_Ptser2,
      payment_Ptname2,
      payment_Bno2,
      payment_type2,
      payment_bank2;
  int? Cancell_bill = 0, Day_Cancell_bill = 0;
  ///////////--------------------------------------------->
  int renTal_lavel = 0;
  int Status_dates = 0;

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
  double sum_Pakan = 0,
      sum_Pakan_KF = 0,
      dis_Pakan = 0,
      dis_matjum = 0,
      dis_sum_Pakan = 0.00,
      dis_sum_Matjum = 0.00,
      sum_Matjum_KF = 0,
      sum_tran_dis = 0,
      sum_matjum = 0.00,
      sum_tran_fine = 0,
      fine_total = 0,
      fine_total2 = 0,
      sum_fine = 0;

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
  String? numinvoice;
  int TitleType_Default_Receipt = 0;
  String _ReportValue_type = "ไม่ระบุ";
  String? TitleType_Default_Receipt_Name;
  ///////////--------------------------------------------->
  String? base64_Imgmap, tem_page_ser;
  ///////////--------------------------------------------->
  var round_p, paper, paper_run;
  String? bneme_check, bno_check, bser_check;
  ///////////--------------------------------------------->
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'คู่ฉบับ',
    'สำเนา',
    'สำเนาคู่ฉบับ',
  ];
  List Default_ = [
    'บิลธรรมดา',
  ];
  List Default2_ = [
    'บิลธรรมดา',
    'ใบกำกับภาษี',
  ];
  ///////////--------------------------------------------->
  String randomString = '';

  String? email_login;
  String? seremail_login;

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

  ///////////--------------------------------------------->
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
      ac4_1.addAll(
          AcListTitle().ac_4_1); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac4_1(String ser) {
    if (ac4_1
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
      // //print(result);
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
            Cancell_bill = int.parse(renTalModel.cancell_bill!);
            Day_Cancell_bill = int.parse(renTalModel.day_cancell_bill!);
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
  }

  //////////////----------------------------------------->
  Future<Null> red_payMent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
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
    red_InvoiceMon_bill().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

////////--------------------------------------------------------------->

  Future<Null> red_InvoiceMon_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    setState(() {
      isLoading_main = true;
      isLoading = true;
      InvoiceModels.clear();
      data.clear();
      filteredData.clear();
    });

    String Serdata =
        (zone.toString() == '0' || zone == null) ? 'All' : 'Allzone';
    String url = (Serdata.toString() == 'All')
        ? '${MyConstant().domain}/GC_bill_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now&status=$Status_dates'
        : '${MyConstant().domain}/GC_bill_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now&status=$Status_dates';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceModels.add(transMeterModel);
          });
        }
      }

      setState(() {
        _InvoiceModels = InvoiceModels;
      });
      AddDaTa();
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (InvoiceModels.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(InvoiceModels.length, (index) {
          // Ensure that docno exists and is not null
          final cid = InvoiceModels[index].cid ?? "";
          final docno = InvoiceModels[index].docno ?? "";

          final daterec = (InvoiceModels[index].daterec == null ||
                  InvoiceModels[index].daterec! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec} 00:00:00'))}-${DateTime.parse('${InvoiceModels[index].daterec} 00:00:00').year + 0}';
          final date = (InvoiceModels[index].date == null)
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].date} 00:00:00'))}-${DateTime.parse('${InvoiceModels[index].date} 00:00:00').year + 0}';

          final sname = InvoiceModels[index].scname ?? "";
          final cname = InvoiceModels[index].cname ?? "";
          final zn = '${InvoiceModels[index].zn}';
          final ln = '${InvoiceModels[index].ln}';
          final type = InvoiceModels[index].btype ?? "";
          final amt_dis = (InvoiceModels[index].amt_dis == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].amt_dis!))}';

          final total = (InvoiceModels[index].total_bill == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].total_bill!))}';
          final total_dis = (InvoiceModels[index].total_dis == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].total_dis!))}';
          final refapi = InvoiceModels[index].refapi ?? "";
          final ref1 = InvoiceModels[index].ref1 ?? "";
          final ref2 = InvoiceModels[index].ref2 ?? "";

          return {
            "index": "$index",
            if (where_ac4_1("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac4_1("1") == false) "เลขที่ใบแจ้งหนี้": "$docno",
            if (where_ac4_1("2") == false) "วันที่ทำรายการ": "$daterec",
            if (where_ac4_1("3") == false) "กำหนดชำระ": "$date",
            if (where_ac4_1("4") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac4_1("5") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac4_1("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac4_1("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac4_1("8") == false) "ช่องทางชำระ": "$type",
            if (where_ac4_1("9") == false) "ส่วนลด": "$amt_dis",
            if (where_ac4_1("10") == false) "ยอดรวม": "$total",
            if (where_ac4_1("11") == false) "ยอดสุทธิ": "$total_dis",
            if (where_ac4_1("12") == false) "รหัสอ้างอิง": "$refapi",
            if (where_ac4_1("13") == false) "Ref1": "$ref1",
            if (where_ac4_1("14") == false) "Ref2": "$ref2",
          };
        });
        filteredData = data;
      });
    } else {
      // Handle the case where contractxPakanModels is empty
      // //print("contractxPakanModels is empty, no data to add. $data");
    }

    // //print("Data added: $data");
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
    return InvoiceModels.where((e) =>
            // e.daterec.toString() == row['วันที่ทำรายการ'].toString() &&
            // e.date.toString() == row['กำหนดชำระ'].toString() &&
            e.ln.toString() == row['รหัสพื้นที่'].toString() &&
            e.zn.toString() == row['โซนพื้นที่'].toString()).length >
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
        // ใช้ Map เพื่อตรวจสอบความถี่ของค่าใน รหัสพื้นที่
        final seen = <String, int>{};
        for (var row in data) {
          final key =
              row["รหัสพื้นที่"]?.toString() ?? ''; // ใช้ รหัสพื้นที่ เป็น key

          // ตรวจสอบว่า key ไม่เป็นค่าว่างก่อนที่จะนับ
          if (key != '') {
            seen[key] = (seen[key] ?? 0) + 1; // นับจำนวนครั้งที่พบ
          }
        }

        // กรองเฉพาะข้อมูลที่ซ้ำ
        filteredData = data.where((row) {
          final key =
              row["รหัสพื้นที่"]?.toString() ?? ''; // ใช้ รหัสพื้นที่ เป็น key
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

  Future<Null> red_Trans_select(
      index, ciddoc, qutser, tser, docno, page) async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    var docnoin = docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // //print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = (_InvoiceHistoryModel.pvat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = (_InvoiceHistoryModel.vat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = (_InvoiceHistoryModel.wht == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = (_InvoiceHistoryModel.total_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = (_InvoiceHistoryModel.disendbill == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = (_InvoiceHistoryModel.disendbillper == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            paper = _InvoiceHistoryModel.paper;
            paper_run = _InvoiceHistoryModel.paper_run;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
      checkshowDialog(index, docno, page);
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
      // //print('เกิน กำหนด.');
      // Count_time_check = Count_time_check + 1;
      return true;
    } else {
      return false;
    }
  }

/////////----------------------------------------------------------->
  Future<Null> red_Trans_selectPay(index) async {
    // //print(
    //     'Ser : ${InvoiceModels[index].ser} // docno :  ${InvoiceModels[index].docno} ///total : ${InvoiceModels[index].total_dis}');
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = InvoiceModels[index].cid;
    var qutser = '1';
    var docnoin = InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;

            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else if (result.toString() == 'false') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;

            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Translate.TranslateAndSetText(
                'มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                Colors.white,
                TextAlign.start,
                null,
                Font_.Fonts_T,
                14,
                1),

            // Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
            //     style: TextStyle(
            //         color: Colors.white, fontFamily: Font_.Fonts_T))
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Translate.TranslateAndSetText(
              'มีผู้ใช้อื่นกำลังทำรายการอยู่....',
              Colors.white,
              TextAlign.start,
              null,
              Font_.Fonts_T,
              14,
              1),
          //  Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
          //     style:
          //         TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))
        ),
      );
    }
  }

  /////////----------------------------------------------------------->
  Future<Null> in_Trans_invoice_refnoPay(
      index, Value_newDateY1, Value_newDatepay, serpay_all) async {
    var Times = DateFormat('HH:mm:ss').format(datex).toString();
    String? fileName_Slip_ = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = InvoiceModels[index].cid;
    var qutser = '1';
    var sumdis = sum_disamt.toString();
    var sumdisp = sum_disp.toString();
    var dateY = Value_newDatepay;
    var dateY1 = Value_newDateY1;
    var time = Times;
    //pamentpage == 0
    var dis_akan = dis_sum_Pakan.toString();
    var dis_Matjum = dis_sum_Matjum.toString();
    var payment1 = InvoiceModels[index].total_dis.toString();
    var payment2 = '';
    var pSer1 = InvoiceModels[index].payment_ser.toString();
    var pSer2 = paymentSer2;
    var ref = InvoiceModels[index].docno;
    var sum_whta = sum_wht.toString();
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var comment = '';
    var sum_fine = sum_tran_fine;
    var fine_total_amt = (fine_total + fine_total2);

    String url =
        '${MyConstant().domain}/In_tran_finanref1.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&ref=$ref&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&dis_Matjum=$dis_Matjum&sum_fine=$sum_fine&fine_total_amt=$fine_total_amt';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'No') {
        // //print('result.toString() != No');
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
          setState(() {
            cFinn = cFinnancetransModel.docno;

            doctax = cFinnancetransModel.doctax;
          });
          // //print('zzzzasaaa123454>>>>  $cFinn');
        }
        // setState(() {
        //   Invoic_selectAllSuccess.add(InvoiceModels[index].docno.toString());
        // });

        Insert_log.Insert_logs('บัญชี', 'ประวัติวางบิล --> อนุมัติ:$cFinn ');
        if (serpay_all == '0') {
          Navigator.pop(context, 'OK');
        } else {}

        setState(() async {
          dis_sum_Pakan = 0.00;
          dis_Pakan = 0;
          dis_matjum = 0;
          sum_matjum = 0.00;
          dis_sum_Matjum = 0.00;
          sum_tran_fine = 0;
          fine_total = 0;
          fine_total2 = 0;
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;

          _InvoiceModels.clear();
          _InvoiceHistoryModels.clear();
        });
        // //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///////////--------------------------------------------->
  Future<Null> red_Trans_selectPay_check(index) async {
    setState(() {
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_disamt = 0;
      sum_disp = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _InvoiceModels[index].cid;
    var qutser = '1';
    var docnoin = _InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
          });
        }
      } else if (result.toString() == 'false') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
          });
        }
      } else {}
    } catch (e) {}
  }

  ///////////--------------------------------------------->
  Future<Null> in_Trans_invoice_refnoPay_chack(
      index, Value_newDateY1, Value_newDatepay, serpay_all) async {
    var Times = DateFormat('HH:mm:ss').format(datex).toString();
    String? fileName_Slip_ = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _InvoiceModels[index].cid;
    var qutser = '1';
    var sumdis = _InvoiceModels[index].amt_dis.toString();
    var sumdisp = 0.toString();
    var dateY = Value_newDatepay;
    var dateY1 = Value_newDateY1;
    var time = Times;
    //pamentpage == 0
    var dis_akan = dis_sum_Pakan.toString();
    var dis_Matjum = dis_sum_Matjum.toString();
    var payment1 = _InvoiceModels[index].total_dis.toString();
    var payment2 = '';
    var pSer1 = _InvoiceModels[index].payment_ser.toString();
    var pSer2 = paymentSer2;
    var ref = _InvoiceModels[index].docno;
    var sum_whta = sum_wht.toString();
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var comment = '';
    var sum_fine = sum_tran_fine;
    var fine_total_amt = (fine_total + fine_total2);

    String url =
        '${MyConstant().domain}/In_tran_finanref1.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&ref=$ref&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&dis_Matjum=$dis_Matjum&sum_fine=$sum_fine&fine_total_amt=$fine_total_amt';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() != 'No') {
        // //print('result.toString() != No');
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
          setState(() {
            cFinn = cFinnancetransModel.docno;

            doctax = cFinnancetransModel.doctax;
          });
          // //print('zzzzasaaa123454>>>>  $cFinn');
        }

        Insert_log.Insert_logs('บัญชี', 'ประวัติวางบิล --> อนุมัติ:$cFinn ');
      }
    } catch (e) {}
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    double calculatedWidth =
        (ac4_1.where((item) => item["st"] == '1').toList().length <= 10)
            ? (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.83
                : 1400
            : (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.83 +
                    ((ac4_1.where((item) => item["st"] == '1').toList().length -
                            10) *
                        30)
                : 1400 +
                    ((ac4_1.where((item) => item["st"] == '1').toList().length -
                            10) *
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
                            : (InvoiceModels.isEmpty)
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

                            items: ac4_1.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac4_1.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // //print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac4_1[selectedIndex]["st"] = '0';
                                          } else {
                                            ac4_1[selectedIndex]["st"] = '1';
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
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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
                                      // Padding(
                                      //   padding: EdgeInsets.all(2.0),

                                      //   ///Status_dates
                                      //   child: Translate.TranslateAndSetText(
                                      //       'สถานะ :',
                                      //       ReportScreen_Color.Colors_Text2_,
                                      //       TextAlign.start,
                                      //       null,
                                      //       Font_.Fonts_T,
                                      //       12,
                                      //       1),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          width: 170,
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
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  topLeft: Radius.circular(10),
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
                                            hint: Translate.TranslateAndSetText(
                                                'ประจำเดือน',
                                                AccountScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.start,
                                                null,
                                                Font_.Fonts_T,
                                                11,
                                                1),
                                            // value: (Status_dates == null)
                                            //     ? 'ประจำเดือน'
                                            //     : (Status_dates == 1)
                                            //         ? 'เลยกำหนดชำระ'
                                            //         : (Status_dates == 2)
                                            //             ? 'ยังเลยกำหนดชำระ'
                                            //             : 'ประจำเดือน',

                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              // Icons.sort_rounded,
                                              color: Colors.black,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            iconSize: 20,
                                            buttonHeight:
                                                (Status_dates == 0) ? 30 : 47,
                                            buttonWidth: 250,
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
                                              DropdownMenuItem<String>(
                                                value: '0',
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        '🟢ประจำเดือน',
                                                        Colors.grey,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        11,
                                                        1),
                                              ),
                                              DropdownMenuItem<String>(
                                                value: '1',
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Translate
                                                        .TranslateAndSetText(
                                                            '🟢เลยกำหนดชำระ',
                                                            Colors.grey,
                                                            TextAlign.start,
                                                            null,
                                                            Font_.Fonts_T,
                                                            11,
                                                            1),
                                                    Translate.TranslateAndSetText(
                                                        '***(กำหนดชำระ < วันปัจจุบัน)',
                                                        Colors.red[300],
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        9,
                                                        2),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem<String>(
                                                value: '2',
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Translate.TranslateAndSetText(
                                                        '🟢ยังไม่เลยกำหนดชำระ',
                                                        Colors.grey,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        11,
                                                        1),
                                                    Translate.TranslateAndSetText(
                                                        '**(กำหนดชำระ >= วันปัจจุบัน)',
                                                        Colors.red[300],
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        9,
                                                        2),
                                                  ],
                                                ),
                                              ),
                                            ],

                                            onChanged: (value) async {
                                              setState(() {
                                                Status_dates =
                                                    int.parse(value.toString());
                                              });
                                              Loading_Trans_bill();
                                              // red_InvoiceMon_bill();
                                            },
                                          ),
                                        ),
                                      ),
                                      if (Status_dates == 0)
                                        Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Translate.TranslateAndSetText(
                                              'เดือนที่ครบกำหนด :',
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
                                      if (Status_dates == 0)
                                        Padding(
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
                                      if (Status_dates == 0)
                                        Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Translate.TranslateAndSetText(
                                              'ปีที่ครบกำหนด :',
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
                                      if (Status_dates == 0)
                                        Padding(
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

                                      if (api_key == 'Y')
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 2, 4, 2),
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
                                                        Color.fromARGB(
                                                            255, 180, 121, 43)),
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
                                                    for (var index = 0;
                                                        index <
                                                            _InvoiceModels
                                                                .length;
                                                        index++) {
                                                      if (_InvoiceModels[index]
                                                              .refapi !=
                                                          "") {
                                                        var refapi =
                                                            _InvoiceModels[
                                                                    index]
                                                                .refapi;
                                                        var incid =
                                                            _InvoiceModels[
                                                                    index]
                                                                .cid;
                                                        var indocno =
                                                            _InvoiceModels[
                                                                    index]
                                                                .docno;
                                                        var insum = double.parse(
                                                            _InvoiceModels[
                                                                    index]
                                                                .total_dis!);
                                                        var name =
                                                            _InvoiceModels[
                                                                    index]
                                                                .scname;
                                                        var datec =
                                                            _InvoiceModels[
                                                                    index]
                                                                .date;

                                                        // //print('$refapi $insum $incid $indocno $name $datec');
                                                        // if (_InvoiceModels[index].ser_noti != null) {
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        var ren = preferences
                                                            .getString(
                                                                'renTalSer');
                                                        String url =
                                                            '${MyConstant().domain}/chack_invoice_api.php?isAdd=true&ren=$ren&refapi=$refapi&name=$name&insum=$insum&datec=$datec';

                                                        try {
                                                          var response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      url));

                                                          var result = json
                                                              .decode(response
                                                                  .body);

                                                          if (result
                                                                  .toString() !=
                                                              'No') {
                                                            //  //print(result
                                                            //    .toString());
                                                            ChackpayinvoiceModel
                                                                chackpayinvoiceModel =
                                                                ChackpayinvoiceModel
                                                                    .fromJson(
                                                                        result);
                                                            var amountx =
                                                                chackpayinvoiceModel
                                                                    .amount;
                                                            var ref_idx =
                                                                chackpayinvoiceModel
                                                                    .ref_id;
                                                            var transTimex =
                                                                chackpayinvoiceModel
                                                                    .transTime;
                                                            var reference2x =
                                                                chackpayinvoiceModel
                                                                    .reference2;
                                                            var reference1x =
                                                                chackpayinvoiceModel
                                                                    .reference1;
                                                            var Value_newDateY1 =
                                                                DateTime.now();
                                                            var Value_newDatepay =
                                                                chackpayinvoiceModel
                                                                    .transDate;
                                                            // //print('>>>> $amountx $ref_idx $transTimex $reference2x $reference1x $Value_newDatepay');
                                                            red_Trans_selectPay_check(
                                                                    index)
                                                                .then((value) =>
                                                                    in_Trans_invoice_refnoPay_chack(
                                                                        index,
                                                                        Value_newDateY1,
                                                                        Value_newDatepay,
                                                                        '0'));
                                                          } else {
                                                            //print(
                                                            //    'ยังไม่มีการชำระ');
                                                          }
                                                        } catch (e) {
                                                          // //print('Error-Dis(read_GC_rental) : ${e}');
                                                        }
                                                      } else {
                                                        //print(
                                                        // ' ${_InvoiceModels[index].cid}');
                                                      }
                                                    }
                                                    setState(() {
                                                      Loading_Trans_bill();
                                                      // Future.delayed(const Duration(milliseconds: 800));
                                                      // red_InvoiceMon_bill();
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                  onTapCancel: () {
                                                    Navigator.pop(context);
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.success,
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
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
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 2, 4, 2),
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
                                                      Color.fromARGB(
                                                          255, 105, 180, 43)),
                                            ),
                                            onPressed: () async {
                                              PanaraConfirmDialog
                                                  .showAnimatedGrow(
                                                context,
                                                title: "Line Notification",
                                                message:
                                                    "แจ้งเตือนชำระค่าบริการผ่านไลน์",
                                                confirmButtonText: "Confirm",
                                                cancelButtonText: "Cancel",
                                                onTapConfirm: () async {
                                                  for (var index = 0;
                                                      index <
                                                          _InvoiceModels.length;
                                                      index++) {
                                                    if (_InvoiceModels[index]
                                                            .ser_noti !=
                                                        null) {
                                                      var serregis =
                                                          _InvoiceModels[index]
                                                              .ser_noti;
                                                      var incid =
                                                          _InvoiceModels[index]
                                                              .cid;
                                                      var indocno =
                                                          _InvoiceModels[index]
                                                              .docno;
                                                      var insum = nFormat
                                                          .format(double.parse(
                                                              _InvoiceModels[
                                                                      index]
                                                                  .total_dis!));
                                                      if (_InvoiceModels[index]
                                                              .ser_noti !=
                                                          null) {
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        var ren = preferences
                                                            .getString(
                                                                'renTalSer');
                                                        String url =
                                                            '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                                                        renTal_name = preferences
                                                            .getString(
                                                                'renTalName');
                                                        try {
                                                          var response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      url));

                                                          var result = json
                                                              .decode(response
                                                                  .body);

                                                          if (result
                                                                  .toString() ==
                                                              'Line Successfully') {
                                                            // //print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                                            // ScaffoldMessenger.of(context).showSnackBar(
                                                            //   SnackBar(
                                                            //     content: Text(
                                                            //       'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ) (${_InvoiceModels[index].scname} : ${_InvoiceModels[index].cname})',
                                                            //       style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                            //     ),
                                                            //   ),
                                                            // );
                                                          } else {
                                                            // //print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                                            // ScaffoldMessenger.of(context).showSnackBar(
                                                            //   SnackBar(
                                                            //     content: Text(
                                                            //       'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่) (${_InvoiceModels[index].scname} : ${_InvoiceModels[index].cname})',
                                                            //       style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                            //     ),
                                                            //   ),
                                                            // );
                                                          }
                                                        } catch (e) {
                                                          // //print('Error-Dis(read_GC_rental) : ${e}');
                                                        }
                                                      }
                                                    }
                                                    if (index + 1 ==
                                                        _InvoiceModels.length) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  // Navigator.pop(context);
                                                },
                                                onTapCancel: () {
                                                  Navigator.pop(context);
                                                },
                                                panaraDialogType:
                                                    PanaraDialogType.success,
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.notifications,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                Expanded(
                                                  child: Translate
                                                      .TranslateAndSet_TextAutoSize(
                                                          'Line Notify',
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
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 0, 0, 0),
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
                                          color: AppbackgroundColor
                                              .Sub_Abg_Colors.withOpacity(0.5),
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
                                              child:
                                                  Translate.TranslateAndSetText(
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
                                // Spacer(),
                              ]))),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 150,
                      child: PopupMenuButton(
                        tooltip: (Type_delete == 1)
                            ? 'ปิด-การยกเลิกบิลแบบหลายรายการ'
                            : 'การยกเลิกบิล แบบหลายรายการ',
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
                            (Type_delete == 1)
                                ? 'ปิด-การยกเลิกบิล'
                                : 'การยกเลิกบิลหลายรายการ:',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              decoration: TextDecoration.underline,
                              color: (Type_delete == 1)
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
                                  invoice_select.clear();
                                  invoice_select_delete.clear();
                                  Type_delete = (Type_delete == 1) ? 0 : 1;
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
                                  (Type_delete == 1)
                                      ? 'ยกเลิก-การเลือกทั้งหมด'
                                      : 'เลือกรายการ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (Type_delete == 1)
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
                          Container(
                            // color: Colors.orange,
                            width: 50,
                            child: Center(
                              child: Text(
                                '...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontSize: 13,
                                    fontFamily: Font_.Fonts_T
                                    //fontSize: 10.0
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: (displayedData.length == 0)
                                ? SizedBox()
                                : Center(
                                    child: Container(
                                      width: 70,
                                      child: (invoice_select.length != 0 &&
                                              InvoiceModels.length != 0)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Container(
                                                  //   decoration: BoxDecoration(
                                                  //     color: Colors.white,
                                                  //     borderRadius:
                                                  //         const BorderRadius
                                                  //                 .only(
                                                  //             topLeft: Radius
                                                  //                 .circular(6),
                                                  //             topRight: Radius
                                                  //                 .circular(6),
                                                  //             bottomLeft: Radius
                                                  //                 .circular(6),
                                                  //             bottomRight:
                                                  //                 Radius
                                                  //                     .circular(
                                                  //                         6)),
                                                  //     border: Border.all(
                                                  //         color: Colors.grey,
                                                  //         width: 1),
                                                  //   ),
                                                  //   padding:
                                                  //       const EdgeInsets.all(2),
                                                  //   child:
                                                  // Text(
                                                  //     'Save ( ${invoice_select.length} )',
                                                  //     textAlign:
                                                  //         TextAlign.center,
                                                  //     style: TextStyle(
                                                  //       fontSize: 10,
                                                  //       color: Colors.grey[800],
                                                  //       fontWeight:
                                                  //           FontWeight.bold,
                                                  //       fontFamily:
                                                  //           FontWeight_.Fonts_T,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  PopupMenuButton(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(6),
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Column(
                                                        children: [
                                                          const Text(
                                                            // 'Save',
                                                            'Save :',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white,
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
                                                            '( ${invoice_select.length} )',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white,
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
                                                      //    const Icon(
                                                      //     Icons.download,
                                                      //     color: Colors.white,
                                                      //     size: 22,
                                                      //   ),
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

                                                              _showMyDialog_SAVE2(
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
                                                                  'Save( ${invoice_select.length} ) : Folder ',
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

                                                              _showMyDialog_SAVE2(
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
                                                                  'Save( ${invoice_select.length} ) : File ',
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
                                                              invoice_select
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
                                                                    'ยกเลิกทั้งหมด( ${invoice_select.length} ) : ',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    13,
                                                                    1),
                                                                // Text(
                                                                //   'ยกเลิกทั้งหมด( ${invoice_select.length} ) : ',
                                                                //   style: const TextStyle(
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
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
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
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                width: 80,
                                                child: InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      invoice_select_delete
                                                          .clear();
                                                      invoice_select.clear();
                                                    });
                                                    // //print(InvoiceModels
                                                    //     .length);
                                                    for (int index = 0;
                                                        index <
                                                            InvoiceModels
                                                                .length;
                                                        index++) {
                                                      if (InvoiceModels[index]
                                                                  .btype ==
                                                              null ||
                                                          InvoiceModels[index]
                                                                  .btype
                                                                  .toString() ==
                                                              '') {
                                                      } else {
                                                        setState(() {
                                                          invoice_select.add(
                                                              '${InvoiceModels[index].docno}');
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Text(
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
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                          ),

                          ...columnHeaders
                              .skip(1)
                              .map((column) => Expanded(
                                    flex: (columnHeaders.any((columnx) {
                                      return
                                          // column.toString() ==
                                          //         'เลขที่สัญญา' ||
                                          column.toString() ==
                                              'เลขที่ใบแจ้งหนี้';
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
                                                              'ส่วนลด' ||
                                                          column.toString() ==
                                                              'ยอดรวม' ||
                                                          column.toString() ==
                                                              'ยอดสุทธิ';
                                                    }))
                                                        ? TextAlign.right
                                                        : (columnHeaders
                                                                .any((columnx) {
                                                            return column
                                                                        .toString() ==
                                                                    'ช่องทางชำระ' ||
                                                                column.toString() ==
                                                                    'รหัสอ้างอิง' ||
                                                                column.toString() ==
                                                                    'Ref1' ||
                                                                column.toString() ==
                                                                    'Ref2';
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
                                      final columnToCheck = 'รหัสพื้นที่';
                                      final columnToCheck_zn = 'โซนพื้นที่';

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
                                          // : (transReChackBillModels.length != 0)
                                          //     ? Container(
                                          //         width: calculatedWidth,
                                          //         child: Column(
                                          //           children: [
                                          //             List_Material(
                                          //                 index,
                                          //                 columnHeaders,
                                          //                 row,
                                          //                 columnToCheck),
                                          //             Container(
                                          //               width: calculatedWidth,
                                          //               child:
                                          //                   List_Material_TransReChackBill(
                                          //                       index_x,
                                          //                       columnHeaders,
                                          //                       row,
                                          //                       columnToCheck,
                                          //                       calculatedWidth),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       )
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
      // color: tappedIndex_ == index.toString()
      //     ? tappedIndex_Color.tappedIndex_Colors
      //     : AppbackgroundColor.Sub_Abg_Colors,
      color: tappedIndex_ == index.toString()
          ? tappedIndex_Color.tappedIndex_Colors
          : (hasDuplicate(row) && row[columnToCheck]?.toString() != '')
              ? Colors.red[200]!.withOpacity(0.6)
              : AppbackgroundColor.Sub_Abg_Colors,
      child: InkWell(
        hoverColor: Colors.grey[350]!.withOpacity(0.5),
        onTap: () async {
          int index_x = int.parse('${row['index']}');
          List newValuePDFimg = [];
          for (int index = 0; index < 1; index++) {
            if (renTalModels[0].imglogo!.trim() == '') {
              // newValuePDFimg.add(
              //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
            } else {
              newValuePDFimg.add(
                  '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
            }
          }

          var ciddoc = InvoiceModels[index_x].cid;
          var qutser = '1';
          var tser = InvoiceModels[index_x].total_dis;
          var docno = InvoiceModels[index_x].docno;

          setState(() {
            tappedIndex_ = index.toString();
            payment_Ptser1 = InvoiceModels[index_x].ptser;
            payment_Ptname1 = InvoiceModels[index_x].ptname;
            payment_Bno1 = InvoiceModels[index_x].bno;

            Datex_invoice = InvoiceModels[index_x].daterec;

            payment_type1 = InvoiceModels[index_x].btype;
            payment_bank1 = InvoiceModels[index_x].bank;
          });
          await Dia_log1();
          red_Trans_select(index_x, ciddoc, qutser, tser, docno, '0');
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
                  InvoiceModels[index].ser_noti != null
                      ? Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(
                              child: CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                Colors.green.shade600.withOpacity(0.3),
                            child: InkWell(
                                onTap: () async {
                                  PanaraConfirmDialog.showAnimatedGrow(
                                    context,
                                    title: "Line Notification",
                                    message: "แจ้งเตือนชำระค่าบริการผ่านไลน์",
                                    confirmButtonText: "Confirm",
                                    cancelButtonText: "Cancel",
                                    onTapConfirm: () async {
                                      if (InvoiceModels[index].ser_noti !=
                                          null) {
                                        var serregis =
                                            InvoiceModels[index].ser_noti;
                                        var incid = InvoiceModels[index].cid;
                                        var indocno =
                                            InvoiceModels[index].docno;
                                        var insum = nFormat.format(double.parse(
                                            InvoiceModels[index].total_dis!));
                                        SharedPreferences preferences =
                                            await SharedPreferences
                                                .getInstance();
                                        var ren =
                                            preferences.getString('renTalSer');
                                        String url =
                                            '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                                        renTal_name =
                                            preferences.getString('renTalName');
                                        try {
                                          var response =
                                              await http.get(Uri.parse(url));

                                          var result =
                                              json.decode(response.body);

                                          if (result.toString() ==
                                              'Line Successfully') {
                                            ////print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Translate
                                                    .TranslateAndSetText(
                                                        'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                        Colors.white,
                                                        TextAlign.start,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                // ),
                                              ),
                                            );
                                          } else {
                                            // //print('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Translate
                                                    .TranslateAndSetText(
                                                        'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                        Colors.white,
                                                        TextAlign.start,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                // ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          //print(
                                          //    'Error-Dis(read_GC_rental) : ${e}');
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                    onTapCancel: () {
                                      Navigator.pop(context);
                                    },
                                    panaraDialogType: PanaraDialogType.success,
                                  );
                                },
                                child: Center(
                                    child: Icon(
                                  Icons.notifications_none,
                                  size: 18,
                                  color: Colors.blueGrey,
                                ))),
                          )),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(child: SizedBox()),
                        ),
                  (InvoiceModels[index].date == null ||
                          DateTime.parse(
                                  '${InvoiceModels[index].date} 23:59:58')
                              .isBefore(DateTime.now()))
                      ? Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Center(
                            child: PopupMenuButton(
                              tooltip: 'เลยวันครบกำหนด',
                              onOpened: () {},
                              child: Center(
                                child: InkWell(
                                  child: Center(
                                      child: Icon(
                                    Icons.lock_clock,
                                    size: 18,
                                    color: Colors.blueGrey,
                                  )),
                                ),
                              ),
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                    child: Text(
                                  (InvoiceModels[index].date == null)
                                      ? ''
                                      : '${InvoiceModels[index].docno} : เลยวันครบกำหนดชำระมาแล้ว ${DateTime.now().difference(DateTime.parse(InvoiceModels[index].date!)).inDays} วัน',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                )),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(child: SizedBox()),
                        ),
                ],
              ),
            ),
            (Type_delete == 1)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[100]!.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      width: 55,
                      padding: const EdgeInsets.all(1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: (invoice_select_delete.contains(
                                        '${InvoiceModels[int.parse('${row['index']}')].docno}') ==
                                    true)
                                ? Icon(Icons.check_box,
                                    size: 20, color: Colors.red[300])
                                : const Icon(Icons.check_box_outline_blank,
                                    size: 20, color: Colors.grey),
                            onTap: () async {
                              int index_x = int.parse('${row['index']}');
                              setState(() {
                                invoice_select.clear();
                                // invoice_select_delete.clear();
                              });
                              if (invoice_select_delete.length >= 50) {
                                setState(() {
                                  invoice_select_delete.remove(
                                      '${InvoiceModels[index_x].docno}');
                                });
                                Dialog_notimax(50);
                              } else {
                                setState(() {
                                  if (invoice_select_delete.contains(
                                          '${InvoiceModels[index_x].docno}') ==
                                      true) {
                                    invoice_select_delete.remove(
                                        '${InvoiceModels[index_x].docno}');
                                  } else {
                                    invoice_select_delete
                                        .add('${InvoiceModels[index_x].docno}');
                                  }
                                });
                              }
                            },
                          ),

                          ///invoice_loade_Success
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: (invoice_loade_Success_delete.contains(
                                        '${InvoiceModels[int.parse('${row['index']}')].docno}') ==
                                    true)
                                ? Colors.red[600]
                                : null,
                          )
                        ],
                      ),
                    ),
                  )
                : (InvoiceModels[int.parse('${row['index']}')].btype == null ||
                        InvoiceModels[int.parse('${row['index']}')]
                                .btype
                                .toString() ==
                            '')
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: (invoice_select.contains(
                                            '${InvoiceModels[int.parse('${row['index']}')].docno}') ==
                                        true)
                                    ? const Icon(Icons.check_box,
                                        size: 20,
                                        color: AppBarColors.ABar_Colors)
                                    : const Icon(Icons.check_box_outline_blank,
                                        size: 20, color: Colors.grey),
                                onTap: () async {
                                  int index_x = int.parse('${row['index']}');
                                  setState(() {
                                    invoice_select_delete.clear();
                                  });
                                  if (invoice_select.length >= 50) {
                                    setState(() {
                                      invoice_select.remove(
                                          '${InvoiceModels[index_x].docno}');
                                    });
                                    Dialog_notimax(50);
                                  } else {
                                    setState(() {
                                      if (invoice_select.contains(
                                              '${InvoiceModels[index_x].docno}') ==
                                          true) {
                                        invoice_select.remove(
                                            '${InvoiceModels[index_x].docno}');
                                      } else {
                                        invoice_select.add(
                                            '${InvoiceModels[index_x].docno}');
                                      }
                                    });
                                  }
                                },
                              ),

                              ///invoice_loade_Success
                              Icon(
                                Icons.download,
                                size: 20,
                                color: (invoice_loade_Success.contains(
                                            '${InvoiceModels[int.parse('${row['index']}')].docno}') ==
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
                          column.toString() == 'เลขที่ใบแจ้งหนี้' ||
                          column.toString() == 'ชื่อผู้เช่า' ||
                          column.toString() == 'รหัสอ้างอิง' ||
                          column.toString() == 'Ref1' ||
                          column.toString() == 'Ref2';
                    }))
                        ? Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return
                                  //  column.toString() == 'เลขที่สัญญา' ||
                                  column.toString() == 'เลขที่ใบแจ้งหนี้';
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
                                      return column.toString() == 'ส่วนลด' ||
                                          column.toString() == 'ยอดรวม' ||
                                          column.toString() == 'ยอดสุทธิ';
                                    }))
                                        ? TextAlign.right
                                        : (columnHeaders.any((columnx) {
                                            return column.toString() ==
                                                'ช่องทางชำระ';
                                          }))
                                            ? TextAlign.center
                                            : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: (row['ยอดสุทธิ'].toString() ==
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
                              return
                                  // column.toString() == 'เลขที่สัญญา' ||
                                  column.toString() == 'เลขที่ใบแจ้งหนี้';
                            }))
                                ? 2
                                : 1,
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              row[column]?.toString() ?? '',
                              textAlign: (columnHeaders.any((columnx) {
                                return column.toString() == 'ส่วนลด' ||
                                    column.toString() == 'ยอดรวม' ||
                                    column.toString() == 'ยอดสุทธิ';
                              }))
                                  ? TextAlign.right
                                  : (columnHeaders.any((columnx) {
                                      return column.toString() == 'ช่องทางชำระ';
                                    }))
                                      ? TextAlign.center
                                      : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: (row['ยอดสุทธิ'].toString() == '0.00')
                                      ? Colors.red[600]
                                      : PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ))
                .toList(),
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
          Timer(Duration(milliseconds: 250), () {
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

///////////--------------------------------->
  Dialog_duplicates() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ไม่พบรายการที่ใบวางบิลที่อาจซ้ำกัน (No duplicates found) !!",
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

  Dialog_notimax(max) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Translate.TranslateAndSetText(
            'เลือกได้สูงสุด $max รายการ...!!',
            Colors.white,
            TextAlign.center,
            null,
            Font_.Fonts_T,
            14,
            1),
        // Text('เลือกได้สูงสุด $max รายการ...!!',
        //     style: const TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //         fontFamily: FontWeight_.Fonts_T)
        //         )
      ),
    );
  }

  //////////////////////////------------------------------>
  Future<Null> de_invoice(Get_Value_cid, Get_Value_NameShop_index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = Get_Value_cid;
    var qutser = Get_Value_NameShop_index;
    var because = Formbecause_.text?.toString() ?? '';
    // //print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      //print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result>>>>>>> $result');
      // //print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          Loading_Trans_bill();
          // //print('numinvoice 4 $numinvoice');
          // red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
    Navigator.pop(context, 'OK');
  }

  ///--------------------------------------------------------->
  Future<Null> de_invoice2(Get_Value_cid, Get_Value_NameShop_index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = Get_Value_cid;
    var qutser = Get_Value_NameShop_index;
    var because = Formbecause_.text.toString() ?? '';
    // //print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      // //print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result>>>>>>> $result');
      // //print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          Loading_Trans_bill();
          // //print('numinvoice 4 $numinvoice');
          // red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///--------------------------------------------------------->
  Future<Null> read_GC_Line(index) async {
    if (regis_models.isNotEmpty) {
      setState(() {
        regis_models.clear();
      });
    }
    var custno = _InvoiceModels[index].custno;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_line_regis.php?isAdd=true&ren=$ren&custno=$custno';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          Regis_model regis_model = Regis_model.fromJson(map);
          setState(() {
            if (regis_model.userid != '') {
              regis_models.add(regis_model);
            }
          });
        }
      } else {}
    } catch (e) {
      //print('Error-Dis(read_GC_rental) : ${e}');
    }
    // //print('name>>>>>  $renname');
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index, docno, page) async {
    int selectedIndex = (page.toString() == '0')
        ? InvoiceModels.indexWhere(
            (item) => item.docno.toString() == docno.toString())
        : InvoiceModels.indexWhere(
            (item) => item.inv.toString() == docno.toString());
    try {
      setState(() {
        read_GC_Line(selectedIndex);
      });
    } catch (e) {}
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
                                              'รายละเอียดบิล ',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.center,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              12,
                                              1),

                                          // AutoSizeText(
                                          //   minFontSize: 8,
                                          //   maxFontSize: 14,
                                          //   'รายละเอียดบิล ', //numinvoice
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
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'บิลเลขที่ ${docno} ',
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    12,
                                                    1),
                                            //  AutoSizeText(
                                            //   minFontSize: 8,
                                            //   maxFontSize: 12,
                                            //   'บิลเลขที่ ${docno} ',
                                            //   textAlign: TextAlign.center,
                                            //   style: const TextStyle(
                                            //       color: PeopleChaoScreen_Color
                                            //           .Colors_Text1_,
                                            //       fontWeight: FontWeight.bold,
                                            //       fontFamily:
                                            //           FontWeight_.Fonts_T
                                            //       //fontSize: 10.0
                                            //       //fontSize: 10.0
                                            //       ),
                                            // ),
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
                                      Container(
                                        width: 80,
                                        child: Translate.TranslateAndSetText(
                                            'ลำดับ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.center,
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
                                            12,
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
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'จำนวน',
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
                                            'หน่วย',
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
                                          'Vat',
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
                                            'ราคารวม',
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
                                            'ส่วนลด',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.end,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            12,
                                            1),
                                      ),
                                      // const Expanded(
                                      //   flex: 1,
                                      //   child: AutoSizeText(
                                      //     minFontSize: 8,
                                      //     maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     'ราคารวม Vat',
                                      //     textAlign: TextAlign.end,
                                      //     style: TextStyle(
                                      //         color: PeopleChaoScreen_Color
                                      //             .Colors_Text1_,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T
                                      //         //fontSize: 10.0
                                      //         //fontSize: 10.0
                                      //         ),
                                      //   ),
                                      // ),
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
                                              _InvoiceHistoryModels.length,
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
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .date ==
                                                                null)
                                                            ? '-'
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_InvoiceHistoryModels[index].date} 00:00:00'))}',
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
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .ln ==
                                                                null)
                                                            ? ''
                                                            : '${_InvoiceHistoryModels[index].ln}',
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
                                                        '${_InvoiceHistoryModels[index].refno}',
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
                                                        '${_InvoiceHistoryModels[index].descr}',
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
                                                        double.parse(_InvoiceHistoryModels[
                                                                        index]
                                                                    .tf!) ==
                                                                0.00
                                                            ? (_InvoiceHistoryModels[
                                                                            index]
                                                                        .qty ==
                                                                    null)
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}'
                                                            : 'ก่อน[Before]-หลัง[After] (${int.parse((_InvoiceHistoryModels[index].ovalue == null) ? '0' : _InvoiceHistoryModels[index].ovalue!)} - ${int.parse((_InvoiceHistoryModels[index].nvalue == null) ? '0' : _InvoiceHistoryModels[index].nvalue!)}) ${double.parse((_InvoiceHistoryModels[index].qty == null) ? '0' : _InvoiceHistoryModels[index].qty!)}',
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
                                                        double.parse(_InvoiceHistoryModels[
                                                                        index]
                                                                    .tf!) !=
                                                                0.00
                                                            ? '${nFormat.format(double.parse((_InvoiceHistoryModels[index].pri == null) ? '0' : _InvoiceHistoryModels[index].pri!))} (tf ${nFormat.format((double.parse((_InvoiceHistoryModels[index].amt == null) ? '0' : _InvoiceHistoryModels[index].amt!) - (double.parse((_InvoiceHistoryModels[index].vat == null) ? '0' : _InvoiceHistoryModels[index].vat!) + double.parse((_InvoiceHistoryModels[index].pvat == null) ? '0' : _InvoiceHistoryModels[index].pvat!))))})'
                                                            : (_InvoiceHistoryModels[
                                                                            index]
                                                                        .nvat ==
                                                                    null)
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].nvat!))}',
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
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .vat_t ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].vat_t!))}',
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
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .pvat_t ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pvat_t!))}',
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
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .dis ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].dis!))}',
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
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 14,
                                                    //     maxLines: 1,
                                                    //     '${nFormat.format(double.parse(_InvoiceHistoryModels[index].amt!))}',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        maxLines: 1,
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .total_t ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].total_t!) - double.parse(_InvoiceHistoryModels[index].dis!))}',
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
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10)),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    children: [
                                                      if (InvoiceModels[index]
                                                              .refapi! !=
                                                          '')
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                            (InvoiceModels[index]
                                                                        .refapi ==
                                                                    null)
                                                                ? 'อ้างอิง : -'
                                                                : 'อ้างอิง : ${InvoiceModels[index].refapi}',
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: const TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontSize: 10.0),
                                                          ),
                                                        ),
                                                      if (InvoiceModels[index]
                                                              .ref1! !=
                                                          '')
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                            (InvoiceModels[index]
                                                                        .ref1 ==
                                                                    null)
                                                                ? 'Ref1 : -'
                                                                : 'Ref1 : ${InvoiceModels[index].ref1}',
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: const TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontSize: 10.0),
                                                          ),
                                                        ),
                                                      if (InvoiceModels[index]
                                                              .ref2! !=
                                                          '')
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                            (InvoiceModels[index]
                                                                        .ref2 ==
                                                                    null)
                                                                ? 'Ref2 : -'
                                                                : 'Ref2 : ${InvoiceModels[index].ref2}',
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: const TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontSize: 10.0),
                                                          ),
                                                        ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'รูปแบบชำระ : (วันที่ออกใบ : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 0})',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                11,
                                                                1),
                                                        //     const AutoSizeText(
                                                        //   minFontSize: 8,
                                                        //   maxFontSize: 13,
                                                        //   'รูปแบบชำระ : ',
                                                        //   textAlign:
                                                        //       TextAlign.end,
                                                        //   style: TextStyle(
                                                        //       color: PeopleChaoScreen_Color
                                                        //           .Colors_Text1_,
                                                        //       // fontWeight:
                                                        //       //     FontWeight
                                                        //       //         .bold,
                                                        //       fontFamily:
                                                        //           FontWeight_
                                                        //               .Fonts_T
                                                        //       //fontSize: 10.0
                                                        //       ),
                                                        // ),
                                                      ),
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
                                                                '1. จำนวน ${nFormat.format(sum_amt - sum_disamt)} บาท (${payment_Ptname1})',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                11,
                                                                1),
                                                            // AutoSizeText(
                                                            //   minFontSize:
                                                            //       8,
                                                            //   maxFontSize:
                                                            //       13,
                                                            //   '1. จำนวน ${nFormat.format(sum_amt - sum_disamt)} บาท (${payment_Ptname1})',
                                                            //   style: const TextStyle(
                                                            //       color: PeopleChaoScreen_Color
                                                            //           .Colors_Text2_,
                                                            //       fontWeight:
                                                            //           FontWeight
                                                            //               .w500,
                                                            //       fontFamily:
                                                            //           Font_
                                                            //               .Fonts_T),
                                                            // ),
                                                            if (payment_Ptname1
                                                                        .toString() !=
                                                                    'CASH' ||
                                                                payment_Ptname1
                                                                        .toString() !=
                                                                    'null')
                                                              Translate.TranslateAndSetText(
                                                                  '  ** 1.1. ธนาคาร : ${payment_bank1} , เลขบช. : ${payment_Bno1}',
                                                                  AccountScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  11,
                                                                  1),
                                                            // AutoSizeText(
                                                            //   minFontSize:
                                                            //       8,
                                                            //   maxFontSize:
                                                            //       11,
                                                            //   '  ** 1.1. ธนาคาร : ${payment_bank1} , เลขบช. : ${payment_Bno1}',
                                                            //   style: TextStyle(
                                                            //       color: Colors.grey[800],
                                                            //       //fontWeight: FontWeight.bold,
                                                            //       fontFamily: Font_.Fonts_T),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Align(
                                                      //   alignment:
                                                      //       Alignment.topLeft,
                                                      //   child: AutoSizeText(
                                                      //     minFontSize: 8,
                                                      //     maxFontSize: 13,
                                                      //     (payment_Ptname1 ==
                                                      //             null)
                                                      //         ? 'รูปแบบ'
                                                      //         : (payment_Bno1 ==
                                                      //                 null)
                                                      //             ? '${payment_Ptname1}  '
                                                      //             : '${payment_Ptname1} : ${payment_Bno1}',
                                                      //     style: const TextStyle(
                                                      //         color: PeopleChaoScreen_Color
                                                      //             .Colors_Text2_,
                                                      //         //fontWeight: FontWeight.bold,
                                                      //         fontFamily:
                                                      //             Font_.Fonts_T),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                                // payment_Ptser1 == '8'
                                                //     ? Expanded(
                                                //         flex: 2,
                                                //         child: IconButton(
                                                //             onPressed: () {
                                                //               showdialog_ComingQR(
                                                //                   index);
                                                //             },
                                                //             icon: Icon(
                                                //               Icons
                                                //                   .qr_code_sharp,
                                                //               size: 50,
                                                //             )))
                                                //     : SizedBox()
                                              ],
                                            )),
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
                                                            //  AutoSizeText(
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
                  Column(children: [
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
                                    : MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[400],
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
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () async {
                                              setState(() {
                                                bneme_check =
                                                    InvoiceModels[index].ptname;
                                                bno_check =
                                                    InvoiceModels[index].bno;
                                                bser_check =
                                                    InvoiceModels[index].ptser;
                                              });
                                              red_Trans_selectPay(index)
                                                  .then((value) {
                                                _showMyDialog_pay(index)
                                                    .then((value) {
                                                  Navigator.pop(context, 'OK');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        backgroundColor:
                                                            Colors.green[600],
                                                        content: Row(
                                                          children: [
                                                            Text(
                                                                'อนุมัติ :${bno_check}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T)),
                                                          ],
                                                        )),
                                                  );
                                                });
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: 22,
                                                ),
                                                Translate.TranslateAndSetText(
                                                    'ถูกต้อง/อนุมัติ',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.center,
                                                    null,
                                                    Font_.Fonts_T,
                                                    14,
                                                    1),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      InvoiceModels[index].refapi == ''
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple[400],
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
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Gen_QRAPINEW(index);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.qr_code,
                                                        color: Colors.black,
                                                        size: 22,
                                                      ),
                                                      Translate
                                                          .TranslateAndSetText(
                                                              'Show QR',
                                                              AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: (Cancell_bill.toString() ==
                                                  '1')
                                              ? null
                                              : (DateTime.parse(
                                                              '${InvoiceModels[index].daterec} 00:00:00')
                                                          .add(Duration(
                                                              days: int.parse(
                                                                  '${Day_Cancell_bill}')))
                                                          .isBefore(datex) &&
                                                      Day_Cancell_bill
                                                              .toString() !=
                                                          '0')
                                                  ? null
                                                  : (renTal_Ser.toString() ==
                                                              '106' ||
                                                          renTal_Ser
                                                                  .toString() ==
                                                              '50')
                                                      ? () async {
                                                          String url =
                                                              '${MyConstant().domain}/v2/choice/check_genqr_new.php';

                                                          try {
                                                            final response =
                                                                await http.post(
                                                              Uri.parse(url),
                                                              headers: {
                                                                "Content-Type":
                                                                    "application/json",
                                                              },
                                                              body: jsonEncode({
                                                                "isAdd": 'true',
                                                                "ren": renTal_Ser
                                                                    .toString(),
                                                                "invoice":
                                                                    "'${numinvoice.toString()}'",
                                                                "custno": InvoiceModels[
                                                                        index]
                                                                    .custno
                                                                    .toString(),
                                                              }),
                                                            );
                                                            // //print({
                                                            //   "isAdd": true,
                                                            //   "ren": renTal_Ser
                                                            //       .toString(),
                                                            //   "invoice":
                                                            //       "'${numinvoice.toString()}'",
                                                            //   "custno":
                                                            //       InvoiceModels[
                                                            //               index]
                                                            //           .custno
                                                            //           .toString(),
                                                            // });
                                                            //print(
                                                            //     "=== Response Status Code: ${response.statusCode} ===");
                                                            // //print(
                                                            //     "=== Response Body: ${response.body} ===");

                                                            // ตรวจสอบว่าได้ response 200 และมีข้อมูลไม่ว่าง
                                                            if (response.statusCode ==
                                                                    200 &&
                                                                response.body
                                                                    .isNotEmpty) {
                                                              PanaraInfoDialog
                                                                  .showAnimatedGrow(
                                                                context,
                                                                title:
                                                                    "คำเตือน",
                                                                message:
                                                                    "ไม่สามารถยกเลิกบิลได้ เนื่องจากผู้เช่ามีการ Gen QR เพื่อเตรียมชำระแล้ว",

                                                                buttonText:
                                                                    "รับทราบ",
                                                                onTapDismiss:
                                                                    () async {
                                                                  Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true,
                                                                  ).pop();
                                                                },
                                                                panaraDialogType:
                                                                    PanaraDialogType
                                                                        .warning,
                                                                barrierDismissible:
                                                                    false, // optional parameter (default is true)
                                                              );
                                                            } else {
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
                                                                          BorderRadius.all(
                                                                              Radius.circular(20.0))),
                                                                  title: Center(
                                                                    child: Translate.TranslateAndSetText(
                                                                        'ยืนยันการยกเลิกวางบิล',
                                                                        AccountScreen_Color
                                                                            .Colors_Text1_,
                                                                        TextAlign
                                                                            .start,
                                                                        FontWeight
                                                                            .bold,
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                        12,
                                                                        1),
                                                                    //             Text(
                                                                    //   'ยืนยันการยกเลิกวางบิล',
                                                                    //   style:
                                                                    //       TextStyle(
                                                                    //     color: PeopleChaoScreen_Color
                                                                    //         .Colors_Text1_,
                                                                    //     // fontWeight: FontWeight.bold,
                                                                    //     fontFamily:
                                                                    //         FontWeight_
                                                                    //             .Fonts_T,
                                                                    //     fontWeight:
                                                                    //         FontWeight
                                                                    //             .bold,
                                                                    //   ),
                                                                    // )
                                                                  ),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Translate.TranslateAndSetText('เลขที่ใบเสร็จ', AccountScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 12, 1),

                                                                                //  Text(
                                                                                //   'เลขที่ใบเสร็จ',
                                                                                //   textAlign: TextAlign.center,
                                                                                //   style: TextStyle(
                                                                                //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                //       //fontWeight: FontWeight.bold,
                                                                                //       fontFamily: Font_.Fonts_T),
                                                                                // ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  '$numinvoice',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(
                                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                      //fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                TextFormField(
                                                                              keyboardType: TextInputType.number,
                                                                              controller: Formbecause_,
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                                                }
                                                                                // if (int.parse(value.toString()) < 13) {
                                                                                //   return '< 13';
                                                                                // }
                                                                                return null;
                                                                              },
                                                                              // maxLength: 13,
                                                                              cursorColor: Colors.green,
                                                                              decoration: InputDecoration(
                                                                                  fillColor: Colors.white.withOpacity(0.3),
                                                                                  filled: true,
                                                                                  // prefixIcon: const Icon(Icons.water,
                                                                                  //     color: Colors.blue),
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
                                                                                  enabledBorder: const OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.only(
                                                                                      topRight: Radius.circular(15),
                                                                                      topLeft: Radius.circular(15),
                                                                                      bottomRight: Radius.circular(15),
                                                                                      bottomLeft: Radius.circular(15),
                                                                                    ),
                                                                                    borderSide: BorderSide(
                                                                                      width: 1,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                  ),
                                                                                  labelText: 'หมายเหตุ-Note',
                                                                                  labelStyle: const TextStyle(
                                                                                    color: AccountScreen_Color.Colors_Text2_,
                                                                                    // fontWeight:
                                                                                    //     FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T,
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
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      if (numinvoice != null) {
                                                                                        Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                                                                        // //print(numinvoice);
                                                                                        de_invoice(numinvoice, '1');
                                                                                        Navigator.pop(context);
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(
                                                                                              backgroundColor: Colors.red[600],
                                                                                              content: Row(
                                                                                                children: [
                                                                                                  Text('ยกเลิกการวางบิล(${numinvoice.toString()})', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
                                                                                                ],
                                                                                              )),
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                        height: 50,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.green.shade500,
                                                                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                          border: Border.all(color: Colors.grey, width: 1),
                                                                                        ),
                                                                                        padding: const EdgeInsets.all(3.0),
                                                                                        child: Center(
                                                                                          child: Translate.TranslateAndSetText('ตกลง', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                          // Text(
                                                                                          //   'ตกลง',
                                                                                          //   style: TextStyle(
                                                                                          //       color: Colors.white,
                                                                                          //       // fontSize: 10.0,
                                                                                          //       fontFamily: FontWeight_.Fonts_T),
                                                                                          // ),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Container(
                                                                                        height: 50,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.black,
                                                                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                          border: Border.all(color: Colors.grey, width: 1),
                                                                                        ),
                                                                                        padding: const EdgeInsets.all(3.0),
                                                                                        child: Center(
                                                                                          child: Translate.TranslateAndSetText('ยกเลิก', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                          // Text(
                                                                                          //   'ยกเลิก',
                                                                                          //   style: TextStyle(
                                                                                          //       color: Colors.white,
                                                                                          //       // fontSize: 10.0,
                                                                                          //       fontFamily: FontWeight_.Fonts_T),
                                                                                          // ),
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {}
                                                        }
                                                      : () {
                                                          if (numinvoice !=
                                                              null) {
                                                            showDialog<String>(
                                                              barrierDismissible:
                                                                  false,
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
                                                                      'ยืนยันการยกเลิกวางบิล',
                                                                      AccountScreen_Color
                                                                          .Colors_Text1_,
                                                                      TextAlign
                                                                          .start,
                                                                      FontWeight
                                                                          .bold,
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                      12,
                                                                      1),
                                                                  //             Text(
                                                                  //   'ยืนยันการยกเลิกวางบิล',
                                                                  //   style:
                                                                  //       TextStyle(
                                                                  //     color: PeopleChaoScreen_Color
                                                                  //         .Colors_Text1_,
                                                                  //     // fontWeight: FontWeight.bold,
                                                                  //     fontFamily:
                                                                  //         FontWeight_
                                                                  //             .Fonts_T,
                                                                  //     fontWeight:
                                                                  //         FontWeight
                                                                  //             .bold,
                                                                  //   ),
                                                                  // )
                                                                ),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Translate.TranslateAndSetText('เลขที่ใบเสร็จ', AccountScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 12, 1),

                                                                              //  Text(
                                                                              //   'เลขที่ใบเสร็จ',
                                                                              //   textAlign: TextAlign.center,
                                                                              //   style: TextStyle(
                                                                              //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //       //fontWeight: FontWeight.bold,
                                                                              //       fontFamily: Font_.Fonts_T),
                                                                              // ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                '$numinvoice',
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                    //fontWeight: FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              TextFormField(
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            controller:
                                                                                Formbecause_,
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.isEmpty) {
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
                                                                            decoration: InputDecoration(
                                                                                fillColor: Colors.white.withOpacity(0.3),
                                                                                filled: true,
                                                                                // prefixIcon: const Icon(Icons.water,
                                                                                //     color: Colors.blue),
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
                                                                                enabledBorder: const OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topRight: Radius.circular(15),
                                                                                    topLeft: Radius.circular(15),
                                                                                    bottomRight: Radius.circular(15),
                                                                                    bottomLeft: Radius.circular(15),
                                                                                  ),
                                                                                  borderSide: BorderSide(
                                                                                    width: 1,
                                                                                    color: Colors.grey,
                                                                                  ),
                                                                                ),
                                                                                labelText: 'หมายเหตุ-Note',
                                                                                labelStyle: const TextStyle(
                                                                                  color: AccountScreen_Color.Colors_Text2_,
                                                                                  // fontWeight:
                                                                                  //     FontWeight.bold,
                                                                                  fontFamily: Font_.Fonts_T,
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
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    if (numinvoice != null) {
                                                                                      Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                                                                      // //print(numinvoice);
                                                                                      de_invoice(numinvoice, '1');
                                                                                      Navigator.pop(context);
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(
                                                                                            backgroundColor: Colors.red[600],
                                                                                            content: Row(
                                                                                              children: [
                                                                                                Text('ยกเลิกการวางบิล(${numinvoice.toString()})', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
                                                                                              ],
                                                                                            )),
                                                                                      );
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                      height: 50,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.green.shade500,
                                                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                        border: Border.all(color: Colors.grey, width: 1),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(3.0),
                                                                                      child: Center(
                                                                                        child: Translate.TranslateAndSetText('ตกลง', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                        // Text(
                                                                                        //   'ตกลง',
                                                                                        //   style: TextStyle(
                                                                                        //       color: Colors.white,
                                                                                        //       // fontSize: 10.0,
                                                                                        //       fontFamily: FontWeight_.Fonts_T),
                                                                                        // ),
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Container(
                                                                                      height: 50,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.black,
                                                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                        border: Border.all(color: Colors.grey, width: 1),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(3.0),
                                                                                      child: Center(
                                                                                        child: Translate.TranslateAndSetText('ยกเลิก', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                        // Text(
                                                                                        //   'ยกเลิก',
                                                                                        //   style: TextStyle(
                                                                                        //       color: Colors.white,
                                                                                        //       // fontSize: 10.0,
                                                                                        //       fontFamily: FontWeight_.Fonts_T),
                                                                                        // ),
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: (Cancell_bill.toString() ==
                                                      '1')
                                                  ? Colors.grey[200]
                                                  : (DateTime.parse(
                                                                  '${InvoiceModels[index].daterec} 00:00:00')
                                                              .add(Duration(
                                                                  days: int.parse(
                                                                      '${Day_Cancell_bill}')))
                                                              .isBefore(
                                                                  datex) &&
                                                          Day_Cancell_bill
                                                                  .toString() !=
                                                              '0')
                                                      ? Colors.grey[200]
                                                      : Colors.orange[200],
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            child: (Cancell_bill.toString() ==
                                                    '1')
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
                                                                'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        // Text(
                                                        //   'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                        //   style:
                                                        //       TextStyle(
                                                        //     color: AccountScreen_Color
                                                        //         .Colors_Text2_,
                                                        //     // fontWeight:
                                                        //     //     FontWeight.bold,
                                                        //     fontFamily:
                                                        //         Font_
                                                        //             .Fonts_T,
                                                        //   ),
                                                        // )
                                                      ),
                                                    ],
                                                  )
                                                : (DateTime.parse(
                                                                '${InvoiceModels[index].daterec} 00:00:00')
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
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Icon(
                                                                Icons
                                                                    .cancel_presentation,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Translate.TranslateAndSetText(
                                                                'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            //  Text(
                                                            //   'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                            //   style:
                                                            //       TextStyle(
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
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Icon(
                                                                Icons
                                                                    .cancel_presentation,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Translate.TranslateAndSetText(
                                                                'ยกเลิกการวางบิล',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            //  Text(
                                                            //   'ยกเลิกการวางบิล',
                                                            //   style:
                                                            //       TextStyle(
                                                            //     color: AccountScreen_Color
                                                            //         .Colors_Text2_,
                                                            //     // fontWeight:
                                                            //     //     FontWeight.bold,
                                                            //     fontFamily:
                                                            //         Font_
                                                            //             .Fonts_T,
                                                            //   ),
                                                            // ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        ),
                                      ),
                                      regis_models.length == 0
                                          ? const SizedBox()
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 200,
                                              child: InkWell(
                                                onTap: () {
                                                  showdialog_Coming(index);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          const BorderRadius
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
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      "images/lineicon.png"),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              child:
                                                                  const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                            )),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'แจ้งเตือนชำระ',
                                                                  AccountScreen_Color
                                                                      .Colors_Text2_,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  Text(
                                                          //   'แจ้งเตือนชำระ',
                                                          //   style:
                                                          //       TextStyle(
                                                          //     color: Colors
                                                          //         .white,
                                                          //     // fontWeight:
                                                          //     //     FontWeight.bold,
                                                          //     fontFamily:
                                                          //         Font_
                                                          //             .Fonts_T,
                                                          //   ),
                                                          // ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                      (InvoiceModels[index].btype == null ||
                                              InvoiceModels[index]
                                                      .btype
                                                      .toString() ==
                                                  '')
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                // color: Colors.green,
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
                                              child: Column(
                                                children: [
                                                  Translate.TranslateAndSetText(
                                                      '** พิมพ์ ไม่ได้ไม่พบช่องทางรับชำระ !!!',
                                                      Colors.orange,
                                                      TextAlign.start,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                                  // Text(
                                                  //   '** พิมพ์ ไม่ได้ไม่พบช่องทางรับชำระ !!!',
                                                  //   style: TextStyle(
                                                  //     color:
                                                  //         Colors.orange,
                                                  //     // fontWeight:
                                                  //     //     FontWeight.bold,
                                                  //     fontFamily:
                                                  //         Font_.Fonts_T,
                                                  //   ),
                                                  // ),
                                                  Translate.TranslateAndSetText(
                                                      '( โปรดตรวจสอบหรือยกเลิก )',
                                                      Colors.orange,
                                                      TextAlign.start,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                                  // Text(
                                                  //   '( โปรดตรวจสอบหรือยกเลิก )',
                                                  //   style: TextStyle(
                                                  //     color:
                                                  //         Colors.orange,
                                                  //     // fontWeight:
                                                  //     //     FontWeight.bold,
                                                  //     fontFamily:
                                                  //         Font_.Fonts_T,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 200,
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
                                                  var docno =
                                                      _InvoiceModels[index]
                                                          .cname;
                                                  var namenew =
                                                      _InvoiceModels[index]
                                                          .cname;
                                                  _showMyDialog_SAVE(
                                                      newValuePDFimg,
                                                      docno,
                                                      namenew);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          const BorderRadius
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
                                                              Icons.print,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'พิมพ์',
                                                                  AccountScreen_Color
                                                                      .Colors_Text2_,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  Text(
                                                          //   'พิมพ์',
                                                          //   style:
                                                          //       TextStyle(
                                                          //     color: Colors
                                                          //         .white,
                                                          //     // fontWeight:
                                                          //     //     FontWeight.bold,
                                                          //     fontFamily:
                                                          //         Font_
                                                          //             .Fonts_T,
                                                          //   ),
                                                          // ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                    ]))))
                  ])
                ],
              ),
            ));
  }

  ////////////--------------------------------------------->
  showdialog_Coming(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              height: 700, // MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // payment_Ptser1 == '8'
                  //     ? Container(
                  //         width: 500,
                  //         height: 500,
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //             image: NetworkImage(
                  //                 '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=${_InvoiceModels[index].refapi}&incid=${_InvoiceModels[index].cid}&sum=${(sum_amt - sum_disamt)}&extension=.png'),
                  //           ),
                  //           borderRadius: BorderRadius.only(
                  //               topLeft: Radius.circular(10),
                  //               topRight: Radius.circular(10),
                  //               bottomLeft: Radius.circular(0),
                  //               bottomRight: Radius.circular(0)),
                  //         ),
                  //       )
                  //     : SizedBox(),
                  for (int inregis = 0;
                      inregis < regis_models.length;
                      inregis++)
                    // if(regis_models[inregis].cid ==_InvoiceModels[index].cid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Line UserName : ${regis_models[inregis].username}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () async {
                              var serregis = regis_models[inregis].ser;
                              var incid = _InvoiceModels[index].cid;
                              var indocno = _InvoiceModels[index].docno;
                              var insum = nFormat.format(sum_amt - sum_disamt);
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var ren = preferences.getString('renTalSer');
                              String url =
                                  '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                              renTal_name = preferences.getString('renTalName');
                              try {
                                var response = await http.get(Uri.parse(url));

                                var result = json.decode(response.body);

                                if (result.toString() == 'Line Successfully') {
                                  //print(
                                  //'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                } else {
                                  //print(
                                  // 'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                }
                              } catch (e) {
                                //print('Error-Dis(read_GC_rental) : ${e}');
                              }
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Send Line >>> ',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "images/lineicon.png"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: const SizedBox(
                                          width: 20,
                                          height: 20,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Divider(),
                ],
              ),
            ),
          );
        });
  }

  ////////////--------------------------------------------->
  Future<Null> Gen_QRAPINEW(int index) async {
    var total_QRsend = (sum_amt - sum_disamt).toStringAsFixed(2);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, 'OK');
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 22,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Online Standard QR',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref1 : ${InvoiceModels[index].ref1}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref2 : ${InvoiceModels[index].ref2}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total : ${total_QRsend} ',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ],
                        );
                      }),
                  SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'SCAN ME',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Container(
                              width: 500,
                              height: 500,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=${InvoiceModels[index].refapi}&incid=${InvoiceModels[index].cid}&sum=$total_QRsend&extension=.png'),
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InvoiceModels[index].ser_noti != null
                                    ? Container(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {
                                            PanaraConfirmDialog
                                                .showAnimatedGrow(
                                              context,
                                              title: "Line Notification",
                                              message:
                                                  "แจ้งเตือนชำระค่าบริการผ่านไลน์",
                                              confirmButtonText: "Confirm",
                                              cancelButtonText: "Cancel",
                                              onTapConfirm: () async {
                                                if (InvoiceModels[index]
                                                        .ser_noti !=
                                                    null) {
                                                  var serregis =
                                                      InvoiceModels[index]
                                                          .ser_noti;
                                                  var incid =
                                                      InvoiceModels[index].cid;
                                                  var indocno =
                                                      InvoiceModels[index]
                                                          .docno;
                                                  var insum = nFormat.format(
                                                      double.parse(
                                                          InvoiceModels[index]
                                                              .total_dis!));
                                                  SharedPreferences
                                                      preferences =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  var ren = preferences
                                                      .getString('renTalSer');
                                                  String url =
                                                      '${MyConstant().domain}/sent_line_noti_image.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                                                  renTal_name = preferences
                                                      .getString('renTalName');
                                                  try {
                                                    var response = await http
                                                        .get(Uri.parse(url));

                                                    var result = json
                                                        .decode(response.body);

                                                    if (result.toString() ==
                                                        'Line Successfully') {
                                                      ////print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Translate
                                                              .TranslateAndSetText(
                                                                  'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                          // Text(
                                                          //   'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                          //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                          // ),
                                                        ),
                                                      );
                                                    } else {
                                                      // //print('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Translate
                                                              .TranslateAndSetText(
                                                                  'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                          // Text(
                                                          //   'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                          //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                          // ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    //print(
                                                    //    'Error-Dis(read_GC_rental) : ${e}');
                                                  }
                                                }
                                                Navigator.pop(context);
                                              },
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.success,
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Send Line ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.send_outlined,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          ],
                        );
                      }),
                ],
              ),
            ));
      },
    );
  }

////////////------------------------------------------------------>(Export file)
  Future<void> _showMyDialog_SAVE(newValuePDFimg, cid, namenew) async {
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

                  //  Text(
                  //   'หัวบิล :',
                  //   style: TextStyle(
                  //     color: ReportScreen_Color.Colors_Text2_,
                  //     // fontWeight: FontWeight.bold,
                  //     fontFamily: Font_.Fonts_T,
                  //   ),
                  // ),
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
                        BillingNoteInvlice_History_Tempage(
                            newValuePDFimg,
                            renTal_name,
                            cid,
                            namenew,
                            '0',
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
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
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
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
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

  /////////------------------------>
  Future<void> _showMyDialog_SAVE2(newValuePDFimg, Folder_File) async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    String? TitleType_Default_Receipt_Name;
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
                                      invoice_select.clear();
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
                              child:
                                  // Translate.TranslateAndSetText(
                                  //     (innerloop == false)
                                  //         ? 'กำลังหยุดดำเนินการ...'
                                  //         : '${invoice_Now} ',
                                  //     (innerloop == false)
                                  //         ? Colors.red
                                  //         : Colors.blue,
                                  //     TextAlign.center,
                                  //     null,
                                  //     Font_.Fonts_T,
                                  //     14,
                                  //     1),
                                  Text(
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
                            // Translate.TranslateAndSetText(
                            //     'ดำเนินการ ทั้งหมด : ${invoice_select.length} รายการ',
                            //     AccountScreen_Color.Colors_Text1_,
                            //     TextAlign.center,
                            //     null,
                            //     Font_.Fonts_T,
                            //     14,
                            //     1),
                            Text(
                              'ดำเนินการ ทั้งหมด : ${invoice_select.length} รายการ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                            // Translate.TranslateAndSetText(
                            //     'หัวบิล :',
                            //     AccountScreen_Color.Colors_Text1_,
                            //     TextAlign.center,
                            //     null,
                            //     Font_.Fonts_T,
                            //     14,
                            //     1),
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
                                direction: Axis.horizontal,
                                groupValue: _ReportValue_type,
                                horizontalAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                  // //print(TitleType_Default_Receipt_Name);
                                },
                                items: const <String>[
                                  'ไม่ระบุ',
                                  'ต้นฉบับ',
                                  'สำเนา',
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
                                        index < invoice_select.length;
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
                                          // //print('stop/break ');
                                          setState(() {
                                            preferences.setString('name_page',
                                                '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()}');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            invoice_select.clear();
                                          });
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   Navigator.pop(context, 'OK');
                                          // });
                                          break innerloop_for;
                                        }
                                        var docno =
                                            invoice_select[index].toString();
                                        setState(() {
                                          numinvoice = invoice_select[index];
                                          invoice_Now =
                                              'กำลังดำเนินการ (${index + 1} / ${invoice_select.length}) : ${invoice_select[index]}';
                                        });
                                        var namenew = '';
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));

                                        BillingNoteInvlice_History_Tempage(
                                            newValuePDFimg,
                                            renTal_name,
                                            docno,
                                            namenew,
                                            '$Folder_File',
                                            TitleType_Default_Receipt_Name);

                                        setState(() {
                                          invoice_loade_Success.add(
                                              invoice_select[index].toString());
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (index + 1 ==
                                            invoice_select.length) {
                                          await Future.delayed(const Duration(
                                              milliseconds: 400));
                                          setState(() {
                                            preferences.setString('name_page',
                                                'ใบวางบิล/ใบแจ้งหนี้_${currentPage_1 + 1}of${(filteredData.length / rowsPerPage_1).ceil()}($MONTH_Now-$YEAR_Now)');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            invoice_select.clear();
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            // //print('')

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
                                  child: Center(
                                    child:
                                        // Translate.TranslateAndSetText(
                                        //     'ปิด',
                                        //     Colors.white,
                                        //     TextAlign.center,
                                        //     null,
                                        //     Font_.Fonts_T,
                                        //     14,
                                        //     1),

                                        Text(
                                      'close',
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

/////////////////////////------------------------------>
  Future<void> _showMyDialog_delete() async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    setState(() {
      generateRandomString();
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
            return Form(
              // key: _formKey,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: SingleChildScrollView(
                  child: (invoice_select_Ser == 1)
                      ? ListBody(children: <Widget>[
                          const Center(
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator())),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                '${invoice_Now} ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ])
                      : ListBody(
                          children: <Widget>[
                            Translate.TranslateAndSetText(
                                'ลบ ทั้งหมด : ${invoice_select_delete.length} รายการ',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                            // Text(
                            //   'ลบ ทั้งหมด : ${invoice_select_delete.length} รายการ',
                            //   textAlign: TextAlign.center,
                            //   style: const TextStyle(
                            //     color: ReportScreen_Color.Colors_Text2_,
                            //     fontWeight: FontWeight.bold,
                            //     fontFamily: FontWeight_.Fonts_T,
                            //   ),
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Translate.TranslateAndSetText(
                                  'ผู้ดำเนินการ',
                                  AccountScreen_Color.Colors_Text1_,
                                  TextAlign.center,
                                  null,
                                  Font_.Fonts_T,
                                  14,
                                  1),

                              // Text(
                              //   'ผู้ดำเนินการ',
                              //   style: TextStyle(
                              //       color: AccountScreen_Color.Colors_Text2_,
                              //       fontWeight: FontWeight.bold,
                              //       fontFamily: Font_.Fonts_T),
                              // ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                '- ${email_login}($seremail_login)',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AccountScreen_Color.Colors_Text2_,
                                    // fontWeight:
                                    //     FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'CODE : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Color.fromARGB(
                                              255, 179, 177, 170),
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
                                            style: TextStyle(
                                                color: Colors.red[800],
                                                fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
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
                            const SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: Formbecause_,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ใส่ข้อมูลให้ครบถ้วน ';
                                  }
                                  // if (int.parse(value.toString()) < 13) {
                                  //   return '< 13';
                                  // }
                                  return null;
                                },
                                // maxLength: 13,
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.3),
                                    filled: true,
                                    // prefixIcon: const Icon(Icons.water,
                                    //     color: Colors.blue),
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
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    labelText: 'หมายเหตุ-Note',
                                    labelStyle: const TextStyle(
                                      color: AccountScreen_Color.Colors_Text2_,
                                      // fontWeight:
                                      //     FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
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
                              height: 10,
                            ),
                            const Divider(
                              color: Colors.grey,
                              height: 1.0,
                            ),
                            const SizedBox(
                              height: 5.0,
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
                                onTap: (Pincontroller.text != "$randomString")
                                    ? null
                                    : () async {
                                        setState(() {
                                          invoice_select_Ser = 1;
                                        });
                                        try {
                                          for (int index = 0;
                                              index <
                                                  invoice_select_delete.length;
                                              index++) {
                                            var docno =
                                                invoice_select_delete[index]
                                                    .toString();
                                            setState(() {
                                              numinvoice =
                                                  invoice_select_delete[index];
                                              invoice_Now =
                                                  'delete (${index + 1} / ${invoice_select_delete.length}) : ${invoice_select_delete[index]}';
                                            });
                                            var namenew = '';
                                            de_invoice2(numinvoice, '1');
                                            await Future.delayed(const Duration(
                                                milliseconds: 800));
                                            setState(() {
                                              invoice_loade_Success_delete.add(
                                                  invoice_select_delete[index]
                                                      .toString());
                                            });
                                            await Future.delayed(const Duration(
                                                milliseconds: 500));
                                            if (index + 1 ==
                                                invoice_select_delete.length) {
                                              setState(() {
                                                invoice_select_delete.clear();
                                              });
                                              Navigator.pop(context, 'OK');
                                            }
                                          }
                                        } catch (e) {
                                          Navigator.pop(context, 'OK');
                                        }
                                      },
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        (Pincontroller.text != "$randomString")
                                            ? Colors.grey
                                            : Colors.green,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'ลบ',
                                        Colors.white,
                                        TextAlign.center,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),

                                    //  Text(
                                    //   'ลบ',
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
                                        TextAlign.center,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                    // Text(
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
      },
    );
  } /////////----------------------------------------------------------->

  Future<void> _showMyDialog_pay(index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();

        DateTime datexDialog = DateTime.now();
        String Value_newDatepay = '${InvoiceModels[index].date}';
        String Value_newDateY1 =
            '${DateFormat('yyyy-MM-dd').format(datexDialog)}';
        //  '${DateFormat('yyyy-MM-dd').format(datexDialog)}';

        return Form(
          key: _formKey,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Container(
              width: 220,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          '${InvoiceModels[index].docno}',
                          style: const TextStyle(
                            color: ReportScreen_Color.Colors_Text2_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Translate.TranslateAndSetText(
                            'เลขที่สัญญา : ${InvoiceModels[index].cid} ',
                            Colors.grey,
                            TextAlign.start,
                            null,
                            Font_.Fonts_T,
                            14,
                            1),
                        //  Text(
                        //   'เลขที่สัญญา : ${InvoiceModels[index].cid} ',
                        //   style: const TextStyle(
                        //     color: Colors.grey,
                        //     fontFamily: Font_.Fonts_T,
                        //   ),
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          'ชื่อร้าน-Shop  : ${InvoiceModels[index].scname} ',
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          'รหัสพื้นที่-Area : ${InvoiceModels[index].ln} ',
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 0.5),
                    const Divider(),
                    const SizedBox(height: 0.5),
                    Container(
                      // width: 200,
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'วันที่รับชำระ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'วันที่รับชำระ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                    width: 200,
                                    height: 35,
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              // color: Colors.green[50],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(2.0),
                                            child: AutoSizeText(
                                              Value_newDatepay == ''
                                                  ? 'เลือกวันที่-Select'
                                                  : '$Value_newDatepay',
                                              minFontSize: 10,
                                              maxFontSize: 16,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              DateTime? newDate =
                                                  await showDatePicker(
                                                locale:
                                                    const Locale('th', 'TH'),
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now().add(
                                                    const Duration(days: -50)),
                                                lastDate: DateTime.now().add(
                                                    const Duration(days: 365)),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          const ColorScheme
                                                              .light(
                                                        primary: AppBarColors
                                                            .ABar_Colors, // header background color
                                                        onPrimary: Colors
                                                            .white, // header text color
                                                        onSurface: Colors
                                                            .black, // body text color
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors
                                                              .black, // button text color
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (newDate == null) {
                                                return;
                                              } else {
                                                String start =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(newDate);

                                                setState(() {
                                                  Value_newDatepay = start;
                                                });
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  // color: Colors.green[50],
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: const Icon(Icons.edit)))
                                      ],
                                    ));
                              }),
                          // Container(
                          //     height: 35,
                          //     width: 200,
                          //     color: AppbackgroundColor.Sub_Abg_Colors,
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: Row(
                          //       children: [
                          //         Expanded(
                          //           child: Container(
                          //             height: 35,
                          //             decoration: BoxDecoration(
                          //               color: Colors.grey[100],
                          //               borderRadius:
                          //                   const BorderRadius.only(
                          //                 topLeft: Radius.circular(8),
                          //                 topRight: Radius.circular(8),
                          //                 bottomLeft: Radius.circular(8),
                          //                 bottomRight: Radius.circular(8),
                          //               ),
                          //               border: Border.all(
                          //                   color: Colors.grey, width: 1),
                          //             ),
                          //             padding: const EdgeInsets.all(2.0),
                          //             child: AutoSizeText(
                          //               '$Value_newDatepay',
                          //               // '${bankExcBilling.where((model) => model.ref1.toString() == InvoiceModels[index].docno.toString() && model.amount.toString() == result.toString()).map((model) => model.payment_date).join(', ')}',
                          //               minFontSize: 10,
                          //               maxFontSize: 16,
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                   color: PeopleChaoScreen_Color
                          //                       .Colors_Text2_,
                          //                   // fontWeight: FontWeight.bold,
                          //                   fontFamily: Font_.Fonts_T),
                          //               maxLines: 1,
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     )),
                        ],
                      ),
                    ),
                    Container(
                      // width: 200,
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'ยอดรวมสุทธิ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'ยอดรวมสุทธิ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          Container(
                              height: 35,
                              width: 200,
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      child: AutoSizeText(
                                        '${InvoiceModels[index].total_dis}',
                                        minFontSize: 10,
                                        maxFontSize: 16,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 0.5),
                    const Divider(),
                    const SizedBox(height: 0.5),
                    Container(
                      // width: 200,
                      // color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'รูปแบบบิล',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'รูปแบบบิล',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                  width: 200,
                                  height: 35,
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField2(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    isExpanded: true,

                                    hint: Text(
                                      bills_name_.toString(),
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                    ),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontFamily: Font_.Fonts_T),
                                    iconSize: 30,
                                    buttonHeight: 40,
                                    // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    items: bill_tser == '1'
                                        ? Default_.map((item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            )).toList()
                                        : Default2_.map((item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            )).toList(),

                                    onChanged: (value) async {
                                      var bill_set =
                                          value == 'บิลธรรมดา' ? 'P' : 'F';
                                      setState(() {
                                        bills_name_ = bill_set;
                                      });
                                      // //print(bills_name_);
                                    },
                                    // onSaved: (value) {
                                    //   // selectedValue = value.toString();
                                    // },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    Container(
                      // width: 200,
                      // color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'วันที่ทำรายการ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'วันที่ทำรายการ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                    width: 200,
                                    height: 35,
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              // color: Colors.green[50],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(2.0),
                                            child: AutoSizeText(
                                              Value_newDateY1 == ''
                                                  ? 'เลือกวันที่-Select'
                                                  : '$Value_newDateY1',
                                              minFontSize: 10,
                                              maxFontSize: 16,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // InkWell(
                                        //     onTap: () async {
                                        //       DateTime? newDate =
                                        //           await showDatePicker(
                                        //         locale: const Locale('th', 'TH'),
                                        //         context: context,
                                        //         initialDate: DateTime.now(),
                                        //         firstDate: DateTime.now().add(
                                        //             const Duration(days: -50)),
                                        //         lastDate: DateTime.now().add(
                                        //             const Duration(days: 365)),
                                        //         builder: (context, child) {
                                        //           return Theme(
                                        //             data: Theme.of(context)
                                        //                 .copyWith(
                                        //               colorScheme:
                                        //                   const ColorScheme.light(
                                        //                 primary: AppBarColors
                                        //                     .ABar_Colors, // header background color
                                        //                 onPrimary: Colors
                                        //                     .white, // header text color
                                        //                 onSurface: Colors
                                        //                     .black, // body text color
                                        //               ),
                                        //               textButtonTheme:
                                        //                   TextButtonThemeData(
                                        //                 style:
                                        //                     TextButton.styleFrom(
                                        //                   primary: Colors
                                        //                       .black, // button text color
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //             child: child!,
                                        //           );
                                        //         },
                                        //       );

                                        //       if (newDate == null) {
                                        //         return;
                                        //       } else {
                                        //         String start =
                                        //             DateFormat('yyyy-MM-dd')
                                        //                 .format(newDate);

                                        //         setState(() {
                                        //           Value_newDateY1 = start;
                                        //         });
                                        //       }
                                        //     },
                                        //     child: Container(
                                        //         decoration: BoxDecoration(
                                        //           // color: Colors.green[50],
                                        //           borderRadius:
                                        //               const BorderRadius.only(
                                        //             topLeft: Radius.circular(0),
                                        //             topRight: Radius.circular(8),
                                        //             bottomLeft:
                                        //                 Radius.circular(0),
                                        //             bottomRight:
                                        //                 Radius.circular(8),
                                        //           ),
                                        //           border: Border.all(
                                        //               color: Colors.grey,
                                        //               width: 1),
                                        //         ),
                                        //         padding:
                                        //             const EdgeInsets.all(2.0),
                                        //         child: const Icon(Icons.edit)))
                                      ],
                                    ));
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Column(
                children: [
                  const SizedBox(height: 0.5),
                  const Divider(),
                  const SizedBox(height: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () async {
                            // //print(
                            //     'Docno InvoiceModels1 >>>>> ${InvoiceModels[index].docno}');
                            in_Trans_invoice_refnoPay(index, Value_newDateY1,
                                    Value_newDatepay, '0')
                                .then((value) {
                              setState(() {
                                Future.delayed(
                                    const Duration(milliseconds: 800));
                                Loading_Trans_bill();
                              });
                            });

                            // Pay_Invoice(
                            //     index, Value_newDateY1, Value_newDatepay);
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
                                  'ยืนยัน',
                                  Colors.white,
                                  TextAlign.center,
                                  null,
                                  Font_.Fonts_T,
                                  14,
                                  1),
                              //  Text(
                              //   'ยืนยัน',
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
                                  TextAlign.center,
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
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
  //////////////////////////------------------------------>

  Future<Null> BillingNoteInvlice_History_Tempage(newValuePDFimg, renTal_name,
      cid, namenew, Preview_ser, TitleType_Default_Receipt_Name) async {
    // String? TitleType_Default_Receipt_Name;
    // if (TitleType_Default_Receipt == 0) {
    // } else {
    //   setState(() {
    //     TitleType_Default_Receipt_Name =
    //         '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}';
    //   });
    // }
    Man_BillingNoteInvlice_PDF.ManBillingNoteInvlice_PDF(
        TitleType_Default_Receipt_Name,
        foder,
        '1',
        tem_page_ser,
        context,
        '${cid}',
        '${namenew}',
        '${renTalModels[0].bill_addr}',
        '${renTalModels[0].bill_email}',
        '${renTalModels[0].bill_tel}',
        '${renTalModels[0].bill_tax}',
        '${renTalModels[0].bill_name}',
        newValuePDFimg,
        numinvoice,
        Preview_ser);
  }
}
