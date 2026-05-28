import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetInvoiceRe_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetType_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_maintenance_model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'package:http/http.dart' as http;

import 'Excel_BankDaily_Report.dart';
import 'Excel_Bankmovemen_Report.dart';
import 'Report_Mini/Mini_Ex_InvoiceAll_Report.dart';
import 'Excel_Invoice_Report.dart';
import 'Excel_Overdue_Report.dart';
import '../Report_Ortorkor/Excel_invoiceOrtor_Report.dart';
import 'Excel_transMeter_Report.dart';
import 'Report_Mini/MIni_Ex_BankDaily_Re.dart';
import 'Report_Mini/MIni_Ex_Bankmovemen_Re.dart';
import 'Report_Mini/MIni_Ex_Invoice_Re.dart';

class ReportScreen9 extends StatefulWidget {
  const ReportScreen9({super.key});

  @override
  State<ReportScreen9> createState() => _ReportScreen9State();
}

class _ReportScreen9State extends State<ReportScreen9> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  int? show_more;
  //-------------------------------------->
  String _verticalGroupValue_PassW = "EXCEL";
  String _ReportValue_type = "ปกติ";
  String _verticalGroupValue_NameFile = "จากระบบ";
  String Value_Report = ' ';
  String NameFile_ = '';
  String Pre_and_Dow = '';
  final _formKey = GlobalKey<FormState>();
  final FormNameFile_text = TextEditingController();
  String? Type_search, Type_search_Invoice;

  ///------------------------>
  int? Await_Status_Report1,
      Await_Status_Report2,
      Await_Status_Report3,
      Await_Status_Report4,
      Await_Status_Report5,
      Await_Status_Report6;
  double Text_Size = 13.00;
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<InvoiceReModel> InvoiceModels = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];
  List<TransReBillModel> TransReBillModels_ = [];
  List<TransReBillHistoryModel> TranHisBillModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<PayMentModel> payMentModels = [];
  List<ExpModel> expModels = [];
  List<ExpModel> expModels_Mini = [];
  List<UserModel> userModels = [];
  List<UserModel> _userModels = <UserModel>[];
  List<String> YE_Th = [];
  List<String> Mont_Th = [];

  ///////////--------------------------------------------->
  String? renTal_user, renTal_name, zone_ser, zone_name;
  DateTime now = DateTime.now();
  String? rtname, type, typex, renname, bill_name, bill_addr, bill_tax;
  String? bill_tel, bill_email, expbill, expbill_name, bill_default;
  String? bill_tser, foder;
  String? name_slip, name_slip_ser, bills_name_;
  String? base64_Slip, fileName_Slip;
////////--------------------------------------------->>

  List<RenTalModel> renTalModels = [];
  int Type_Invoice = 0;
  int Ser_BodySta1 = 0;
  int Ser_BodySta2 = 0;
  int Ser_BodySta3 = 0;
  int Ser_BodySta4 = 0;

  ///------>
  String? zone_ser_Invoice_Daily, zone_name_Invoice_Daily;
  String? zone_ser_Invoice_Mon, zone_name_Invoice_Mon;
  String? YE_Invoice_Mon, Mon_Invoice_Mon;
  var Value_InvoiceDate_Daily;

  ///------>
  String? zone_ser_BillAwatCheck_Daily, zone_name_BillAwatCheck_Daily;
  String? zone_ser_BillAwatCheck_Mon, zone_name_BillAwatCheck_Mon;
  String? YE_BillAwatCheck_Mon, Mon_BillAwatCheck_Mon;
  var Value_BillAwatCheck_Daily;

  ///------------------------>
  String? ser_Zonex, Value_stasus, Status_pe;
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
  String? Status_pe_bill = 'ปัจจุบัน', Status_pe_ser_bill = '0';
  String? Status_datexs = 'วันที่รับชำระ', Status_datexs_ser = '0';
  List StatusDate = [
    'วันที่รับชำระ',
    'วันที่ทำรายการ',
  ];
  List Status = [
    'ปัจจุบัน',
    'ถูกยกเลิก',
  ];
  List<dynamic> Type_vat = [
    {"ser": "1", "st": "1", "type": "pvat", "pn": "ก่อนVAT"},
    {"ser": "2", "st": "0", "type": "vat", "pn": "VAT"},
    {"ser": "3", "st": "0", "type": "dis", "pn": "ส่วนลด"},
    {"ser": "4", "st": "0", "type": "total", "pn": "รวมVAT"},
  ];
  List<TextEditingController> Dropdown_Controller_zone = [];
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    // TODO: implement initState
    super.initState();
    read_GC_User();
    checkPreferance();
    read_GC_rental();
    read_GC_zone();
    read_GC_Exp();
    read_GC_PayMentModel();
  }

///////------------------------------------------------------------------>
  Future<Null> read_GC_User() async {
    if (userModels.isNotEmpty) {
      setState(() {
        userModels.clear();
        _userModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_userSetting.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      Map<String, dynamic> map = Map();
      map['ser'] = '0';

      map['fname'] = 'ทั้งหมด';
      map['lname'] = '';

      UserModel userModelsx = UserModel.fromJson(map);

      setState(() {
        userModels.add(userModelsx);
      });
      if (result != null) {
        for (var map in result) {
          UserModel userModel = UserModel.fromJson(map);
          setState(() {
            userModels.add(userModel);
            _userModels = userModels;
          });
        }
      } else {}
    } catch (e) {}
  }

///////------------------------------------------------------------------>
  Future<Null> read_GC_PayMentModel() async {
    if (payMentModels.length != 0) {
      payMentModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    // print('ren >>>>>> $ren');

    String url =
        '${MyConstant().domain}/GC_Bank_Paytype.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          PayMentModel payMentModel = PayMentModel.fromJson(map);
          setState(() {
            payMentModels.add(payMentModel);
          });
        }
      } else {}
    } catch (e) {}
  }

  /////////------------------------------------------------------------->
  Future<Null> checkPreferance() async {
    int currentYear = DateTime.now().year + 1;
    for (int i = currentYear; i >= currentYear - 11; i--) {
      YE_Th.add(i.toString());
    }
    for (int i2 = 0; i2 < 12; i2++) {
      Mont_Th.add('${i2 + 1}');
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
    });
    // System_New_Update();
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

////////--------------------------------------------------------------->
  System_New_Update() async {
    // String accept_ = showst_update_!;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: const Text(
          '📢ขออภัย !!!! ',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontFamily: Font_.Fonts_T,
          ),
        ),
        content: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/pngegg.png"),
              // fit: BoxFit.cover,
            ),
          ),
          child: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ขออภัย ขณะนี้ฟังก์ชั่นก์ รายงานหน้า 9 อยู่ในช่วงทดสอบ... !!!!!! ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () async {
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text(
                                'รับทราบ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
        ],
      ),
    );
  }

  ////////--------------------------------------------------------------->
  Future<Null> read_GC_Exp() async {
    if (expModels.isNotEmpty) {
      expModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_exp_Report.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ExpModel expModel = ExpModel.fromJson(map);

          setState(() {
            expModels.add(expModel);
          });
        }
      } else {}
    } catch (e) {}
  }

////////--------------------------------------------------------------->
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      zoneModels.clear();
      zoneModels_report.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

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
        zoneModels_report.add(zoneModelx);
      });

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        setState(() {
          zoneModels.add(zoneModel);
          zoneModels_report.add(zoneModel);
        });
      }
      // zoneModels_report.sort((a, b) => a.zn!.compareTo(b.zn!));
      zoneModels_report.sort((a, b) {
        if (a.zn == 'ทั้งหมด') {
          return -1; // 'all' should come before other elements
        } else if (b.zn == 'ทั้งหมด') {
          return 1; // 'all' should come after other elements
        } else {
          return a.zn!
              .compareTo(b.zn!); // sort other elements in ascending order
        }
      });
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
  }

////////--------------------------------------------------------------->

  Future<Null> red_InvoiceMonFull_bill() async {
    setState(() {
      InvoiceModels.clear();
      Await_Status_Report2 = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = (zone_ser_Invoice_Mon == null ||
            zone_ser_Invoice_Mon.toString() == '')
        ? '${MyConstant().domain}/GC_bill_invoiceAll_historyReport.php?isAdd=true&ren=$ren&Serdata=Mon&serzone=0_monts=$Mon_Invoice_Mon&yex=$YE_Invoice_Mon'
        : '${MyConstant().domain}/GC_bill_invoiceAll_historyReport.php?isAdd=true&ren=$ren&Serdata=Mon&serzone=$zone_ser_Invoice_Mon&_monts=$Mon_Invoice_Mon&yex=$YE_Invoice_Mon';
    // print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        // setState(() {
        //   Await_Status_Report1 = 1;
        // });
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceModels.add(transMeterModel);
          });
        }
      }

      setState(() {
        _InvoiceModels = InvoiceModels;
        // Await_Status_Report1 = null;
      });
    } catch (e) {
      // print(e);
    }
  }

//////////---------------------------------------->Value_teNantDate_Daily
  Future<Null> red_InvoiceDaily_bill() async {
    setState(() {
      InvoiceModels.clear();
      Await_Status_Report1 = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = (zone_ser_Invoice_Daily == null ||
            zone_ser_Invoice_Daily.toString() == '')
        ? '${MyConstant().domain}/GC_bill_invoiceAll_historyReport.php?isAdd=true&ren=$ren&Serdata=Day&serzone=0&dates=$Value_InvoiceDate_Daily'
        : '${MyConstant().domain}/GC_bill_invoiceAll_historyReport.php?isAdd=true&ren=$ren&Serdata=Day&serzone=$zone_ser_Invoice_Daily&dates=$Value_InvoiceDate_Daily';
    // print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        // setState(() {
        //   Await_Status_Report1 = 1;
        // });
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceModels.add(transMeterModel);
          });
        }
      }

      setState(() {
        _InvoiceModels = InvoiceModels;
        // Await_Status_Report1 = null;
      });
    } catch (e) {
      //  print(e);
    }
  }

//////////---------------------------------------->Value_teNantDate_Daily
  // Future<Null> red_InvoiceDaily_bill() async {
  //   String Serdata =
  //       (zone_ser_Invoice_Mon.toString() == '0' || zone_ser_Invoice_Mon == null)
  //           ? 'All'
  //           : 'Allzone';

  //   setState(() {
  //     InvoiceModels.clear();
  //   });
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');

  //   String url = (Serdata.toString() == 'All')
  //       ? '${MyConstant().domain}/GC_bill_invoiceDaily_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Daily&dates=$Value_InvoiceDate_Daily'
  //       : '${MyConstant().domain}/GC_bill_invoiceDaily_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Daily&dates=$Value_InvoiceDate_Daily';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print('result $ciddoc');
  //     if (result.toString() != 'null') {
  //       setState(() {
  //         Await_Status_Report2 = 1;
  //       });
  //       for (var map in result) {
  //         InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
  //         setState(() {
  //           InvoiceModels.add(transMeterModel);
  //         });
  //       }
  //     }

  //     Future.delayed(const Duration(milliseconds: 700), () async {
  //       setState(() {
  //         _InvoiceModels = InvoiceModels;
  //         Await_Status_Report2 = null;
  //       });
  //     });
  //   } catch (e) {}
  // }

  ////////////----------------------->
  // Future<Null> red_Trans_select(ciddoc, docnoin, index) async {
  //   if (_InvoiceHistoryModels.length != 0) {
  //     setState(() {
  //       _InvoiceHistoryModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');

  //   String url =
  //       '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         InvoiceHistoryModel _InvoiceHistoryModel =
  //             InvoiceHistoryModel.fromJson(map);

  //         setState(() {
  //           _InvoiceHistoryModels.add(_InvoiceHistoryModel);
  //         });
  //       }
  //     }
  //   } catch (e) {}
  // }

  ////////////----------------------->
  Future<Null> red_TransAll_Invoice_select() async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    var ser_Zone = (Type_search_Invoice == 'Mon')
        ? zone_ser_Invoice_Mon
        : zone_ser_Invoice_Daily;

    String url =
        '${MyConstant().domain}/GC_bill_invoiceAll_historyReport.php?isAdd=true&ren=$ren&yex=$YE_Invoice_Mon&_monts=$Mon_Invoice_Mon&serzone=$ser_Zone&Typesearch=$Type_search_Invoice&datex=$Value_InvoiceDate_Daily';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          setState(() {
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
    } catch (e) {}
  }

  ////////////----------------------->
  Future<Null> red_Trans_selectIncome(ciddoc, docnoin, index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    setState(() {
      TranHisBillModels.clear();
    });
    String url =
        '${MyConstant().domain}/GC_bill_pay_history_DailyReport.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel TranHisBillModels_Mons =
              TransReBillHistoryModel.fromJson(map);
          setState(() {
            TranHisBillModels.add(TranHisBillModels_Mons);
          });
        }
      }
    } catch (e) {
      // print('Error-Dis(red_Trans_selectIncome) : ${e}');
    }
  }

/////////////------------------------------------>
  Future<Null> red_Trans_selectIncomeAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    setState(() {
      TranHisBillModels.clear();
    });
    var ser_Zone = (Type_search == 'Mon')
        ? zone_ser_BillAwatCheck_Mon
        : zone_ser_BillAwatCheck_Daily;

    String url =
        '${MyConstant().domain}/GC_bill_pay_historyselect_VerifiAllDisReport.php?isAdd=true&ren=$ren&mont_h=$Mon_BillAwatCheck_Mon&yea_r=$YE_BillAwatCheck_Mon&serzone=$ser_Zone&datex=$Value_BillAwatCheck_Daily&Typesearch=$Type_search';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel TranHisBillModels_Mons =
              TransReBillHistoryModel.fromJson(map);
          setState(() {
            TranHisBillModels.add(TranHisBillModels_Mons);
          });
        }
      }
    } catch (e) {
      // print('Error-Dis(red_Trans_selectIncomeAll) : ${e}');
    }
  }

  ////////////-----------------------(วันที่รายงานประจำวัน)
  Future<Null> _select_Date_Daily(BuildContext context) async {
    setState(() {
      zone_ser_Invoice_Mon = null;
      zone_name_Invoice_Mon = null;
      YE_Invoice_Mon = null;
      Mon_Invoice_Mon = null;
      Ser_BodySta1 = 0;
      Ser_BodySta2 = 0;
    });
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

        var formatter = DateFormat('y-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          Value_InvoiceDate_Daily = "${formatter.format(result)}";
        });
        // if (Value_Chang_Zone_Daily != null) {
        //   red_Trans_bill();
        //   red_Trans_billDailyBank();
        // }

        // red_Trans_bill_Groptype_daly();
      }
    });
  }

