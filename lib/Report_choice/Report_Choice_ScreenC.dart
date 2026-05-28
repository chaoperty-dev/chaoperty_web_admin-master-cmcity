import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetPakan_Contractx_Choice_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNantRenew_Choice_Model.dart';
import '../Model/GetTeNant_Choice_Model.dart';
import '../Model/GetTrans_BillPay_Choice_Model.dart';
import '../Model/GetTrans_Kon_Choice_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Excel_Area_serviceFeeShort_Report.dart';
import 'Excel_BillPayFutureMonRent_Report_Choice.dart';
import 'Excel_PeopleTenant_Report_Choice.dart';
import 'Excel_SalesTaxFull_Report_Choice.dart';
import 'Excel_SalesTaxShortReport_Choice.dart';
import 'Excel_TeNantNew2_Report_Choice.dart';
import 'Excel_TeNantNew_Report_Choice.dart';

class Report_Choice_ScreenC extends StatefulWidget {
  const Report_Choice_ScreenC({super.key});

  @override
  State<Report_Choice_ScreenC> createState() => _Report_Choice_ScreenCState();
}

class _Report_Choice_ScreenCState extends State<Report_Choice_ScreenC> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("#,##0", "en_US");
  DateTime datex = DateTime.now();
  int Status_ = 1, open_set_date = 30;
  int? Await_Status_Report1,
      Await_Status_Report2,
      Await_Status_Report3,
      Await_Status_Report4;
  int Ser_BodySta1 = 0;
  int Ser_BodySta2 = 0;
  int Ser_BodySta3 = 0;
  int Ser_BodySta4 = 0;
  double Text_Size = 13.00;
//-------------------------------------->
  String _verticalGroupValue_PassW = "EXCEL";
  String _ReportValue_type = "ปกติ";
  String _verticalGroupValue_NameFile = "จากระบบ";
  String Value_Report = ' ';
  String NameFile_ = '';
  String Pre_and_Dow = '';
  final _formKey = GlobalKey<FormState>();
  final FormNameFile_text = TextEditingController();
  ///////////--------------------------------------------->

  String? renTal_user, renTal_name, zone_ser, zone_name;
  String? rtname, type, typex, renname, bill_name, bill_addr, bill_tax;
  String? bill_tel, bill_email, expbill, expbill_name, bill_default;
  String? bill_tser, foder;
  String? Status_pe_History, Status_pe_ser_History;

  String? Status_pe_New = 'สัญญาปัจจุบัน', Status_pe_ser_New = '0';
  String? Status_date = 'ทำสัญญา', Status_ser_date = '0';
  String? Status_date_pay = 'เดือนที่รับชำระ', Status_ser_date_pay = '1';
  /////////////////---------------------------->
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<PayMentModel> payMentModels = [];
  List<RenTalModel> renTalModels = [];
  List<ExpModel> expModels = [];
  List<String> YE_Th = [];
  List<String> Mont_Th = [];

  ///////////////---------------------------------------->
  List<ContractxPakanChoiceModel> contractxPakan = [];
  List<ContractxPakanChoiceModel> _contractxPakan =
      <ContractxPakanChoiceModel>[];

  ///////////////-------------------------------------->
  List<TransBillPayChoiceModel> billpay_Mon = [];
  List<TransBillPayChoiceModel> _billpay_Mon = <TransBillPayChoiceModel>[];
  ///////////////-------------------------------------->
  List<TeNantChoiceModel> teNantModels = [];
  List<TeNantChoiceModel> _teNantModels = <TeNantChoiceModel>[];
  ///////////////-------------------------------------->
  List<TeNantChoiceModel> teNantModels_New = [];
  List<TeNantChoiceModel> _teNantModels_New = <TeNantChoiceModel>[];
  ///////////////-------------------------------------->
  String? Value_Chang_Zone_billpayMon, Value_Chang_Zone_billpayMon_Ser;
  String? Value_Chang_Zone_People_TeNant, Value_Chang_Zone_Ser_People_TeNant;
  String? Value_Chang_Zone_People_TeNantNew,
      Value_Chang_Zone_Ser_People_TeNantNew;
  ///////////////-------------------------------------->

  String? Mon_billpay_Mon, YE_billpay_Mon;
  String? Mon_PeopleTeNant_Mon, YE_PeopleTeNant_Mon;
  String? Mon_PeopleTeNantNew_Mon, YE_PeopleTeNantNew_Mon;
  String? Mon_PeopleTeNantNewsub_Mon, YE_PeopleTeNantNewsub_Mon;
  String? sdate_1, ldate_1, day_lday;
  String? sdate_2, ldate_2, day_lday_2;
  ///////////////-------------------------------------->
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
  List<TextEditingController> Dropdown_Controller_zone = [];

  List<dynamic> Type_vat = [
    {"ser": "1", "st": "1", "type": "pvat", "pn": "ก่อนVAT"},
    {"ser": "2", "st": "1", "type": "vat", "pn": "VAT"},
    {"ser": "3", "st": "1", "type": "wht", "pn": "WHT"},
    {"ser": "4", "st": "0", "type": "total", "pn": "รวมVAT"},
  ];
  List Status = [
    'ทั้งหมด',
    'สัญญาปัจจุบัน',
    'ยกเลิกสัญญา',
  ];
  List Status_new = [
    // 'ทั้งหมด',
    'สัญญาปัจจุบัน',
    'ยกเลิกสัญญา',
  ];
  ///////////////-------------------------------------->
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    super.initState();
    checkPreferance();
    read_GC_rental();
    read_GC_zone();
    read_GC_Exp();
    // read_GC_PayMentModel();
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
            // if (bill_defaultx == 'P') {
            //   bills_name_ = 'บิลธรรมดา';
            // } else {
            //   bills_name_ = 'ใบกำกับภาษี';
            // }
          });
        }
      } else {}
    } catch (e) {
      // print('Error-Dis(read_GC_rental) : ${e}');
    }
    // print('name>>>>>  $renname');
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
          if (expModel.exptser! != '2') {
            setState(() {
              expModels.add(expModel);
            });
          }
        }
        expModels.sort((a, b) {
          if (a.exptser == 'ทั้งหมด') {
            return -1; // 'all' should come before other elements
          } else if (b.exptser == 'ทั้งหมด') {
            return 1; // 'all' should come after other elements
          } else {
            return a.exptser!.compareTo(
                b.exptser!); // sort other elements in ascending order
          }
        });
        for (int index = 0; index < expModels.length; index++) {
          setState(() {
            if (expModels[index].ser.toString() == '1' ||
                expModels[index].ser.toString() == '16' ||
                expModels[index].ser.toString() == '35' ||
                expModels[index].ser.toString() == '6' ||
                expModels[index].ser.toString() == '7' ||
                expModels[index].ser.toString() == '17') {
              expModels[index].st = '1';
            } else {
              expModels[index].st = '0';
            }
          });
        }
      } else {}
    } catch (e) {}
  }

////////--------------------------------------------------------------->

  Future<Null> TransBill_PayMon() async {
    if (billpay_Mon.isNotEmpty) {
      billpay_Mon.clear();
      _billpay_Mon.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (Value_Chang_Zone_billpayMon_Ser == null)
        ? '0'
        : Value_Chang_Zone_billpayMon_Ser;
    String url =
        '${MyConstant().domain}/GC_billpayfuture_Report_Choice.php?isAdd=true&ren=$ren&zser=$zone&month_s=$Mon_billpay_Mon&year_s=$YE_billpay_Mon&sdate_s=$sdate_1&ldate_s=$ldate_1';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TransBillPayChoiceModel billpay_Mons =
              TransBillPayChoiceModel.fromJson(map);

          setState(() {
            billpay_Mon.add(billpay_Mons);
          });
        }
        setState(() {
          _billpay_Mon = billpay_Mon;
        });
      } else {}
    } catch (e) {}
    // print('TransBill_PayTaxShort : ${salesTax_short.length}');
    setState(() {
      Await_Status_Report1 = 1;
    });
  }

  ////////-------------------------------------------------------->(รายงานประวัติผู้เช่า)
  Future<Null> People_tenant() async {
    if (teNantModels.isNotEmpty) {
      teNantModels.clear();
      _teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (Value_Chang_Zone_Ser_People_TeNant == null)
        ? '0'
        : Value_Chang_Zone_Ser_People_TeNant;
    String url =
        '${MyConstant().domain}/GC_People_Tenant_AllReport_Choice.php?isAdd=true&ren=$ren&zser=$zone&month_s=$Mon_PeopleTeNant_Mon&year_s=$YE_PeopleTeNant_Mon&statuspe=$Status_pe_ser_History';
    // print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result != null) {
        for (var map in result) {
          TeNantChoiceModel teNantModelss = TeNantChoiceModel.fromJson(map);

          setState(() {
            teNantModels.add(teNantModelss);
          });
        }
        setState(() {
          _teNantModels = teNantModels;
        });
      } else {}
    } catch (e) {}
    // print('People_tenant : ${teNantModels.length}');
    setState(() {
      Await_Status_Report2 = 1;
    });
  }

  /// @Fuglomib8
  ////////-------------------------------------------------------->(รายงานผู้เช่ารายใหม่)
  Future<Null> People_tenant_New() async {
    if (teNantModels_New.isNotEmpty) {
      teNantModels_New.clear();
      _teNantModels_New.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (Value_Chang_Zone_Ser_People_TeNantNew == null)
        ? '0'
        : Value_Chang_Zone_Ser_People_TeNantNew;
    // String url =
    //     '${MyConstant().domain}/GC_People_TenantNew_AllReport_Choice.php?isAdd=true&ren=$ren&zser=$zone&month_s=$Mon_PeopleTeNantNew_Mon&year_s=$YE_PeopleTeNantNew_Mon&month_p=$Mon_PeopleTeNantNewsub_Mon&year_p=$YE_PeopleTeNantNewsub_Mon&type_date=$Status_ser_date&type_cid=$Status_pe_ser_New&typepay=$Status_ser_date_pay';

    // print(url);
    try {
      String url =
          '${MyConstant().domain}/GC_People_TenantNew_AllReport_Choice.php?isAdd=true&ren=$ren';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'zser': '$zone',
          'month_s': '$Mon_PeopleTeNantNew_Mon',
          'year_s': '$YE_PeopleTeNantNew_Mon',
          'month_p': '$Mon_PeopleTeNantNewsub_Mon',
          'year_p': '$YE_PeopleTeNantNewsub_Mon',
          'type_date': '$Status_ser_date',
          'type_cid': '$Status_pe_ser_New',
          'type_pay': '$Status_ser_date_pay',
        },
      );

      var result = json.decode(response.body);
      // print(
      //   {
      //     'zser': '$zone',
      //     'month_s': '$Mon_PeopleTeNantNew_Mon',
      //     'year_s': '$YE_PeopleTeNantNew_Mon',
      //     'month_p': '$Mon_PeopleTeNantNewsub_Mon',
      //     'year_p': '$YE_PeopleTeNantNewsub_Mon',
      //     'type_date': '$Status_ser_date',
      //     'type_cid': '$Status_pe_ser_New',
      //     'type_pay': '$Status_ser_date_pay',
      //   },
      // );
      if (result != null) {
        for (var map in result) {
          TeNantChoiceModel teNantModelss = TeNantChoiceModel.fromJson(map);

          setState(() {
            teNantModels_New.add(teNantModelss);
          });
        }
        setState(() {
          _teNantModels_New = teNantModels_New;
        });
      } else {}
    } catch (e) {
      // print('Error during image processing: $e');
    }

    // try {
    //   var response = await http.get(Uri.parse(url));

    //   var result = json.decode(response.body);
    //   // print(result);
    //   if (result != null) {
    //     for (var map in result) {
    //       TeNantChoiceModel teNantModelss = TeNantChoiceModel.fromJson(map);

    //       setState(() {
    //         teNantModels_New.add(teNantModelss);
    //       });
    //     }
    //     setState(() {
    //       _teNantModels_New = teNantModels_New;
    //     });
    //   } else {}
    // } catch (e) {}
    // print('People_tenant : ${teNantModels.length}');
    setState(() {
      Await_Status_Report3 = 1;
      Await_Status_Report4 = 1;
    });
  }

