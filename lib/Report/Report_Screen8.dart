import 'dart:async';
import 'dart:convert';

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
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetType_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_maintenance_model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Model/Getexp_sz_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'package:http/http.dart' as http;

import 'Excel_Overdue_Report.dart';
import 'Excel_transMeter_Report.dart';
import 'Report_Mini/Mini_Ex_Overdue_Report.dart';

class ReportScreen8 extends StatefulWidget {
  const ReportScreen8({super.key});

  @override
  State<ReportScreen8> createState() => _ReportScreen8State();
}

class _ReportScreen8State extends State<ReportScreen8> {
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
  String? expSZ_name;
  String? expSZ_ser;

  final _formKey = GlobalKey<FormState>();
  final FormNameFile_text = TextEditingController();

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
  List<TypeModel> typeModels = [];
  late List<List<TransBillModel>> _TransBillModels;
  List<TransBillModel> TransBillModels_Select = [];
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<TeNantModel> teNantModels_mini = [];
  List<ExpSZModel> expSZModels = [];
  List<String> YE_Th = [];
  List<String> Mont_Th = [];

  ///------>

  String? Mon_transMeter_Mon;
  String? YE_transMeter_Mon;

  ///------>
  String? renTal_user, renTal_name;

  ///------>

  String? zone_ser_transMeter,
      zone_name_transMeter,
      Status_transMeter_,
      Status_transMeter_ser;

  ///------>
  String? zone_ser_teNant_Daily, zone_name_teNant_Daily;
  String? zone_ser_teNant_Mon, zone_name_teNant_Mon;
  String? zone_ser_teNant_All, zone_name_teNant_All;
  String? Mon_teNant_Mon, YE_teNant_Mon;
  var Value_teNantDate_Daily;

  ///------>
  List<CustomerModel> customerModels = [];
  List<CustomerModel> _customerModels = <CustomerModel>[];
  List<TransMeterModel> transMeterModels = [];
  List<TransMeterModel> _transMeterModels = <TransMeterModel>[];

  ///------>
  int Ser_BodySta1 = 0;
  int Ser_BodyOverdue = 0;

  ///------------------------>

  List maintenance_Status = [
    'ทั้งหมด',
    'ไฟฟ้า', //     Ser_BodySta1 = 1;
    'น้ำ',

    ///      Ser_BodySta1 = 2;
  ];

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
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    // TODO: implement initState
    super.initState();
    checkPreferance();
    read_GC_zone();
    read_GC_type();
    red_exp_sz();
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
  }

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
                    'ขออภัย ขณะนี้ฟังก์ชั่นก์ รายงานหน้า 7 อยู่ในช่วงทดสอบ... !!!!!! ',
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
  Future<Null> red_exp_sz() async {
    if (expSZModels.length != 0) {
      setState(() {
        expSZModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    String url = '${MyConstant().domain}/GC_exp_sz.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        Map<String, dynamic> map = Map();
        map['ser'] = '0';
        map['user'] = '0';
        map['etype'] = '0';
        map['exptser'] = '0';
        map['expname'] = 'ทั้งหมด';
        map['st'] = '0';
        map['unit'] = '0';
        map['sdate'] = '0';
        map['vat'] = '0';
        map['wht'] = '0';
        map['cal'] = '0';
        map['pri'] = '0';
        map['rser'] = '0';
        map['fine'] = '0';
        map['fine_unit'] = '0';
        map['fine_late'] = '0';
        map['fine_cal'] = '0';
        map['fine_pri'] = '0';
        map['data_update'] = '0';

        ExpSZModel expSZModel = ExpSZModel.fromJson(map);

        setState(() {
          expSZModels.add(expSZModel);
        });

        for (var map in result) {
          ExpSZModel expSZModel = ExpSZModel.fromJson(map);
          setState(() {
            expSZModels.add(expSZModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

////////--------------------------------------------------------------->
  Future<Null> read_GC_type() async {
    if (typeModels.isNotEmpty) {
      typeModels.clear();
    }

    String url = '${MyConstant().domain}/GC_type.php?isAdd=true';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['type'] = 'ทั้งหมด';
      map['st'] = '0';
      map['data_update'] = '0';

      TypeModel typeModelx = TypeModel.fromJson(map);
      setState(() {
        typeModels.add(typeModelx);
      });
      if (result != null) {
        for (var map in result) {
          TypeModel typeModel = TypeModel.fromJson(map);
          setState(() {
            typeModels.add(typeModel);
          });
        }
        // setState(() {
        //   for (var i = 0; i < typeModels.length; i++) {
        //     _verticalGroupValue = typeModels[i].type!;
        //   }
        // });
      } else {}
    } catch (e) {}
  }

  // $Sertype = $_GET['sertype'];
  // $Serzone = $_GET['serzone'];
  //   $monx_S = $_GET['monx'];
  //   $yex_S = $_GET['yex'];

  Future<Null> red_Trans_bill() async {
    setState(() {
      transMeterModels.clear();
      teNantModels.clear();
      Await_Status_Report1 = null;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var expSZ_ser_ = (expSZ_ser == null || expSZ_ser == '') ? 0 : expSZ_ser;

    String url = (expSZ_ser_.toString() == '0')
        ? '${MyConstant().domain}/GC_trans_mitter_ReportNew.php?isAdd=true&ren=$ren&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon&sertype=0'
        : '${MyConstant().domain}/GC_trans_mitterZone_ReportNew.php?isAdd=true&ren=$ren&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon&sertype=$expSZ_ser_';
    //  (expSZ_name != null &&
    //         expSZ_name.toString().trim() != 'ทั้งหมด')
    //     ? '${MyConstant().domain}/GC_trans_mitter_ReportNew.php?isAdd=true&ren=106&serzone=0&monx=09&yex=2024&sertype=0'
    //     : '${MyConstant().domain}/GC_trans_mitterZone_ReportNew.php?isAdd=true&ren=$ren&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon&sertype=$expSZ_ser_';
    // String url = (zone_ser_transMeter.toString() == 'null')
    //     ? (Ser_BodySta1 == 0)
    //         ? '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=0&serzone=0&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon'
    //         : (Ser_BodySta1 == 1)
    //             ? '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=1&serzone=0&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon'
    //             : '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=2&serzone=0&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon'
    //     : (Ser_BodySta1 == 0)
    //         ? '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=0&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon'
    //         : (Ser_BodySta1 == 1)
    //             ? '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=1&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon'
    //             : '${MyConstant().domain}/GC_trans_mitter_Report.php?isAdd=true&ren=$ren&sertype=2&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  print('result $url');
      if (result.toString() != 'null') {
        setState(() {
          Await_Status_Report1 = 1;
        });
        for (var map in result) {
          TransMeterModel transMeterModel = TransMeterModel.fromJson(map);
          setState(() {
            transMeterModels.add(transMeterModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }

      Future.delayed(const Duration(milliseconds: 800), () async {
        setState(() {
          _transMeterModels = transMeterModels;
          Await_Status_Report1 = null;
        });
        // print('mitter : ${transMeterModels.length}');
      });
    } catch (e) {}
  }

// https://chaoperties.com/Choice/chao_api/GC_trans_mitter_ReportNew.php?isAdd=true&ren=106&serzone=0&monx=09&yex=2024&sertype=0
// https://chaoperties.com/Choice/chao_api/GC_trans_mitterZone_ReportNew.php?isAdd=true&ren=106&serzone=0&monx=9&yex=2024&sertype=0
//////////---------------------------------------->Value_teNantDate_Daily
  Future<Null> read_GC_tenant_Daily() async {
    setState(() {
      teNantModels.clear();
      transMeterModels.clear();
      Await_Status_Report2 = null;
      Await_Status_Report3 = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_teNant_Daily == null) ? '0' : zone_ser_teNant_Daily;
    // var zone_Sub = preferences.getString('zoneSubSer');

    String url =
        '${MyConstant().domain}/GC_tenantAll_setring_DailyReport.php?isAdd=true&ren=$ren&zone=$zone&day_s=$Value_teNantDate_Daily';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        setState(() {
          Await_Status_Report1 = 1;
        });
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
            }
          });
        }
      } else {}

      Future.delayed(const Duration(milliseconds: 800), () async {
        setState(() {
          _teNantModels = teNantModels;
          Await_Status_Report1 = null;
        });
        // print('tenant_Daily : ${teNantModels.length}');
      });
    } catch (e) {}
  }

  Future<Null> read_GC_tenant_Mont() async {
    setState(() {
      teNantModels.clear();
      transMeterModels.clear();
      Await_Status_Report1 = null;
      Await_Status_Report3 = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_teNant_Mon == null) ? '0' : zone_ser_teNant_Mon;
    // var zone_Sub = preferences.getString('zoneSubSer');

    String url =
        '${MyConstant().domain}/GC_tenantAll_setring_MonReport.php?isAdd=true&ren=$ren&zone=$zone&yex=${YE_teNant_Mon}&_monts=${Mon_teNant_Mon}';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  print(result);
      if (result != null) {
        setState(() {
          Await_Status_Report2 = 1;
        });
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
            }
          });
        }
      } else {}

      Future.delayed(const Duration(milliseconds: 800), () async {
        setState(() {
          _teNantModels = teNantModels;
          Await_Status_Report2 = null;
        });
        // print('tenant_Daily : ${teNantModels.length}');
      });
    } catch (e) {}
  }

  Future<Null> read_GC_tenant_All() async {
    setState(() {
      teNantModels.clear();
      transMeterModels.clear();
      Await_Status_Report1 = null;
      Await_Status_Report2 = null;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_teNant_All == null) ? '0' : zone_ser_teNant_All;
    // var zone_Sub = preferences.getString('zoneSubSer');

    String url =
        '${MyConstant().domain}/GC_tenantAll_setring_Report.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        setState(() {
          Await_Status_Report3 = 1;
        });
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            if (teNantModel.cid != '') {
              if (teNantModel.invoice == null || teNantModel.invoice == '') {
                setState(() {
                  teNantModels.add(teNantModel);
                });
              }
            }
          });
        }
        Future.delayed(const Duration(milliseconds: 800), () async {
          setState(() {
            _teNantModels = teNantModels;
            Await_Status_Report3 = null;
          });
          // print('tenant_All : ${teNantModels.length}');
        });
      } else {}
    } catch (e) {}
  }

  Future<Null> read_GC_tenant_All_Mini() async {
    setState(() {
      teNantModels_mini.clear();
      teNantModels_mini.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_teNant_All == null) ? '0' : zone_ser_teNant_All;

    String url =
        '${MyConstant().domain}/GC_tenantAll_setringMini_Report.php?isAdd=true&ren=$ren&zone=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModelmini = TeNantModel.fromJson(map);
          setState(() {
            if (teNantModelmini.cid != '') {
              if (teNantModelmini.invoice == null ||
                  teNantModelmini.invoice == '') {
                setState(() {
                  teNantModels_mini.add(teNantModelmini);
                });
              }
            }
          });
        }
      } else {}
    } catch (e) {}
  }

  ////////////----------------------------------------------(วันที่รายงานประจำวัน)
  Future<Null> _select_Date_Daily(BuildContext context) async {
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

        var formatter = DateFormat('y-MM-d');
        print("${formatter.format(result!)}");
        setState(() {
          Value_teNantDate_Daily = "${formatter.format(result)}";
        });
        // if (Value_Chang_Zone_Daily != null) {
        //   red_Trans_bill();
        //   red_Trans_billDailyBank();
        // }

        // red_Trans_bill_Groptype_daly();
      }
    });
  }