///////--------------------------------------------------->
  ///
  Future<Null> red_Trans_bill_Mon() async {
    setState(() {
      TransReBillModels_.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_ReportMon.php?isAdd=true&ren=$ren&mont_h=$Mon_BillAwatCheck_Mon&yea_r=$YE_BillAwatCheck_Mon&serzone=$zone_ser_BillAwatCheck_Mon&type_datex=$Status_datexs_ser';
    // print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            TransReBillModels_.add(transReBillModel);
          });
        }
        Future.delayed(const Duration(milliseconds: 800), () async {
          setState(() {
            Await_Status_Report3 = null;
          });
          // print('red_Trans_bill_Mon : ${TransReBillModels_.length}');
        });
      }
    } catch (e) {}
  }

///////--------------------------------------------------->
  ///
  Future<Null> red_Trans_bill_Daily() async {
    setState(() {
      TransReBillModels_.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_ReportDaily.php?isAdd=true&ren=$ren&date=$Value_BillAwatCheck_Daily&serzone=$zone_ser_BillAwatCheck_Daily';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            TransReBillModels_.add(transReBillModel);
          });
        }
        Future.delayed(const Duration(milliseconds: 800), () async {
          setState(() {
            Await_Status_Report4 = null;
          });
          // print('red_Trans_bill_Daily : ${TransReBillModels_.length}');
        });
      }
    } catch (e) {}
  }

//
  ////////////-----------------------(วันที่รายงานประจำวัน)
  Future<Null> _select_Date_DailyBillAwatCheck(BuildContext context) async {
    setState(() {
      zone_ser_BillAwatCheck_Mon = null;
      zone_name_BillAwatCheck_Mon = null;
      YE_BillAwatCheck_Mon = null;
      Mon_BillAwatCheck_Mon = null;
      Ser_BodySta3 = 0;
      Ser_BodySta4 = 0;
    });
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
        var formatter = DateFormat('y-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          Value_BillAwatCheck_Daily = "${formatter.format(result)}";
        });
      }
    });
  }
  //////////------------------>

/////////////---------------------------------------->
  slip_Widget(Url, doc_) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Center(
            child: Column(
              children: [
                Text(
                  '${doc_}',
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                      fontSize: 14.0),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            SizedBox(
              width: 300,
              child: Image.network('$Url'),
            )
          ])),
          actions: <Widget>[
            SizedBox(
              // width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '*** วิธีตรวจสอบ "สลิป" เบื้องต้น',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T),
                  ),
                  const Text(
                    '1. สังเกตความละเอียดของ ตัวเลข หรือ ตัวหนังสือ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: Font_.Fonts_T),
                  ),
                  const Text(
                    '2. เปิดแอปฯ ธนาคารขึ้นมา สแกน QR CODE บนสลิปโอนเงิน',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: Font_.Fonts_T),
                  ),
                  const Text(
                    '3. ใช้  Mobile Banking เช็ก ยอดเงิน วัน-เวลาที่โอน ตรงกับในสลิปที่ได้มาหรือไม่',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: Font_.Fonts_T),
                  ),
                  const Text(
                    '4. ควรตรวจสอบสลิปทันทีที่ได้รับมา เพราะ QR code บนสลิปของบางธนาคารจะมีอายุจำกัด ตั้งเเต่ 7 วัน ถึง 60 วัน ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: Font_.Fonts_T),
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text(
                              'ปิด',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
    );
  }

