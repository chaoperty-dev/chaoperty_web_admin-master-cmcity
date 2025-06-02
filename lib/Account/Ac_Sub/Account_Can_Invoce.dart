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
import '../../Model/GetInvoiceRe_Model.dart';
import '../../Model/GetInvoice_history_Model.dart';
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

///bill_InvoceCancel_BC()
class Account_Cancel_Invoce extends StatefulWidget {
  @override
  _Account_Cancel_InvoceState createState() => _Account_Cancel_InvoceState();
}

class _Account_Cancel_InvoceState extends State<Account_Cancel_Invoce> {
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
  List<InvoiceReModel> InvoiceBillModels_cancel = [];
  List<InvoiceReModel> _InvoiceBillModels_cancel = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<String> YE_Th = [];
  List<Map<String, String>> ac9_2 = [];

  List<int> Fix_data = [1, 2];

  ///////////--------------------------------------------->

  int Fix_Expan1 = 2, Fix_Expan2 = 1;
  ///////////--------------------------------------------->
  String? numinvoice;

  String? Datex_invoice;
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
  String sortColumn = "กำหนดชำระ";
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

      ac9_2.addAll(AcListTitle().ac9_2);
    });
  }

  where_ac9_2(String ser) {
    if (ac9_2
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
    red_InvoiceMon_bill().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

  //////////------------------------------------------------------->(รายงาน ประวัติวางบิล (ยกเลิก))

  Future<Null> red_InvoiceMon_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');
    setState(() {
      isLoading_main = true;
      isLoading = true;
      InvoiceBillModels_cancel.clear();
      _InvoiceBillModels_cancel.clear();
      data.clear();
      filteredData.clear();
    });
    String Serdata =
        (zone.toString() == '0' || zone == null) ? 'All' : 'Allzone';
    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_bill_CancelinvoiceMon_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=0&_monts=$MONTH_Now&yex=$YEAR_Now&date_type=$Date_Typepay'
        : '${MyConstant().domain}/GC_bill_CancelinvoiceMon_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now&date_type=$Date_Typepay';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceBillModels_cancel.add(transMeterModel);
          });
        }
        setState(() {
          _InvoiceBillModels_cancel = InvoiceBillModels_cancel;
        });
      }
      AddDaTa();
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();

    // Check if contractxPakanModels is not empty
    if (InvoiceBillModels_cancel.isNotEmpty) {
      // Populate the data list with mock data based on the contractxPakanModels list
      setState(() {
        data = List.generate(InvoiceBillModels_cancel.length, (index) {
          // Ensure that docno exists and is not null
          final cid = InvoiceBillModels_cancel[index].cid ?? "";
          final docno = InvoiceBillModels_cancel[index].docno ?? "";

          final daterec = (InvoiceBillModels_cancel[index].daterec == null ||
                  InvoiceBillModels_cancel[index].daterec! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceBillModels_cancel[index].daterec} 00:00:00'))}-${DateTime.parse('${InvoiceBillModels_cancel[index].daterec} 00:00:00').year + 0}';

          final date = (InvoiceBillModels_cancel[index].date == null ||
                  InvoiceBillModels_cancel[index].date! == '0000-00-00')
              ? '-'
              : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceBillModels_cancel[index].date} 00:00:00'))}-${DateTime.parse('${InvoiceBillModels_cancel[index].date} 00:00:00').year + 0}';

          final zn = InvoiceBillModels_cancel[index].zn ?? "";
          final ln = InvoiceBillModels_cancel[index].ln ?? "";
          final cname = InvoiceBillModels_cancel[index].cname ?? "";
          final sname = InvoiceBillModels_cancel[index].scname ?? "";
          final btype = InvoiceBillModels_cancel[index].btype ?? "";
          final amt_dis = (InvoiceBillModels_cancel[index].amt_dis == null ||
                  InvoiceBillModels_cancel[index].amt_dis.toString() == '')
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceBillModels_cancel[index].amt_dis.toString()))}';
          final total_bill = (InvoiceBillModels_cancel[index].total_bill ==
                      null ||
                  InvoiceBillModels_cancel[index].total_bill.toString() == '')
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceBillModels_cancel[index].total_bill.toString()))}';
          final total_dis = (InvoiceBillModels_cancel[index].total_dis ==
                      null ||
                  InvoiceBillModels_cancel[index].total_dis.toString() == '')
              ? '0.00'
              : '${nFormat.format(double.parse(InvoiceBillModels_cancel[index].total_dis.toString()))}';

          final remark = (InvoiceBillModels_cancel[index].remark == null)
              ? '-'
              : '${InvoiceBillModels_cancel[index].remark}';

          return {
            "index": "$index",
            if (where_ac9_2("0") == false) "เลขที่สัญญา": "$cid",
            if (where_ac9_2("1") == false) "เลขที่ใบแจ้งหนี้": "$docno",
            if (where_ac9_2("2") == false) "วันที่ออกใบแจ้งหนี้": "$daterec",
            if (where_ac9_2("3") == false) "กำหนดชำระ": "$date",
            if (where_ac9_2("4") == false) "ชื่อร้านค้า": "$sname",
            if (where_ac9_2("5") == false) "ชื่อผู้ติดต่อ": "$cname",
            if (where_ac9_2("6") == false) "โซนพื้นที่": "$zn",
            if (where_ac9_2("7") == false) "รหัสพื้นที่": "$ln",
            if (where_ac9_2("8") == false) "ช่องทางชำระ": "$btype",
            if (where_ac9_2("9") == false) "ส่วนลด": "$amt_dis",
            if (where_ac9_2("10") == false) "ยอดรวม": "$total_bill",
            if (where_ac9_2("11") == false) "ยอดสุทธิ": "$total_dis",
            if (where_ac9_2("12") == false) "สถานะ": "ถูกยกเลิก",
            if (where_ac9_2("13") == false) "เหตุผล": "$remark",
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
  Future<Null> red_Trans_select(index, ciddoc, qutser, tser, docno) async {
    setState(() {
      _InvoiceHistoryModels.clear();
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
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    var docnoin = docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoiceCencel_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
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
            numinvoice = _InvoiceHistoryModel.docno;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
      checkshowDialog(index, docno);
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
    return InvoiceBillModels_cancel.where(
            (e) => e.ln.toString() == row['รหัสพื้นที่'].toString()).length >
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
        (ac9_2.where((item) => item["st"] == '1').toList().length <= 8)
            ? (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.85
                : 1200
            : (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.85 +
                    ((ac9_2.where((item) => item["st"] == '1').toList().length -
                            8) *
                        30)
                : 1200 +
                    ((ac9_2.where((item) => item["st"] == '1').toList().length -
                            8) *
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
                            : (InvoiceBillModels_cancel.isEmpty)
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

                            items: ac9_2.asMap().entries.map((entry) {
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
                                        int selectedIndex = ac9_2.indexWhere(
                                            (items) =>
                                                items["ser"] == item["ser"]);
                                        // print(ac1[selectedIndex]
                                        //     [
                                        //     "pn"]);
                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (item["st"]! == '1') {
                                            ac9_2[selectedIndex]["st"] = '0';
                                          } else {
                                            ac9_2[selectedIndex]["st"] = '1';
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
                                            'วันที่ออกใบแจ้งหนี้',
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
                                                    'วันที่ออกใบแจ้งหนี้',
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
                                                    'กำหนดชำระ',
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
                                          print(Date_Typepay);
                                          Loading_Trans_bill();
                                          // red_Trans_bill();
                                        },
                                      ),
                                    ),
                                  ),
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
                                    flex: (columnHeaders.any((columnx) {
                                      return column.toString() ==
                                              'เลขที่สัญญา' ||
                                          column.toString() ==
                                              'เลขที่ใบแจ้งหนี้';
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
                                      final columnToCheck = 'รหัสพื้นที่';
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

          setState(() {
            tappedIndex_ = '${index}';
          });
          var ciddoc = InvoiceBillModels_cancel[index_x].cid;
          var qutser = '1';
          var tser = InvoiceBillModels_cancel[index_x].total_dis;
          var docno = InvoiceBillModels_cancel[index_x].docno;

          setState(() {
            payment_Ptser1 = InvoiceBillModels_cancel[index_x].ptser;
            payment_Ptname1 = InvoiceBillModels_cancel[index_x].ptname;
            payment_Bno1 = InvoiceBillModels_cancel[index_x].bno;

            Datex_invoice = InvoiceBillModels_cancel[index_x].daterec;

            payment_type1 = InvoiceBillModels_cancel[index_x].btype;
            payment_bank1 = InvoiceBillModels_cancel[index_x].bank;
          });
          red_Trans_select(index_x, ciddoc, qutser, tser, docno);
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
                          column.toString() == 'เลขที่ใบแจ้งหนี้';
                    }))
                        ? Expanded(
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่สัญญา' ||
                                  column.toString() == 'เลขที่ใบแจ้งหนี้';
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
                                      return column.toString() == 'ส่วนลด' ||
                                          column.toString() == 'ยอดรวม' ||
                                          column.toString() == 'ยอดสุทธิ';
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
                            flex: (columnHeaders.any((columnx) {
                              return column.toString() == 'เลขที่สัญญา' ||
                                  column.toString() == 'เลขที่ใบแจ้งหนี้';
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
                                return column.toString() == 'ส่วนลด' ||
                                    column.toString() == 'ยอดรวม' ||
                                    column.toString() == 'ยอดสุทธิ';
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
          ]),
        ),
      ),
    );
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index, docno) async {
    // int selectedIndex = InvoiceModels.indexWhere(
    //     (item) => item.docno.toString() == docno.toString());

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
                                              'รายละเอียดบิล ( ถูกยกเลิก ) ',
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
                                              Translate.TranslateAndSetText(
                                                  'บิลเลขที่',
                                                  Colors.red,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  12,
                                                  1),
                                              Center(
                                                child: AutoSizeText(
                                                  minFontSize: 8,
                                                  maxFontSize: 12,
                                                  '${docno}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Translate.TranslateAndSetText(
                                                  '( ถูกยกเลิก )',
                                                  Colors.red,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  12,
                                                  1),
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
                                            14,
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
                                                                    null ||
                                                                _InvoiceHistoryModels[
                                                                            index]
                                                                        .date! ==
                                                                    '')
                                                            ? '${_InvoiceHistoryModels[index].date}'
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
                                                      child: (_InvoiceHistoryModels[
                                                                          index]
                                                                      .ovalue ==
                                                                  null ||
                                                              _InvoiceHistoryModels[
                                                                          index]
                                                                      .nvalue ==
                                                                  null)
                                                          ? AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 12,
                                                              maxLines: 1,
                                                              '${_InvoiceHistoryModels[index].descr}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            )
                                                          : AutoSizeText(
                                                              minFontSize: 8,
                                                              maxFontSize: 12,
                                                              maxLines: 1,
                                                              double.parse(_InvoiceHistoryModels[
                                                                              index]
                                                                          .tf!) ==
                                                                      0.00
                                                                  ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}'
                                                                  : 'ก่อน[Before]-หลัง[After] (${int.parse(_InvoiceHistoryModels[index].ovalue!)} - ${int.parse(_InvoiceHistoryModels[index].nvalue!)}) ${double.parse(_InvoiceHistoryModels[index].qty!)}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
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
                                                            ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pri!))} (tf ${nFormat.format((double.parse(_InvoiceHistoryModels[index].amt!) - (double.parse(_InvoiceHistoryModels[index].vat!) + double.parse(_InvoiceHistoryModels[index].pvat!))))})'
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
                                                            ? '${_InvoiceHistoryModels[index].total_t}'
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
                                                            ? '${_InvoiceHistoryModels[index].total_t}'
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
                                                            ? '${_InvoiceHistoryModels[index].total_t}'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].total_t!))}',
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
                                              if (InvoiceBillModels_cancel[
                                                          index]
                                                      .refapi! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (InvoiceBillModels_cancel[
                                                                    index]
                                                                .refapi ==
                                                            null)
                                                        ? 'อ้างอิง : -'
                                                        : 'อ้างอิง : ${InvoiceBillModels_cancel[index].refapi}',
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
                                              if (InvoiceBillModels_cancel[
                                                          index]
                                                      .ref1! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (InvoiceBillModels_cancel[
                                                                    index]
                                                                .ref1 ==
                                                            null)
                                                        ? 'Ref1 : -'
                                                        : 'Ref1 : ${InvoiceBillModels_cancel[index].ref1}',
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
                                              if (InvoiceBillModels_cancel[
                                                          index]
                                                      .ref2! !=
                                                  '')
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 12,
                                                    (InvoiceBillModels_cancel[
                                                                    index]
                                                                .ref2 ==
                                                            null)
                                                        ? 'Ref2 : -'
                                                        : 'Ref2 : ${InvoiceBillModels_cancel[index].ref2}',
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
                                              //           'วันที่ออกใบแจ้งหนี้/วางบิล : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 0}',
                                              //           AccountScreen_Color
                                              //               .Colors_Text1_,
                                              //           TextAlign.start,
                                              //           null,
                                              //           Font_.Fonts_T,
                                              //           11,
                                              //           1),
                                              // AutoSizeText(
                                              //   minFontSize: 8,
                                              //   maxFontSize: 13,
                                              //   'วันที่ออกใบแจ้งหนี้/วางบิล : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 543}',
                                              //   textAlign:
                                              //       TextAlign.end,
                                              //   style: const TextStyle(
                                              //       color: PeopleChaoScreen_Color
                                              //           .Colors_Text1_,
                                              //       // fontWeight:
                                              //       //     FontWeight
                                              //       //         .bold,
                                              //       fontFamily:
                                              //           Font_.Fonts_T
                                              //       //fontSize: 10.0
                                              //       ),
                                              // ),
                                              // ),
                                              Align(
                                                alignment: Alignment.topLeft,
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
                                                //  const AutoSizeText(
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
                                                alignment: Alignment.topLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Translate.TranslateAndSetText(
                                                        '1. Tatal : ${nFormat.format(sum_amt - sum_disamt)}  (${payment_Ptname1})',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        11,
                                                        1),
                                                    // AutoSizeText(
                                                    //   minFontSize: 8,
                                                    //   maxFontSize: 13,
                                                    //   '1. Tatal ${nFormat.format(sum_amt - sum_disamt)}  (${payment_Ptname1})',
                                                    //   style: const TextStyle(
                                                    //       color: PeopleChaoScreen_Color
                                                    //           .Colors_Text2_,
                                                    //       fontWeight:
                                                    //           FontWeight
                                                    //               .w500,
                                                    //       fontFamily: Font_
                                                    //           .Fonts_T),
                                                    // ),
                                                    if (payment_Ptname1
                                                                .toString() !=
                                                            'CASH' ||
                                                        payment_Ptname1
                                                                .toString() !=
                                                            'null')
                                                      AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 11,
                                                        '  ** 1.1. Bank : ${payment_bank1} , No. : ${payment_Bno1}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[800],
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
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
                                                                    'รวม',
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
                                                            // AutoSizeText(
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

                                                            //  AutoSizeText(
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'เหตุผล :${InvoiceBillModels_cancel[index].remark}',
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
                    Divider(
                      color: Colors.grey,
                      height: 2.0,
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
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
      message: "ไม่พบรายการที่ใบวางบิลที่พื้นที่ซ้ำกัน(No duplicates found) !!",
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