//////////////------------------------------------->
  Widget getDateRangePicker(type) {
    // final localeObj = Locale('th');
    return Container(
      height: 250,
      width: 300,
      child: Card(
        child: SfDateRangePicker(
          allowViewNavigation: (type == 2) ? true : false,
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
                  : selectionChanged_month2,
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
        Value_teNantDate_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    } else if (args.value is DateTime) {
      setState(() {
        Value_teNantDate_Daily = DateFormat('yyyy-MM-dd').format(args.value);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });

    // print(Value_teNantDate_Daily);
  }

  void selectionChanged_month1(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      //  (Mon_transMeter_Mon == null ||
      //                                         YE_transMeter_Mon == '')
      setState(() {
        Mon_transMeter_Mon = DateFormat('MM').format(selectedDate);
        YE_transMeter_Mon = DateFormat('yyyy').format(selectedDate);
      });
      // print(
      //     'Selected month: ${Mon_transMeter_Mon}, Year: ${YE_transMeter_Mon}');
    }
  }

  void selectionChanged_month2(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
//  (Mon_syslog_Mon == null ||
//                                             YE_syslog_Mon == '')
      setState(() {
        Mon_teNant_Mon = DateFormat('MM').format(selectedDate);
        YE_teNant_Mon = DateFormat('yyyy').format(selectedDate);
      });
      //   print('Selected month: ${Mon_teNant_Mon}, Year: ${YE_teNant_Mon}');
    }
  }
  //////////------------------>

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
                                    (Mon_transMeter_Mon == null ||
                                            YE_transMeter_Mon == '')
                                        ? 'เลือก'
                                        : '$Mon_transMeter_Mon / $YE_transMeter_Mon',
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
                      //       value: (Mon_transMeter_Mon == null)
                      //           ? null
                      //           : Mon_transMeter_Mon,
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
                      //         Mon_transMeter_Mon = value;
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'ปี :',
                      //       Colors.grey,
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
                      //       value: (YE_transMeter_Mon == null)
                      //           ? null
                      //           : YE_transMeter_Mon,
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
                      //         YE_transMeter_Mon = value;

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
                          width: 260,
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField2(
                            value: (expSZ_name == null) ? null : expSZ_name,
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
                            items: expSZModels
                                .map((item) => DropdownMenuItem<String>(
                                      value: '${item.expname}',
                                      child: Text(
                                        '${item.expname}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Text_Size,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ))
                                .toList(),

                            onChanged: (value) async {
                              int selectedIndex = expSZModels
                                  .indexWhere((item) => item.expname == value);

                              setState(() {
                                expSZ_name = value!;
                                expSZ_ser = expSZModels[selectedIndex].ser!;
                              });
                              // print(
                              //     'Selected Index: $expSZ_name  //${expSZ_ser}');
                            },
                          ),
                        ),
                      ),
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
                                value: (zone_name_transMeter == null)
                                    ? null
                                    : zone_name_transMeter,
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
                                hint: (zone_name_transMeter == null)
                                    ? null
                                    : Text(
                                        '$zone_name_transMeter',
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
                                    zone_name_transMeter = value!;
                                    zone_ser_transMeter =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_name_transMeter  //${zone_ser_transMeter}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[0].clear();
                                  }
                                }),
                          ),

                          //  DropdownButtonFormField2(
                          //   value: (zone_name_transMeter == null)
                          //       ? null
                          //       : zone_name_transMeter,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_transMeter = value!;
                          //       zone_ser_transMeter =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_name_transMeter  //${zone_ser_transMeter}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            // setState(() {
                            //   Ser_BodySta1 = 1;
                            // });

                            if (Mon_transMeter_Mon != null &&
                                YE_transMeter_Mon != null &&
                                zone_name_transMeter != null) {
                              setState(() {
                                Await_Status_Report2 = 0;
                              });
                              Dia_log();
                              red_Trans_bill();
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
                            ),
                            onTap: (transMeterModels.isEmpty ||
                                    zone_name_transMeter == null)
                                ? null
                                : () async {
                                    Insert_log.Insert_logs(
                                        'รายงาน', 'กดดูรายงานมิเตอร์น้ำ-ไฟฟ้า');
                                    Electric_Widget();
                                  }),
                        // (Ser_BodySta1 != 1)
                        //     ? Padding(
                        //         padding: EdgeInsets.all(8.0),
                        //         child: Text(
                        //           'รายงานมิเตอร์น้ำ-ไฟฟ้า',
                        //           style: TextStyle(
                        //             color: ReportScreen_Color.Colors_Text2_,
                        //             // fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T,
                        //           ),
                        //         ),
                        //       )
                        //     :
                        (transMeterModels.isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (Status_transMeter_ != null &&
                                            transMeterModels.isEmpty &&
                                            zone_name_transMeter != null &&
                                            Await_Status_Report2 != null)
                                        ? (expSZ_name != null &&
                                                expSZ_name.toString().trim() !=
                                                    'ทั้งหมด')
                                            ? 'รายงาน $expSZ_name (ไม่พบข้อมูล ✖️)'
                                            : 'รายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ] (ไม่พบข้อมูล ✖️)'
                                        : (expSZ_name != null &&
                                                expSZ_name.toString().trim() !=
                                                    'ทั้งหมด')
                                            ? 'รายงาน $expSZ_name'
                                            : 'รายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ]',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (transMeterModels.length != 0 &&
                                    Await_Status_Report1 != null)
                                ? SizedBox(
                                    // height: 20,
                                    child: Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(4.0),
                                          child:
                                              const CircularProgressIndicator()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Translate.TranslateAndSetText(
                                            (expSZ_name != null &&
                                                    expSZ_name
                                                            .toString()
                                                            .trim() !=
                                                        'ทั้งหมด')
                                                ? 'กำลังโหลดรายงาน $expSZ_name...'
                                                : 'กำลังโหลดรายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ]...',
                                            ReportScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.w500,
                                            Font_.Fonts_T,
                                            Text_Size,
                                            1),
                                      ),
                                    ],
                                  ))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (expSZ_name != null &&
                                                expSZ_name.toString().trim() !=
                                                    'ทั้งหมด')
                                            ? 'รายงาน $expSZ_name ✔️'
                                            : 'รายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ]✔️',
                                        ReportScreen_Color.Colors_Text1_,
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
              // const SizedBox(
              //   height: 5.0,
              // ),
              // Row(
              //   children: [
              //     Container(
              //       width: MediaQuery.of(context).size.width / 2,
              //       height: 4.0,
              //       child: Divider(
              //         color: Colors.grey[300],
              //         height: 4.0,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 5.0,
              // ),
              // ScrollConfiguration(
              //   behavior:
              //       ScrollConfiguration.of(context).copyWith(dragDevices: {
              //     PointerDeviceKind.touch,
              //     PointerDeviceKind.mouse,
              //   }),
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Row(
              //       children: [
              //         const Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Text(
              //             'เดือน :',
              //             style: TextStyle(
              //               color: ReportScreen_Color.Colors_Text2_,
              //               // fontWeight: FontWeight.bold,
              //               fontFamily: Font_.Fonts_T,
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Container(
              //             decoration: const BoxDecoration(
              //               color: AppbackgroundColor.Sub_Abg_Colors,
              //               borderRadius: BorderRadius.only(
              //                   topLeft: Radius.circular(10),
              //                   topRight: Radius.circular(10),
              //                   bottomLeft: Radius.circular(10),
              //                   bottomRight: Radius.circular(10)),
              //               // border: Border.all(color: Colors.grey, width: 1),
              //             ),
              //             width: 120,
              //             padding: const EdgeInsets.all(8.0),
              //             child: DropdownButtonFormField2(
              //               alignment: Alignment.center,
              //               focusColor: Colors.white,
              //               autofocus: false,
              //               decoration: InputDecoration(
              //                 floatingLabelAlignment:
              //                     FloatingLabelAlignment.center,
              //                 enabled: true,
              //                 hoverColor: Colors.brown,
              //                 prefixIconColor: Colors.blue,
              //                 fillColor: Colors.white.withOpacity(0.05),
              //                 filled: false,
              //                 isDense: true,
              //                 contentPadding: EdgeInsets.zero,
              //                 border: OutlineInputBorder(
              //                   borderSide: const BorderSide(color: Colors.red),
              //                   borderRadius: BorderRadius.circular(10),
              //                 ),
              //                 focusedBorder: const OutlineInputBorder(
              //                   borderRadius: BorderRadius.only(
              //                     topRight: Radius.circular(10),
              //                     topLeft: Radius.circular(10),
              //                     bottomRight: Radius.circular(10),
              //                     bottomLeft: Radius.circular(10),
              //                   ),
              //                   borderSide: BorderSide(
              //                     width: 1,
              //                     color: Color.fromARGB(255, 231, 227, 227),
              //                   ),
              //                 ),
              //               ),
              //               isExpanded: false,
              //               value:
              //                   (Ser_BodySta1 != 2) ? null : Mon_transMeter_Mon,
              //               // hint: Text(
              //               //   Mon_Income == null
              //               //       ? 'เลือก'
              //               //       : '$Mon_Income',
              //               //   maxLines: 2,
              //               //   textAlign: TextAlign.center,
              //               //   style: const TextStyle(
              //               //     overflow:
              //               //         TextOverflow.ellipsis,
              //               //     fontSize: 14,
              //               //     color: Colors.grey,
              //               //   ),
              //               // ),
              //               icon: const Icon(
              //                 Icons.arrow_drop_down,
              //                 color: Colors.black,
              //               ),
              //               style: const TextStyle(
              //                 color: Colors.grey,
              //               ),
              //               iconSize: 20,
              //               buttonHeight: 40,
              //               buttonWidth: 200,
              //               // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //               dropdownDecoration: BoxDecoration(
              //                 // color: Colors
              //                 //     .amber,
              //                 borderRadius: BorderRadius.circular(10),
              //                 border: Border.all(color: Colors.white, width: 1),
              //               ),
              //               items: [
              //                 for (int item = 1; item < 13; item++)
              //                   DropdownMenuItem<String>(
              //                     value: '${item}',
              //                     child: Text(
              //                       '${monthsInThai[item - 1]}',
              //                       //'${item}',
              //                       textAlign: TextAlign.center,
              //                       style: const TextStyle(
              //                         overflow: TextOverflow.ellipsis,
              //                         fontSize: 14,
              //                         color: Colors.grey,
              //                       ),
              //                     ),
              //                   )
              //               ],

              //               onChanged: (value) async {
              //                 Mon_transMeter_Mon = value;

              //                 // if (Value_Chang_Zone_Income !=
              //                 //     null) {
              //                 //   red_Trans_billIncome();
              //                 //   red_Trans_billMovemen();
              //                 // }
              //               },
              //             ),
              //           ),
              //         ),
              //         const Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Text(
              //             'ปี :',
              //             style: TextStyle(
              //               color: ReportScreen_Color.Colors_Text2_,
              //               // fontWeight: FontWeight.bold,
              //               fontFamily: Font_.Fonts_T,
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Container(
              //             decoration: const BoxDecoration(
              //               color: AppbackgroundColor.Sub_Abg_Colors,
              //               borderRadius: BorderRadius.only(
              //                   topLeft: Radius.circular(10),
              //                   topRight: Radius.circular(10),
              //                   bottomLeft: Radius.circular(10),
              //                   bottomRight: Radius.circular(10)),
              //               // border: Border.all(color: Colors.grey, width: 1),
              //             ),
              //             width: 120,
              //             padding: const EdgeInsets.all(8.0),
              //             child: DropdownButtonFormField2(
              //               alignment: Alignment.center,
              //               focusColor: Colors.white,
              //               autofocus: false,
              //               decoration: InputDecoration(
              //                 floatingLabelAlignment:
              //                     FloatingLabelAlignment.center,
              //                 enabled: true,
              //                 hoverColor: Colors.brown,
              //                 prefixIconColor: Colors.blue,
              //                 fillColor: Colors.white.withOpacity(0.05),
              //                 filled: false,
              //                 isDense: true,
              //                 contentPadding: EdgeInsets.zero,
              //                 border: OutlineInputBorder(
              //                   borderSide: const BorderSide(color: Colors.red),
              //                   borderRadius: BorderRadius.circular(10),
              //                 ),
              //                 focusedBorder: const OutlineInputBorder(
              //                   borderRadius: BorderRadius.only(
              //                     topRight: Radius.circular(10),
              //                     topLeft: Radius.circular(10),
              //                     bottomRight: Radius.circular(10),
              //                     bottomLeft: Radius.circular(10),
              //                   ),
              //                   borderSide: BorderSide(
              //                     width: 1,
              //                     color: Color.fromARGB(255, 231, 227, 227),
              //                   ),
              //                 ),
              //               ),
              //               isExpanded: false,
              //               value:
              //                   (Ser_BodySta1 != 2) ? null : YE_transMeter_Mon,
              //               // hint: Text(
              //               //   YE_Income == null
              //               //       ? 'เลือก'
              //               //       : '$YE_Income',
              //               //   maxLines: 2,
              //               //   textAlign: TextAlign.center,
              //               //   style: const TextStyle(
              //               //     overflow:
              //               //         TextOverflow.ellipsis,
              //               //     fontSize: 14,
              //               //     color: Colors.grey,
              //               //   ),
              //               // ),
              //               icon: const Icon(
              //                 Icons.arrow_drop_down,
              //                 color: Colors.black,
              //               ),
              //               style: const TextStyle(
              //                 color: Colors.grey,
              //               ),
              //               iconSize: 20,
              //               buttonHeight: 40,
              //               buttonWidth: 200,
              //               // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //               dropdownDecoration: BoxDecoration(
              //                 // color: Colors
              //                 //     .amber,
              //                 borderRadius: BorderRadius.circular(10),
              //                 border: Border.all(color: Colors.white, width: 1),
              //               ),
              //               items: YE_Th.map((item) => DropdownMenuItem<String>(
              //                     value: '${item}',
              //                     child: Text(
              //                       '${item}',
              //                       // '${int.parse(item) + 543}',
              //                       textAlign: TextAlign.center,
              //                       style: const TextStyle(
              //                         overflow: TextOverflow.ellipsis,
              //                         fontSize: 14,
              //                         color: Colors.grey,
              //                       ),
              //                     ),
              //                   )).toList(),

              //               onChanged: (value) async {
              //                 YE_transMeter_Mon = value;

              //                 // if (Value_Chang_Zone_Income !=
              //                 //     null) {
              //                 //   red_Trans_billIncome();
              //                 //   red_Trans_billMovemen();
              //                 // }
              //               },
              //             ),
              //           ),
              //         ),
              //         const Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Text(
              //             'โซน :',
              //             style: TextStyle(
              //               color: ReportScreen_Color.Colors_Text2_,
              //               // fontWeight: FontWeight.bold,
              //               fontFamily: Font_.Fonts_T,
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Container(
              //             decoration: const BoxDecoration(
              //               color: AppbackgroundColor.Sub_Abg_Colors,
              //               borderRadius: BorderRadius.only(
              //                   topLeft: Radius.circular(10),
              //                   topRight: Radius.circular(10),
              //                   bottomLeft: Radius.circular(10),
              //                   bottomRight: Radius.circular(10)),
              //               // border: Border.all(color: Colors.grey, width: 1),
              //             ),
              //             width: 260,
              //             padding: const EdgeInsets.all(8.0),
              //             child: DropdownButtonFormField2(
              //               value: (Ser_BodySta1 != 2)
              //                   ? null
              //                   : zone_name_transMeter,
              //               alignment: Alignment.center,
              //               focusColor: Colors.white,
              //               autofocus: false,
              //               decoration: InputDecoration(
              //                 enabled: true,
              //                 hoverColor: Colors.brown,
              //                 prefixIconColor: Colors.blue,
              //                 fillColor: Colors.white.withOpacity(0.05),
              //                 filled: false,
              //                 isDense: true,
              //                 contentPadding: EdgeInsets.zero,
              //                 border: OutlineInputBorder(
              //                   borderSide: const BorderSide(color: Colors.red),
              //                   borderRadius: BorderRadius.circular(10),
              //                 ),
              //                 focusedBorder: const OutlineInputBorder(
              //                   borderRadius: BorderRadius.only(
              //                     topRight: Radius.circular(10),
              //                     topLeft: Radius.circular(10),
              //                     bottomRight: Radius.circular(10),
              //                     bottomLeft: Radius.circular(10),
              //                   ),
              //                   borderSide: BorderSide(
              //                     width: 1,
              //                     color: Color.fromARGB(255, 231, 227, 227),
              //                   ),
              //                 ),
              //               ),
              //               isExpanded: false,

              //               icon: const Icon(
              //                 Icons.arrow_drop_down,
              //                 color: Colors.black,
              //               ),
              //               style: const TextStyle(
              //                 color: Colors.grey,
              //               ),
              //               iconSize: 20,
              //               buttonHeight: 40,
              //               buttonWidth: 250,
              //               // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //               dropdownDecoration: BoxDecoration(
              //                 // color: Colors
              //                 //     .amber,
              //                 borderRadius: BorderRadius.circular(10),
              //                 border: Border.all(color: Colors.white, width: 1),
              //               ),
              //               items: zoneModels_report
              //                   .map((item) => DropdownMenuItem<String>(
              //                         value: '${item.zn}',
              //                         child: Text(
              //                           '${item.zn}',
              //                           textAlign: TextAlign.center,
              //                           style: const TextStyle(
              //                             overflow: TextOverflow.ellipsis,
              //                             fontSize: 14,
              //                             color: Colors.grey,
              //                           ),
              //                         ),
              //                       ))
              //                   .toList(),

              //               onChanged: (value) async {
              //                 int selectedIndex = zoneModels_report
              //                     .indexWhere((item) => item.zn == value);

              //                 setState(() {
              //                   zone_name_transMeter = value!;
              //                   zone_ser_transMeter =
              //                       zoneModels_report[selectedIndex].ser!;
              //                 });
              //                 print(
              //                     'Selected Index: $zone_name_transMeter  //${zone_ser_transMeter}');
              //               },
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: InkWell(
              //             onTap: () async {
              //               setState(() {
              //                 Ser_BodySta1 = 2;
              //               });

              //               if (Mon_transMeter_Mon != null &&
              //                   YE_transMeter_Mon != null &&
              //                   zone_name_transMeter != null &&
              //                   Ser_BodySta1 == 2) {
              //                 setState(() {
              //                   Await_Status_Report2 = 0;
              //                 });
              //                 Dia_log();
              //                 red_Trans_bill();
              //               }
              //             },
              //             child: Container(
              //                 width: 100,
              //                 padding: const EdgeInsets.all(8.0),
              //                 decoration: BoxDecoration(
              //                   color: Colors.green[700],
              //                   borderRadius: const BorderRadius.only(
              //                       topLeft: Radius.circular(10),
              //                       topRight: Radius.circular(10),
              //                       bottomLeft: Radius.circular(10),
              //                       bottomRight: Radius.circular(10)),
              //                 ),
              //                 child: Center(
              //                   child: Text(
              //                     'ค้นหา',
              //                     style: TextStyle(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.bold,
              //                       fontFamily: FontWeight_.Fonts_T,
              //                     ),
              //                   ),
              //                 )),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       InkWell(
              //           child: Container(
              //             decoration: BoxDecoration(
              //               color: Colors.yellow[600],
              //               borderRadius: const BorderRadius.only(
              //                   topLeft: Radius.circular(10),
              //                   topRight: Radius.circular(10),
              //                   bottomLeft: Radius.circular(10),
              //                   bottomRight: Radius.circular(10)),
              //               border: Border.all(color: Colors.grey, width: 1),
              //             ),
              //             padding: const EdgeInsets.all(8.0),
              //             child: const Center(
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Text(
              //                     'เรียกดู',
              //                     style: TextStyle(
              //                       color: ReportScreen_Color.Colors_Text1_,
              //                       fontWeight: FontWeight.bold,
              //                       fontFamily: FontWeight_.Fonts_T,
              //                     ),
              //                   ),
              //                   Icon(
              //                     Icons.navigate_next,
              //                     color: Colors.grey,
              //                   )
              //                 ],
              //               ),
              //             ),
              //           ),
              //           onTap: (transMeterModels.isEmpty ||
              //                   zone_name_transMeter == null ||
              //                   Ser_BodySta1 == 1)
              //               ? null
              //               : () async {
              //                   Electric_Widget();
              //                   // Insert_log.Insert_logs(
              //                   //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
              //                   // RE_maintenance_Widget();
              //                 }),
              //       (Ser_BodySta1 != 2)
              //           ? Padding(
              //               padding: EdgeInsets.all(8.0),
              //               child: Text(
              //                 'รายงานมิเตอร์น้ำ',
              //                 style: TextStyle(
              //                   color: ReportScreen_Color.Colors_Text2_,
              //                   // fontWeight: FontWeight.bold,
              //                   fontFamily: Font_.Fonts_T,
              //                 ),
              //               ),
              //             )
              //           : (transMeterModels.isEmpty)
              //               ? Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Text(
              //                     (Status_transMeter_ != null &&
              //                             transMeterModels.isEmpty &&
              //                             zone_name_transMeter != null &&
              //                             Await_Status_Report1 != null &&
              //                             Ser_BodySta1 != 1)
              //                         ? 'รายงานมิเตอร์น้ำ (ไม่พบข้อมูล ✖️)'
              //                         : 'รายงานมิเตอร์น้ำ',
              //                     style: const TextStyle(
              //                       color: ReportScreen_Color.Colors_Text2_,
              //                       // fontWeight: FontWeight.bold,
              //                       fontFamily: Font_.Fonts_T,
              //                     ),
              //                   ),
              //                 )
              //               : (transMeterModels.length != 0 &&
              //                       Await_Status_Report1 != null &&
              //                       Ser_BodySta1 == 2)
              //                   ? SizedBox(
              //                       // height: 20,
              //                       child: Row(
              //                       children: [
              //                         Container(
              //                             padding: const EdgeInsets.all(4.0),
              //                             child:
              //                                 const CircularProgressIndicator()),
              //                         const Padding(
              //                           padding: EdgeInsets.all(8.0),
              //                           child: Text(
              //                             'กำลังโหลดรายงานมิเตอร์น้ำ...',
              //                             style: TextStyle(
              //                               color: ReportScreen_Color
              //                                   .Colors_Text2_,
              //                               // fontWeight: FontWeight.bold,
              //                               fontFamily: Font_.Fonts_T,
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ))
              //                   : const Padding(
              //                       padding: EdgeInsets.all(8.0),
              //                       child: Text(
              //                         'รายงานมิเตอร์น้ำ ✔️',
              //                         style: TextStyle(
              //                           color: ReportScreen_Color.Colors_Text2_,
              //                           // fontWeight: FontWeight.bold,
              //                           fontFamily: Font_.Fonts_T,
              //                         ),
              //                       ),
              //                     ),
              //     ],
              //   ),
              // ),
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
                                    (Value_teNantDate_Daily == null)
                                        ? 'เลือก'
                                        : '$Value_teNantDate_Daily',
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
                      //               (Value_teNantDate_Daily == null)
                      //                   ? 'เลือก'
                      //                   : '$Value_teNantDate_Daily',
                      //               ReportScreen_Color.Colors_Text2_,
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
                                value: (zone_name_teNant_Daily == null)
                                    ? null
                                    : zone_name_teNant_Daily,
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
                                hint: (zone_name_teNant_Daily == null)
                                    ? null
                                    : Text(
                                        '$zone_name_teNant_Daily',
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
                                    zone_name_teNant_Daily = value!;
                                    zone_ser_teNant_Daily =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_name_teNant_Daily  //${zone_ser_teNant_Daily}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[1].clear();
                                  }
                                }),
                          ),
                          // DropdownButtonFormField2(
                          //   value: zone_name_teNant_Daily,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_teNant_Daily = value!;
                          //       zone_ser_teNant_Daily =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_name_teNant_Daily  //${zone_ser_teNant_Daily}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              Ser_BodyOverdue = 1;
                            });
                            if (Ser_BodyOverdue == 1 &&
                                zone_ser_teNant_Daily != null &&
                                Value_teNantDate_Daily != null) {
                              read_GC_tenant_Daily();
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
                            ),
                            onTap: (Ser_BodyOverdue == 1 &&
                                    teNantModels.length != 0 &&
                                    Value_teNantDate_Daily != null)
                                ? () async {
                                    Overdue_Widget();
                                    Insert_log.Insert_logs('รายงาน',
                                        'กดดูรายงานตั้งหนี้ค้างชำระรายวัน');
                                    // RE_maintenance_Widget();
                                  }
                                : null),
                        (Ser_BodyOverdue != 1)
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'รายงานตั้งหนี้ค้างชำระรายวัน',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (teNantModels.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (teNantModels.isEmpty &&
                                                Value_teNantDate_Daily !=
                                                    null &&
                                                Ser_BodyOverdue == 1)
                                            ? 'รายงานตั้งหนี้ค้างชำระรายวัน (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานตั้งหนี้ค้างชำระรายวัน',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                  )
                                : (Await_Status_Report2 != null &&
                                        Ser_BodyOverdue == 1)
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
                                                'กำลังโหลดรายงานตั้งหนี้ค้างชำระรายวัน...',
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
                                    : (teNantModels.length != 0 &&
                                            Await_Status_Report2 == 1 &&
                                            Ser_BodyOverdue == 1)
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
                                                        'กำลังโหลดรายงานตั้งหนี้ค้างชำระรายวัน...',
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
                                                'รายงานตั้งหนี้ค้างชำระรายวัน ✔️',
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
                                    (Mon_teNant_Mon == null ||
                                            YE_teNant_Mon == null)
                                        ? 'เลือก'
                                        : '$Mon_teNant_Mon / $YE_teNant_Mon',
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
                      //       value: (Mon_teNant_Mon == null)
                      //           ? null
                      //           : Mon_teNant_Mon,
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
                      //         Mon_teNant_Mon = value.toString();
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
                      //       value: YE_teNant_Mon,
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
                      //         YE_teNant_Mon = value.toString();
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
                                // value: (zone_name_BillAwatCheck_Mon == null)
                                //     ? null
                                //     : zone_name_BillAwatCheck_Mon,
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
                                hint: (zone_name_teNant_Mon == null)
                                    ? null
                                    : Text(
                                        '$zone_name_teNant_Mon',
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
                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_teNant_Mon = value!;
                                    zone_ser_teNant_Mon =
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              Ser_BodyOverdue = 2;
                            });
                            if (Ser_BodyOverdue == 2 &&
                                zone_ser_teNant_Mon != null &&
                                Mon_teNant_Mon != null) {
                              read_GC_tenant_Mont();
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
                            ),
                            onTap: (Ser_BodyOverdue == 2 &&
                                    teNantModels.length != 0 &&
                                    Mon_teNant_Mon != null)
                                ? () async {
                                    Overdue_Widget();
                                    Insert_log.Insert_logs('รายงาน',
                                        'กดดูรายงานตั้งหนี้ค้างชำระรายเดือน');
                                    // RE_maintenance_Widget();
                                  }
                                : null),
                        (Ser_BodyOverdue != 2)
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'รายงานค้างชำระรายเดือน',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (teNantModels.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (teNantModels.isEmpty &&
                                                Mon_teNant_Mon != null &&
                                                Ser_BodyOverdue == 2)
                                            ? 'รายงานตั้งหนี้ค้างชำระรายเดือน (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานตั้งหนี้ค้างชำระรายเดือน',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                  )
                                : (Await_Status_Report2 != null &&
                                        Ser_BodyOverdue == 2)
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
                                                'กำลังโหลดรายงานตั้งหนี้ค้างชำระรายเดือน...',
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
                                    : (teNantModels.length != 0 &&
                                            Await_Status_Report2 == 1 &&
                                            Ser_BodyOverdue == 2)
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
                                                        'กำลังโหลดรายงานตั้งหนี้ค้างชำระรายเดือน...',
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
                                                'รายงานตั้งหนี้ค้างชำระรายเดือน ✔️',
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
                                value: (zone_name_teNant_All == null)
                                    ? null
                                    : zone_name_teNant_All,
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
                                hint: (zone_name_teNant_All == null)
                                    ? null
                                    : Text(
                                        '$zone_name_teNant_All',
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
                                  int selectedIndex = zoneModels_report
                                      .indexWhere((item) => item.zn == value);

                                  setState(() {
                                    zone_name_teNant_All = value!;
                                    zone_ser_teNant_All =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // print(
                                  //     'Selected Index: $zone_name_teNant_All  //${zone_ser_teNant_All}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[2].clear();
                                  }
                                }),
                          ),

                          // DropdownButtonFormField2(
                          //   value: zone_name_teNant_All,
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
                          //     int selectedIndex = zoneModels_report
                          //         .indexWhere((item) => item.zn == value);

                          //     setState(() {
                          //       zone_name_teNant_All = value!;
                          //       zone_ser_teNant_All =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // print(
                          //     //     'Selected Index: $zone_name_teNant_All  //${zone_ser_teNant_All}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              Ser_BodyOverdue = 3;
                            });
                            if (Ser_BodyOverdue == 3 &&
                                zone_ser_teNant_All != null) {
                              read_GC_tenant_All();
                              read_GC_tenant_All_Mini();
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
                            ),
                            onTap: (Ser_BodyOverdue == 3 &&
                                    teNantModels.length != 0 &&
                                    zone_ser_teNant_All != null)
                                ? () async {
                                    Overdue_Widget();
                                    Insert_log.Insert_logs('รายงาน',
                                        'กดดูรายงานตั้งหนี้ค้างชำระทั้งหมด');
                                    // RE_maintenance_Widget();
                                  }
                                : null),
                        (Ser_BodyOverdue != 3)
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    'รายงานตั้งหนี้ค้างชำระทั้งหมด',
                                    ReportScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              )
                            : (teNantModels.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        (teNantModels.isEmpty &&
                                                zone_ser_teNant_All != null &&
                                                Ser_BodyOverdue == 3)
                                            ? 'รายงานตั้งหนี้ค้างชำระทั้งหมด (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานตั้งหนี้ค้างชำระทั้งหมด',
                                        ReportScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.w500,
                                        Font_.Fonts_T,
                                        Text_Size,
                                        1),
                                  )
                                : (teNantModels.length != 0 &&
                                        Await_Status_Report3 == 1 &&
                                        Ser_BodyOverdue == 3)
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
                                                'กำลังโหลดรายงานตั้งหนี้ค้างชำระทั้งหมด...',
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
                                            'รายงานตั้งหนี้ค้างชำระทั้งหมด✔️',
                                            ReportScreen_Color.Colors_Text1_,
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

  ///////////////////////////----------------------------------------------->(รายงานมิเตอร์ไฟฟ้า-น้ำ)
  Electric_Widget() {
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
                  child: Text(
                (zone_name_transMeter == null)
                    ? (expSZ_name.toString().trim() != 'ทั้งหมด')
                        ? 'รายงาน $expSZ_name (กรุณาเลือกโซน)'
                        : 'รายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ]  (กรุณาเลือกโซน)'
                    : (expSZ_name.toString().trim() != 'ทั้งหมด')
                        ? 'รายงาน $expSZ_name  (โซน : $zone_name_transMeter)'
                        : 'รายงาน [${expSZModels.where((model) => model.ser.toString() != '0').map((model) => model.expname).join(',')} ]  (โซน : $zone_name_transMeter)',
                // (zone_name_transMeter == null)
                //     ? 'รายงานมิเตอร์น้ำ-ไฟฟ้า (กรุณาเลือกโซน)'
                //     : 'รายงานมิเตอร์น้ำ-ไฟฟ้า (โซน : $zone_name_transMeter) ',
                style: const TextStyle(
                  color: ReportScreen_Color.Colors_Text1_,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              )
                  //  (Ser_BodySta1 == 1)
                  //     ? Text(
                  //         (zone_name_transMeter == null)
                  //             ? 'รายงานมิเตอร์ไฟฟ้า (กรุณาเลือกโซน)'
                  //             : 'รายงานมิเตอร์ไฟฟ้า (โซน : $zone_name_transMeter) ',
                  //         style: const TextStyle(
                  //           color: ReportScreen_Color.Colors_Text1_,
                  //           fontWeight: FontWeight.bold,
                  //           fontFamily: FontWeight_.Fonts_T,
                  //         ),
                  //       )
                  //     : Text(
                  //         (zone_name_transMeter == null)
                  //             ? 'รายงานมิเตอร์น้ำ (กรุณาเลือกโซน)'
                  //             : 'รายงานมิเตอร์น้ำ (โซน : $zone_name_transMeter) ',
                  //         style: const TextStyle(
                  //           color: ReportScreen_Color.Colors_Text1_,
                  //           fontWeight: FontWeight.bold,
                  //           fontFamily: FontWeight_.Fonts_T,
                  //         ),
                  //       )
                  ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        (Mon_transMeter_Mon == null &&
                                YE_transMeter_Mon == null)
                            ? 'เดือน : ? (?) '
                            : (Mon_transMeter_Mon == null)
                                ? 'เดือน : ? ($YE_transMeter_Mon) '
                                : (YE_transMeter_Mon == null)
                                    ? 'เดือน : $Mon_transMeter_Mon (?) '
                                    : 'เดือน : $Mon_transMeter_Mon ($YE_transMeter_Mon) ',
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
                        'ทั้งหมด: ${transMeterModels.length}',
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
                    // Expanded(child: _searchBar_ChoArea()),
                  ],
                ),
              ),
            ],
          ),
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
                              ? MediaQuery.of(context).size.width * 0.925
                              : (transMeterModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (transMeterModels.length == 0)
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
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
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รหัสพื้นที่',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'เลขที่สัญญา',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ชื่อร้านค้า',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รายการ',
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
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'วันที่',
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
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'หมายเลขเครื่อง',
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
                                            flex: 1,
                                            child: Text(
                                              (transMeterModels.length == 0 ||
                                                      transMeterModels[0]
                                                              .date ==
                                                          null ||
                                                      transMeterModels[0]
                                                              .date
                                                              .toString() ==
                                                          '')
                                                  ? 'เลขมิเตอร์เดือน(??)'
                                                  : 'เลขมิเตอร์เดือน(${DateFormat.MMM('th_TH').format(DateTime.parse('${DateFormat('yyyy').format(DateTime.parse('${transMeterModels[0].date}'))}-${(DateTime.parse('${transMeterModels[0].date}').month - 1).toString().padLeft(2, '0')}-${DateFormat('dd').format(DateTime.parse('${transMeterModels[0].date}'))} 00:00:00'))})',
                                              // 'เลขมิเตอร์เดือน(${DateFormat.MMM('th_TH').format(DateTime.parse('${transMeterModels[0].date}'))})',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              (transMeterModels.length == 0 ||
                                                      transMeterModels[0]
                                                              .date ==
                                                          null ||
                                                      transMeterModels[0]
                                                              .date
                                                              .toString() ==
                                                          '')
                                                  ? 'เลขมิเตอร์เดือน(??)'
                                                  : 'เลขมิเตอร์เดือน(${DateFormat.MMM('th_TH').format(DateTime.parse('${transMeterModels[0].date}'))})',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'หน่วยที่ใช้',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ราคาต่อหน่วย',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รวม Vat',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: Text(
                                          //     '...',
                                          //     textAlign: TextAlign.center,
                                          //     style: TextStyle(
                                          //       color: ManageScreen_Color
                                          //           .Colors_Text1_,
                                          //       fontWeight: FontWeight.bold,
                                          //       fontFamily: FontWeight_.Fonts_T,
                                          //     ),
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
                                      itemCount: transMeterModels.length,
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
                                              setState(() {
                                                show_more = index;
                                              });
                                            },
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
                                              child: Row(children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].zn}',
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].ln}',
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].refno}',
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].sname}',
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].expname}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    '${DateFormat('dd-MM').format(DateTime.parse('${transMeterModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${transMeterModels[index].date}'))}') + 543}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    '${transMeterModels[index].num_meter}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    '${nFormat2.format(double.parse(transMeterModels[index].ovalue!))}',
                                                    // '${transMeterModels[index].ovalue}',
                                                    textAlign: TextAlign.right,
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
                                                  flex: 1,
                                                  child: Text(
                                                    '${nFormat2.format(double.parse(transMeterModels[index].nvalue!))}',
                                                    // '${transMeterModels[index].nvalue}',
                                                    textAlign: TextAlign.end,
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
                                                  flex: 1,
                                                  child: Text(
                                                    '${nFormat.format(double.parse(transMeterModels[index].qty!))}',
                                                    //'${transMeterModels[index].qty}',
                                                    textAlign: TextAlign.right,
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
                                                  flex: 1,
                                                  child: Text(
                                                    transMeterModels[index]
                                                                .ele_ty ==
                                                            '0'
                                                        ? '${nFormat.format(double.parse(transMeterModels[index].c_qty!))}'
                                                        : 'อัตราพิเศษ',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      color: transMeterModels[
                                                                      index]
                                                                  .ele_ty ==
                                                              '0'
                                                          ? ManageScreen_Color
                                                              .Colors_Text2_
                                                          : Colors.orange,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${nFormat.format(double.parse(transMeterModels[index].c_amt!))}',
                                                    //'${transMeterModels[index].c_amt}',
                                                    textAlign: TextAlign.right,
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
                    if (transMeterModels.length != 0)
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
                              Value_Report = 'รายงานมิเตอร์น้ำ-ไฟฟ้า';
                              // Value_Report = (Ser_BodySta1 == 1)
                              //     ? 'รายงานมิเตอร์ไฟฟ้า'
                              //     : 'รายงานมิเตอร์น้ำ';
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
                            transMeterModels.clear();
                            Ser_BodySta1 = 0;
                            YE_transMeter_Mon = null;
                            Mon_transMeter_Mon = null;

                            zone_ser_transMeter = null;
                            zone_name_transMeter = null;
                            Status_transMeter_ = null;
                            Status_transMeter_ser = null;
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

  ///////////////////////////----------------------------------------------->(รายงานค้างชำระ) Excel_Overdue_Report
  Overdue_Widget() {
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
                  child: Text(
                (Value_teNantDate_Daily != null)
                    ? (zone_ser_teNant_Daily == null)
                        ? 'รายงานตั้งหนี้ค้างชำระรายวัน (กรุณาเลือกโซน)'
                        : 'รายงานตั้งหนี้ค้างชำระรายวัน (โซน : $zone_name_teNant_Daily)'
                    : (Mon_teNant_Mon != null ||
                            YE_teNant_Mon != null ||
                            zone_ser_teNant_Mon != null)
                        ? (zone_ser_teNant_Mon == null)
                            ? 'รายงานตั้งหนี้ค้างชำระรายเดือน (กรุณาเลือกโซน)'
                            : 'รายงานตั้งหนี้ค้างชำระรายเดือน (โซน : ${zone_name_teNant_Mon})'
                        : (zone_ser_teNant_All == null)
                            ? 'รายงานตั้งหนี้ค้างชำระทั้งหมด (กรุณาเลือกโซน)'
                            : 'รายงานตั้งหนี้ค้างชำระทั้งหมด (โซน : ${zone_name_teNant_All})',
                // (zone_name_transMeter == null)
                //     ? 'รายงานค้างชำระ (กรุณาเลือกโซน)'
                //     : 'รายงานค้างชำระ (โซน : $zone_name_transMeter) ',
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
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: RichText(
                        text: TextSpan(
                          text: 'หมายเหตุค้างชำระ/Info:',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: FontWeight_.Fonts_T),
                          children: <TextSpan>[
                            TextSpan(
                              text: '  > 90วัน/day,',
                              style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 10,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                            TextSpan(
                              text: '  > 60วัน/day,',
                              style: TextStyle(
                                  color: Colors.orange.shade400,
                                  fontSize: 10,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                            TextSpan(
                              text: '  > 30วัน/day',
                              style: TextStyle(
                                  color: Colors.deepPurple.shade400,
                                  fontSize: 10,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                // padding: EdgeInsets.all(10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Expanded(child: _searchBar_ChoArea()),
                  ],
                ),
              ),
            ],
          ),
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
                              ? MediaQuery.of(context).size.width * 0.925
                              : (teNantModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (teNantModels.length == 0)
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'เลขที่สัญญา',
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
                                            flex: 1,
                                            child: Text(
                                              'เลขที่ตั้งหนี้',
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
                                            flex: 1,
                                            child: Text(
                                              'เลขที่วางบิล',
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
                                            flex: 1,
                                            child: Text(
                                              'โซน',
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
                                            flex: 1,
                                            child: Text(
                                              'รหัสพื้นที่',
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
                                            flex: 1,
                                            child: Text(
                                              'ชื่อร้าน',
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
                                            flex: 1,
                                            child: Text(
                                              'ผู้เช่า',
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
                                            flex: 1,
                                            child: Text(
                                              'รายการค้างชำระ',
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
                                            flex: 1,
                                            child: Text(
                                              'กำหนดชำระ',
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
                                            flex: 1,
                                            child: Text(
                                              'ค้างชำระ',
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
                                      itemCount: teNantModels.length,
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
                                              setState(() {
                                                show_more = index;
                                              });
                                            },
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
                                              child: Row(children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${teNantModels[index].cid}',
                                                      style: const TextStyle(
                                                        color: HomeScreen_Color
                                                            .Colors_Text1_,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: Text(
                                                      (teNantModels[index]
                                                                  .cid ==
                                                              null)
                                                          ? ''
                                                          : '${teNantModels[index].cid}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                        color:
                                                            ManageScreen_Color
                                                                .Colors_Text2_,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${teNantModels[index].docno}',
                                                      style: const TextStyle(
                                                        color: HomeScreen_Color
                                                            .Colors_Text1_,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: Text(
                                                      (teNantModels[index]
                                                                  .docno ==
                                                              null)
                                                          ? ''
                                                          : '${teNantModels[index].docno}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color:
                                                            ManageScreen_Color
                                                                .Colors_Text2_,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text: teNantModels[index]
                                                                  .invoice ==
                                                              null
                                                          ? ''
                                                          : '${teNantModels[index].invoice}',
                                                      style: const TextStyle(
                                                        color: HomeScreen_Color
                                                            .Colors_Text1_,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        //fontSize: 10.0
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: Text(
                                                      (teNantModels[index]
                                                                  .invoice ==
                                                              null)
                                                          ? ''
                                                          : '${teNantModels[index].invoice}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color:
                                                            ManageScreen_Color
                                                                .Colors_Text2_,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        // fontSize: 12.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${teNantModels[index].zn}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index].ln_c ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels[index].ln_c}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index]
                                                                .sname ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels[index].sname}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index]
                                                                .cname ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels[index].cname}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index]
                                                                .expname ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels[index].expname}',
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
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index].date ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse(teNantModels[index].date!))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${teNantModels[index].date}'))}') + 0}',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      color: (DateTime.parse(
                                                                  teNantModels[index]
                                                                      .date!)
                                                              .isBefore(datex.add(
                                                                  Duration(
                                                                      days:
                                                                          -90))))
                                                          ? Colors.red.shade400
                                                          : (DateTime.parse(
                                                                      teNantModels[index]
                                                                          .date!)
                                                                  .isBefore(datex
                                                                      .add(Duration(days: -60))))
                                                              ? Colors.orange.shade400
                                                              : (DateTime.parse(teNantModels[index].date!).isBefore(datex.add(Duration(days: -30))))
                                                                  ? Colors.deepPurple.shade400
                                                                  : ManageScreen_Color.Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (teNantModels[index]
                                                                .total ==
                                                            null)
                                                        ? ''
                                                        : '${nFormat.format(double.parse(teNantModels[index].total!))}',
                                                    textAlign: TextAlign.right,
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
                              Value_Report = (Ser_BodyOverdue == 1)
                                  ? 'รายงานตั้งหนี้ค้างชำระรายวัน'
                                  : (Ser_BodyOverdue == 2)
                                      ? 'รายงานตั้งหนี้ค้างชำระรายเดือน'
                                      : 'รายงานตั้งหนี้ค้างชำระทั้งหมด';
                              Pre_and_Dow = 'Download';
                            });
                            if (Ser_BodyOverdue == 1 || Ser_BodyOverdue == 2) {
                              _showMyDialog_SAVE();
                            } else {
                              _showMyDialog_SAVE2();
                            }
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
                            teNantModels.clear();
                            //----->
                            Value_teNantDate_Daily = null;
                            zone_ser_teNant_Daily = null;
                            zone_name_teNant_Daily = null;
                            //----->
                            zone_ser_teNant_Mon = null;
                            zone_name_teNant_Mon = null;
                            Mon_teNant_Mon = null;
                            YE_teNant_Mon = null;
                            //----->
                            zone_ser_teNant_All = null;
                            zone_name_teNant_All = null;
                            Ser_BodyOverdue = 0;
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

  ////////////------------------------------------------------------>(Export file)
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

  ////////////------------------------------------------------------>(Export file2)
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
                            //  print(_ReportValue_type);
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

////////////------------------------------------------>
  void InkWell_onTap(context) async {
    setState(() {
      NameFile_ = '';
      NameFile_ = FormNameFile_text.text;
    });

    if (_verticalGroupValue_NameFile == 'กำหนดเอง') {
    } else {
      if (_verticalGroupValue_PassW == 'PDF') {
        Navigator.of(context).pop();
      } else {
        if (Value_Report == 'รายงานมิเตอร์น้ำ-ไฟฟ้า') {
          Excgen_transMeterReport.exportExcel_transMeterReport(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              transMeterModels,
              Mon_transMeter_Mon,
              YE_transMeter_Mon,
              Status_transMeter_,
              zone_name_transMeter,
              Ser_BodySta1,
              expSZ_name,
              expSZModels);
        }
        // else if (Value_Report == 'รายงานมิเตอร์น้ำ') {
        //   Excgen_transMeterReport.exportExcel_transMeterReport(
        //       context,
        //       NameFile_,
        //       _verticalGroupValue_NameFile,
        //       renTal_name,
        //       transMeterModels,
        //       Mon_transMeter_Mon,
        //       YE_transMeter_Mon,
        //       Status_transMeter_,
        //       zone_name_transMeter,
        //       Ser_BodySta1);
        // }
        else if (Value_Report == 'รายงานค้างชำระรายวัน') {
          Excgen_OverdueReport.exportExcel_overdueReport(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              teNantModels,
              Value_teNantDate_Daily,
              zone_name_teNant_Daily,
              zone_name_teNant_All,
              Ser_BodyOverdue,
              zone_ser_teNant_All);
        } else if (Value_Report == 'รายงานตั้งหนี้ค้างชำระรายเดือน') {
          Excgen_OverdueReport.exportExcel_overdueReport(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              teNantModels,
              Value_teNantDate_Daily,
              zone_name_teNant_Mon,
              zone_name_teNant_Mon,
              Ser_BodyOverdue,
              zone_ser_teNant_All);
        } else if (Value_Report == 'รายงานตั้งหนี้ค้างชำระทั้งหมด') {
          if (_ReportValue_type.toString() == 'ย่อ') {
            Mini_Excgen_OverdueReport.mini_exportExcel_overdueReport(
                context,
                NameFile_,
                _verticalGroupValue_NameFile,
                renTal_name,
                teNantModels_mini,
                Value_teNantDate_Daily,
                zone_name_teNant_Daily,
                zone_name_teNant_All,
                Ser_BodyOverdue,
                zone_ser_teNant_All);
          } else {
            Excgen_OverdueReport.exportExcel_overdueReport(
                context,
                NameFile_,
                _verticalGroupValue_NameFile,
                renTal_name,
                teNantModels,
                Value_teNantDate_Daily,
                zone_name_teNant_Daily,
                zone_name_teNant_All,
                Ser_BodyOverdue,
                zone_ser_teNant_All);
          }
        }
        Navigator.of(context).pop();
      }
    }
  }
}

// SELECT
//     c_area.*,
//     c_trans.ser AS ser_tran,
//     c_trans.docno AS docno,
//    SUM( c_trans.total ) AS total,
//     c_trans.date,
//     c_invoice.docno AS invoice,
//     c_trans.expname,
//     c_contract.sdate AS sdate,
//     c_contract.ldate AS ldate,
//     c_contract.cname AS cname,
//     c_contract.sname AS sname,
//     c_contract.addr AS addr,
//     c_contract.tax AS tax,
//     c_contract.period AS period,
//     c_contract.rtname AS rtname,
//     c_contract.ln AS ln_c,
//     c_contract.area AS area_c,
//     c_contract.zn AS zn,
//     1 AS count_bill,
//     c_trans.total AS count_total

// FROM c_area
// LEFT JOIN c_contract ON c_area.cid = c_contract.cid

// LEFT JOIN c_trans ON c_contract.cid = c_trans.refno
// LEFT JOIN c_invoice ON c_trans.docno = c_invoice.refno  AND c_invoice.dtype != '!Z'

// WHERE  c_trans.dtype IN ('KR', 'KD', 'KO', 'KU')

// AND c_trans.refno = c_contract.cid

// AND MONTH(c_trans.date) <= MONTH(CURDATE())
// AND c_trans.date <= CURDATE()
// AND YEAR(c_trans.date) <= YEAR(CURDATE())
// -- AND c_trans.refno =  'LE100446'

// AND ( NOT (c_trans.docno IN ( SELECT c_trans.refno FROM c_trans WHERE c_trans.dtype IN ('KP') )) )
// OR (c_trans.dtype IN ('KU') AND ( NOT (c_trans.docno IN ( SELECT c_trans.refno FROM c_trans WHERE c_trans.dtype IN ('KP')))) )

// AND c_trans.refno = c_contract.cid
// AND MONTH(c_trans.date) <= MONTH(CURDATE())
// AND c_trans.date <= CURDATE()
//  AND c_trans.date <= CURDATE()
// -- AND c_trans.refno =  'LE100446'
// AND (
//       (c_trans.dtype IN ('KR','KD','KO','KU') and (NOT(c_trans.docno IN (SELECT c_trans.refno FROM c_trans WHERE (c_trans.dtype IN ('KP'))))))
//     )

// AND MONTH(c_trans.date) <= MONTH(CURDATE())
// AND c_trans.date <= CURDATE()
//  AND c_trans.date <= CURDATE()
// AND YEAR(c_trans.date) <= YEAR(CURDATE())
// -- AND c_trans.refno =  'LE100446'

// AND (NOT(c_trans.docno IN (SELECT c_invoice.refno FROM c_invoice WHERE c_invoice.docno = '' AND dtype = '!Z')))
// AND MONTH(c_trans.date) <= MONTH(CURDATE())

// AND ( SELECT c_invoice.docno FROM c_invoice WHERE c_invoice.refno = c_trans.docno AND c_invoice.dtype IN ('KR', 'KD', 'KU', 'KO'))

// 	GROUP BY c_trans.refno  , MONTH(c_trans.date)
// HAVING total != 0 AND (invoice IS NULL OR invoice = '')
// ORDER BY c_contract.zn ,c_contract.ln  ASC;
