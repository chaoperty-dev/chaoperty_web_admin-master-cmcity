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

class Account_Bill_InvoceSuccess extends StatefulWidget {
  const Account_Bill_InvoceSuccess({super.key});

  @override
  State<Account_Bill_InvoceSuccess> createState() =>
      _Account_Bill_InvoceSuccessState();
}

class _Account_Bill_InvoceSuccessState
    extends State<Account_Bill_InvoceSuccess> {
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

  ///////////--------------------------------------------->

  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac4_3 = [];
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
      ac4_3.addAll(
          AcListTitle().ac_4_3); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac4_3(String ser) {
    if (ac4_3
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
    red_InvoiceMon_billPay().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

////////--------------------------------------------------------------->
  Future<Null> red_InvoiceMon_billPay() async {
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
        ? '${MyConstant().domain}/GC_billPay_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now'
        : '${MyConstant().domain}/GC_billPay_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now';
    print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
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
          final inv = InvoiceModels[index].inv ?? "";

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

          final total_dis = (InvoiceModels[index].total_dis == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].total_dis!))}';
          final pdate = (InvoiceModels[index].pdate == null)
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].pdate} 00:00:00'))}-${DateTime.parse('${InvoiceModels[index].pdate} 00:00:00').year + 0}';

          final docno = (InvoiceModels[index].doctax == null ||
                  InvoiceModels[index].doctax! == '')
              ? '${InvoiceModels[index].docno}'
              : '${InvoiceModels[index].doctax}';
          final status_pay =
              (InvoiceModels[index].pos == '1') ? 'รอตรวจสอบ' : 'ชำระแล้ว';
          final pay_fine = (InvoiceModels[index].pay_fine == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].pay_fine!))}';
          final paytotal_dis = (InvoiceModels[index].paytotal_dis == null)
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceModels[index].paytotal_dis!))}';
          final ref1 = InvoiceModels[index].ref1 ?? "";
          final ref2 = InvoiceModels[index].ref2 ?? "";
          final ref4 = InvoiceModels[index].ref4 ?? "";

          return {
            "index": "$index",
            if (where_ac4_3("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac4_3("1") == false) "เลขที่ใบแจ้งหนี้": "$inv",
            if (where_ac4_3("2") == false) "วันที่ทำรายการ": "$daterec",
            if (where_ac4_3("3") == false) "กำหนดชำระ": "$date",
            if (where_ac4_3("9") == false) "วันที่ชำระ": "$pdate",
            if (where_ac4_3("4") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac4_3("5") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac4_3("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac4_3("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac4_3("8") == false) "ยอดสุทธิ(วางบิล)": "$total_dis",
            if (where_ac4_3("11") == false) "สถานะ": "$status_pay",
            if (where_ac4_3("10") == false) "ใบเสร็จรับชำระ": "$docno",
            if (where_ac4_3("12") == false) "ค่าปรับ(รับชำระ)": "$pay_fine",
            if (where_ac4_3("13") == false)
              "ยอดสุทธิ(รับชำระ)": "$paytotal_dis",
            if (where_ac4_3("14") == false) "รหัสอ้างอิง": "$ref1",
            if (where_ac4_3("15") == false) "Ref1": "$ref2",
            if (where_ac4_3("16") == false) "Ref2": "$ref4",
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

  ////////-------------------------->
// ฟังก์ชันตรวจสอบข้อมูลซ้ำ
  bool hasDuplicate(Map<String, dynamic> row) {
    // ตรวจสอบว่ามีข้อมูลซ้ำใน _TransReBillModels หรือไม่
    return row['ใบเสร็จรับชำระ'].toString().length > 15;
    // InvoiceModels.where((e) =>
    //         // e.daterec.toString() == row['วันที่ทำรายการ'].toString() &&
    //         // e.date.toString() == row['กำหนดชำระ'].toString() &&
    //         e.inv.toString() == row['เลขที่ใบแจ้งหนี้'].toString()).length >
    //     1;
  }

// ฟังก์ชันกรองข้อมูลซ้ำ
  void filterDuplicates() {
    setState(() {
      tappedIndex_ = '';
      if (showDuplicatesOnly) {
        // แสดงข้อมูลทั้งหมด
        filteredData = List.from(data);
      } else {
        // ใช้ Map เพื่อตรวจสอบความถี่ของ "ใบเสร็จรับชำระ"
        // final seen = <String, int>{};
        // for (var row in data) {
        //   final receiptNumber = row["ใบเสร็จรับชำระ"]?.toString() ??
        //       ''; // ใช้ ใบเสร็จรับชำระ เป็น key

        //   // ตรวจสอบว่า receiptNumber ไม่เป็นค่าว่างก่อนที่จะนับ
        //   if (receiptNumber.isNotEmpty) {
        //     seen[receiptNumber] =
        //         (seen[receiptNumber] ?? 0) + 1; // นับจำนวนครั้งที่พบ
        //   }
        // }

        // กรองเฉพาะข้อมูลที่ซ้ำและมีความยาวของ "ใบเสร็จรับชำระ" มากกว่า 15
        filteredData = data.where((row) {
          final receiptNumber =
              row["ใบเสร็จรับชำระ"]?.toString() ?? ''; // ใช้ ใบเสร็จรับชำระ
          return receiptNumber.length >
              15; // เงื่อนไข: receiptNumber มีมากกว่า 1 ครั้ง
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
  // void filterDuplicates() {
  //   setState(() {
  //     tappedIndex_ = '';
  //     if (showDuplicatesOnly) {
  //       // แสดงข้อมูลทั้งหมด
  //       filteredData = List.from(data);
  //     } else {
  //       // ใช้ Map เพื่อตรวจสอบความถี่ของค่าใน รหัสพื้นที่
  //       final seen = <String, int>{};
  //       for (var row in data) {
  //         final key = row["เลขที่ใบแจ้งหนี้"]?.toString() ??
  //             ''; // ใช้ เลขที่ใบแจ้งหนี้ เป็น key

  //         // ตรวจสอบว่า key ไม่เป็นค่าว่างก่อนที่จะนับ
  //         if (key != '') {
  //           seen[key] = (seen[key] ?? 0) + 1; // นับจำนวนครั้งที่พบ
  //         }
  //       }

  //       // กรองเฉพาะข้อมูลที่ซ้ำ
  //       filteredData = data.where((row) {
  //         final key = row["เลขที่ใบแจ้งหนี้"]?.toString() ??
  //             ''; // ใช้ เลขที่ใบแจ้งหนี้ เป็น key
  //         return key != '' &&
  //             seen[key]! >
  //                 1; // เงื่อนไข: key ไม่เป็นค่าว่างและมีมากกว่า 1 ครั้ง
  //       }).toList();

  //       // แจ้งเตือนหากไม่มีข้อมูลซ้ำ
  //       if (filteredData.isEmpty) {
  //         Dialog_duplicates();
  //         // ScaffoldMessenger.of(context).showSnackBar(
  //         //   SnackBar(content: Text('No duplicates found')),
  //         // );
  //         filteredData = List.from(data); // คืนค่าข้อมูลทั้งหมด
  //       }
  //     }

  //     // สลับสถานะการแสดงผล
  //     showDuplicatesOnly = !showDuplicatesOnly;
  //   });
  // }
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
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
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
      // print('เกิน กำหนด.');
      // Count_time_check = Count_time_check + 1;
      return true;
    } else {
      return false;
    }
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    double calculatedWidth =
        (ac4_3.where((item) => item["st"] == '1').toList().length <= 10)
            ? (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.83
                : 1200
            : (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.83 +
                    ((ac4_3.where((item) => item["st"] == '1').toList().length -
                            10) *
                        30)
                : 1200 +
                    ((ac4_3.where((item) => item["st"] == '1').toList().length -
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

                            items: ac4_3.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac4_3.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac4_3[selectedIndex]["st"] = '0';
                                          } else {
                                            ac4_3[selectedIndex]["st"] = '1';
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
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            items: YE_Th.map((item) =>
                                                DropdownMenuItem<String>(
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
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'ใบเสร็จรับชำระ' ||
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
                                                              'ยอดสุทธิ(วางบิล)' ||
                                                          column.toString() ==
                                                              'ค่าปรับ(รับชำระ)' ||
                                                          column.toString() ==
                                                              'ยอดสุทธิ(รับชำระ)';
                                                    }))
                                                        ? TextAlign.right
                                                        : (columnHeaders
                                                                .any((columnx) {
                                                            return column
                                                                        .toString() ==
                                                                    'สถานะ' ||
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
                                      final columnToCheck = 'ใบเสร็จรับชำระ';
                                      final columnToCheck_inv =
                                          'เลขที่ใบแจ้งหนี้';

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
                                                          'ตรวจพบข้อมูลที่อาจชำระซ้ำ..!! ( ${row[columnToCheck_inv]} )',
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
          var docno = InvoiceModels[index_x].inv;

          setState(() {
            payment_Ptser1 = InvoiceModels[index_x].ptser;
            payment_Ptname1 = InvoiceModels[index_x].ptname;
            payment_Bno1 = InvoiceModels[index_x].bno;

            Datex_invoice = InvoiceModels[index_x].daterec;

            payment_type1 = InvoiceModels[index_x].btype;
            payment_bank1 = InvoiceModels[index_x].bank;
          });

          await Dia_log1();
          red_Trans_select(index_x, ciddoc, qutser, tser, docno, '2');
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
                          column.toString() == 'เลขที่ใบแจ้งหนี้' ||
                          column.toString() == 'ใบเสร็จรับชำระ' ||
                          column.toString() == 'รหัสอ้างอิง' ||
                          column.toString() == 'Ref1' ||
                          column.toString() == 'Ref2';
                    }))
                        ? Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'ใบเสร็จรับชำระ' ||
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
                                      return column.toString() ==
                                              'ยอดสุทธิ(วางบิล)' ||
                                          column.toString() ==
                                              'ค่าปรับ(รับชำระ)' ||
                                          column.toString() ==
                                              'ยอดสุทธิ(รับชำระ)';
                                    }))
                                        ? TextAlign.right
                                        : (columnHeaders.any((columnx) {
                                            return column.toString() == 'สถานะ';
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
                              return column.toString() == 'ใบเสร็จรับชำระ' ||
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
                                return column.toString() ==
                                        'ยอดสุทธิ(วางบิล)' ||
                                    column.toString() == 'ค่าปรับ(รับชำระ)' ||
                                    column.toString() == 'ยอดสุทธิ(รับชำระ)';
                              }))
                                  ? TextAlign.right
                                  : (columnHeaders.any((columnx) {
                                      return column.toString() == 'สถานะ';
                                    }))
                                      ? TextAlign.center
                                      : TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: (row['ยอดสุทธิ(วางบิล)'].toString() ==
                                              '0.00' ||
                                          row['ยอดสุทธิ(รับชำระ)'].toString() ==
                                              '0.00')
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
      message:
          "ไม่พบรายการที่ชำระใบวางบิลที่อาจซ้ำกัน (No duplicates found) !!",
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
    // print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result>>>>>>> $result');
      // print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          Loading_Trans_bill();
          // print('numinvoice 4 $numinvoice');
          // red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // print('rrrrrrrrrrrrrr');
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
    // print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      // print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result>>>>>>> $result');
      // print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          Loading_Trans_bill();
          // print('numinvoice 4 $numinvoice');
          // red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index, docno, page) async {
    int selectedIndex = (page.toString() == '0')
        ? InvoiceModels.indexWhere(
            (item) => item.docno.toString() == docno.toString())
        : InvoiceModels.indexWhere(
            (item) => item.inv.toString() == docno.toString());

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
                                                                ? 'อ้างอิง : -'
                                                                : 'อ้างอิง : ${InvoiceModels[index].ref1}',
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
                                                                ? 'Ref1 : -'
                                                                : 'Ref1 : ${InvoiceModels[index].ref2}',
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
                                                              .ref4! !=
                                                          '')
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                            (InvoiceModels[index]
                                                                        .ref4 ==
                                                                    null)
                                                                ? 'Ref2 : -'
                                                                : 'Ref2 : ${InvoiceModels[index].ref4}',
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
                                                          child: Translate.TranslateAndSetText(
                                                              'พิมพ์ใบวางบิลอีกครั้ง',
                                                              AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
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