///////////------------------------------------------------------->
//////////////------------------------------------->
  Widget getDateRangePicker(type) {
    // final localeObj = Locale('th');
    return Container(
      height: 250,
      width: 300,
      child: Card(
        child: SfDateRangePicker(
          allowViewNavigation: (type == 2 || type == 4) ? true : false,
          startRangeSelectionColor: Colors.purple,
          endRangeSelectionColor: Colors.deepPurple,
          rangeSelectionColor: Colors.green[100],
          view: DateRangePickerView.year,
          // monthViewSettings:
          //     DateRangePickerMonthViewSettings(viewHeaderHeight: 100),
          selectionMode: DateRangePickerSelectionMode.single,
          enableMultiView: false,
          toggleDaySelection: false,
          // showTodayButton: true,
          onSelectionChanged: (type == 1)
              ? selectionChanged_month1
              : (type == 2)
                  ? selectionChanged1
                  : (type == 3)
                      ? selectionChanged_month2
                      : selectionChanged2,
          // backgroundColor: AppBarColors.ABar_Colors,
        ),
      ),
    );
  }

  /////////////////---------------------------->
  void selectionChanged1(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;

      setState(() {
        Value_InvoiceDate_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    } else if (args.value is DateTime) {
      setState(() {
        Value_InvoiceDate_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });

    //print(Value_InvoiceDate_Daily);
  }

  void selectionChanged2(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;

      setState(() {
        Value_BillAwatCheck_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    } else if (args.value is DateTime) {
      setState(() {
        Value_BillAwatCheck_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });

    // print(Value_BillAwatCheck_Daily);
  }

  void selectionChanged_month1(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      //  (Mon_Invoice_Mon == null ||
      //                                         YE_Invoice_Mon == '')
      setState(() {
        Mon_Invoice_Mon = DateFormat('MM').format(selectedDate);
        YE_Invoice_Mon = DateFormat('yyyy').format(selectedDate);
      });
      setState(() {
        zone_ser_Invoice_Daily = null;
        zone_name_Invoice_Daily = null;
        Value_InvoiceDate_Daily = null;
        Ser_BodySta1 = 0;
        Ser_BodySta2 = 0;
      });
      // print('Selected month: ${Mon_Invoice_Mon}, Year: ${YE_Invoice_Mon}');
    }
  }

  void selectionChanged_month2(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
//  (Mon_BillAwatCheck_Mon == null ||
//                                             YE_BillAwatCheck_Mon == '')
      setState(() {
        Mon_BillAwatCheck_Mon = DateFormat('MM').format(selectedDate);
        YE_BillAwatCheck_Mon = DateFormat('yyyy').format(selectedDate);
      });
      setState(() {
        zone_ser_BillAwatCheck_Daily = null;
        zone_name_BillAwatCheck_Daily = null;
        Value_BillAwatCheck_Daily = null;
        Ser_BodySta3 = 0;
        Ser_BodySta4 = 0;
      });
      // print(
      //     'Selected month: ${Mon_BillAwatCheck_Mon}, Year: ${YE_BillAwatCheck_Mon}');
    }
  }

////////////------------------------------------------>
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              // color: Colors.lime[200],
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.grey, width: 1),
            ),
            child:
                ListView(padding: const EdgeInsets.all(8), children: <Widget>[
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'สถานะบิล :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 150,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            value: Status_pe_bill,

                            alignment: Alignment.center,
                            focusColor: Colors.white,
                            autofocus: false,
                            decoration: InputDecoration(
                              enabled: true,
                              hoverColor: Colors.brown,
                              prefixIconColor: Colors.blue,
                              fillColor: Colors.white.withOpacity(0.05),
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 231, 227, 227),
                                ),
                              ),
                            ),
                            isExpanded: false,
                            // hint: StreamBuilder(
                            //     stream: Stream.periodic(const Duration(seconds: 1)),
                            //     builder: (context, snapshot) {
                            //       return Text(
                            //         Status_pe == null ? 'เลือก' : '$Status_pe',
                            //         maxLines: 2,
                            //         textAlign: TextAlign.center,
                            //         style: const TextStyle(
                            //           overflow: TextOverflow.ellipsis,
                            //           fontSize: 14,
                            //           color: Colors.grey,
                            //         ),
                            //       );
                            //     }),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            iconSize: 20,
                            buttonHeight: 40,
                            buttonWidth: 250,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items:
                                Status.map((item) => DropdownMenuItem<String>(
                                      value: '${item}',
                                      child: Translate.TranslateAndSetText(
                                          '${item}',
                                          Colors.grey,
                                          TextAlign.center,
                                          FontWeight.w500,
                                          Font_.Fonts_T,
                                          Text_Size,
                                          1),
                                    )).toList(),

                            onChanged: (value) async {
                              int selectedIndex =
                                  Status.indexWhere((item) => item == value);
                              setState(() {
                                Status_pe_bill = Status[selectedIndex]!;
                                Status_pe_ser_bill = '${selectedIndex}';
                              });
                              // print(Status_pe_ser);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'เดือน/ปีที่ครบกำหนดชำระ :',
                            ReportScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: Text(''),
                                      content: Container(
                                        height: 300,
                                        child: Column(
                                          children: <Widget>[
                                            getDateRangePicker(1),
                                            MaterialButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ));
                                });
                            // _select_Date_Daily(context);
                          },
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
                              width: 180,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    (Mon_Invoice_Mon == null ||
                                            YE_Invoice_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_Invoice_Mon / $YE_Invoice_Mon',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size - 2,
                                    1),
                              )),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       color: AppbackgroundColor.Sub_Abg_Colors,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       // border: Border.all(color: Colors.grey, width: 1),
                      //     ),
                      //     width: 120,
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: DropdownButtonFormField2(
                      //       alignment: Alignment.center,
                      //       focusColor: Colors.white,
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         floatingLabelAlignment:
                      //             FloatingLabelAlignment.center,
                      //         enabled: true,
                      //         hoverColor: Colors.brown,
                      //         prefixIconColor: Colors.blue,
                      //         fillColor: Colors.white.withOpacity(0.05),
                      //         filled: false,
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.zero,
                      //         border: OutlineInputBorder(
                      //           borderSide: const BorderSide(color: Colors.red),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.only(
                      //             topRight: Radius.circular(10),
                      //             topLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //           ),
                      //           borderSide: BorderSide(
                      //             width: 1,
                      //             color: Color.fromARGB(255, 231, 227, 227),
                      //           ),
                      //         ),
                      //       ),
                      //       isExpanded: false,
                      //       value: (Mon_Invoice_Mon == null)
                      //           ? null
                      //           : Mon_Invoice_Mon,
                      //       // hint: Text(
                      //       //   Mon_Income == null
                      //       //       ? 'เลือก'
                      //       //       : '$Mon_Income',
                      //       //   maxLines: 2,
                      //       //   textAlign: TextAlign.center,
                      //       //   style: const TextStyle(
                      //       //     overflow:
                      //       //         TextOverflow.ellipsis,
                      //       //     fontSize: 14,
                      //       //     color: Colors.grey,
                      //       //   ),
                      //       // ),
                      //       icon: const Icon(
                      //         Icons.arrow_drop_down,
                      //         color: Colors.black,
                      //       ),
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //       ),
                      //       iconSize: 20,
                      //       buttonHeight: 40,
                      //       buttonWidth: 200,
                      //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //       dropdownDecoration: BoxDecoration(
                      //         // color: Colors
                      //         //     .amber,
                      //         borderRadius: BorderRadius.circular(10),
                      //         border: Border.all(color: Colors.white, width: 1),
                      //       ),
                      //       items: [
                      //         for (int item = 1; item < 13; item++)
                      //           DropdownMenuItem<String>(
                      //             value: '${item}',
                      //             child: Translate.TranslateAndSetText(
                      //                 '${monthsInThai[item - 1]}',
                      //                 Colors.grey,
                      //                 TextAlign.center,
                      //                 FontWeight.w500,
                      //                 Font_.Fonts_T,
                      //                 Text_Size,
                      //                 1),
                      //           )
                      //       ],

                      //       onChanged: (value) async {
                      //         setState(() {
                      //           zone_ser_Invoice_Daily = null;
                      //           zone_name_Invoice_Daily = null;
                      //           Value_InvoiceDate_Daily = null;
                      //           Ser_BodySta1 = 0;
                      //           Ser_BodySta2 = 0;
                      //         });
                      //         Mon_Invoice_Mon = value.toString();
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ปีที่ครบกำหนดชำระ :',
                      //       ReportScreen_Color.Colors_Text2_,
                      //       TextAlign.center,
                      //       FontWeight.w500,
                      //       Font_.Fonts_T,
                      //       Text_Size,
                      //       1),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       color: AppbackgroundColor.Sub_Abg_Colors,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       // border: Border.all(color: Colors.grey, width: 1),
                      //     ),
                      //     width: 120,
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: DropdownButtonFormField2(
                      //       alignment: Alignment.center,
                      //       focusColor: Colors.white,
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         floatingLabelAlignment:
                      //             FloatingLabelAlignment.center,
                      //         enabled: true,
                      //         hoverColor: Colors.brown,
                      //         prefixIconColor: Colors.blue,
                      //         fillColor: Colors.white.withOpacity(0.05),
                      //         filled: false,
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.zero,
                      //         border: OutlineInputBorder(
                      //           borderSide: const BorderSide(color: Colors.red),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.only(
                      //             topRight: Radius.circular(10),
                      //             topLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //           ),
                      //           borderSide: BorderSide(
                      //             width: 1,
                      //             color: Color.fromARGB(255, 231, 227, 227),
                      //           ),
                      //         ),
                      //       ),
                      //       isExpanded: false,
                      //       value: (Ser_BodySta1 != 1) ? null : YE_Invoice_Mon,
                      //       // hint: Text(
                      //       //   YE_Income == null
                      //       //       ? 'เลือก'
                      //       //       : '$YE_Income',
                      //       //   maxLines: 2,
                      //       //   textAlign: TextAlign.center,
                      //       //   style: const TextStyle(
                      //       //     overflow:
                      //       //         TextOverflow.ellipsis,
                      //       //     fontSize: 14,
                      //       //     color: Colors.grey,
                      //       //   ),
                      //       // ),
                      //       icon: const Icon(
                      //         Icons.arrow_drop_down,
                      //         color: Colors.black,
                      //       ),
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //       ),
                      //       iconSize: 20,
                      //       buttonHeight: 40,
                      //       buttonWidth: 200,
                      //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //       dropdownDecoration: BoxDecoration(
                      //         // color: Colors
                      //         //     .amber,
                      //         borderRadius: BorderRadius.circular(10),
                      //         border: Border.all(color: Colors.white, width: 1),
                      //       ),
                      //       items: YE_Th.map((item) => DropdownMenuItem<String>(
                      //             value: '${item}',
                      //             child: Text(
                      //               '${item}',
                      //               // '${int.parse(item) + 543}',
                      //               textAlign: TextAlign.center,
                      //               style: TextStyle(
                      //                 overflow: TextOverflow.ellipsis,
                      //                 fontSize: Text_Size,
                      //                 color: Colors.grey,
                      //               ),
                      //             ),
                      //           )).toList(),

                      //       onChanged: (value) async {
                      //         setState(() {
                      //           zone_ser_Invoice_Daily = null;
                      //           zone_name_Invoice_Daily = null;
                      //           Value_InvoiceDate_Daily = null;
                      //           Ser_BodySta1 = 0;
                      //           Ser_BodySta2 = 0;
                      //         });
                      //         YE_Invoice_Mon = value.toString();

                      //         // if (Value_Chang_Zone_Income !=
                      //         //     null) {
                      //         //   red_Trans_billIncome();
                      //         //   red_Trans_billMovemen();
                      //         // }
                      //       },
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'โซน :',
                            ReportScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 300,
                          // padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                                isExpanded: false,
                                searchController: Dropdown_Controller_zone[0],
                                value: (zone_name_Invoice_Mon == null)
                                    ? null
                                    : zone_name_Invoice_Mon,
                                alignment: Alignment.center,
                                focusColor: Colors.white,
                                searchInnerWidget: Container(
                                  // width: 200,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red[100]!.withOpacity(0.5),
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
                                    controller: Dropdown_Controller_zone[0],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search...',
                                      // fillColor: Colors.red[300],
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 227, 227),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                hint: (zone_name_Invoice_Mon == null)
                                    ? null
                                    : Text(
                                        '$zone_name_Invoice_Mon',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: Text_Size,
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: TextHome_Color.TextHome_Colors,
                                ),
                                style: TextStyle(
                                    fontSize: Text_Size,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                                iconSize: 20,
                                buttonHeight: 35,
                                buttonWidth: 250,
                                dropdownDecoration: BoxDecoration(
                                  // color: Colors.red[100]!.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                //  BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                items: zoneModels_report
                                    .map((item) => DropdownMenuItem<String>(
                                          value: '${item.zn}',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.zn!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: Text_Size,
                                                    fontFamily: Font_.Fonts_T),
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
                                  setState(() {
                                    zone_ser_Invoice_Daily = null;
                                    zone_name_Invoice_Daily = null;
                                    Value_InvoiceDate_Daily = null;
                                    Ser_BodySta1 = 0;
                                    Ser_BodySta2 = 0;
                                  });
                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_Invoice_Mon = value!;
                                    zone_ser_Invoice_Mon =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_ser_Invoice_Mon  //${zone_name_Invoice_Mon}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[0].clear();
                                  }
                                }),
                          ),
                          //  DropdownButtonFormField2(
                          //   value: (Ser_BodySta1 != 1)
                          //       ? null
                          //       : zone_name_Invoice_Mon,
                          //   alignment: Alignment.center,
                          //   focusColor: Colors.white,
                          //   autofocus: false,
                          //   decoration: InputDecoration(
                          //     enabled: true,
                          //     hoverColor: Colors.brown,
                          //     prefixIconColor: Colors.blue,
                          //     fillColor: Colors.white.withOpacity(0.05),
                          //     filled: false,
                          //     isDense: true,
                          //     contentPadding: EdgeInsets.zero,
                          //     border: OutlineInputBorder(
                          //       borderSide: const BorderSide(color: Colors.red),
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     focusedBorder: const OutlineInputBorder(
                          //       borderRadius: BorderRadius.only(
                          //         topRight: Radius.circular(10),
                          //         topLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //       ),
                          //       borderSide: BorderSide(
                          //         width: 1,
                          //         color: Color.fromARGB(255, 231, 227, 227),
                          //       ),
                          //     ),
                          //   ),
                          //   isExpanded: false,

                          //   icon: const Icon(
                          //     Icons.arrow_drop_down,
                          //     color: Colors.black,
                          //   ),
                          //   style: const TextStyle(
                          //     color: Colors.grey,
                          //   ),
                          //   iconSize: 20,
                          //   buttonHeight: 40,
                          //   buttonWidth: 250,
                          //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                          //   dropdownDecoration: BoxDecoration(
                          //     // color: Colors
                          //     //     .amber,
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.white, width: 1),
                          //   ),
                          //   items: zoneModels_report
                          //       .map((item) => DropdownMenuItem<String>(
                          //             value: '${item.zn}',
                          //             child: Text(
                          //               '${item.zn}',
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                 overflow: TextOverflow.ellipsis,
                          //                 fontSize: 14,
                          //                 color: Colors.grey,
                          //               ),
                          //             ),
                          //           ))
                          //       .toList(),

                          //   onChanged: (value) async {
                          //     setState(() {
                          //       zone_ser_Invoice_Daily = null;
                          //       zone_name_Invoice_Daily = null;
                          //       Value_InvoiceDate_Daily = null;
                          //       Ser_BodySta1 = 0;
                          //       Ser_BodySta2 = 0;
                          //     });
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_Invoice_Mon = value!;
                          //       zone_ser_Invoice_Mon =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_ser_Invoice_Mon  //${zone_name_Invoice_Mon}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            if (zone_name_Invoice_Mon != null) {
                              setState(() {
                                Ser_BodySta1 = 1;
                                Await_Status_Report1 = 0;
                              });
                              Dia_log3();
                            }
                            try {
                              red_InvoiceMonFull_bill().then((result) {
                                // print('red_InvoiceMonFull_bill');
                                // print('red_InvoiceMonFull_bill');
                                setState(() {
                                  Await_Status_Report1 = 1;
                                });
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              //  print('object catch');
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    'ค้นหา',
                                    Colors.white,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                          onTap: (zone_name_Invoice_Mon == null ||
                                  InvoiceModels.isEmpty)
                              ? null
                              : () async {
                                  // Insert_log.Insert_logs(
                                  //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
                                  Invoice_Widget();
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Translate.TranslateAndSetText(
                                      'เรียกดู',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                            ),
                          )),
                      (Await_Status_Report1 == 0)
                          ? SizedBox(
                              // height: 20,
                              child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(4.0),
                                    child: const CircularProgressIndicator()),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      'กำลังโหลดรายงานข้อมูลใบแจ้งหนี้/วางบิล...',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                ),
                              ],
                            ))
                          : (InvoiceModels.isEmpty ||
                                  Await_Status_Report1 == null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      (InvoiceModels.isEmpty &&
                                              zone_name_Invoice_Mon != null &&
                                              Await_Status_Report1 != null)
                                          ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิล (ไม่พบข้อมูล ✖️)'
                                          : 'รายงานข้อมูลใบแจ้งหนี้/วางบิล',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      'รายงานข้อมูลใบแจ้งหนี้/วางบิล✔️',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 4.0,
                    child: Divider(
                      color: Colors.grey[300],
                      height: 4.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'สถานะบิล :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 150,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            value: Status_pe_bill,

                            alignment: Alignment.center,
                            focusColor: Colors.white,
                            autofocus: false,
                            decoration: InputDecoration(
                              enabled: true,
                              hoverColor: Colors.brown,
                              prefixIconColor: Colors.blue,
                              fillColor: Colors.white.withOpacity(0.05),
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 231, 227, 227),
                                ),
                              ),
                            ),
                            isExpanded: false,
                            // hint: StreamBuilder(
                            //     stream: Stream.periodic(const Duration(seconds: 1)),
                            //     builder: (context, snapshot) {
                            //       return Text(
                            //         Status_pe == null ? 'เลือก' : '$Status_pe',
                            //         maxLines: 2,
                            //         textAlign: TextAlign.center,
                            //         style: const TextStyle(
                            //           overflow: TextOverflow.ellipsis,
                            //           fontSize: 14,
                            //           color: Colors.grey,
                            //         ),
                            //       );
                            //     }),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            iconSize: 20,
                            buttonHeight: 40,
                            buttonWidth: 250,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items:
                                Status.map((item) => DropdownMenuItem<String>(
                                      value: '${item}',
                                      child: Translate.TranslateAndSetText(
                                          '${item}',
                                          Colors.grey,
                                          TextAlign.center,
                                          FontWeight.w500,
                                          Font_.Fonts_T,
                                          Text_Size,
                                          1),
                                    )).toList(),

                            onChanged: (value) async {
                              int selectedIndex =
                                  Status.indexWhere((item) => item == value);
                              setState(() {
                                Status_pe_bill = Status[selectedIndex]!;
                                Status_pe_ser_bill = '${selectedIndex}';
                              });
                              // print(Status_pe_ser);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'วันที่ที่ครบกำหนดชำระ :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: Text(''),
                                      content: Container(
                                        height: 300,
                                        child: Column(
                                          children: <Widget>[
                                            getDateRangePicker(2),
                                            MaterialButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ));
                                });
                            // _select_Date_Daily(context);
                          },
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
                              width: 180,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    (Value_InvoiceDate_Daily == null)
                                        ? 'เลือก'
                                        : '$Value_InvoiceDate_Daily',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size - 2,
                                    1),
                              )),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: InkWell(
                      //     onTap: () {
                      //       _select_Date_Daily(context);
                      //     },
                      //     child: Container(
                      //         decoration: BoxDecoration(
                      //           color: AppbackgroundColor.Sub_Abg_Colors,
                      //           borderRadius: const BorderRadius.only(
                      //               topLeft: Radius.circular(10),
                      //               topRight: Radius.circular(10),
                      //               bottomLeft: Radius.circular(10),
                      //               bottomRight: Radius.circular(10)),
                      //           border:
                      //               Border.all(color: Colors.grey, width: 1),
                      //         ),
                      //         width: 120,
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Center(
                      //           child: Translate.TranslateAndSetText(
                      //               (Value_InvoiceDate_Daily == null)
                      //                   ? 'เลือก'
                      //                   : '$Value_InvoiceDate_Daily',
                      //               ReportScreen_Color.Colors_Text1_,
                      //               TextAlign.center,
                      //               FontWeight.w500,
                      //               Font_.Fonts_T,
                      //               Text_Size,
                      //               1),
                      //         )),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'โซน :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 300,
                          // padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                                isExpanded: false,
                                searchController: Dropdown_Controller_zone[1],
                                value: (zone_name_Invoice_Daily == null)
                                    ? null
                                    : zone_name_Invoice_Daily,
                                alignment: Alignment.center,
                                focusColor: Colors.white,
                                searchInnerWidget: Container(
                                  // width: 200,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red[100]!.withOpacity(0.5),
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
                                    controller: Dropdown_Controller_zone[1],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search...',
                                      // fillColor: Colors.red[300],
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 227, 227),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                hint: (zone_name_Invoice_Daily == null)
                                    ? null
                                    : Text(
                                        '$zone_name_Invoice_Daily',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: Text_Size,
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: TextHome_Color.TextHome_Colors,
                                ),
                                style: TextStyle(
                                    fontSize: Text_Size,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                                iconSize: 20,
                                buttonHeight: 35,
                                buttonWidth: 250,
                                dropdownDecoration: BoxDecoration(
                                  // color: Colors.red[100]!.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                //  BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                items: zoneModels_report
                                    .map((item) => DropdownMenuItem<String>(
                                          value: '${item.zn}',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.zn!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: Text_Size,
                                                    fontFamily: Font_.Fonts_T),
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
                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_Invoice_Daily = value.toString();
                                    zone_ser_Invoice_Daily =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[1].clear();
                                  }
                                }),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            if (zone_name_Invoice_Daily != null) {
                              setState(() {
                                Ser_BodySta2 = 1;
                                Await_Status_Report2 = 0;
                                Type_search_Invoice = 'Daily';
                              });
                              Dia_log3();
                            }
                            try {
                              red_InvoiceDaily_bill().then((result) {
                                // print('red_InvoiceMonFull_bill');
                                // print('red_InvoiceMonFull_bill');
                                setState(() {
                                  Await_Status_Report2 = 1;
                                });
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              //  print('object catch');
                              Navigator.of(context).pop();
                            }
                            // setState(() {
                            //   Ser_BodySta2 = 1;
                            //   Type_search_Invoice = 'Daily';
                            // });
                            // if (Ser_BodySta2 == 1 &&
                            //     zone_ser_Invoice_Daily != null &&
                            //     Value_InvoiceDate_Daily != null) {
                            //   Dia_log();
                            //   red_InvoiceDaily_bill();
                            // }
                          },
                          child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    'ค้นหา',
                                    Colors.white,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                          onTap: (zone_name_Invoice_Daily == null ||
                                  InvoiceModels.isEmpty)
                              ? null
                              : () async {
                                  // Insert_log.Insert_logs(
                                  //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
                                  Invoice_Widget();
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Translate.TranslateAndSetText(
                                      'เรียกดู',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                            ),
                          )),
                      (Await_Status_Report2 == 0)
                          ? SizedBox(
                              // height: 20,
                              child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(4.0),
                                    child: const CircularProgressIndicator()),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      'กำลังโหลดรายงานข้อมูลใบแจ้งหนี้/วางบิลรายวัน...',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                ),
                              ],
                            ))
                          : (InvoiceModels.isEmpty ||
                                  Await_Status_Report2 == null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      (InvoiceModels.isEmpty &&
                                              zone_name_Invoice_Daily != null &&
                                              Await_Status_Report2 != null)
                                          ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน(ไม่พบข้อมูล ✖️)'
                                          : 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน✔️',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 4.0,
                    child: Divider(
                      color: Colors.grey[300],
                      height: 4.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ค้นจาก :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 150,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            value: Status_datexs,

                            alignment: Alignment.center,
                            focusColor: Colors.white,
                            autofocus: false,
                            decoration: InputDecoration(
                              enabled: true,
                              hoverColor: Colors.brown,
                              prefixIconColor: Colors.blue,
                              fillColor: Colors.white.withOpacity(0.05),
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 231, 227, 227),
                                ),
                              ),
                            ),
                            isExpanded: false,
                            // hint: StreamBuilder(
                            //     stream: Stream.periodic(const Duration(seconds: 1)),
                            //     builder: (context, snapshot) {
                            //       return Text(
                            //         Status_pe == null ? 'เลือก' : '$Status_pe',
                            //         maxLines: 2,
                            //         textAlign: TextAlign.center,
                            //         style: const TextStyle(
                            //           overflow: TextOverflow.ellipsis,
                            //           fontSize: 14,
                            //           color: Colors.grey,
                            //         ),
                            //       );
                            //     }),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            iconSize: 20,
                            buttonHeight: 40,
                            buttonWidth: 250,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items: StatusDate.map(
                                (item) => DropdownMenuItem<String>(
                                      value: '${item}',
                                      child: Translate.TranslateAndSetText(
                                          '${item}',
                                          Colors.grey,
                                          TextAlign.center,
                                          FontWeight.w500,
                                          Font_.Fonts_T,
                                          Text_Size,
                                          1),
                                    )).toList(),

                            onChanged: (value) async {
                              int selectedIndex = StatusDate.indexWhere(
                                  (item) => item == value);
                              setState(() {
                                Status_datexs = StatusDate[selectedIndex]!;
                                Status_datexs_ser = '${selectedIndex}';
                              });
                              // print(Status_pe_ser);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'เดือน/ปี :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: Text(''),
                                      content: Container(
                                        height: 300,
                                        child: Column(
                                          children: <Widget>[
                                            getDateRangePicker(3),
                                            MaterialButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ));
                                });
                            // _select_Date_Daily(context);
                          },
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
                              width: 180,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    (Mon_BillAwatCheck_Mon == null ||
                                            YE_BillAwatCheck_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_BillAwatCheck_Mon / $YE_BillAwatCheck_Mon',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size - 2,
                                    1),
                              )),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       color: AppbackgroundColor.Sub_Abg_Colors,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       // border: Border.all(color: Colors.grey, width: 1),
                      //     ),
                      //     width: 120,
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: DropdownButtonFormField2(
                      //       alignment: Alignment.center,
                      //       focusColor: Colors.white,
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         floatingLabelAlignment:
                      //             FloatingLabelAlignment.center,
                      //         enabled: true,
                      //         hoverColor: Colors.brown,
                      //         prefixIconColor: Colors.blue,
                      //         fillColor: Colors.white.withOpacity(0.05),
                      //         filled: false,
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.zero,
                      //         border: OutlineInputBorder(
                      //           borderSide: const BorderSide(color: Colors.red),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.only(
                      //             topRight: Radius.circular(10),
                      //             topLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //           ),
                      //           borderSide: BorderSide(
                      //             width: 1,
                      //             color: Color.fromARGB(255, 231, 227, 227),
                      //           ),
                      //         ),
                      //       ),
                      //       isExpanded: false,
                      //       value: (Mon_BillAwatCheck_Mon == null)
                      //           ? null
                      //           : Mon_BillAwatCheck_Mon,
                      //       // hint: Text(
                      //       //   Mon_Income == null
                      //       //       ? 'เลือก'
                      //       //       : '$Mon_Income',
                      //       //   maxLines: 2,
                      //       //   textAlign: TextAlign.center,
                      //       //   style: const TextStyle(
                      //       //     overflow:
                      //       //         TextOverflow.ellipsis,
                      //       //     fontSize: 14,
                      //       //     color: Colors.grey,
                      //       //   ),
                      //       // ),
                      //       icon: const Icon(
                      //         Icons.arrow_drop_down,
                      //         color: Colors.black,
                      //       ),
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //       ),
                      //       iconSize: 20,
                      //       buttonHeight: 40,
                      //       buttonWidth: 200,
                      //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //       dropdownDecoration: BoxDecoration(
                      //         // color: Colors
                      //         //     .amber,
                      //         borderRadius: BorderRadius.circular(10),
                      //         border: Border.all(color: Colors.white, width: 1),
                      //       ),
                      //       items: [
                      //         for (int item = 1; item < 13; item++)
                      //           DropdownMenuItem<String>(
                      //             value: '${item}',
                      //             child: Translate.TranslateAndSetText(
                      //                 '${monthsInThai[item - 1]}',
                      //                 ReportScreen_Color.Colors_Text1_,
                      //                 TextAlign.center,
                      //                 FontWeight.w500,
                      //                 Font_.Fonts_T,
                      //                 Text_Size,
                      //                 1),
                      //           )
                      //       ],

                      //       onChanged: (value) async {
                      //         setState(() {
                      //           zone_ser_BillAwatCheck_Daily = null;
                      //           zone_name_BillAwatCheck_Daily = null;
                      //           Value_BillAwatCheck_Daily = null;
                      //           Ser_BodySta3 = 0;
                      //           Ser_BodySta4 = 0;
                      //         });
                      //         Mon_BillAwatCheck_Mon = value.toString();
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ปี :',
                      //       ReportScreen_Color.Colors_Text1_,
                      //       TextAlign.center,
                      //       FontWeight.w500,
                      //       Font_.Fonts_T,
                      //       Text_Size,
                      //       1),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       color: AppbackgroundColor.Sub_Abg_Colors,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       // border: Border.all(color: Colors.grey, width: 1),
                      //     ),
                      //     width: 120,
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: DropdownButtonFormField2(
                      //       alignment: Alignment.center,
                      //       focusColor: Colors.white,
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         floatingLabelAlignment:
                      //             FloatingLabelAlignment.center,
                      //         enabled: true,
                      //         hoverColor: Colors.brown,
                      //         prefixIconColor: Colors.blue,
                      //         fillColor: Colors.white.withOpacity(0.05),
                      //         filled: false,
                      //         isDense: true,
                      //         contentPadding: EdgeInsets.zero,
                      //         border: OutlineInputBorder(
                      //           borderSide: const BorderSide(color: Colors.red),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: const OutlineInputBorder(
                      //           borderRadius: BorderRadius.only(
                      //             topRight: Radius.circular(10),
                      //             topLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //           ),
                      //           borderSide: BorderSide(
                      //             width: 1,
                      //             color: Color.fromARGB(255, 231, 227, 227),
                      //           ),
                      //         ),
                      //       ),
                      //       isExpanded: false,
                      //       value: YE_BillAwatCheck_Mon,
                      //       // hint: Text(
                      //       //   YE_Income == null
                      //       //       ? 'เลือก'
                      //       //       : '$YE_Income',
                      //       //   maxLines: 2,
                      //       //   textAlign: TextAlign.center,
                      //       //   style: const TextStyle(
                      //       //     overflow:
                      //       //         TextOverflow.ellipsis,
                      //       //     fontSize: 14,
                      //       //     color: Colors.grey,
                      //       //   ),
                      //       // ),
                      //       icon: const Icon(
                      //         Icons.arrow_drop_down,
                      //         color: Colors.black,
                      //       ),
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //       ),
                      //       iconSize: 20,
                      //       buttonHeight: 40,
                      //       buttonWidth: 200,
                      //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //       dropdownDecoration: BoxDecoration(
                      //         // color: Colors
                      //         //     .amber,
                      //         borderRadius: BorderRadius.circular(10),
                      //         border: Border.all(color: Colors.white, width: 1),
                      //       ),
                      //       items: YE_Th.map((item) => DropdownMenuItem<String>(
                      //             value: '${item}',
                      //             child: Text(
                      //               '${item}',
                      //               // '${int.parse(item) + 543}',
                      //               textAlign: TextAlign.center,
                      //               style: TextStyle(
                      //                 overflow: TextOverflow.ellipsis,
                      //                 fontSize: Text_Size,
                      //                 color: Colors.grey,
                      //               ),
                      //             ),
                      //           )).toList(),

                      //       onChanged: (value) async {
                      //         setState(() {
                      //           zone_ser_BillAwatCheck_Daily = null;
                      //           zone_name_BillAwatCheck_Daily = null;
                      //           Value_BillAwatCheck_Daily = null;
                      //           Ser_BodySta3 = 0;
                      //           Ser_BodySta4 = 0;
                      //         });
                      //         YE_BillAwatCheck_Mon = value.toString();

                      //         // if (Value_Chang_Zone_Income !=
                      //         //     null) {
                      //         //   red_Trans_billIncome();
                      //         //   red_Trans_billMovemen();
                      //         // }
                      //       },
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'โซน :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 300,
                          // padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                                isExpanded: false,
                                searchController: Dropdown_Controller_zone[2],
                                value: (zone_name_BillAwatCheck_Mon == null)
                                    ? null
                                    : zone_name_BillAwatCheck_Mon,
                                alignment: Alignment.center,
                                focusColor: Colors.white,
                                searchInnerWidget: Container(
                                  // width: 200,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red[100]!.withOpacity(0.5),
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
                                    controller: Dropdown_Controller_zone[2],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search...',
                                      // fillColor: Colors.red[300],
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 227, 227),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                hint: (zone_name_BillAwatCheck_Mon == null)
                                    ? null
                                    : Text(
                                        '$zone_name_BillAwatCheck_Mon',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: Text_Size,
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: TextHome_Color.TextHome_Colors,
                                ),
                                style: TextStyle(
                                    fontSize: Text_Size,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                                iconSize: 20,
                                buttonHeight: 35,
                                buttonWidth: 250,
                                dropdownDecoration: BoxDecoration(
                                  // color: Colors.red[100]!.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                //  BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                items: zoneModels_report
                                    .map((item) => DropdownMenuItem<String>(
                                          value: '${item.zn}',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.zn!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: Text_Size,
                                                    fontFamily: Font_.Fonts_T),
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
                                  setState(() {
                                    zone_ser_BillAwatCheck_Daily = null;
                                    zone_name_BillAwatCheck_Daily = null;
                                    Value_BillAwatCheck_Daily = null;
                                    Ser_BodySta3 = 0;
                                    Ser_BodySta4 = 0;
                                  });
                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_BillAwatCheck_Mon = value!;
                                    zone_ser_BillAwatCheck_Mon =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_ser_BillAwatCheck_Mon  //${zone_name_BillAwatCheck_Mon}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[2].clear();
                                  }
                                }),
                          ),

                          // DropdownButtonFormField2(
                          //   value: zone_name_BillAwatCheck_Mon,
                          //   alignment: Alignment.center,
                          //   focusColor: Colors.white,
                          //   autofocus: false,
                          //   decoration: InputDecoration(
                          //     enabled: true,
                          //     hoverColor: Colors.brown,
                          //     prefixIconColor: Colors.blue,
                          //     fillColor: Colors.white.withOpacity(0.05),
                          //     filled: false,
                          //     isDense: true,
                          //     contentPadding: EdgeInsets.zero,
                          //     border: OutlineInputBorder(
                          //       borderSide: const BorderSide(color: Colors.red),
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     focusedBorder: const OutlineInputBorder(
                          //       borderRadius: BorderRadius.only(
                          //         topRight: Radius.circular(10),
                          //         topLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //       ),
                          //       borderSide: BorderSide(
                          //         width: 1,
                          //         color: Color.fromARGB(255, 231, 227, 227),
                          //       ),
                          //     ),
                          //   ),
                          //   isExpanded: false,

                          //   icon: const Icon(
                          //     Icons.arrow_drop_down,
                          //     color: Colors.black,
                          //   ),
                          //   style: const TextStyle(
                          //     color: Colors.grey,
                          //   ),
                          //   iconSize: 20,
                          //   buttonHeight: 40,
                          //   buttonWidth: 250,
                          //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                          //   dropdownDecoration: BoxDecoration(
                          //     // color: Colors
                          //     //     .amber,
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.white, width: 1),
                          //   ),
                          //   items: zoneModels_report
                          //       .map((item) => DropdownMenuItem<String>(
                          //             value: '${item.zn}',
                          //             child: Text(
                          //               '${item.zn}',
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                 overflow: TextOverflow.ellipsis,
                          //                 fontSize: 14,
                          //                 color: Colors.grey,
                          //               ),
                          //             ),
                          //           ))
                          //       .toList(),

                          //   onChanged: (value) async {
                          //     setState(() {
                          //       zone_ser_BillAwatCheck_Daily = null;
                          //       zone_name_BillAwatCheck_Daily = null;
                          //       Value_BillAwatCheck_Daily = null;
                          //       Ser_BodySta3 = 0;
                          //       Ser_BodySta4 = 0;
                          //     });
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_BillAwatCheck_Mon = value!;
                          //       zone_ser_BillAwatCheck_Mon =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_ser_BillAwatCheck_Mon  //${zone_name_BillAwatCheck_Mon}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              Type_search = 'Mon';
                              Ser_BodySta3 = 1;
                            });

                            if (Mon_BillAwatCheck_Mon != null &&
                                YE_BillAwatCheck_Mon != null &&
                                zone_name_BillAwatCheck_Mon != null &&
                                Ser_BodySta3 == 1) {
                              setState(() {
                                Await_Status_Report3 = 0;
                              });
                              Dia_log();
                              red_Trans_bill_Mon();
                            }

                            // red_Trans_c_maintenance();
                          },
                          child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    'ค้นหา',
                                    Colors.white,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                            onTap: (Ser_BodySta3 == 1)
                                ? () async {
                                    // Insert_log.Insert_logs(
                                    //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
                                    TransIncomeBillAwatCheck_Widget();
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[600],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Translate.TranslateAndSetText(
                                        'เรียกดู',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                    Icon(
                                      Icons.navigate_next,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            )),
                        (Ser_BodySta3 != 1)
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'รายงานประวัติชำระรอตรวจสอบ',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (TransReBillModels_.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (TransReBillModels_.isEmpty &&
                                                Value_BillAwatCheck_Daily !=
                                                    null &&
                                                Ser_BodySta3 == 1)
                                            ? 'รายงานประวัติชำระรอตรวจสอบ (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานประวัติชำระรอตรวจสอบ',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                  )
                                : (Await_Status_Report3 != null &&
                                        Ser_BodySta3 == 1)
                                    ? SizedBox(
                                        // height: 20,
                                        child: Row(
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  const CircularProgressIndicator()),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Translate.TranslateAndSetText(
                                                'กำลังโหลดรายงานประวัติชำระรอตรวจสอบ...',
                                                ReportScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.center,
                                                FontWeight.w500,
                                                Font_.Fonts_T,
                                                Text_Size,
                                                1),
                                          ),
                                        ],
                                      ))
                                    : (TransReBillModels_.length != 0 &&
                                            Await_Status_Report3 == 1 &&
                                            Ser_BodySta3 == 1)
                                        ? SizedBox(
                                            // height: 20,
                                            child: Row(
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child:
                                                      const CircularProgressIndicator()),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'รายงานประวัติชำระรอตรวจสอบ...',
                                                        ReportScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.w500,
                                                        Font_.Fonts_T,
                                                        Text_Size,
                                                        1),
                                              ),
                                            ],
                                          ))
                                        : Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Translate.TranslateAndSetText(
                                                'รายงานประวัติชำระรอตรวจสอบ ✔️',
                                                ReportScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.center,
                                                FontWeight.w500,
                                                Font_.Fonts_T,
                                                Text_Size,
                                                1),
                                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 4.0,
                    child: Divider(
                      color: Colors.grey[300],
                      height: 4.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'วันที่ :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      actionsPadding: const EdgeInsets.all(6.0),
                                      title: Text(''),
                                      content: Container(
                                        height: 300,
                                        child: Column(
                                          children: <Widget>[
                                            getDateRangePicker(4),
                                            MaterialButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ));
                                });
                            // _select_Date_Daily(context);
                          },
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
                              width: 180,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    (Value_BillAwatCheck_Daily == null)
                                        ? 'เลือก'
                                        : '$Value_BillAwatCheck_Daily',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size - 2,
                                    1),
                              )),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: InkWell(
                      //     onTap: () {
                      //       _select_Date_DailyBillAwatCheck(context);
                      //     },
                      //     child: Container(
                      //         decoration: BoxDecoration(
                      //           color: AppbackgroundColor.Sub_Abg_Colors,
                      //           borderRadius: const BorderRadius.only(
                      //               topLeft: Radius.circular(10),
                      //               topRight: Radius.circular(10),
                      //               bottomLeft: Radius.circular(10),
                      //               bottomRight: Radius.circular(10)),
                      //           border:
                      //               Border.all(color: Colors.grey, width: 1),
                      //         ),
                      //         width: 120,
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Center(
                      //           child: Translate.TranslateAndSetText(
                      //               (Value_BillAwatCheck_Daily == null)
                      //                   ? 'เลือก'
                      //                   : '$Value_BillAwatCheck_Daily',
                      //               ReportScreen_Color.Colors_Text1_,
                      //               TextAlign.center,
                      //               FontWeight.w500,
                      //               Font_.Fonts_T,
                      //               Text_Size,
                      //               1),
                      //         )),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'โซน :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 300,
                          // padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                                isExpanded: false,
                                searchController: Dropdown_Controller_zone[3],
                                value: (zone_name_BillAwatCheck_Daily == null)
                                    ? null
                                    : zone_name_BillAwatCheck_Daily,
                                alignment: Alignment.center,
                                focusColor: Colors.white,
                                searchInnerWidget: Container(
                                  // width: 200,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.red[100]!.withOpacity(0.5),
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
                                    controller: Dropdown_Controller_zone[3],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search...',
                                      // fillColor: Colors.red[300],
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 231, 227, 227),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                hint: (zone_name_BillAwatCheck_Daily == null)
                                    ? null
                                    : Text(
                                        '$zone_name_BillAwatCheck_Daily',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: Text_Size,
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: TextHome_Color.TextHome_Colors,
                                ),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                                iconSize: 20,
                                buttonHeight: 35,
                                buttonWidth: 250,
                                dropdownDecoration: BoxDecoration(
                                  // color: Colors.red[100]!.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                //  BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                items: zoneModels_report
                                    .map((item) => DropdownMenuItem<String>(
                                          value: '${item.zn}',
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.zn!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: Text_Size,
                                                    fontFamily: Font_.Fonts_T),
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
                                  setState(() {
                                    zone_ser_BillAwatCheck_Mon = null;
                                    zone_name_BillAwatCheck_Mon = null;
                                    Mon_BillAwatCheck_Mon = null;
                                    YE_BillAwatCheck_Mon = null;
                                    Ser_BodySta3 = 0;
                                    Ser_BodySta4 = 0;
                                  });

                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_BillAwatCheck_Daily =
                                        value.toString();
                                    zone_ser_BillAwatCheck_Daily =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_name_BillAwatCheck_Daily  //${zone_ser_BillAwatCheck_Daily}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[3].clear();
                                  }
                                }),
                          ),
                          // DropdownButtonFormField2(
                          //   value: zone_name_BillAwatCheck_Daily,
                          //   alignment: Alignment.center,
                          //   focusColor: Colors.white,
                          //   autofocus: false,
                          //   decoration: InputDecoration(
                          //     enabled: true,
                          //     hoverColor: Colors.brown,
                          //     prefixIconColor: Colors.blue,
                          //     fillColor: Colors.white.withOpacity(0.05),
                          //     filled: false,
                          //     isDense: true,
                          //     contentPadding: EdgeInsets.zero,
                          //     border: OutlineInputBorder(
                          //       borderSide: const BorderSide(color: Colors.red),
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     focusedBorder: const OutlineInputBorder(
                          //       borderRadius: BorderRadius.only(
                          //         topRight: Radius.circular(10),
                          //         topLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //       ),
                          //       borderSide: BorderSide(
                          //         width: 1,
                          //         color: Color.fromARGB(255, 231, 227, 227),
                          //       ),
                          //     ),
                          //   ),
                          //   isExpanded: false,

                          //   icon: const Icon(
                          //     Icons.arrow_drop_down,
                          //     color: Colors.black,
                          //   ),
                          //   style: const TextStyle(
                          //     color: Colors.grey,
                          //   ),
                          //   iconSize: 20,
                          //   buttonHeight: 40,
                          //   buttonWidth: 250,
                          //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                          //   dropdownDecoration: BoxDecoration(
                          //     // color: Colors
                          //     //     .amber,
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(color: Colors.white, width: 1),
                          //   ),
                          //   items: zoneModels_report
                          //       .map((item) => DropdownMenuItem<String>(
                          //             value: '${item.zn}',
                          //             child: Text(
                          //               '${item.zn}',
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                 overflow: TextOverflow.ellipsis,
                          //                 fontSize: 14,
                          //                 color: Colors.grey,
                          //               ),
                          //             ),
                          //           ))
                          //       .toList(),

                          //   onChanged: (value) async {
                          //     setState(() {
                          //       zone_ser_BillAwatCheck_Mon = null;
                          //       zone_name_BillAwatCheck_Mon = null;
                          //       Mon_BillAwatCheck_Mon = null;
                          //       YE_BillAwatCheck_Mon = null;
                          //       Ser_BodySta3 = 0;
                          //       Ser_BodySta4 = 0;
                          //     });

                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_BillAwatCheck_Daily =
                          //           value.toString();
                          //       zone_ser_BillAwatCheck_Daily =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_name_BillAwatCheck_Daily  //${zone_ser_BillAwatCheck_Daily}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              Type_search = 'Daily';
                              Ser_BodySta4 = 1;
                            });
                            if (Ser_BodySta4 == 1 &&
                                zone_ser_BillAwatCheck_Daily != null &&
                                Value_BillAwatCheck_Daily != null) {
                              Dia_log();
                              red_Trans_bill_Daily();
                            }
                          },
                          child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Translate.TranslateAndSetText(
                                    'ค้นหา',
                                    Colors.white,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                            onTap: (Ser_BodySta4 == 1)
                                ? () async {
                                    // Insert_log.Insert_logs(
                                    //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
                                    TransIncomeBillAwatCheck_Widget();
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[600],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Translate.TranslateAndSetText(
                                        'เรียกดู',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                    Icon(
                                      Icons.navigate_next,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            )),
                        (Ser_BodySta4 != 1)
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'รายงานประวัติชำระรอตรวจสอบรายวัน',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (TransReBillModels_.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (TransReBillModels_.isEmpty &&
                                                Value_BillAwatCheck_Daily !=
                                                    null &&
                                                Ser_BodySta4 == 1)
                                            ? 'รายงานประวัติชำระรอตรวจสอบรายวัน (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานประวัติชำระรอตรวจสอบรายวัน',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                  )
                                : (Await_Status_Report4 != null &&
                                        Ser_BodySta4 == 1)
                                    ? SizedBox(
                                        // height: 20,
                                        child: Row(
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  const CircularProgressIndicator()),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Translate.TranslateAndSetText(
                                                'กำลังโหลดรายงานประวัติชำระรอตรวจสอบรายวัน...',
                                                ReportScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.center,
                                                FontWeight.w500,
                                                Font_.Fonts_T,
                                                Text_Size,
                                                1),
                                          ),
                                        ],
                                      ))
                                    : (TransReBillModels_.length != 0 &&
                                            Await_Status_Report4 == 1 &&
                                            Ser_BodySta4 == 1)
                                        ? SizedBox(
                                            // height: 20,
                                            child: Row(
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child:
                                                      const CircularProgressIndicator()),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'รายงานประวัติชำระรอตรวจสอบรายวัน...',
                                                        ReportScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.w500,
                                                        Font_.Fonts_T,
                                                        Text_Size,
                                                        1),
                                              ),
                                            ],
                                          ))
                                        : Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Translate.TranslateAndSetText(
                                                'รายงานประวัติชำระรอตรวจสอบรายวัน ✔️',
                                                ReportScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.center,
                                                FontWeight.w500,
                                                Font_.Fonts_T,
                                                Text_Size,
                                                1),
                                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ])));
  }

  Dia_log3() {
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

///////////////-------------------------------->
  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(const Duration(milliseconds: 3600), () {
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

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext builderContext) {
    //       Timer(Duration(seconds: 3), () {
    //         Navigator.of(context).pop();
    //       });

    //       return AlertDialog(
    //         backgroundColor: Colors.transparent,
    //         elevation: 0,
    //         content: Container(
    //           child: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         ),
    //       );
    //     });
  }

  ///////////////////////////----------------------------------------------->(รายงานInvoice)
  Invoice_Widget() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
            children: [
              //Mon_transMeter_Mon  YE_transMeter_Mon
              Center(
                  child: (Ser_BodySta1 == 1)
                      ? Text(
                          (zone_name_Invoice_Mon == null)
                              ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิลรายเดือน (กรุณาเลือกโซน)'
                              : 'รายงานข้อมูลใบแจ้งหนี้/วางบิลรายเดือน (โซน : $zone_name_Invoice_Mon) ',
                          style: const TextStyle(
                            color: ReportScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        )
                      : Text(
                          (zone_name_Invoice_Daily == null)
                              ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิลรายวัน (กรุณาเลือกโซน)'
                              : 'รายงานข้อมูลใบแจ้งหนี้/วางบิลรายวัน (โซน : $zone_name_Invoice_Daily) ',
                          style: const TextStyle(
                            color: ReportScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        )),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        (Ser_BodySta1 == 1)
                            ? (Mon_Invoice_Mon == null &&
                                    YE_Invoice_Mon == null)
                                ? 'เดือน : ? (?) '
                                : (Mon_Invoice_Mon == null)
                                    ? 'เดือน : ? ($YE_Invoice_Mon) '
                                    : (YE_Invoice_Mon == null)
                                        ? 'เดือน : $Mon_Invoice_Mon (?) '
                                        : 'เดือน : $Mon_Invoice_Mon ($YE_Invoice_Mon) '
                            : (Value_InvoiceDate_Daily == null)
                                ? 'วันที่ :  (?) '
                                : 'วันที่ : $Value_InvoiceDate_Daily ',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ReportScreen_Color.Colors_Text1_,
                          // fontWeight: FontWeight.bold, Value_InvoiceDate_Daily
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'ทั้งหมด: ${InvoiceModels.length}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ReportScreen_Color.Colors_Text1_,
                          // fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            AppbackgroundColor.TiTile_Colors.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      width: 220,
                      // height: 30,
                      padding: const EdgeInsets.all(2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'เลือกค่าบริการ ที่จะแสดง',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ReportScreen_Color.Colors_Text1_,
                              // fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          items: expModels.map((item) {
                            return DropdownMenuItem(
                              value: item.ser,
                              //disable default onTap to avoid closing menu when selecting an item
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  // final isSelected = selectedItems.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      int selectedIndex = expModels.indexWhere(
                                          (items) => items.ser == item.ser);
                                      //     print(expModels[selectedIndex].expname);
                                      // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                      //This rebuilds the StatefulWidget to update the button's text
                                      setState(() {
                                        if (item.st! == '1') {
                                          expModels[selectedIndex].st = '0';
                                        } else {
                                          expModels[selectedIndex].st = '1';
                                        }
                                      });
                                      //This rebuilds the dropdownMenu Widget to update the check mark
                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          if (item.st! == '1')
                                            Icon(
                                              Icons.check_box_outlined,
                                              color: Colors.green[400],
                                            )
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item.expname!,
                                              style: const TextStyle(
                                                fontSize: 14,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            AppbackgroundColor.TiTile_Colors.withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      width: 200,
                      height: 30,
                      padding: const EdgeInsets.all(2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'เลือกค่า VAT ที่จะแสดง',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ReportScreen_Color.Colors_Text1_,
                              // fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                          items: [
                            for (int index = 0;
                                index < Type_vat.length;
                                index++)
                              DropdownMenuItem(
                                value: Type_vat[index]["ser"],
                                //disable default onTap to avoid closing menu when selecting an item
                                enabled: false,
                                child: StatefulBuilder(
                                  builder: (context, menuSetState) {
                                    // final isSelected = selectedItems.contains(item);
                                    return InkWell(
                                      onTap: () {
                                        // int selectedIndex =
                                        //     Type_vat.indexWhere(
                                        //         (items) =>
                                        //             items.ser ==
                                        //             Type_vat[index]
                                        //                 .ser);

                                        // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                        //This rebuilds the StatefulWidget to update the button's text
                                        setState(() {
                                          if (Type_vat[index]["st"]! == '1') {
                                            Type_vat[index]["st"] = '0';
                                          } else {
                                            Type_vat[index]["st"] = '1';
                                          }
                                        });
                                        //This rebuilds the dropdownMenu Widget to update the check mark
                                        menuSetState(() {});
                                      },
                                      child: Container(
                                        height: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            if (Type_vat[index]["st"]! == '1')
                                              Icon(
                                                Icons.check_box_outlined,
                                                color: Colors.green[400],
                                              )
                                            else
                                              const Icon(Icons
                                                  .check_box_outline_blank),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                Type_vat[index]["pn"]!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              const Divider(),
              const SizedBox(height: 1),
              Container(
                width: MediaQuery.of(context).size.width,
                // padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Expanded(child: _searchBar_ChoArea()),
                  ],
                ),
              ),
            ],
          ),
          content: StreamBuilder(
              stream:
                  Stream<void>.periodic(const Duration(seconds: 3), (i) => i)
                      .take(3),
              // stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          // color: Colors.grey[50],
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 1.2
                              : (InvoiceModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1400,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (InvoiceModels.length == 0)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'ไม่พบข้อมูล',
                                        style: TextStyle(
                                          color:
                                              ReportScreen_Color.Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      // width: 1050,
                                      decoration: BoxDecoration(
                                        color: AppbackgroundColor.TiTile_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          // Expanded(
                                          //   flex: 3,
                                          //   child: Text(
                                          //     'บริษัท',
                                          //     textAlign: TextAlign.start,
                                          //     style: TextStyle(
                                          //       color: ManageScreen_Color
                                          //           .Colors_Text1_,
                                          //       fontWeight: FontWeight.bold,
                                          //       fontFamily: FontWeight_.Fonts_T,
                                          //     ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'เลขที่รับชำระ',
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'เลขที่ใบแจ้งหนี้',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Text(
                                          //     'สถานะ',
                                          //     textAlign: TextAlign.start,
                                          //     style: TextStyle(
                                          //       color: ManageScreen_Color
                                          //           .Colors_Text1_,
                                          //       fontWeight: FontWeight.bold,
                                          //       fontFamily: FontWeight_.Fonts_T,
                                          //     ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'วันที่ออกใบแจ้งหนี้',
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'วันที่ครบกำหนด',
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ชื่อลูกค้า',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'รอบการเช่า',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'โซน',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ล็อค',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          // for (int index = 0;
                                          //     index < expModels.length;
                                          //     index++)
                                          //   Expanded(
                                          //     flex: 3,
                                          //     child: Padding(
                                          //       padding:
                                          //           const EdgeInsets.fromLTRB(
                                          //               2, 0, 2, 0),
                                          //       child: Row(
                                          //         children: [
                                          //           Expanded(
                                          //             flex: 1,
                                          //             child: Container(
                                          //               color: Colors
                                          //                   .deepPurple[200]!
                                          //                   .withOpacity(0.5),
                                          //               padding:
                                          //                   const EdgeInsets
                                          //                       .all(3.0),
                                          //               child: Text(
                                          //                 'QTY',
                                          //                 textAlign:
                                          //                     TextAlign.end,
                                          //                 style: TextStyle(
                                          //                   color: ManageScreen_Color
                                          //                       .Colors_Text1_,
                                          //                   fontWeight:
                                          //                       FontWeight.bold,
                                          //                   fontFamily:
                                          //                       FontWeight_
                                          //                           .Fonts_T,
                                          //                 ),
                                          //               ),
                                          //             ),
                                          //           ),
                                          //           Expanded(
                                          //             flex: 2,
                                          //             child: Container(
                                          //               color: Colors
                                          //                   .deepPurple[300]!
                                          //                   .withOpacity(0.6),
                                          //               padding:
                                          //                   const EdgeInsets
                                          //                       .all(3.0),
                                          //               child: Text(
                                          //                 '${expModels[index].expname}',
                                          //                 textAlign:
                                          //                     TextAlign.end,
                                          //                 style: TextStyle(
                                          //                   color: ManageScreen_Color
                                          //                       .Colors_Text1_,
                                          //                   fontWeight:
                                          //                       FontWeight.bold,
                                          //                   fontFamily:
                                          //                       FontWeight_
                                          //                           .Fonts_T,
                                          //                 ),
                                          //               ),
                                          //             ),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ภาษีมูลค่าเพิ่ม',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ภาษีหัก ณ ที่จ่าย',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ส่วนลด',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ยอดรวม',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'ยอดสุทธิ',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              color: Colors.green[300]!
                                                  .withOpacity(0.6),
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                'ค่าปรับ-รับชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              color: Colors.green[300]!
                                                  .withOpacity(0.6),
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                'ส่วนลด-รับชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              color: Colors.green[300]!
                                                  .withOpacity(0.6),
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                'ยอดสุทธิ-รับชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'หมายเหตุ',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        // height: (Responsive.isDesktop(context))
                                        //     ? MediaQuery.of(context).size.width * 0.255
                                        //     : MediaQuery.of(context).size.height * 0.45,
                                        child: ListView.builder(
                                      itemCount: InvoiceModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Material(
                                          color: (show_more == index)
                                              ? tappedIndex_Color
                                                  .tappedIndex_Colors
                                                  .withOpacity(0.5)
                                              : AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                          child: ListTile(
                                            onTap: () {
                                              // setState(() {
                                              //   show_more = index;
                                              // });
                                            },
                                            title: Container(
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
                                                // Expanded(
                                                //   flex: 3,
                                                //   child: Text(
                                                //     '${renTal_name}',
                                                //     textAlign: TextAlign.start,
                                                //     overflow:
                                                //         TextOverflow.ellipsis,
                                                //     style: const TextStyle(
                                                //       color: ManageScreen_Color
                                                //           .Colors_Text2_,
                                                //       // fontWeight: FontWeight.bold,
                                                //       fontFamily: Font_.Fonts_T,
                                                //       //fontSize: 10.0
                                                //     ),
                                                //   ),
                                                // ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .docno ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .docno
                                                                    .toString() ==
                                                                '')
                                                        ? 'รอชำระ'
                                                        : (InvoiceModels[index]
                                                                        .doctax ==
                                                                    null ||
                                                                InvoiceModels[
                                                                            index]
                                                                        .doctax
                                                                        .toString() ==
                                                                    '')
                                                            ? '${InvoiceModels[index].docno}'
                                                            : '${InvoiceModels[index].doctax}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: (InvoiceModels[
                                                                          index]
                                                                      .docno ==
                                                                  null ||
                                                              InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString() ==
                                                                  '')
                                                          ? Colors.orange[600]
                                                          : (InvoiceModels[
                                                                          index]
                                                                      .pos
                                                                      .toString() ==
                                                                  '1')
                                                              ? Colors
                                                                  .orange[600]
                                                              : ManageScreen_Color
                                                                  .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    '${InvoiceModels[index].inv}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      //fontSize: 10.0
                                                    ),
                                                  ),
                                                ),
                                                // const Expanded(
                                                //   flex: 1,
                                                //   child: Text(
                                                //     '-',
                                                //     textAlign: TextAlign.start,
                                                //     overflow:
                                                //         TextOverflow.ellipsis,
                                                //     style: TextStyle(
                                                //       color: ManageScreen_Color
                                                //           .Colors_Text2_,
                                                //       // fontWeight: FontWeight.bold,
                                                //       fontFamily: Font_.Fonts_T,
                                                //       //fontSize: 10.0
                                                //     ),
                                                //   ),
                                                // ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .date ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .daterec
                                                                    .toString() ==
                                                                '')
                                                        ? '${InvoiceModels[index].daterec}'
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))}-${DateTime.parse('${InvoiceModels[index].daterec}').year + 543}',
                                                    //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      // fontSize: 12.0
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .date ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .date
                                                                    .toString() ==
                                                                '')
                                                        ? '${InvoiceModels[index].date}'
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].date}'))}-${DateTime.parse('${InvoiceModels[index].date}').year + 543}',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      // fontSize: 12.0
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .scname ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .scname
                                                                    .toString() ==
                                                                '-')
                                                        ? '${InvoiceModels[index].cname}'
                                                        : '${InvoiceModels[index].scname}',
                                                    // '${transMeterModels[index].ovalue}',
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      //fontSize: 12.0
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .date ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .date
                                                                    .toString() ==
                                                                '')
                                                        ? '${InvoiceModels[index].date}'
                                                        : '${DateFormat('MMM', 'th_TH').format(DateTime.parse('${InvoiceModels[index].date}'))} ${DateTime.parse('${InvoiceModels[index].date}').year + 543}',
                                                    // '${transMeterModels[index].nvalue}',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                      // fontSize: 12.0
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${InvoiceModels[index].zn}',
                                                    maxLines: 2,
                                                    //'${transMeterModels[index].qty}',
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${InvoiceModels[index].ln}',
                                                    //'${transMeterModels[index].qty}',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                // for (int index2 = 0;
                                                //     index2 < expModels.length;
                                                //     index2++)
                                                //   Expanded(
                                                //     flex: 3,
                                                //     child: Padding(
                                                //       padding: const EdgeInsets
                                                //           .fromLTRB(1, 0, 1, 0),
                                                //       child: Container(
                                                //         decoration:
                                                //             BoxDecoration(
                                                //           border: Border(
                                                //             right: BorderSide(
                                                //                 color: Colors
                                                //                     .grey),
                                                //             // left: BorderSide(
                                                //             //     color: Colors
                                                //             //         .grey),
                                                //           ),
                                                //         ),
                                                //         child: Row(
                                                //           children: [
                                                //             Expanded(
                                                //               flex: 1,
                                                //               child:
                                                //                   FutureBuilder<
                                                //                       String>(
                                                //                 future: read_QtyGCExpSer(
                                                //                     index,
                                                //                     expModels[
                                                //                             index2]
                                                //                         .ser),
                                                //                 initialData:
                                                //                     '0', // Set an initial value as a string
                                                //                 builder: (BuildContext
                                                //                         context,
                                                //                     AsyncSnapshot<
                                                //                             String>
                                                //                         snapshot) {
                                                //                   if (snapshot
                                                //                           .connectionState ==
                                                //                       ConnectionState
                                                //                           .waiting) {
                                                //                     return Row(
                                                //                       mainAxisAlignment:
                                                //                           MainAxisAlignment
                                                //                               .center,
                                                //                       children: [
                                                //                         SizedBox(
                                                //                           height:
                                                //                               50,
                                                //                           child:
                                                //                               CircularProgressIndicator(),
                                                //                         ),
                                                //                       ],
                                                //                     );
                                                //                   } else if (snapshot
                                                //                       .hasError) {
                                                //                     return Text(
                                                //                         'Error: ${snapshot.error}');
                                                //                   } else {
                                                //                     return Text(
                                                //                       snapshot.data ??
                                                //                           '', // Display the result or an empty string if null
                                                //                       // maxLines: 1,
                                                //                       textAlign:
                                                //                           TextAlign
                                                //                               .end,
                                                //                       style:
                                                //                           const TextStyle(
                                                //                         color: PeopleChaoScreen_Color
                                                //                             .Colors_Text2_,
                                                //                         fontFamily:
                                                //                             Font_.Fonts_T,
                                                //                       ),
                                                //                     );
                                                //                   }
                                                //                 },
                                                //               ),
                                                //             ),
                                                //             Expanded(
                                                //               flex: 2,
                                                //               child:
                                                //                   FutureBuilder<
                                                //                       String>(
                                                //                 future: read_SumGCExpSer(
                                                //                     index,
                                                //                     expModels[
                                                //                             index2]
                                                //                         .ser),
                                                //                 initialData:
                                                //                     '0', // Set an initial value as a string
                                                //                 builder: (BuildContext
                                                //                         context,
                                                //                     AsyncSnapshot<
                                                //                             String>
                                                //                         snapshot) {
                                                //                   if (snapshot
                                                //                           .connectionState ==
                                                //                       ConnectionState
                                                //                           .waiting) {
                                                //                     return Row(
                                                //                       mainAxisAlignment:
                                                //                           MainAxisAlignment
                                                //                               .center,
                                                //                       children: [
                                                //                         SizedBox(
                                                //                           height:
                                                //                               50,
                                                //                           child:
                                                //                               CircularProgressIndicator(),
                                                //                         ),
                                                //                       ],
                                                //                     );
                                                //                   } else if (snapshot
                                                //                       .hasError) {
                                                //                     return Text(
                                                //                         'Error: ${snapshot.error}');
                                                //                   } else {
                                                //                     return Text(
                                                //                       snapshot.data ??
                                                //                           '', // Display the result or an empty string if null
                                                //                       // maxLines: 1,
                                                //                       textAlign:
                                                //                           TextAlign
                                                //                               .end,
                                                //                       style:
                                                //                           const TextStyle(
                                                //                         color: PeopleChaoScreen_Color
                                                //                             .Colors_Text2_,
                                                //                         fontFamily:
                                                //                             Font_.Fonts_T,
                                                //                       ),
                                                //                     );
                                                //                   }
                                                //                 },
                                                //               ),
                                                //             ),
                                                //           ],
                                                //         ),
                                                //       ),
                                                //     ),
                                                //   ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                .total_vat ==
                                                            null)
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(InvoiceModels[index].total_vat.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                  // FutureBuilder<String>(
                                                  //   future:
                                                  //       read_SumGCExpWht(index),
                                                  //   initialData:
                                                  //       '0', // Set an initial value as a string
                                                  //   builder: (BuildContext
                                                  //           context,
                                                  //       AsyncSnapshot<String>
                                                  //           snapshot) {
                                                  //     if (snapshot
                                                  //             .connectionState ==
                                                  //         ConnectionState
                                                  //             .waiting) {
                                                  //       return Row(
                                                  //         mainAxisAlignment:
                                                  //             MainAxisAlignment
                                                  //                 .center,
                                                  //         children: [
                                                  //           SizedBox(
                                                  //             height: 50,
                                                  //             child:
                                                  //                 CircularProgressIndicator(),
                                                  //           ),
                                                  //         ],
                                                  //       );
                                                  //     } else if (snapshot
                                                  //         .hasError) {
                                                  //       return Text(
                                                  //           'Error: ${snapshot.error}');
                                                  //     } else {
                                                  //       return Text(
                                                  //         snapshot.data ??
                                                  //             '', // Display the result or an empty string if null
                                                  //         // maxLines: 1,
                                                  //         textAlign:
                                                  //             TextAlign.end,
                                                  //         style:
                                                  //             const TextStyle(
                                                  //           color: PeopleChaoScreen_Color
                                                  //               .Colors_Text2_,
                                                  //           fontFamily:
                                                  //               Font_.Fonts_T,
                                                  //         ),
                                                  //       );
                                                  //     }
                                                  //   },
                                                  // ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                .total_wht ==
                                                            null)
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(InvoiceModels[index].total_wht.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                  // FutureBuilder<String>(
                                                  //   future: read_SumGCExpNWht(
                                                  //       index),
                                                  //   initialData:
                                                  //       '0', // Set an initial value as a string
                                                  //   builder: (BuildContext
                                                  //           context,
                                                  //       AsyncSnapshot<String>
                                                  //           snapshot) {
                                                  //     if (snapshot
                                                  //             .connectionState ==
                                                  //         ConnectionState
                                                  //             .waiting) {
                                                  //       return Row(
                                                  //         mainAxisAlignment:
                                                  //             MainAxisAlignment
                                                  //                 .center,
                                                  //         children: [
                                                  //           SizedBox(
                                                  //             height: 20,
                                                  //             child:
                                                  //                 CircularProgressIndicator(),
                                                  //           ),
                                                  //         ],
                                                  //       );
                                                  //     } else if (snapshot
                                                  //         .hasError) {
                                                  //       return Text(
                                                  //           'Error: ${snapshot.error}');
                                                  //     } else {
                                                  //       return Text(
                                                  //         snapshot.data ??
                                                  //             '', // Display the result or an empty string if null
                                                  //         // maxLines: 1,
                                                  //         textAlign:
                                                  //             TextAlign.end,
                                                  //         style:
                                                  //             const TextStyle(
                                                  //           color: PeopleChaoScreen_Color
                                                  //               .Colors_Text2_,
                                                  //           fontFamily:
                                                  //               Font_.Fonts_T,
                                                  //         ),
                                                  //       );
                                                  //     }
                                                  //   },
                                                  // ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .amt_dis ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .amt_dis
                                                                    .toString() ==
                                                                '')
                                                        ? '0.00'
                                                        : '${InvoiceModels[index].amt_dis}',
                                                    // '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()) - double.parse(InvoiceModels[index].total_dis.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                .total_bill ==
                                                            null)
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                .total_dis ==
                                                            null)
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(InvoiceModels[index].total_dis.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .docno ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .docno
                                                                    .toString() ==
                                                                '')
                                                        ? 'รอชำระ'
                                                        : (InvoiceModels[index]
                                                                    .pos
                                                                    .toString() ==
                                                                '1')
                                                            ? 'รอตวรจสอบชำระ'
                                                            : (InvoiceModels[index]
                                                                            .pay_fine ==
                                                                        null ||
                                                                    InvoiceModels[index]
                                                                            .pay_fine
                                                                            .toString() ==
                                                                        '')
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(InvoiceModels[index].pay_fine.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: (InvoiceModels[
                                                                          index]
                                                                      .docno ==
                                                                  null ||
                                                              InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString() ==
                                                                  '')
                                                          ? Colors.orange[600]
                                                          : (InvoiceModels[
                                                                          index]
                                                                      .pos
                                                                      .toString() ==
                                                                  '1')
                                                              ? Colors
                                                                  .orange[600]
                                                              : ManageScreen_Color
                                                                  .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .docno ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .docno
                                                                    .toString() ==
                                                                '')
                                                        ? 'รอชำระ'
                                                        : (InvoiceModels[index]
                                                                    .pos
                                                                    .toString() ==
                                                                '1')
                                                            ? 'รอตวรจสอบชำระ'
                                                            : (InvoiceModels[index]
                                                                            .pay_dis ==
                                                                        null ||
                                                                    InvoiceModels[index]
                                                                            .pay_dis
                                                                            .toString() ==
                                                                        '')
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(InvoiceModels[index].pay_dis.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: (InvoiceModels[
                                                                          index]
                                                                      .docno ==
                                                                  null ||
                                                              InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString() ==
                                                                  '')
                                                          ? Colors.orange[600]
                                                          : (InvoiceModels[
                                                                          index]
                                                                      .pos
                                                                      .toString() ==
                                                                  '1')
                                                              ? Colors
                                                                  .orange[600]
                                                              : ManageScreen_Color
                                                                  .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (InvoiceModels[index]
                                                                    .docno ==
                                                                null ||
                                                            InvoiceModels[index]
                                                                    .docno
                                                                    .toString() ==
                                                                '')
                                                        ? 'รอชำระ'
                                                        : (InvoiceModels[index]
                                                                    .pos
                                                                    .toString() ==
                                                                '1')
                                                            ? 'รอตวรจสอบชำระ'
                                                            : (InvoiceModels[index]
                                                                            .paytotal_dis ==
                                                                        null ||
                                                                    InvoiceModels[index]
                                                                            .paytotal_dis
                                                                            .toString() ==
                                                                        '')
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(InvoiceModels[index].paytotal_dis.toString()))}',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: (InvoiceModels[
                                                                          index]
                                                                      .docno ==
                                                                  null ||
                                                              InvoiceModels[
                                                                          index]
                                                                      .docno
                                                                      .toString() ==
                                                                  '')
                                                          ? Colors.orange[600]
                                                          : (InvoiceModels[
                                                                          index]
                                                                      .pos
                                                                      .toString() ==
                                                                  '1')
                                                              ? Colors
                                                                  .orange[600]
                                                              : ManageScreen_Color
                                                                  .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${InvoiceModels[index].remark}',
                                                    //'${transMeterModels[index].c_amt}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          actions: <Widget>[
            const SizedBox(height: 1),
            const Divider(),
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (InvoiceModels.length != 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                              child: Text(
                                'Export file',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              Value_Report = (Ser_BodySta1 == 1)
                                  ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายเดือน'
                                  : 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน';
                              Pre_and_Dow = 'Download';
                            });
                            _showMyDialog_SAVE2();
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
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
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            InvoiceModels.clear();
                            Ser_BodySta1 = 0;
                            Ser_BodySta2 = 0;
                            YE_Invoice_Mon = null;
                            Mon_Invoice_Mon = null;
                            zone_ser_Invoice_Daily = null;
                            zone_name_Invoice_Daily = null;
                            zone_ser_Invoice_Mon = null;
                            zone_name_Invoice_Mon = null;
                            Value_InvoiceDate_Daily = null;
                          });
                          // check_clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> read_SumGCExpWht(int index) async {
    String textdata = '${InvoiceModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double sumWhtExp = dataList
          .whereType<Map<String, dynamic>>()
          .map((element) => double.parse(element['wht_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(sumWhtExp.toString()))}';
    } catch (e) {
      return '$e';
    }
  }

  Future<String> read_SumGCExpNWht(int index) async {
    String textdata = '${InvoiceModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double sumNWhtExp = dataList
          .whereType<Map<String, dynamic>>()
          .map((element) => double.parse(element['nwht_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(sumNWhtExp.toString()))}';
    } catch (e) {
      return '$e';
    }
  }

  Future<String> read_SumGCExpSer(int index, serexp) async {
    String textdata = '${InvoiceModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double amt = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['amt_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(amt.toString()))}';
    } catch (e) {
      return '$e';
    }
  }

  Future<String> read_QtyGCExpSer(int index, serexp) async {
    String textdata = '${InvoiceModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double qty = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['qty_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(qty.toString()))}';
    } catch (e) {
      return '$e';
    }
  }