///////////////-------------------------------------->
  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          // Timer(const Duration(milliseconds: 6600), () {
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
  }

///////////////-------------------------------------->
  Dia_log_lod() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(const Duration(milliseconds: 6600), () {
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
  }

  Future<Null> lastDay() async {
    if (Mon_billpay_Mon == null || YE_billpay_Mon == null) {
    } else {
// Parse the month string into an integer
      int month = int.parse(Mon_billpay_Mon!);
      int year = int.parse(YE_billpay_Mon!);

// Find the first day of the next month
      DateTime firstDayOfNextMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);

// Subtract one day to get the last day of the current month
      DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
      //  lastDayOfMonth.day.toString();
      setState(() {
        sdate_1 = '$YE_billpay_Mon' + '-$Mon_billpay_Mon' + '-25';
        ldate_1 = '$YE_billpay_Mon' +
            '-$Mon_billpay_Mon' +
            '-${lastDayOfMonth.day.toString()}';
        day_lday = lastDayOfMonth.day.toString();
      });
      // print(sdate_1);
      // print(ldate_1);
    }
  }

  Future<Null> lastDay2() async {
    if (Mon_PeopleTeNantNewsub_Mon == null ||
        YE_PeopleTeNantNewsub_Mon == null) {
    } else {
// Parse the month string into an integer
      int month = (int.parse(Mon_PeopleTeNantNewsub_Mon!) == 12)
          ? int.parse(Mon_PeopleTeNantNewsub_Mon!) + 1
          : int.parse(Mon_PeopleTeNantNewsub_Mon!);
      int year = (int.parse(Mon_PeopleTeNantNewsub_Mon!) == 12)
          ? int.parse(YE_PeopleTeNantNewsub_Mon!) + 1
          : int.parse(YE_PeopleTeNantNewsub_Mon!);

// Find the first day of the next month
      DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);

// Subtract one day to get the last day of the current month
      DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
      //  lastDayOfMonth.day.toString();
      setState(() {
        sdate_2 = '$year' + '-$month' + '-25';
        ldate_2 = '$year' + '-$month' + '-${lastDayOfMonth.day.toString()}';
        day_lday_2 = '25-' +
            lastDayOfMonth.day.toString() +
            '(เดือน: ${monthsInThai[int.parse(month.toString()) - 1]} ปี: $year)';
      });
      // print(sdate_2);
      // print(ldate_2);
    }
  }

  /////////////////------------------------------------------------------->
  final DateRangePickerController _controller = DateRangePickerController();

  Widget getDateRangePicker(type) {
    // final localeObj = Locale('th');
    return Container(
      height: 250,
      width: 300,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      _controller.backward!();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 15,
                      color: Colors.grey,
                    )),
                IconButton(
                    onPressed: () {
                      _controller.forward!();
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Card(
              child: SfDateRangePicker(
                controller: _controller,
                allowViewNavigation: false,
                startRangeSelectionColor: Colors.purple,
                endRangeSelectionColor: Colors.deepPurple,
                rangeSelectionColor: Colors.green[100],
                view: DateRangePickerView.year,
                // monthViewSettings:
                //     DateRangePickerMonthViewSettings(viewHeaderHeight: 100),
                selectionMode: DateRangePickerSelectionMode.single,
                // navigationDirection:
                //     DateRangePickerNavigationDirection.vertical,
                // navigationMode: DateRangePickerNavigationMode.scroll,
                enableMultiView: false,
                toggleDaySelection: false,
                // showTodayButton: true,
                onSelectionChanged: (type == 1)
                    ? selectionChanged_month1
                    : (type == 2)
                        ? selectionChanged_month2
                        : (type == 3)
                            ? selectionChanged_month3
                            : selectionChanged_month4,
                // backgroundColor: AppBarColors.ABar_Colors,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectionChanged_month1(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      //  (Mon_billpay_Mon == null ||
      //                                         YE_billpay_Mon == '') lastDay();
      setState(() {
        Mon_billpay_Mon = DateFormat('MM').format(selectedDate);
        YE_billpay_Mon = DateFormat('yyyy').format(selectedDate);
        lastDay();
      });
      //   print('ผSelected month: ${Mon_billpay_Mon}, Year: ${YE_billpay_Mon}');
    }
  }

  void selectionChanged_month2(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      //  (Mon_PeopleTeNant_Mon == null ||
      //                                           YE_PeopleTeNant_Mon == '')
      setState(() {
        Mon_PeopleTeNant_Mon = DateFormat('MM').format(selectedDate);
        YE_PeopleTeNant_Mon = DateFormat('yyyy').format(selectedDate);
      });
      // print(
      //     'Selected month: ${Mon_PeopleTeNant_Mon}, Year: ${YE_PeopleTeNant_Mon}');
    }
  }

  void selectionChanged_month3(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
//  (Mon_PeopleTeNantNew_Mon == null ||
//                                             YE_PeopleTeNantNew_Mon == '')
      setState(() {
        Mon_PeopleTeNantNew_Mon = DateFormat('MM').format(selectedDate);
        YE_PeopleTeNantNew_Mon = DateFormat('yyyy').format(selectedDate);
      });
      // print(
      //     'เดือนที่ทำสัญญา Selected month: ${Mon_PeopleTeNantNew_Mon}, Year: ${YE_PeopleTeNantNew_Mon}');
    }
  }

  void selectionChanged_month4(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
//  (Mon_PeopleTeNantNewsub_Mon == null ||
//                                             YE_PeopleTeNantNewsub_Mon == '')
      setState(() {
        Mon_PeopleTeNantNewsub_Mon = DateFormat('MM').format(selectedDate);
        YE_PeopleTeNantNewsub_Mon = DateFormat('yyyy').format(selectedDate);
      });
      // print(
      //     'เดือนที่รับชำระ Selected month: ${Mon_PeopleTeNantNewsub_Mon}, Year: ${YE_PeopleTeNantNewsub_Mon}');
    }
  }

  // void selectionChanged_month5(DateRangePickerSelectionChangedArgs args) {
  //   // Handle the selection change
  //   if (args.value is DateTime) {
  //     DateTime selectedDate = args.value;
  //     //  (Mon_transMeter_Mon == null || YE_transMeter_Mon == ')

  //     // setState(() {
  //     //   Mon_transMeter_Mon = DateFormat('MM').format(selectedDate);
  //     //   YE_transMeter_Mon = DateFormat('yyyy').format(selectedDate);
  //     // });
  //     // print(
  //     //     'Selected month: ${Mon_transMeter_Mon}, Year: ${YE_transMeter_Mon}');
  //   }
  // }

  /////////////////---------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.lime[200],

                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                  // border: Border.all(color: Colors.grey, width: 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'พิเศษ : Choice Ministore - บริษัท ชอยส์ มินิสโตร์ จำกัด ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
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
                            'วันที่ตั้งหนี้ชำระ:',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSetText(
                            '25 - ${(Mon_billpay_Mon == null || YE_billpay_Mon == null) ? 'สิ้นเดือน' : '$day_lday'}',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'เดือน/ปี ที่ชำระ :',
                            // 'เดือนที่ตั้งหนี้ชำระ :',
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
                                    (Mon_billpay_Mon == null ||
                                            YE_billpay_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_billpay_Mon / $YE_billpay_Mon',
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
                      //       value: (Mon_billpay_Mon == null)
                      //           ? null
                      //           : Mon_billpay_Mon,
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
                      //         Mon_billpay_Mon = value;
                      //         lastDay();
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ปีที่ชำระ :',
                      //       // 'ปีที่ตั้งหนี้ชำระ :',
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
                      //       value: (YE_billpay_Mon == null)
                      //           ? null
                      //           : YE_billpay_Mon,
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
                      //         YE_billpay_Mon = value;
                      //         lastDay();
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
                            'โซนที่ชำระ :',
                            // 'โซนที่ตั้งหนี้ชำระ :',
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
                                value: (Value_Chang_Zone_billpayMon == null)
                                    ? null
                                    : Value_Chang_Zone_billpayMon,
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
                                hint: (Value_Chang_Zone_billpayMon == null)
                                    ? null
                                    : Text(
                                        '$Value_Chang_Zone_billpayMon',
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
                                    Value_Chang_Zone_billpayMon = value!;
                                    Value_Chang_Zone_billpayMon_Ser =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[0].clear();
                                  }
                                }),
                          ),
                          // DropdownButtonFormField2(
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
                          //   value: Value_Chang_Zone_billpayMon,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       Value_Chang_Zone_billpayMon = value!;
                          //       Value_Chang_Zone_billpayMon_Ser =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (Value_Chang_Zone_billpayMon == null)
                              ? null
                              : () async {
                                  if (Value_Chang_Zone_billpayMon != null) {
                                    setState(() {
                                      Await_Status_Report1 = 0;
                                    });
                                    Dia_log();
                                  }
                                  try {
                                    TransBill_PayMon().then((result) {
                                      // print('TransBill_PayMon');
                                      // print('TransBill_PayMon');
                                      setState(() {
                                        Await_Status_Report1 = 1;
                                      });
                                      Timer(const Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                      });
                                    });
                                  } catch (e) {
                                    Timer(const Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                    });
                                  }

                                  // TransBill_PayMon();
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
                                    16,
                                    1),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Row(children: [
                  Translate.TranslateAndSetText(
                      '#หมายเหตุ : ไม่นับรวมผู้เช่าเข้าใหม่/วันที่ทำสัญญา ณ เดือนที่ค้นหา หรือวันที่ทำสัญญามากกว่า เดือน/ปีที่ค้นหา',
                      // '#หมายเหตุ : ไม่นับรวมผู้เช่าเข้าใหม่/วันเริ่มสัญญา ณ เดือนที่ค้นหา หรือวันเริ่มสัญญามากกว่า เดือน/ปีที่ค้นหา',
                      // '#หมายเหตุ : ไม่นับรวมผู้เช่าเข้าใหม่/วันเริ่มสัญญา ณ เดือนที่ค้นหา หรือวันเริ่มสัญญา >= เดือน/ปีที่ค้นหา',
                      Colors.deepOrange[800],
                      TextAlign.center,
                      FontWeight.w500,
                      Font_.Fonts_T,
                      12.5,
                      1),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1), //
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
                        ),
                        onTap: (Value_Chang_Zone_billpayMon == null ||
                                billpay_Mon.isEmpty)
                            ? null
                            : () async {
                                Insert_log.Insert_logs('รายงาน',
                                    'กดดูรายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)');
                                RE_billpay_future_Widget();
                              }),
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
                                    'กำลังโหลดรายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)...',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (billpay_Mon.isEmpty || Await_Status_Report1 == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (billpay_Mon.isEmpty &&
                                            Value_Chang_Zone_billpayMon !=
                                                null &&
                                            Await_Status_Report1 != null)
                                        ? 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  (ไม่พบข้อมูล ✖️)'
                                        : 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว) ',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'กำลังโหลดรายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  ✔️',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                  ],
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
                      // Container(
                      //   width: 40,
                      //   decoration: BoxDecoration(
                      //     color: Colors.teal[200],
                      //     borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(0),
                      //         topRight: Radius.circular(10),
                      //         bottomLeft: Radius.circular(0),
                      //         bottomRight: Radius.circular(10)),
                      //     border: Border.all(color: Colors.grey, width: 1),
                      //   ),
                      //   padding: EdgeInsets.all(4.0),
                      //   child: Text(
                      //     '1. ) ',
                      //     style: TextStyle(
                      //       color: ReportScreen_Color.Colors_Text2_,
                      //       fontWeight: FontWeight.bold,
                      //       fontFamily: FontWeight_.Fonts_T,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ผู้เช่า :',
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
                            value: Status_pe_History,

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
                                Status_pe_History = Status[selectedIndex]!;
                                Status_pe_ser_History = '${selectedIndex + 1}';
                              });
                              // print(selectedIndex);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ข้อมูลถึงเดือน/ปี :',
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
                                    (Mon_PeopleTeNant_Mon == null ||
                                            YE_PeopleTeNant_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_PeopleTeNant_Mon / $YE_PeopleTeNant_Mon',
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
                      //       value: (Mon_PeopleTeNant_Mon == null)
                      //           ? null
                      //           : Mon_PeopleTeNant_Mon,
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
                      //                 ReportScreen_Color.Colors_Text2_,
                      //                 TextAlign.center,
                      //                 FontWeight.w500,
                      //                 Font_.Fonts_T,
                      //                 Text_Size,
                      //                 1),
                      //           )
                      //       ],

                      //       onChanged: (value) async {
                      //         Mon_PeopleTeNant_Mon = value;
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ข้อมูลถึงปี :',
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
                      //       value: (YE_PeopleTeNant_Mon == null)
                      //           ? null
                      //           : YE_PeopleTeNant_Mon,
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
                      //         YE_PeopleTeNant_Mon = value;

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
                                searchController: Dropdown_Controller_zone[1],
                                value: (Value_Chang_Zone_People_TeNant == null)
                                    ? null
                                    : Value_Chang_Zone_People_TeNant,
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
                                hint: (Value_Chang_Zone_People_TeNant == null)
                                    ? null
                                    : Text(
                                        '$Value_Chang_Zone_People_TeNant',
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
                                    Value_Chang_Zone_People_TeNant = value!;
                                    Value_Chang_Zone_Ser_People_TeNant =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[1].clear();
                                  }
                                }),
                          ),
                          //  DropdownButtonFormField2(
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
                          //   value: Value_Chang_Zone_People_TeNant,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       Value_Chang_Zone_People_TeNant = value!;
                          //       Value_Chang_Zone_Ser_People_TeNant =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (Value_Chang_Zone_Ser_People_TeNant == null ||
                                  Mon_PeopleTeNant_Mon == null)
                              ? null
                              : () async {
                                  if (Value_Chang_Zone_Ser_People_TeNant !=
                                      null) {
                                    setState(() {
                                      Await_Status_Report2 = 0;
                                    });
                                    Dia_log();
                                  }
                                  try {
                                    People_tenant().then((result) {
                                      // print('People_tenant');
                                      // print('People_tenant');
                                      setState(() {
                                        Await_Status_Report2 = 1;
                                      });
                                      Timer(const Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                      });
                                    });
                                  } catch (e) {
                                    Timer(const Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                  // People_tenant();
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
                child: Row(
                  children: [
                    InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1), //
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
                        ),
                        onTap: (Value_Chang_Zone_People_TeNant == null ||
                                teNantModels.isEmpty ||
                                Status_pe_History == null)
                            ? null
                            : () async {
                                Insert_log.Insert_logs(
                                    'รายงาน', 'กดดูรายงานประวัติผู้เช่า');
                                RE_TeNant_Widget();
                              }),
                    // (teNantModels.isEmpty ||
                    //         Await_Status_Report2 == null ||
                    //         Status_pe_History == null)
                    //     ? Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Translate.TranslateAndSetText(
                    //             (teNantModels.isEmpty &&
                    //                     Value_Chang_Zone_People_TeNant !=
                    //                         null &&
                    //                     Await_Status_Report2 != null)
                    //                 ? 'รายงานประวัติผู้เช่า (ไม่พบข้อมูล ✖️)'
                    //                 : 'รายงานประวัติผู้เช่า',
                    //             ReportScreen_Color.Colors_Text1_,
                    //             TextAlign.center,
                    //             FontWeight.w500,
                    //             Font_.Fonts_T,
                    //             16,
                    //             1),
                    //       )
                    //     : FutureBuilder(
                    //         future: People_tenant(),
                    //         builder: (context, snapshot) {
                    //           if (snapshot.connectionState ==
                    //               ConnectionState.waiting) {
                    //             return Center(
                    //               child: Column(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Text('Downloading data...'),
                    //                   SizedBox(height: 20),
                    //                   LinearProgressIndicator(),
                    //                 ],
                    //               ),
                    //             );
                    //           } else if (snapshot.hasError) {
                    //             return Center(
                    //               child: Text('Error: ${snapshot.error}'),
                    //             );
                    //           } else {
                    //             return Text(
                    //               'รายงานประวัติผู้เช่า ✔️',
                    //             );
                    //           }
                    //         },
                    //       ),
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
                                    'กำลังโหลดรายงานประวัติผู้เช่า...',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (teNantModels.isEmpty ||
                                Await_Status_Report2 == null ||
                                Status_pe_History == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (teNantModels.isEmpty &&
                                            Value_Chang_Zone_People_TeNant !=
                                                null &&
                                            Await_Status_Report2 != null)
                                        ? 'รายงานประวัติผู้เช่า (ไม่พบข้อมูล ✖️)'
                                        : 'รายงานประวัติผู้เช่า',
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
                                    'รายงานประวัติผู้เช่า ✔️',
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
                            'ผู้เช่า :',
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
                            // value: Status_pe_New,
                            hint: Translate.TranslateAndSetText(
                                (Status_pe_New == null)
                                    ? 'สัญญาปัจจุบัน'
                                    : '$Status_pe_New',
                                ReportScreen_Color.Colors_Text2_,
                                TextAlign.center,
                                FontWeight.w500,
                                Font_.Fonts_T,
                                Text_Size,
                                1),
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
                            items: Status_new.map(
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
                              int selectedIndex = Status_new.indexWhere(
                                  (item) => item == value);
                              setState(() {
                                Status_pe_New = Status_new[selectedIndex]!;
                                Status_pe_ser_New = '${selectedIndex}';
                              });
                              // print(selectedIndex);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ค้นจากวันที่ :',
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
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 130,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            // value:
                            //(Status_pe_New == null)
                            //     ? 'เดือนที่ทำสัญญา'
                            //     : Status_pe_New,
                            hint: Translate.TranslateAndSetText(
                                (Status_date == null)
                                    ? 'ทำสัญญา'
                                    : '$Status_date',
                                ReportScreen_Color.Colors_Text2_,
                                TextAlign.center,
                                FontWeight.w500,
                                Font_.Fonts_T,
                                Text_Size,
                                1),
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
                            buttonWidth: 130,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: '0',
                                child: Translate.TranslateAndSetText(
                                    'ทำสัญญา',
                                    Colors.grey,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                              DropdownMenuItem<String>(
                                value: '1',
                                child: Translate.TranslateAndSetText(
                                    'เริ่มสัญญา',
                                    Colors.grey,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],

                            onChanged: (value) async {
                              // int selectedIndex =
                              //     Status.indexWhere((item) => item == value);
                              setState(() {
                                // Status_pe_New = Status[selectedIndex]!;
                                Status_ser_date = '${value}';
                              });
                              // print(selectedIndex);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            (Status_ser_date == null ||
                                    Status_ser_date.toString() == '0')
                                ? 'เดือน/ปี ที่ทำสัญญา :'
                                : 'เดือน/ปี ที่เริ่มสัญญา',
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
                                    (Mon_PeopleTeNantNew_Mon == null ||
                                            YE_PeopleTeNantNew_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_PeopleTeNantNew_Mon / $YE_PeopleTeNantNew_Mon',
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
                      //       value: (Mon_PeopleTeNantNew_Mon == null)
                      //           ? null
                      //           : Mon_PeopleTeNantNew_Mon,
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
                      //         Mon_PeopleTeNantNew_Mon = value;
                      //         // lastDay2();
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       (Status_ser_date == null ||
                      //               Status_ser_date.toString() == '0')
                      //           ? 'ปีที่ทำสัญญา :'
                      //           : 'ปีที่เริ่มสัญญา',
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
                      //       value: (YE_PeopleTeNantNew_Mon == null)
                      //           ? null
                      //           : YE_PeopleTeNantNew_Mon,
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
                      //         YE_PeopleTeNantNew_Mon = value;
                      //         // lastDay2();
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
                            'โซนที่ทำสัญญา :',
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
                                searchController: Dropdown_Controller_zone[2],
                                value:
                                    (Value_Chang_Zone_People_TeNantNew == null)
                                        ? null
                                        : Value_Chang_Zone_People_TeNantNew,
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
                                hint:
                                    (Value_Chang_Zone_People_TeNantNew == null)
                                        ? null
                                        : Text(
                                            '$Value_Chang_Zone_People_TeNantNew',
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
                                    Value_Chang_Zone_People_TeNantNew = value!;
                                    Value_Chang_Zone_Ser_People_TeNantNew =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[2].clear();
                                  }
                                }),
                          ),
                          // DropdownButtonFormField2(
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
                          //   value: Value_Chang_Zone_People_TeNantNew,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       Value_Chang_Zone_People_TeNantNew = value!;
                          //       Value_Chang_Zone_Ser_People_TeNantNew =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $Value_Chang_Zone_Pakan  //${Value_Chang_Zone_Pakan_Ser}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (Value_Chang_Zone_People_TeNantNew == null)
                              ? null
                              : () async {
                                  if (Value_Chang_Zone_Ser_People_TeNantNew !=
                                      null) {
                                    setState(() {
                                      Await_Status_Report3 = 0;
                                      Await_Status_Report4 = 0;
                                    });
                                    Dia_log();
                                  }
                                  try {
                                    People_tenant_New().then((result) {
                                      // print('People_tenant_New');
                                      // print('People_tenant_New');
                                      setState(() {
                                        Await_Status_Report3 = 1;
                                        Await_Status_Report4 = 1;
                                      });
                                      Timer(const Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                      });
                                    });
                                  } catch (e) {
                                    Timer(const Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                  // People_tenant_New();
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
              ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            '[ค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ-อุปกรณ์/รับชำระแล้ว] :',
                            ReportScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       '[ค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ/รับล่วงหน้าชำระแล้ว] วันที่ตั้งหนี้:',
                      //       ReportScreen_Color.Colors_Text1_,
                      //       TextAlign.center,
                      //       FontWeight.w500,
                      //       Font_.Fonts_T,
                      //       16,
                      //       1),
                      // ),
                      // Container(
                      //   // width: 200,
                      //   decoration: BoxDecoration(
                      //     color: Colors.red[100],
                      //     borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(10),
                      //         topRight: Radius.circular(10),
                      //         bottomLeft: Radius.circular(10),
                      //         bottomRight: Radius.circular(10)),
                      //     border: Border.all(color: Colors.grey, width: 1),
                      //   ),
                      //   padding: EdgeInsets.all(4.0),
                      //   child: Translate.TranslateAndSetText(
                      //       (Mon_PeopleTeNantNewsub_Mon == null ||
                      //               YE_PeopleTeNantNewsub_Mon == null)
                      //           ? '25 - สิ้นเดือน'
                      //           : '$day_lday_2',
                      //       ReportScreen_Color.Colors_Text1_,
                      //       TextAlign.center,
                      //       FontWeight.w500,
                      //       Font_.Fonts_T,
                      //       16,
                      //       1),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ประเภท :',
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
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          width: 130,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            // value:
                            //(Status_pe_New == null)
                            //     ? 'เดือนที่ทำสัญญา'
                            //     : Status_pe_New,
                            hint: Translate.TranslateAndSetText(
                                (Status_date_pay == null)
                                    ? 'ทั้งหมด'
                                    : '$Status_date_pay ',
                                ReportScreen_Color.Colors_Text2_,
                                TextAlign.center,
                                FontWeight.w500,
                                Font_.Fonts_T,
                                Text_Size,
                                1),
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
                            buttonWidth: 130,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: '0',
                                child: Translate.TranslateAndSetText(
                                    'ทั้งหมด',
                                    Colors.grey,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                              DropdownMenuItem<String>(
                                value: '1',
                                child: Translate.TranslateAndSetText(
                                    'เดือนที่รับชำระ',
                                    Colors.grey,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],

                            onChanged: (value) async {
                              // int selectedIndex =
                              //     Status.indexWhere((item) => item == value);
                              setState(() {
                                // Status_pe_New = Status[selectedIndex]!;
                                Status_ser_date_pay = '${value}';
                              });
                              // print(selectedIndex);
                            },
                          ),
                        ),
                      ),
                      if (Status_ser_date_pay.toString() == '1')
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSetText(
                              'เดือน/ปี ที่รับชำระ :',
                              // 'เดือนที่ตั้งหนี้ :',
                              ReportScreen_Color.Colors_Text2_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              Text_Size,
                              1),
                        ),
                      if (Status_ser_date_pay.toString() == '1')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        backgroundColor:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        titlePadding: const EdgeInsets.all(0.0),
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        actionsPadding:
                                            const EdgeInsets.all(6.0),
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
                                      (Mon_PeopleTeNantNewsub_Mon == null ||
                                              YE_PeopleTeNantNewsub_Mon == '')
                                          ? 'เลือก'
                                          : '$Mon_PeopleTeNantNewsub_Mon / $YE_PeopleTeNantNewsub_Mon',
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
                      //       value: (Mon_PeopleTeNantNewsub_Mon == null)
                      //           ? null
                      //           : Mon_PeopleTeNantNewsub_Mon,
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
                      //         Mon_PeopleTeNantNewsub_Mon = value;
                      //         // lastDay2();
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ปีที่รับชำระ :',
                      //       // 'ปีที่ตั้งหนี้ :',
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
                      //       value: (YE_PeopleTeNantNewsub_Mon == null)
                      //           ? null
                      //           : YE_PeopleTeNantNewsub_Mon,
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
                      //         YE_PeopleTeNantNewsub_Mon = value;
                      //         // lastDay2();
                      //         // if (Value_Chang_Zone_Income !=
                      //         //     null) {
                      //         //   red_Trans_billIncome();
                      //         //   red_Trans_billMovemen();
                      //         // }
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ]),
                  )),
              if (Status_ser_date_pay.toString() == '1')
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Row(children: [
                    Translate.TranslateAndSetText(
                        '#หมายเหตุ : เดือน/ปีที่รับชำระ วันที่ 1-24',
                        Colors.deepOrange[800],
                        TextAlign.center,
                        FontWeight.w500,
                        Font_.Fonts_T,
                        12.5,
                        1),
                  ]),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1), //
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
                        ),
                        onTap: (Value_Chang_Zone_People_TeNantNew == null ||
                                teNantModels_New.isEmpty)
                            ? null
                            : () async {
                                Insert_log.Insert_logs(
                                    'รายงาน', 'กดดูรายงานผู้เช่ารายใหม่-1');
                                RE_TeNant_New_Widget();
                              }),
                    (Await_Status_Report3 == 0)
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
                                    'กำลังโหลดรายงานผู้เช่ารายใหม่-1...',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (teNantModels_New.isEmpty ||
                                Await_Status_Report3 == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (teNantModels_New.isEmpty &&
                                            Value_Chang_Zone_People_TeNantNew !=
                                                null &&
                                            Await_Status_Report3 != null)
                                        ? 'รายงานผู้เช่ารายใหม่-1 (ไม่พบข้อมูล ✖️)'
                                        : 'รายงานผู้เช่ารายใหม่-1',
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
                                    'รายงานผู้เช่ารายใหม่-1 ✔️',
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1), //
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
                        ),
                        onTap: (Value_Chang_Zone_People_TeNantNew == null ||
                                teNantModels_New.isEmpty)
                            ? null
                            : () async {
                                Insert_log.Insert_logs(
                                    'รายงาน', 'กดดูรายงานผู้เช่ารายใหม่-2');
                                RE_TeNant_New2_Widget();
                              }),
                    (Await_Status_Report4 == 0)
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
                                    'กำลังโหลดรายงานผู้เช่ารายใหม่-2...',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (teNantModels_New.isEmpty ||
                                Await_Status_Report4 == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (teNantModels_New.isEmpty &&
                                            Value_Chang_Zone_People_TeNantNew !=
                                                null &&
                                            Await_Status_Report4 != null)
                                        ? 'รายงานผู้เช่ารายใหม่-2 (ไม่พบข้อมูล ✖️)'
                                        : 'รายงานผู้เช่ารายใหม่-2',
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
                                    'รายงานผู้เช่ารายใหม่-2 ✔️',
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
            ])));
  }

  ///////////////////////////----------------------------------------------->(ค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว))
  RE_billpay_future_Widget() {
    int? ser_index;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //
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
                      (Value_Chang_Zone_billpayMon == null)
                          ? 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  (กรุณาเลือกโซน)'
                          : 'รายงานค่าเช่าพื้นที่ดิน-ค่าเช่า-บริการ(รับล่วงหน้าประจำเดือน/ชำระแล้ว)  (โซน : $Value_Chang_Zone_billpayMon)',
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
                              'วันที่ตั้งหนี้ชำระ: $sdate_1 ถึง $ldate_1',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ReportScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'ทั้งหมด: ${billpay_Mon.length}',
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // for (int index = 0; index < expModels.length; index++)
                          //   Text(
                          //     '[ ]: ${expModels[index].expname}',
                          //     textAlign: TextAlign.end,
                          //     style: const TextStyle(
                          //       fontSize: 14,
                          //       color: ReportScreen_Color.Colors_Text1_,
                          //       // fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T,
                          //     ),
                          //   )
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.TiTile_Colors
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
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
                                              int selectedIndex = expModels
                                                  .indexWhere((items) =>
                                                      items.ser == item.ser);
                                              // print(expModels[selectedIndex]
                                              //     .expname);
                                              // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                              //This rebuilds the StatefulWidget to update the button's text
                                              setState(() {
                                                if (item.st! == '1') {
                                                  expModels[selectedIndex].st =
                                                      '0';
                                                } else {
                                                  expModels[selectedIndex].st =
                                                      '1';
                                                }
                                              });
                                              //This rebuilds the dropdownMenu Widget to update the check mark
                                              menuSetState(() {});
                                            },
                                            child: Container(
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                children: [
                                                  if (item.st! == '1')
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
                                color: AppbackgroundColor.TiTile_Colors
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              width: 200,
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
                                                  if (Type_vat[index]["st"]! ==
                                                      '1') {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Row(
                                                  children: [
                                                    if (Type_vat[index]
                                                            ["st"]! ==
                                                        '1')
                                                      Icon(
                                                        Icons
                                                            .check_box_outlined,
                                                        color:
                                                            Colors.green[400],
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
                    ),
                  ],
                );
              }),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 3)),
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
                              ? MediaQuery.of(context).size.width * 0.93
                              : (billpay_Mon.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1100,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child:
                              // (teNantModels.length == 0)
                              //     ? const Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: [
                              //           Center(
                              //             child: Text(
                              //               'ไม่พบข้อมูล ณ วันที่เลือก',
                              //               style: TextStyle(
                              //                 color:
                              //                     ReportScreen_Color.Colors_Text1_,
                              //                 fontWeight: FontWeight.bold,
                              //                 fontFamily: FontWeight_.Fonts_T,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       )
                              //     :
                              Column(
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
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 50,
                                      child: const Text(
                                        'ลำดับที่',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'วันที่ชำระ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขใบกำกับภาษี',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รายชื่อลูกค้า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'รหัสสาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'สาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'รหัสพื้นที่',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'เลขประจำตัวผู้เสียภาษี',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    for (int index = 0;
                                        index < expModels.length;
                                        index++)
                                      // for (int index_v = 0;
                                      //     index_v < Type_vat.length;
                                      //     index_v++)
                                      if (expModels[index].st! == '1')
                                        Expanded(
                                          flex: Type_vat.where((element) =>
                                                  element["st"]! == '1')
                                              .toList()
                                              .length,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 0, 2, 0),
                                            child: Row(
                                              children: [
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'pvat' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(ก่อนVAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'vat' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(VAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'total' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(รวมVAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'สถานะ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: const Text(
                                    //     'ค่าเช่า',
                                    //     textAlign: TextAlign.end,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: const Text(
                                    //     'ค่าเช่า-ภาษีมูลค่าเพิ่ม',
                                    //     textAlign: TextAlign.end,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: const Text(
                                    //     'ค่าบริการพื้นที่',
                                    //     textAlign: TextAlign.end,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: const Text(
                                    //     'ค่าบริการพื้นที่-ภาษีมูลค่าเพิ่ม',
                                    //     textAlign: TextAlign.end,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: const Text(
                                    //     ' จำนวนเงินรวม ',
                                    //     textAlign: TextAlign.end,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  // height: (Responsive.isDesktop(context))
                                  //     ? MediaQuery.of(context).size.width * 0.255
                                  //     : MediaQuery.of(context).size.height * 0.45,
                                  child: ListView.builder(
                                itemCount: billpay_Mon.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
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
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${index + 1}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index].pdate == null)
                                                  ? ''
                                                  : '${DateFormat('dd-MM').format(DateTime.parse('${billpay_Mon[index].pdate} 00:00:00'))}-${DateTime.parse('${billpay_Mon[index].pdate} 00:00:00').year + 0}',
                                              // '${transKonModels[index].pdate}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index].doctax ==
                                                          null ||
                                                      billpay_Mon[index]
                                                              .doctax! ==
                                                          '')
                                                  ? '${billpay_Mon[index].docno}'
                                                  : '${billpay_Mon[index].doctax}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${billpay_Mon[index].cname}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index]
                                                          .zn!
                                                          .split('_')[0]
                                                          .length <=
                                                      4)
                                                  ? 'CMN0${billpay_Mon[index].zn!.split('_')[0]}'
                                                  : 'CMN${billpay_Mon[index].zn!.split('_')[0]}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index].zn != null)
                                                  ? '${billpay_Mon[index].zn}'
                                                  : '${billpay_Mon[index].znn}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index].ln == null)
                                                  ? ''
                                                  : '${billpay_Mon[index].ln}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${billpay_Mon[index].tax}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          for (int index2 = 0;
                                              index2 < expModels.length;
                                              index2++)
                                            if (expModels[index2].st! == '1')
                                              Expanded(
                                                flex: Type_vat.where(
                                                    (element) =>
                                                        element["st"]! ==
                                                        '1').toList().length,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          1, 0, 1, 0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      // color: Colors
                                                      //     .deepPurple[300]!
                                                      //     .withOpacity(0.6),
                                                      border: Border(
                                                        right: BorderSide(
                                                            color: Colors.grey),
                                                        // left: BorderSide(
                                                        //     color: Colors
                                                        //         .grey),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'pvat' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (billpay_Mon[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: Billpay_PvatGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'vat' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (billpay_Mon[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: Billpay_VatGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'total' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (billpay_Mon[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: Billpay_TotalGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (billpay_Mon[index].st == null)
                                                  ? '-'
                                                  : '${billpay_Mon[index].st}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (billpay_Mon[index].rent_vat ==
                                          //             null)
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${billpay_Mon[index].rent_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (billpay_Mon[index]
                                          //                 .service_pvat ==
                                          //             null)
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${billpay_Mon[index].service_pvat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (billpay_Mon[index].service_vat ==
                                          //             null)
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${billpay_Mon[index].service_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (billpay_Mon[index].rent_total ==
                                          //             null)
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                     '${billpay_Mon[index].rent_total}') +
                                          //                 double.parse(
                                          //                     '${billpay_Mon[index].service_total}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
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
                    if (billpay_Mon.length != 0)
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
                              Value_Report = 'รายงานค่าบริการรับล่วงหน้า';
                              Pre_and_Dow = 'Download';
                            });
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
                            Value_Chang_Zone_billpayMon = null;
                            Value_Chang_Zone_billpayMon_Ser = null;

                            Await_Status_Report1 = null;

                            billpay_Mon.clear();
                            _billpay_Mon.clear();
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

  ///////////////////////////----------------------------------------------billpay_Mon->(รายงานรับล่วงหน้าชำระแล้ว)
  Future<String> Billpay_PvatGCExpSer(int index, serexp) async {
    String textdata = '${billpay_Mon[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double pvat = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['pvat_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(pvat.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  Future<String> Billpay_VatGCExpSer(int index, serexp) async {
    String textdata = '${billpay_Mon[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double vat = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['vat_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(vat.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  Future<String> Billpay_TotalGCExpSer(int index, serexp) async {
    String textdata = '${billpay_Mon[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double total = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['total_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(total.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  ///////////////////////////----------------------------------------------->(รายงานประวัติผู้เช่า)
  Future<String> TeNant_PvatGCExpSer(int index, serexp) async {
    String textdata = '${teNantModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double pvat = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['pvat_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(pvat.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  Future<String> TeNant_VatGCExpSer(int index, serexp) async {
    String textdata = '${teNantModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double vat = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['vat_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(vat.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  Future<String> TeNant_TotalGCExpSer(int index, serexp) async {
    String textdata = '${teNantModels[index].exp_array}';

    // String textdata2 = await textdata.substring(1, textdata.length - 1);

    try {
      List<dynamic> dataList = json.decode(textdata);

      double total = dataList
          .whereType<Map<String, dynamic>>()
          .where((element) => element['ser_exp'].toString() == '$serexp')
          .map((element) => double.parse(element['total_exp'].toString()))
          .fold(0, (prev, wht) => prev + wht);
      return '${nFormat.format(double.parse(total.toString()))}';
    } catch (e) {
      return '0.00';
    }
  }

  ///////////////////////////----------------------------------------------->(รายงานประวัติผู้เช่า)
  RE_TeNant_Widget() {
    int? ser_index;
    var Date_Time = DateTime.now();
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
                      (Value_Chang_Zone_People_TeNant == null)
                          ? 'รายงานประวัติผู้เช่า  (กรุณาเลือกโซน)'
                          : 'รายงานประวัติผู้เช่า  (โซน : $Value_Chang_Zone_People_TeNant)',
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
                              'อัพเดต ณ :${Date_Time}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ReportScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'ทั้งหมด: ${teNantModels.length}',
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                'สถานะ : ${Status_pe_History}',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ReportScreen_Color.Colors_Text1_,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              )),
                          // for (int index = 0; index < expModels.length; index++)
                          //   Text(
                          //     '[ ]: ${expModels[index].expname}',
                          //     textAlign: TextAlign.end,
                          //     style: const TextStyle(
                          //       fontSize: 14,
                          //       color: ReportScreen_Color.Colors_Text1_,
                          //       // fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T,
                          //     ),
                          //   )
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.TiTile_Colors
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
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
                                              int selectedIndex = expModels
                                                  .indexWhere((items) =>
                                                      items.ser == item.ser);
                                              // print(expModels[selectedIndex]
                                              //     .expname);
                                              // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                              //This rebuilds the StatefulWidget to update the button's text
                                              setState(() {
                                                if (item.st! == '1') {
                                                  expModels[selectedIndex].st =
                                                      '0';
                                                } else {
                                                  expModels[selectedIndex].st =
                                                      '1';
                                                }
                                              });
                                              //This rebuilds the dropdownMenu Widget to update the check mark
                                              menuSetState(() {});
                                            },
                                            child: Container(
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Row(
                                                children: [
                                                  if (item.st! == '1')
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
                                color: AppbackgroundColor.TiTile_Colors
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              width: 200,
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
                                                  if (Type_vat[index]["st"]! ==
                                                      '1') {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Row(
                                                  children: [
                                                    if (Type_vat[index]
                                                            ["st"]! ==
                                                        '1')
                                                      Icon(
                                                        Icons
                                                            .check_box_outlined,
                                                        color:
                                                            Colors.green[400],
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
                    ),
                  ],
                );
              }),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 2)),
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
                              ? MediaQuery.of(context).size.width * 1.5
                              : (teNantModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1400,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child:
                              // (teNantModels.length == 0)
                              //     ? const Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: [
                              //           Center(
                              //             child: Text(
                              //               'ไม่พบข้อมูล ณ วันที่เลือก',
                              //               style: TextStyle(
                              //                 color:
                              //                     ReportScreen_Color.Colors_Text1_,
                              //                 fontWeight: FontWeight.bold,
                              //                 fontFamily: FontWeight_.Fonts_T,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       )
                              //     :
                              Column(
                            children: <Widget>[
                              Container(
                                // width: 1050,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.TiTile_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 50,
                                      child: const Text(
                                        'ลำดับที่',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ชื่อ-สกุล ผู้เช่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขบปช.',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รหัสสาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ชื่อสาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขที่สัญญา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขสัญญาเก่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขที่สัญญาประกัน',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขล็อค',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่เริ่มเช่า',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่สิ้นสุดสัญญา',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ประเภทสินค้า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'น้ำ + ไฟ',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),

                                    for (int index = 0;
                                        index < expModels.length;
                                        index++)
                                      // for (int index_v = 0;
                                      //     index_v < Type_vat.length;
                                      //     index_v++)
                                      if (expModels[index].st! == '1')
                                        Expanded(
                                          flex: Type_vat.where((element) =>
                                                  element["st"]! == '1')
                                              .toList()
                                              .length,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 0, 2, 0),
                                            child: Row(
                                              children: [
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'pvat' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(ก่อนVAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'vat' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(VAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                if (Type_vat.where((element) =>
                                                            element["type"]! ==
                                                                'total' &&
                                                            element["st"]! ==
                                                                '1')
                                                        .toList()
                                                        .length !=
                                                    0)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color:
                                                                  Colors.grey),
                                                          // left: BorderSide(
                                                          //     color: Colors
                                                          //         .grey),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${expModels[index].expname}(รวมVAT)',
                                                        textAlign:
                                                            TextAlign.right,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .deepPurple[
                                                                300],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าบริการ',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    if (Type_vat.where((element) =>
                                                element["type"]! == 'pvat' &&
                                                element["st"]! == '1')
                                            .toList()
                                            .length !=
                                        0)
                                      const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'เงินประกัน(ก่อนVAT)',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                              fontSize: 14.0
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                    if (Type_vat.where((element) =>
                                                element["type"]! == 'vat' &&
                                                element["st"]! == '1')
                                            .toList()
                                            .length !=
                                        0)
                                      const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'เงินประกัน(VAT)',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                              fontSize: 14.0
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                    if (Type_vat.where((element) =>
                                                element["type"]! == 'total' &&
                                                element["st"]! == '1')
                                            .toList()
                                            .length !=
                                        0)
                                      const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'เงินประกัน(รวมVAT)',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                              fontSize: 14.0
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่ยกเลิก',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ผู้ดูแล',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขอ้างอิง',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'สถานะ',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
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
                                itemCount: teNantModels.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Container(
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
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${index + 1}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].cname}',
                                              // '${transKonModels[index].pdate}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 2,
                                              '${teNantModels[index].tax}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 2,
                                              (teNantModels[index].zn != null)
                                                  ? (teNantModels[index]
                                                              .zn!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels[index].zn!.split('_')[0]}'
                                                      : 'CMN${teNantModels[index].zn!.split('_')[0]}'
                                                  : (teNantModels[index]
                                                              .zn1!
                                                              .split('_')[0]
                                                              .length <
                                                          4)
                                                      ? 'CMN0${teNantModels[index].zn1!.split('_')[0]}'
                                                      : 'CMN${teNantModels[index].zn1!.split('_')[0]}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Tooltip(
                                              richMessage: TextSpan(
                                                text: (teNantModels[index].zn !=
                                                        null)
                                                    ? '${teNantModels[index].zn}'
                                                    : '${teNantModels[index].zn1}',
                                                style: const TextStyle(
                                                  color: HomeScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  //fontSize: 10.0
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey[200],
                                              ),
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 2,
                                                (teNantModels[index].zn != null)
                                                    ? '${teNantModels[index].zn}'
                                                    : '${teNantModels[index].zn1}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Tooltip(
                                              richMessage: TextSpan(
                                                text: (teNantModels[index]
                                                            .cid ==
                                                        null)
                                                    ? ''
                                                    : '${teNantModels[index].cid}',
                                                style: const TextStyle(
                                                  color: HomeScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  //fontSize: 10.0
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey[200],
                                              ),
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels[index].cid ==
                                                        null)
                                                    ? ''
                                                    : '${teNantModels[index].cid}',
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Tooltip(
                                              richMessage: TextSpan(
                                                text: (teNantModels[index]
                                                            .renew_cid ==
                                                        null)
                                                    ? ''
                                                    : '${teNantModels[index].renew_cid}',
                                                style: const TextStyle(
                                                  color: HomeScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  //fontSize: 10.0
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey[200],
                                              ),
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels[index]
                                                            .renew_cid ==
                                                        null)
                                                    ? ''
                                                    : '${teNantModels[index].renew_cid}',
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels[index].docno ==
                                                      null)
                                                  ? ''
                                                  : '${teNantModels[index].docno}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].ln}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].sdate}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].ldate}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].stype}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${(teNantModels[index].water_electri == null) ? '' : teNantModels[index].water_electri.toString()}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),

                                          for (int index2 = 0;
                                              index2 < expModels.length;
                                              index2++)
                                            if (expModels[index2].st! == '1')
                                              Expanded(
                                                flex: Type_vat.where(
                                                    (element) =>
                                                        element["st"]! ==
                                                        '1').toList().length,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          1, 0, 1, 0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      // color: Colors
                                                      //     .deepPurple[300]!
                                                      //     .withOpacity(0.6),
                                                      border: Border(
                                                        right: BorderSide(
                                                            color: Colors.grey),
                                                        // left: BorderSide(
                                                        //     color: Colors
                                                        //         .grey),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'pvat' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (teNantModels[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: TeNant_PvatGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'vat' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (teNantModels[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: TeNant_VatGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                        if (Type_vat.where((element) =>
                                                                    element["type"]! ==
                                                                        'total' &&
                                                                    element["st"]! ==
                                                                        '1')
                                                                .toList()
                                                                .length !=
                                                            0)
                                                          Expanded(
                                                            flex: 1,
                                                            child: (teNantModels[
                                                                            index]
                                                                        .exp_array ==
                                                                    null)
                                                                ? Text(
                                                                    '0.00',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .deepPurple[
                                                                          300],
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  )
                                                                : FutureBuilder<
                                                                    String>(
                                                                    future: TeNant_TotalGCExpSer(
                                                                        index,
                                                                        expModels[index2]
                                                                            .ser),
                                                                    initialData:
                                                                        '0', // Set an initial value as a string
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<String>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return Text(
                                                                          '0.00',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Text(
                                                                          snapshot.data ??
                                                                              '', // Display the result or an empty string if null
                                                                          // maxLines: 1,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.deepPurple[300],
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     // '${teNantModels[index].rent_total}',
                                          //     (teNantModels[index].rent_total ==
                                          //             null)
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels[index].rent_total}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels[index]
                                          //                 .service_total ==
                                          //             null)
                                          //         ? '0.00'
                                          //         :
                                          // nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels[index].service_total}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          if (Type_vat.where((element) =>
                                                  element["type"]! == 'pvat' &&
                                                  element["st"]! ==
                                                      '1').toList().length !=
                                              0)
                                            Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels[index]
                                                            .pvat_pakan ==
                                                        null)
                                                    ? '0.00'
                                                    : nFormat
                                                        .format(double.parse(
                                                            '${teNantModels[index].pvat_pakan}'))
                                                        .toString(),

                                                //  '${teNantModels[index].pvat_pakan}',
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          if (Type_vat.where((element) =>
                                                  element["type"]! == 'vat' &&
                                                  element["st"]! ==
                                                      '1').toList().length !=
                                              0)
                                            Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels[index]
                                                            .pakan_vat ==
                                                        null)
                                                    ? '0.00'
                                                    : nFormat
                                                        .format(double.parse(
                                                            '${teNantModels[index].pakan_vat}'))
                                                        .toString(),

                                                //  '${teNantModels[index].pvat_pakan}',
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          if (Type_vat.where((element) =>
                                                  element["type"]! == 'total' &&
                                                  element["st"]! ==
                                                      '1').toList().length !=
                                              0)
                                            Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels[index]
                                                            .total_pakan ==
                                                        null)
                                                    ? '0.00'
                                                    : nFormat
                                                        .format(double.parse(
                                                            '${teNantModels[index].total_pakan}'))
                                                        .toString(),

                                                //  '${teNantModels[index].pvat_pakan}',
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels[index]
                                                          .cc_date
                                                          .toString() ==
                                                      '0000-00-00')
                                                  ? ''
                                                  : '${teNantModels[index].cc_date}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${teNantModels[index].name_user}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels[index].wnote ==
                                                      null)
                                                  ? ''
                                                  : '${teNantModels[index].wnote}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels[index].st == null)
                                                  ? ''
                                                  : (teNantModels[index]
                                                              .st
                                                              .toString() ==
                                                          'ยกเลิกสัญญา')
                                                      ? 'ยกเลิกสัญญา'
                                                      : datex.isAfter(DateTime
                                                                      .parse(
                                                                          '${teNantModels[index].ldate} 00:00:00.000')
                                                                  .subtract(
                                                                      const Duration(
                                                                          days:
                                                                              0))) ==
                                                              true
                                                          ? 'หมดสัญญา'
                                                          : '${teNantModels[index].st}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: (teNantModels[index]
                                                              .st ==
                                                          null)
                                                      ? PeopleChaoScreen_Color
                                                          .Colors_Text2_
                                                      : (teNantModels[index]
                                                                  .st
                                                                  .toString() ==
                                                              'ยกเลิกสัญญา')
                                                          ? Colors.red
                                                          : datex.isAfter(DateTime
                                                                          .parse(
                                                                              '${teNantModels[index].ldate} 00:00:00.000')
                                                                      .subtract(
                                                                          const Duration(
                                                                              days: 0))) ==
                                                                  true
                                                              ? Colors.orange
                                                              : Colors.green,

                                                  //  PeopleChaoScreen_Color
                                                  //     .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
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
                    if (teNantModels.length != 0)
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
                              Value_Report = 'รายงานประวัติผู้เช่า';
                              Pre_and_Dow = 'Download';
                            });
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
                            Value_Chang_Zone_People_TeNant = null;
                            Value_Chang_Zone_Ser_People_TeNant = null;

                            Await_Status_Report2 = null;

                            teNantModels.clear();
                            _teNantModels.clear();
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

  ///////////////////////////----------------------------------------------->(รายงานผู้เช่ารายใหม่-1)
  RE_TeNant_New_Widget() {
    int? ser_index;
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
                      (Value_Chang_Zone_People_TeNantNew == null)
                          ? 'รายงานผู้เช่ารายใหม่-1  (กรุณาเลือกโซน)'
                          : 'รายงานผู้เช่ารายใหม่-1  (โซน : $Value_Chang_Zone_People_TeNantNew)',
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
                              'เดือน/ปีที่ทำสัญญา : ${monthsInThai[int.parse(Mon_PeopleTeNantNew_Mon.toString()) - 1]} ${YE_PeopleTeNantNew_Mon}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ReportScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'ทั้งหมด: ${teNantModels_New.length}',
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
                    Container(
                      width: MediaQuery.of(context).size.width,
                      // padding: EdgeInsets.all(10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Expanded(
                          //   child: _searchBar_GetbackPakan(),
                          // ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
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
                              ? MediaQuery.of(context).size.width * 2.3
                              : (teNantModels_New.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1400,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child:
                              // (teNantModels.length == 0)
                              //     ? const Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: [
                              //           Center(
                              //             child: Text(
                              //               'ไม่พบข้อมูล ณ วันที่เลือก',
                              //               style: TextStyle(
                              //                 color:
                              //                     ReportScreen_Color.Colors_Text1_,
                              //                 fontWeight: FontWeight.bold,
                              //                 fontFamily: FontWeight_.Fonts_T,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       )
                              //     :
                              Column(
                            children: <Widget>[
                              Container(
                                // width: 1050,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.TiTile_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                // padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 50,
                                      child: const Text(
                                        'ลำดับที่',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขที่สัญญา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: 80,
                                      child: const Text(
                                        'เลขบัญชีVAN',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รหัสสาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ชื่อสาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขล็อค',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ชื่อ-สกุล ผู้เช่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่เริ่มเช่า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่สิ้นสุดสัญญา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ระยะเวลา',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ประเภทสินค้า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'น้ำ + ไฟ',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่าที่ดิน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'VAT7% ค่าเช่าที่ดิน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่าที่ดินรวมVAT',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่า',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'VAT7% ค่าเช่า',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่ารวมVAT',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าบริการ',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'VAT7% ค่าบริการ',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าบริการรวมVAT',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เงินประกัน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เงินประกันรวมVAT',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าอุปกรณ์รวมvat',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รวมทั้งสิ้น(ค่าเช่า-บริการ-อุปกรณ์-เงินประกัน/vat)',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่ชำระใบเสร็จเงินประกัน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขที่ใบเสร็จเงินประกัน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ผู้ดูแล',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'สถานะ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'อ้างอิง',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
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
                                itemCount: teNantModels_New.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Container(
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 50,
                                            child: Text(
                                              '${index + 1}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].cid}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Container(
                                            width: 80,
                                            child: const Text(
                                              '',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index].zn !=
                                                      null)
                                                  ? (teNantModels_New[index]
                                                              .zn!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels_New[index].zn!.split('_')[0]}'
                                                      : 'CMN${teNantModels_New[index].zn!.split('_')[0]}'
                                                  : (teNantModels_New[index]
                                                              .zn1!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels_New[index].zn1!.split('_')[0]}'
                                                      : 'CMN${teNantModels_New[index].zn1!.split('_')[0]}',
                                              // (teNantModels_New[index].zser !=
                                              //         null)
                                              //     ? '${teNantModels_New[index].zser}'
                                              //     : '${teNantModels_New[index].zser1}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index].zn !=
                                                      null)
                                                  ? '${teNantModels_New[index].zn}'
                                                  : '${teNantModels_New[index].zn1}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].ln}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index].cname ==
                                                      null)
                                                  ? ''
                                                  : '${teNantModels_New[index].cname}',
                                              textAlign: TextAlign.start,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index].sdate ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .sdate
                                                              .toString() ==
                                                          '0000-00-00')
                                                  ? ''
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].sdate}'))}',
                                              // (teNantModels_New[index].sdate ==
                                              //         null)
                                              //     ? ''
                                              //     : '${teNantModels_New[index].sdate}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index].ldate ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .ldate
                                                              .toString() ==
                                                          '0000-00-00')
                                                  ? ''
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].ldate}'))}',
                                              // (teNantModels_New[index].ldate ==
                                              //         null)
                                              //     ? ''
                                              //     : '${teNantModels_New[index].ldate}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].period} / ${teNantModels_New[index].rtname}',
                                              // '${teNantModels_New[index].nday}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].stype}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .water_electri ==
                                                      null)
                                                  ? ''
                                                  : '${teNantModels_New[index].water_electri}',
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].land_pvat}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].land_vat}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .land_total ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].land_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].rent_pvat}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].rent_vat}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .rent_total ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].rent_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .service_pvat ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].service_pvat}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                          .service_vat ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].service_vat}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .service_total ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].service_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .pvat_pakan ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].pvat_pakan}'))
                                                      .toString(),
                                              // '${teNantModels_New[index].pvat_pakan}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .total_pakan ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].total_pakan}'))
                                                      .toString(),
                                              // '${teNantModels_New[index].total_pakan}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .equip_total ==
                                                      null)
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].equip_total}'))
                                                      .toString(),
                                              // '${teNantModels_New[index].equip_total}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${nFormat.format(double.parse((teNantModels_New[index].rent_total == null) ? '0' : '${teNantModels_New[index].rent_total}') + double.parse((teNantModels_New[index].service_total == null) ? '0' : '${teNantModels_New[index].service_total}') + double.parse((teNantModels_New[index].equip_total == null) ? '0' : '${teNantModels_New[index].equip_total}') + double.parse((teNantModels_New[index].total_pakan == null) ? '0' : '${teNantModels_New[index].total_pakan}'))}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                              .pakan_daterec ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .pakan_daterec
                                                              .toString() ==
                                                          '0000-00-00')
                                                  ? ''
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].pakan_daterec}'))}',
                                              // (teNantModels_New[index]
                                              //             .pakan_daterec ==
                                              //         null)
                                              //     ? ''
                                              //     : '${teNantModels_New[index].pakan_daterec}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .pakan_doc ==
                                                      null)
                                                  ? '-'
                                                  : '${teNantModels_New[index].pakan_doc}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].name_user}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].st}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: (teNantModels_New[
                                                                  index]
                                                              .st
                                                              .toString() ==
                                                          'ยกเลิกสัญญา')
                                                      ? Colors.red
                                                      : PeopleChaoScreen_Color
                                                          .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].wnote}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
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
                    if (teNantModels_New.length != 0)
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
                              Value_Report = 'รายงานผู้เช่ารายใหม่-1';
                              Pre_and_Dow = 'Download';
                            });
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
                            Value_Chang_Zone_People_TeNantNew = null;
                            Value_Chang_Zone_Ser_People_TeNantNew = null;

                            Await_Status_Report3 = null;

                            teNantModels_New.clear();
                            _teNantModels_New.clear();
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

  ///////////////////////////----------------------------------------------->(รายงานผู้เช่ารายใหม่-2)
  RE_TeNant_New2_Widget() {
    int? ser_index;
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
                      (Value_Chang_Zone_People_TeNantNew == null)
                          ? 'รายงานผู้เช่ารายใหม่-2  (กรุณาเลือกโซน)'
                          : 'รายงานผู้เช่ารายใหม่-2  (โซน : $Value_Chang_Zone_People_TeNantNew)',
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
                              'เดือน/ปีที่ทำสัญญา : ${monthsInThai[int.parse(Mon_PeopleTeNantNew_Mon.toString()) - 1]} ${YE_PeopleTeNantNew_Mon}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ReportScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'ทั้งหมด: ${teNantModels_New.length}',
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
                            height: 35,
                            decoration: BoxDecoration(
                              color:
                                  AppbackgroundColor.TiTile_Colors.withOpacity(
                                      0.5),
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
                                  'เลือกค่าอุปรณ์/ค่าอื่นๆ ที่จะแสดง',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ReportScreen_Color.Colors_Text1_,
                                    // fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                                items: expModels
                                    .where((element) =>
                                        element.exptser.toString() == '4')
                                    .map((item) {
                                  return DropdownMenuItem(
                                    value: item.ser,
                                    //disable default onTap to avoid closing menu when selecting an item
                                    enabled: false,
                                    child: StatefulBuilder(
                                      builder: (context, menuSetState) {
                                        // final isSelected = selectedItems.contains(item);
                                        return InkWell(
                                          onTap: () {
                                            int selectedIndex =
                                                expModels.indexWhere((items) =>
                                                    items.ser == item.ser);
                                            // print(expModels[selectedIndex]
                                            //     .expname);
                                            // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                            //This rebuilds the StatefulWidget to update the button's text
                                            setState(() {
                                              if (item.st! == '1') {
                                                expModels[selectedIndex].st =
                                                    '0';
                                              } else {
                                                expModels[selectedIndex].st =
                                                    '1';
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
                                                  const Icon(Icons
                                                      .check_box_outline_blank),
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
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Divider(),
                    // const SizedBox(height: 1),
                    // Container(
                    //   width: MediaQuery.of(context).size.width, height: 2,
                    //   // padding: EdgeInsets.all(10),
                    //   child: const Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       // Expanded(
                    //       //   child: _searchBar_GetbackPakan(),
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                  ],
                );
              }),
          content: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
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
                              : (teNantModels_New.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1400,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child:
                              // (teNantModels.length == 0)
                              //     ? const Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         children: [
                              //           Center(
                              //             child: Text(
                              //               'ไม่พบข้อมูล ณ วันที่เลือก',
                              //               style: TextStyle(
                              //                 color:
                              //                     ReportScreen_Color.Colors_Text1_,
                              //                 fontWeight: FontWeight.bold,
                              //                 fontFamily: FontWeight_.Fonts_T,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       )
                              //     :
                              Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: const Text(
                                  '#ข้อมูลตัวอย่างเบื้องต้น..',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontSize: 12.0
                                      //fontSize: 10.0
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
                              Container(
                                // width: 1050,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.TiTile_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 50,
                                      child: const Text(
                                        'ลำดับที่',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันที่ชำระ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขใบกำกับภาษี',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'รายชื่อลูกค้า',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'สาขา',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เลขประจำตัวผู้เสียภาษี',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'เงินประกัน',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ภาษีมูลค่าเพิ่ม 7% (เงินประกัน)',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'เงินประกัน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าเช่าพื้นที่ดิน',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ภาษีมูลค่าเพิ่ม 7% (ค่าเช่าพื้นที่ดิน)',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่าพื้นที่ดิน',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าเช่า',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ภาษีมูลค่าเพิ่ม 7% (ค่าเช่า)',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าเช่า',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าบริการ',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ภาษีมูลค่าเพิ่ม 7% (ค่าบริการพื้นที่)',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าบริการพื้นที่',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าอุปกรณ์',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ภาษีมูลค่าเพิ่ม 7% (ค่าอุปกรณ์)',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'ค่าอุปกรณ์',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าเช่ารับล่วงหน้า',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'ค่าบริการรับล่วงหน้า',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    // const Expanded(
                                    //   flex: 1,
                                    //   child: Text(
                                    //     'จำนวนเงินรวมทั้งสิ้น',
                                    //     textAlign: TextAlign.right,
                                    //     style: TextStyle(
                                    //         color: PeopleChaoScreen_Color
                                    //             .Colors_Text1_,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontFamily: FontWeight_.Fonts_T,
                                    //         fontSize: 14.0
                                    //         //fontSize: 10.0
                                    //         //fontSize: 10.0
                                    //         ),
                                    //   ),
                                    // ),
                                    const Expanded(
                                      flex: 1,
                                      child: Text(
                                        'วันเริ่มต้นสัญญา',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'สถานะ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'อ้างอิง',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontSize: 14.0
                                            //fontSize: 10.0
                                            //fontSize: 10.0
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
                                itemCount: teNantModels_New.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Container(
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 50,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              '${index + 1}',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                              .pakan_daterec ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .pakan_daterec
                                                              .toString() ==
                                                          '0000-00-00')
                                                  ? ''
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].pakan_daterec}'))}',
                                              // (teNantModels_New[index]
                                              //             .pakan_daterec ==
                                              //         null)
                                              //     ? '-'
                                              //     :
                                              // '${teNantModels_New[index].pakan_daterec}',
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (teNantModels_New[index]
                                                          .pakan_doc ==
                                                      null)
                                                  ? '-'
                                                  : '${teNantModels_New[index].pakan_doc}',
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index].datex ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .datex
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? ''
                                          //         : '${DateFormat('dd/MM/yyyy').format(DateTime.parse('${teNantModels_New[index].datex}'))}',
                                          //     // '${salesTax_full[index].daterec}',
                                          //     // '${transKonModels[index].pdate}',
                                          //     textAlign: TextAlign.center,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 2,
                                          //     (teNantModels_New[index].doctax ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .doctax
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '${teNantModels_New[index].docno}'
                                          //         : '${teNantModels_New[index].doctax}',
                                          //     textAlign: TextAlign.left,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index].cname !=
                                                      null)
                                                  ? '${teNantModels_New[index].cname}'
                                                  : '${teNantModels_New[index].remark}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Tooltip(
                                              richMessage: TextSpan(
                                                text: (teNantModels_New[index]
                                                            .zn !=
                                                        null)
                                                    ? '${teNantModels_New[index].zn}'
                                                    : '${teNantModels_New[index].znn}',
                                                style: const TextStyle(
                                                  color: HomeScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  //fontSize: 10.0
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey[200],
                                              ),
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                (teNantModels_New[index].zn !=
                                                        null)
                                                    ? '${teNantModels_New[index].zn}'
                                                    : '${teNantModels_New[index].znn}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index].tax !=
                                                      null)
                                                  ? '${teNantModels_New[index].tax}'
                                                  : '',
                                              // '${salesTax_full[index].tax}',
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .pvat_pakan ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .pvat_pakan
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].pvat_pakan}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .pakan_vat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .pakan_vat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].pakan_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                              .total_pakan ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .total_pakan
                                                              .toString() ==
                                                          '')
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].total_pakan}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .land_pvat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .land_pvat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].land_pvat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .land_vat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .land_vat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].land_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                              .land_total ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .land_total
                                                              .toString() ==
                                                          '')
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].land_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .rent_pvat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .rent_pvat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].rent_pvat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .rent_vat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .rent_vat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].rent_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                              .rent_total ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .rent_total
                                                              .toString() ==
                                                          '')
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].rent_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .service_pvat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .service_pvat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].service_pvat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .service_vat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .service_vat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].service_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                              .service_total ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .service_total
                                                              .toString() ==
                                                          '')
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].service_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .equip_pvat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .equip_pvat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].equip_pvat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .equip_vat ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .equip_vat
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].equip_vat}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index]
                                                              .equip_total ==
                                                          null ||
                                                      teNantModels_New[index]
                                                              .equip_total
                                                              .toString() ==
                                                          '')
                                                  ? '0.00'
                                                  : nFormat
                                                      .format(double.parse(
                                                          '${teNantModels_New[index].equip_total}'))
                                                      .toString(),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .service_total_future ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .service_total_future
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].rent_total_future}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .service_total_future ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .service_total_future
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].service_total_future}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 1,
                                          //     (teNantModels_New[index]
                                          //                     .total_bill ==
                                          //                 null ||
                                          //             teNantModels_New[index]
                                          //                     .total_bill
                                          //                     .toString() ==
                                          //                 '')
                                          //         ? '0.00'
                                          //         : nFormat
                                          //             .format(double.parse(
                                          //                 '${teNantModels_New[index].total_bill}'))
                                          //             .toString(),
                                          //     textAlign: TextAlign.right,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: const TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text2_,
                                          //         //fontWeight: FontWeight.bold,
                                          //         fontFamily: Font_.Fonts_T),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 25,
                                              maxLines: 1,
                                              (teNantModels_New[index].sdate !=
                                                          null ||
                                                      teNantModels_New[index]
                                                              .sdate
                                                              .toString() !=
                                                          '' ||
                                                      teNantModels_New[index]
                                                              .sdate
                                                              .toString() ==
                                                          '0000-00-00')
                                                  ? '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels_New[index].sdate}'))}'
                                                  : 'ล็อกเสียบ',
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].st}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: (teNantModels_New[
                                                                  index]
                                                              .st
                                                              .toString() ==
                                                          'ยกเลิกสัญญา')
                                                      ? Colors.red
                                                      : PeopleChaoScreen_Color
                                                          .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${teNantModels_New[index].wnote}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
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
                    if (teNantModels_New.length != 0)
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
                              Value_Report = 'รายงานผู้เช่ารายใหม่-2';
                              Pre_and_Dow = 'Download';
                            });
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
                            Value_Chang_Zone_People_TeNantNew = null;
                            Value_Chang_Zone_Ser_People_TeNantNew = null;

                            Await_Status_Report4 = null;

                            teNantModels_New.clear();
                            _teNantModels_New.clear();
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

  ////////////------------------------------------------------------>(Export file )
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

  ////////////------------------------------------------>  Excel_BillPayMonRent_Report_Choice
  void InkWell_onTap(context) async {
    await Dia_log_lod();
    setState(() {
      NameFile_ = '';
      NameFile_ = FormNameFile_text.text;
    });

    if (_verticalGroupValue_NameFile == 'กำหนดเอง') {
    } else {
      if (_verticalGroupValue_PassW == 'PDF') {
        Navigator.of(context).pop();
      } else {
        if (Value_Report == 'รายงานค่าบริการรับล่วงหน้า') {
          Excgen_SalesTax_FutureReport_Choice
              .exportExcel_SalesTax_FutureReport_Choice(
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  renTal_name,
                  Value_Chang_Zone_billpayMon,
                  billpay_Mon,
                  'วันที่ตั้งหนี้ชำระ: $sdate_1 ถึง $ldate_1',
                  // monthsInThai[int.parse(Mon_billpay_Mon.toString()) - 1],
                  YE_billpay_Mon,
                  expModels.where((element) => element.st! == '1').toList(),
                  Type_vat.where((element) => element["st"]! == '1').toList());
        } else if (Value_Report == 'รายงานประวัติผู้เช่า') {
          Excgen_PeopleTenantReport_Choice
              .exportExcel_PeopleTenantReport_Choice(
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  renTal_name,
                  Value_Chang_Zone_People_TeNant,
                  teNantModels,
                  monthsInThai[int.parse(Mon_PeopleTeNant_Mon.toString()) - 1],
                  YE_PeopleTeNant_Mon,
                  expModels.where((element) => element.st! == '1').toList(),
                  Type_vat.where((element) => element["st"]! == '1').toList(),
                  Status_pe_History);
        } else if (Value_Report == 'รายงานผู้เช่ารายใหม่-1') {
          Excgen_TeNantNewReport_Choice.exportExcel_TeNantNewReport_Choice(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              Value_Chang_Zone_People_TeNantNew,
              teNantModels_New,
              monthsInThai[int.parse(Mon_PeopleTeNantNew_Mon.toString()) - 1],
              YE_PeopleTeNantNew_Mon);
        } else if (Value_Report == 'รายงานผู้เช่ารายใหม่-2') {
          Excgen_TeNantNew2Report_Choice.exportExcel_TeNantNew2Report_Choice(
            context,
            NameFile_,
            _verticalGroupValue_NameFile,
            renTal_name,
            Value_Chang_Zone_People_TeNantNew,
            teNantModels_New,
            monthsInThai[int.parse(Mon_PeopleTeNantNew_Mon.toString()) - 1],
            YE_PeopleTeNantNew_Mon,
            expModels
                .where(
                    (element) => element.st! == '1' && element.exptser == '4')
                .toList(),
          );
        }
      }
      Navigator.of(context).pop();
    }
  }
}
//     CONVERT(
//   CONCAT(
//     '[',
//     GROUP_CONCAT(
//       CONCAT(
//         '{\"ser_exp\": \"', c_trans.expser, '\", ',
//         '\"name_exp\": \"', c_trans.expname, '\", ',
//         '\"pvat_exp\": \"', c_trans.pvat, '\", ',
//         '\"vat_exp\": \"', c_trans.vat, '\", ',
//         '\"total_exp\": \"', c_trans.total , '\"}'
//       )
//       SEPARATOR ','
//     ),
//     ']'
//   ) USING utf8
// ) AS exp_array