////////////------------------------------------------------->
  TransIncomeBillAwatCheck_Widget() {
    // Insert_log.Insert_logs('รายงาน', 'กดดูรายงานรายรับ');
    int? show_more;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 0)),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Center(
                        child: Text(
                      (Type_search.toString() == 'Mon')
                          ? (zone_name_BillAwatCheck_Mon == null)
                              ? 'รายงานประวัติชำระรอตรวจสอบ  (กรุณาเลือกโซน)'
                              : 'รายงานประวัติชำระรอตรวจสอบ  (โซน : $zone_name_BillAwatCheck_Mon)'
                          : (zone_name_BillAwatCheck_Daily == null)
                              ? 'รายงานประวัติชำระรอตรวจสอบรายวัน  (กรุณาเลือกโซน)'
                              : 'รายงานประวัติชำระรอตรวจสอบรายวัน (โซน : $zone_name_BillAwatCheck_Daily)',
                      style: const TextStyle(
                        color: ReportScreen_Color.Colors_Text1_,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontWeight_.Fonts_T,
                      ),
                    )),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              (Type_search.toString() == 'Mon')
                                  ? (Mon_BillAwatCheck_Mon == null &&
                                          YE_BillAwatCheck_Mon == null)
                                      ? 'เดือน : ? (?) '
                                      : (Mon_BillAwatCheck_Mon == null)
                                          ? 'เดือน : ? ($YE_BillAwatCheck_Mon) '
                                          : (Mon_BillAwatCheck_Mon == null)
                                              ? 'เดือน : $Mon_BillAwatCheck_Mon (?) '
                                              : 'เดือน : $Mon_BillAwatCheck_Mon ($YE_BillAwatCheck_Mon) '
                                  : (Value_BillAwatCheck_Daily == null)
                                      ? 'วันที่: ?'
                                      : 'วันที่: ${DateFormat('dd-MM').format(DateTime.parse('${Value_BillAwatCheck_Daily}'))}-${DateTime.parse('${Value_BillAwatCheck_Daily}').year + 543}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text1_,
                                fontSize: 14,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'ทั้งหมด: ${TransReBillModels_.length}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ReportScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Divider(),
                    const SizedBox(height: 1),
                  ],
                );
              }),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 0)),
              builder: (context, snapshot) {
                return ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          // color: Colors.grey[50],
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 0.9
                              : (TransReBillModels_.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 800,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (TransReBillModels_.length == 0)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'ไม่พบข้อมูล ณ วันที่เลือก',
                                        style: TextStyle(
                                          color:
                                              ReportScreen_Color.Colors_Text1_,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    // for (int index1 = 0;
                                    //     index1 <
                                    //         _TransReBillModels
                                    //             .length;
                                    //     index1++)
                                    Expanded(
                                        // height: MediaQuery.of(context).size.height *
                                        //     0.45,
                                        child: ListView.builder(
                                      itemCount: TransReBillModels_.length,
                                      itemBuilder:
                                          (BuildContext context, int index1) {
                                        return ListTile(
                                          title: SizedBox(
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppbackgroundColor
                                                                  .TiTile_Colors,
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(5),
                                                              bottomLeft: Radius
                                                                  .circular(0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          0)),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Text(
                                                          //'${index1 + 1}. เลขที่: ${_TransReBillModels_Income[index1].docno}',
                                                          TransReBillModels_[
                                                                          index1]
                                                                      .docno ==
                                                                  ''
                                                              ? '${index1 + 1}. เลขที่: ${TransReBillModels_[index1].refno}'
                                                              : '${index1 + 1}. เลขที่: ${TransReBillModels_[index1].docno}',
                                                          style:
                                                              const TextStyle(
                                                            color: ReportScreen_Color
                                                                .Colors_Text1_,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (show_more != index1)
                                                  SizedBox(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppbackgroundColor
                                                                    .TiTile_Colors
                                                                .withOpacity(
                                                                    0.7),
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0)),
                                                          ),
                                                          // padding: const EdgeInsets.all(4.0),
                                                          child: const Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'โซน',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'รหัสพื้นที่',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              // Expanded(
                                                              //   flex: 1,
                                                              //   child: Text(
                                                              //     'ชื่อร้านค้า',
                                                              //     textAlign: TextAlign.center,
                                                              //     style: TextStyle(
                                                              //       color: ReportScreen_Color.Colors_Text1_,
                                                              //       fontWeight: FontWeight.bold,
                                                              //       fontFamily: FontWeight_.Fonts_T,
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'วันที่',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'ชื่อร้านค้า',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'รูปแบบชำระ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              // Expanded(
                                                              //   flex: 1,
                                                              //   child: Text(
                                                              //     'ธนาคาร',
                                                              //     textAlign: TextAlign.center,
                                                              //     style: TextStyle(
                                                              //       color: ReportScreen_Color.Colors_Text1_,
                                                              //       fontWeight: FontWeight.bold,
                                                              //       fontFamily: FontWeight_.Fonts_T,
                                                              //     ),
                                                              //   ),
                                                              // ),

                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'รายการทั้งหมด',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'ราคารวม',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'ส่วนลด',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),

                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'รวมหักส่วนลด',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  'Slip',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  '...',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0)),
                                                          ),
                                                          // padding: const EdgeInsets.all(4.0),
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                              .zn ==
                                                                          null)
                                                                      ? '${TransReBillModels_[index1].znn}'
                                                                      : '${TransReBillModels_[index1].zn}',
                                                                  // '${TransReBillModels[index1].length}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                              .ln ==
                                                                          null)
                                                                      ? '${TransReBillModels_[index1].room_number}'
                                                                      : '${TransReBillModels_[index1].ln}',
                                                                  // '${TransReBillModels[index1].length}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  // '${_TransReBillModels_Income[index1].daterec}',
                                                                  (TransReBillModels_[index1]
                                                                              .daterec ==
                                                                          null)
                                                                      ? ''
                                                                      : '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels_[index1].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${TransReBillModels_[index1].daterec}'))}') + 543}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                                  .sname ==
                                                                              null ||
                                                                          TransReBillModels_[index1].sname.toString() ==
                                                                              '' ||
                                                                          TransReBillModels_[index1].sname.toString() ==
                                                                              'null')
                                                                      ? '${TransReBillModels_[index1].remark}'
                                                                      : '${TransReBillModels_[index1].sname}',
                                                                  // '${TransReBillModels[index1].length}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  '${TransReBillModels_[index1].type}',
                                                                  // '${TransReBillModels[index1].length}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  //'ttt',
                                                                  '${TransReBillModels_[index1].sum_items}',
                                                                  // '${TransReBillModels[index1].length}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                              .total_bill ==
                                                                          null)
                                                                      ? ''
                                                                      : '${nFormat.format(double.parse(TransReBillModels_[index1].total_bill!) + double.parse(TransReBillModels_[index1].total_dis!))}',
                                                                  // '${_TransReBillModels[index1].total_bill}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                              .total_dis ==
                                                                          null)
                                                                      ? ''
                                                                      : '${nFormat.format(double.parse(TransReBillModels_[index1].total_dis!))}',
                                                                  // (TransReBillModels_[index1]
                                                                  //             .total_dis ==
                                                                  //         null)
                                                                  //     ? '0.00'
                                                                  //     : '${nFormat.format(double.parse(TransReBillModels_[index1].total_bill!) - double.parse(TransReBillModels_[index1].total_dis!))}',
                                                                  // '${_TransReBillModels[index1].total_bill}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  (TransReBillModels_[index1]
                                                                              .total_dis ==
                                                                          null)
                                                                      ? '0.00'
                                                                      : '${nFormat.format(double.parse(TransReBillModels_[index1].total_bill!))}',
                                                                  // (TransReBillModels_[index1]
                                                                  //             .total_dis ==
                                                                  //         null)
                                                                  //     ? '${nFormat.format(double.parse(TransReBillModels_[index1].total_bill!))}'
                                                                  //     : '${nFormat.format(double.parse(TransReBillModels_[index1].total_dis!))}',
                                                                  // '${_TransReBillModels[index1].total_bill}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: ReportScreen_Color
                                                                        .Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: (TransReBillModels_[index1].slip.toString() == null ||
                                                                            TransReBillModels_[index1].slip ==
                                                                                null ||
                                                                            TransReBillModels_[index1].slip.toString() ==
                                                                                'null')
                                                                        ? null
                                                                        : () async {
                                                                            String
                                                                                Url =
                                                                                await '${MyConstant().domain}/files/$foder/slip/${TransReBillModels_[index1].slip}';
                                                                            slip_Widget(Url,
                                                                                TransReBillModels_[index1].docno == '' ? '${index1 + 1}. เลขที่: ${TransReBillModels_[index1].refno}' : '${index1 + 1}. เลขที่: ${TransReBillModels_[index1].docno}');
                                                                          },
                                                                    child:
                                                                        Container(
                                                                      // width: 100,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: (TransReBillModels_[index1].slip.toString() == null ||
                                                                                TransReBillModels_[index1].slip == null ||
                                                                                TransReBillModels_[index1].slip.toString() == 'null')
                                                                            ? Colors.grey[300]
                                                                            : Colors.orange[300],
                                                                        borderRadius: const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            topRight: Radius.circular(10),
                                                                            bottomLeft: Radius.circular(10),
                                                                            bottomRight: Radius.circular(10)),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            Text(
                                                                          'เรียกดู',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                ReportScreen_Color.Colors_Text1_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        show_more =
                                                                            index1;
                                                                      });

                                                                      var ciddoc =
                                                                          TransReBillModels_[index1]
                                                                              .ser!;

                                                                      var docnoin = (TransReBillModels_[index1].docno ==
                                                                              null)
                                                                          ? TransReBillModels_[index1]
                                                                              .refno!
                                                                          : TransReBillModels_[index1]
                                                                              .docno!;
                                                                      red_Trans_selectIncome(
                                                                          ciddoc,
                                                                          docnoin,
                                                                          index1);
                                                                      // _TransReBillHistoryModels_Income()
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          100,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green[300],
                                                                        borderRadius: const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            topRight: Radius.circular(10),
                                                                            bottomLeft: Radius.circular(10),
                                                                            bottomRight: Radius.circular(10)),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          const Center(
                                                                        child:
                                                                            Text(
                                                                          'ดูเพิ่มเติม',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                ReportScreen_Color.Colors_Text1_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (show_more == index1)
                                                  SizedBox(
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppbackgroundColor
                                                                        .TiTile_Colors
                                                                    .withOpacity(
                                                                        0.7),
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            0),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            0)),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: const Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'ลำดับ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        'วันที่',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AccountScreen_Color.Colors_Text1_,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              FontWeight_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'กำหนดชำระ',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'รายการ',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'Vat%',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'หน่วย',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'VAT',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'ราคาก่อน Vat',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'ราคารวม Vat',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ReportScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned(
                                                                top: 0,
                                                                right: 2,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      show_more =
                                                                          null;
                                                                    });
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .cancel,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                        for (int index2 = 0;
                                                            index2 <
                                                                TranHisBillModels
                                                                    .length;
                                                            index2++)
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .green[100]!
                                                                  .withOpacity(
                                                                      0.5),
                                                              border:
                                                                  const Border(
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
                                                                        .fromLTRB(
                                                                    5, 0, 5, 0),
                                                            // padding: const EdgeInsets.all(4.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        '${index1 + 1}.${index2 + 1}',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        //  '${TransReBillModels_Income[index1][index2].date}',

                                                                        (TranHisBillModels[index2].daterec ==
                                                                                null)
                                                                            ? ''
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${TranHisBillModels[index2].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${TranHisBillModels[index2].daterec}'))}') + 543}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        //  '${TransReBillModels_Income[index1][index2].date}',

                                                                        (TranHisBillModels[index2].date ==
                                                                                null)
                                                                            ? ''
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${TranHisBillModels[index2].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${TranHisBillModels[index2].date}'))}') + 543}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        '${TranHisBillModels[index2].expname}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        '${TranHisBillModels[index2].nvat}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        '${TranHisBillModels[index2].vtype}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (TranHisBillModels[index2].vat ==
                                                                                null)
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(TranHisBillModels[index2].vat!))}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (TranHisBillModels[index2].pvat ==
                                                                                null)
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(TranHisBillModels[index2].pvat!))}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (TranHisBillModels[index2].dis ==
                                                                                null)
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(TranHisBillModels[index2].total!) + double.parse(TranHisBillModels[index2].dis!))}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (TranHisBillModels[index2].dis ==
                                                                                null)
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(TranHisBillModels[index2].dis!))}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Text(
                                                                        (TranHisBillModels[index2].total ==
                                                                                null)
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(TranHisBillModels[index2].total!))}',
                                                                        // (TranHisBillModels[index2].total ==
                                                                        //         null)
                                                                        //     ? '${nFormat.format(0.00 - ((TranHisBillModels[index2].dis == null) ? 0.00 : double.parse(TranHisBillModels[index2].dis!)))}'
                                                                        //     : '${nFormat.format(double.parse(TranHisBillModels[index2].total!) - ((TranHisBillModels[index2].dis == null) ? 0.00 : double.parse(TranHisBillModels[index2].dis!)))}',
                                                                        // (TranHisBillModels[index2].total ==
                                                                        //         null)
                                                                        //     ? '-'
                                                                        //     : '${nFormat.format(double.parse(TranHisBillModels[index2].total!))}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              ReportScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          actions: <Widget>[
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 0)),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 20, 4),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 120,
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.9
                                  : (TransReBillModels_.length == 0)
                                      ? MediaQuery.of(context).size.width
                                      : 900,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 2,
                                              child: Text(
                                                '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวม',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 3,
                                              child: Text(
                                                '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวมค่าธรรมเนียม',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวมราคารวม',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวมส่วนลด',
                                              //'${nFormat.format(double.parse(_TransReBillModels[index1].ramtd!))}',
                                              //  '${_TransReBillModels[index1].ramtd}',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวมหักส่วนลด',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 2,
                                              child: Text(
                                                ' ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 2,
                                              child: Text(
                                                '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 3,
                                              child: Text(
                                                '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (TransReBillModels_.length == 0)
                                                  ? '0.00'
                                                  : nFormat.format(double.parse(
                                                      TransReBillModels_.fold(
                                                      0.0,
                                                      (previousValue,
                                                              element) =>
                                                          previousValue +
                                                          (element.total_duesbill !=
                                                                  null
                                                              ? double.parse(element
                                                                  .total_duesbill!)
                                                              : 0),
                                                    ).toString())),
                                              // '$Sum_Total_',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (TransReBillModels_.length == 0)
                                                  ? '0.00'
                                                  : nFormat.format(double.parse(
                                                          TransReBillModels_
                                                              .fold(
                                                        0.0,
                                                        (previousValue,
                                                                element) =>
                                                            previousValue +
                                                            (element.total_bill !=
                                                                    null
                                                                ? double.parse(
                                                                    element
                                                                        .total_bill!)
                                                                : 0),
                                                      ).toString()) +
                                                      double.parse(
                                                          (TransReBillModels_
                                                              .fold(
                                                        0.0,
                                                        (previousValue,
                                                                element) =>
                                                            previousValue +
                                                            (element.total_dis !=
                                                                    null
                                                                ? double.parse(
                                                                    element
                                                                        .total_dis!)
                                                                : 0.00),
                                                      )).toString())),
                                              // '$Sum_Total_',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (TransReBillModels_.length == 0)
                                                  ? '0.00'
                                                  : nFormat.format(double.parse(
                                                      (TransReBillModels_.fold(
                                                      0.0,
                                                      (previousValue,
                                                              element) =>
                                                          previousValue +
                                                          (element.total_dis !=
                                                                  null
                                                              ? double.parse(
                                                                  element
                                                                      .total_dis!)
                                                              : 0.00),
                                                    )).toString())),
                                              // '${nFormat.format(double.parse('$Sum_dis_'))}',

                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (TransReBillModels_.length == 0)
                                                  ? '0.00'
                                                  : nFormat.format(double.parse(
                                                      (TransReBillModels_.fold(
                                                      0.0,
                                                      (previousValue,
                                                              element) =>
                                                          previousValue +
                                                          (element.total_bill !=
                                                                  null
                                                              ? double.parse(
                                                                  element
                                                                      .total_bill!)
                                                              : 0.00),
                                                    )).toString())),
                                              // (TransReBillModels_.length == 0)
                                              //     ? '0.00'
                                              //     : nFormat.format(double.parse(
                                              //             (TransReBillModels_
                                              //                 .fold(
                                              //           0.0,
                                              //           (previousValue,
                                              //                   element) =>
                                              //               previousValue +
                                              //               (element.total_bill !=
                                              //                       null
                                              //                   ? double.parse(
                                              //                       element
                                              //                           .total_bill!)
                                              //                   : 0.00),
                                              //         )).toString()) -
                                              //         double.parse(
                                              //             (TransReBillModels_
                                              //                 .fold(
                                              //           0.0,
                                              //           (previousValue,
                                              //                   element) =>
                                              //               previousValue +
                                              //               (element.total_dis !=
                                              //                       null
                                              //                   ? double.parse(
                                              //                       element
                                              //                           .total_dis!)
                                              //                   : 0.00),
                                              //         )).toString())),
                                              // '$Sum_Total_',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: ReportScreen_Color
                                                    .Colors_Text1_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Responsive.isDesktop(context))
                                            const Expanded(
                                              flex: 2,
                                              child: Text(
                                                ' ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: ReportScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 1),
            const Divider(),
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (TransReBillModels_.length != 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                              child: Text(
                                'Export file',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              show_more = null;
                              Value_Report = (Type_search.toString() == 'Mon')
                                  ? 'รายงานประวัติชำระรอตรวจสอบ'
                                  : 'รายงานประวัติชำระรอตรวจสอบประจำวัน';
                              Pre_and_Dow = 'Download';
                            });
                            // Navigator.pop(context);
                            _showMyDialog_SAVE();
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
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
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            Ser_BodySta3 = 0;
                            Ser_BodySta4 = 0;
                            zone_ser_BillAwatCheck_Daily = null;
                            zone_ser_BillAwatCheck_Mon = null;
                            zone_name_BillAwatCheck_Mon = null;
                            YE_BillAwatCheck_Mon = null;
                            Mon_BillAwatCheck_Mon = null;
                            Value_BillAwatCheck_Daily = null;
                            TranHisBillModels.clear();
                            TransReBillModels_.clear();
                          });

                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ////////////------------------------------------------------------>(Export file 1)
  Future<void> _showMyDialog_SAVE() async {
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
                title: Container(
                  width: 300,
                  height: 80,
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        child: Center(
                          child: Text(
                            '$Value_Report',
                            style: const TextStyle(
                              color: ReportScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                            // width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, 'OK'),
                              child: const Text(
                                'ปิด',
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold, color:

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text(
                        'สกุลไฟล์ :',
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
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: RadioGroup<String>.builder(
                          direction: Axis.horizontal,
                          groupValue: _verticalGroupValue_PassW,
                          horizontalAlignment: MainAxisAlignment.spaceAround,
                          onChanged: (value) {
                            setState(() {
                              FormNameFile_text.clear();
                            });
                            setState(() {
                              _verticalGroupValue_PassW = value ?? '';
                            });
                          },
                          items: const <String>[
                            // "PDF",
                            "EXCEL",
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
                      const Text(
                        'รูปแบบ :',
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
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: RadioGroup<String>.builder(
                          direction: Axis.horizontal,
                          groupValue: _ReportValue_type,
                          horizontalAlignment: MainAxisAlignment.spaceAround,
                          onChanged: (value) {
                            // setState(() {
                            //   FormNameFile_text.clear();
                            // });
                            setState(() {
                              _ReportValue_type = value ?? '';
                            });
                          },
                          items: const <String>[
                            "ปกติ",
                            "ย่อ",
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
                actions: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 180,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () async {
                            InkWell_onTap(context);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 25,
                                backgroundImage: (_verticalGroupValue_PassW ==
                                        'PDF')
                                    ? const AssetImage('images/IconPDF.gif')
                                    : const AssetImage('images/excel_icon.gif'),
                              ),
                              Container(
                                width: 80,
                                child: const Text(
                                  'Download',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                                // decoration: const BoxDecoration(
                                //   border: Border(
                                //     bottom: BorderSide(
                                //         color: Colors.white),
                                //   ),
                                // ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ////////////------------------------------------------------------>(Export file 2)
  Future<void> _showMyDialog_SAVE2() async {
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
                title: Container(
                  width: 300,
                  height: 80,
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        child: Center(
                          child: Text(
                            '$Value_Report',
                            style: const TextStyle(
                              color: ReportScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                            // width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, 'OK'),
                              child: const Text(
                                'ปิด',
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold, color:

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text(
                        'สกุลไฟล์ :',
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
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: RadioGroup<String>.builder(
                          direction: Axis.horizontal,
                          groupValue: _verticalGroupValue_PassW,
                          horizontalAlignment: MainAxisAlignment.spaceAround,
                          onChanged: (value) {
                            setState(() {
                              FormNameFile_text.clear();
                            });
                            setState(() {
                              _verticalGroupValue_PassW = value ?? '';
                            });
                          },
                          items: const <String>[
                            // "PDF",
                            "EXCEL",
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
                      const Text(
                        'รูปแบบ :',
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
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: RadioGroup<String>.builder(
                          direction: Axis.horizontal,
                          groupValue: _ReportValue_type,
                          horizontalAlignment: MainAxisAlignment.spaceAround,
                          onChanged: (value) {
                            // setState(() {
                            //   FormNameFile_text.clear();
                            // });
                            setState(() {
                              _ReportValue_type = value ?? '';
                            });
                          },
                          items: const <String>[
                            "ปกติ",
                            // "ย่อ",
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
                actions: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 180,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () async {
                            InkWell_onTap(context);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 25,
                                backgroundImage: (_verticalGroupValue_PassW ==
                                        'PDF')
                                    ? const AssetImage('images/IconPDF.gif')
                                    : const AssetImage('images/excel_icon.gif'),
                              ),
                              Container(
                                width: 80,
                                child: const Text(
                                  'Download',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                ),
                                // decoration: const BoxDecoration(
                                //   border: Border(
                                //     bottom: BorderSide(
                                //         color: Colors.white),
                                //   ),
                                // ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

////////////------------------------------------------>
  void InkWell_onTap(context) async {
    // await red_TransAll_Invoice_select();
    await red_Trans_selectIncomeAll();
    setState(() {
      show_more = null;
      NameFile_ = '';
      NameFile_ = FormNameFile_text.text;
    });

    if (_verticalGroupValue_NameFile == 'กำหนดเอง') {
    } else {
      if (_verticalGroupValue_PassW == 'PDF') {
        Navigator.of(context).pop();
      } else {
        if (Value_Report == 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายเดือน' ||
            Value_Report == 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน') {
          if (_ReportValue_type == 'ปกติ') {
            Excgen_InvoiceReport.exportExcel_InvoiceReport(
                context,
                NameFile_,
                Ser_BodySta1,
                _verticalGroupValue_NameFile,
                Value_Report,
                InvoiceModels,
                _InvoiceModels,
                expModels.where((element) => element.st! == '1').toList(),
                // expModels,
                renTal_name,
                zone_name_Invoice_Mon,
                zone_name_Invoice_Daily,
                YE_Invoice_Mon,
                Mon_Invoice_Mon,
                Value_InvoiceDate_Daily,
                Type_vat.where((element) => element["st"]! == '1').toList());
          } else {
            // Mini_Ex_InvoiceChoiceReport.mini_exportExcel_invoiceChoiceReport(
            //     context,
            //     NameFile_,
            //     Ser_BodySta1,
            //     _verticalGroupValue_NameFile,
            //     Value_Report,
            //     InvoiceModels,
            //     _InvoiceModels,
            //     expModels_Mini,
            //     renTal_name,
            //     zone_name_Invoice_Mon,
            //     zone_name_Invoice_Daily,
            //     YE_Invoice_Mon,
            //     Mon_Invoice_Mon,
            //     Value_InvoiceDate_Daily);
          }
        } else if (Value_Report == 'รายงานประวัติชำระรอตรวจสอบ') {
          (_ReportValue_type == "ปกติ")
              ? Excgen_BankmovemenReport.exportExcel_BankmovemenReport(
                  '5',
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  Value_Report,
                  TransReBillModels_,
                  TranHisBillModels,
                  renTal_name,
                  zoneModels_report,
                  zone_name_BillAwatCheck_Mon,
                  Mon_BillAwatCheck_Mon,
                  YE_BillAwatCheck_Mon,
                  payMentModels,
                  userModels,
                  '1โซน/พื้นที่')
              : Mini_Ex_BankmovemenReport.mini_exportExcel_BankmovemenReport(
                  '5',
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  Value_Report,
                  TransReBillModels_,
                  TranHisBillModels,
                  renTal_name,
                  zoneModels_report,
                  zone_name_BillAwatCheck_Mon,
                  Mon_BillAwatCheck_Mon,
                  YE_BillAwatCheck_Mon,
                  payMentModels,
                  userModels,
                  '1โซน/พื้นที่');
        } else if (Value_Report == 'รายงานประวัติชำระรอตรวจสอบประจำวัน') {
          (_ReportValue_type == "ปกติ")
              ? Excgen_BankDailyReport.exportExcel_BankDailyReport(
                  '5',
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  Value_Report,
                  TransReBillModels_,
                  TranHisBillModels,
                  renTal_name,
                  zoneModels_report,
                  Value_BillAwatCheck_Daily,
                  zone_name_BillAwatCheck_Daily,
                  payMentModels,
                  userModels,
                  '1โซน/พื้นที่')
              : Mini_Ex_BankdailyReport.mini_exportExcel_BankdailyReport(
                  '5',
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  Value_Report,
                  TransReBillModels_,
                  TranHisBillModels,
                  renTal_name,
                  zoneModels_report,
                  Value_BillAwatCheck_Daily,
                  zone_name_BillAwatCheck_Daily,
                  payMentModels,
                  userModels,
                  '1โซน/พื้นที่');
        }
        Navigator.of(context).pop();
      }
    }
  }
}

///​กรรมกรข่าว X ​ทีมพากย์พันธมิตร
