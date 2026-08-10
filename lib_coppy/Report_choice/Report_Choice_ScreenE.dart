import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetInvoiceRe_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Model/Getexp_sz_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Report/Excel_BankDaily_Report.dart';
import '../Report/Excel_Bankmovemen_Report.dart';
import '../Report/Excel_Daily_Report.dart';
import '../Report/Excel_Income_Report.dart';
import '../Report/Excel_PeopleCho_Report.dart';
import '../Report/Excel_teNantnoti.dart';
import '../Report/Report_Mini/MIni_Ex_BankDaily_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Bankmovemen_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Daily_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Income_Re.dart';
import '../Report_Ortorkor/Excel_invoiceOrtor_Report.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Excel_Area_serviceFeeShort_Report.dart';
import 'Excel_ChaoArea_Report_Choice.dart';
import 'Excel_ChaoArea_Report_ChoiceNew.dart';
import 'Excel_PeopleCho_Choice_Report.dart';
import 'Excel_invoiceChoice_Report.dart';
import 'Excel_teNantDate_Choice.dart';
import 'Excel_teNantnoti_Choice.dart';
import 'Excel_transMeterChoice_Report.dart';
import 'Report_Mini/Mini_Ex_invoiceChoice_Report.dart';

class Report_Choice_ScreenE extends StatefulWidget {
  const Report_Choice_ScreenE({super.key});

  @override
  State<Report_Choice_ScreenE> createState() => _Report_Choice_ScreenEState();
}

class _Report_Choice_ScreenEState extends State<Report_Choice_ScreenE> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  int? show_more;
  final _formKey = GlobalKey<FormState>();
  final FormNameFile_text = TextEditingController();
  int open_set_date = 30;

  ///------------------------>
  int? Await_Status_Report1,
      Await_Status_Report2,
      Await_Status_Report3,
      Await_Status_Report4,
      Await_Status_Report5,
      Await_Status_Report6;
  double Text_Size = 13.00;
  //-------------------------------------->
  String _verticalGroupValue_PassW = "EXCEL";
  String _ReportValue_type = "ปกติ";
  String _verticalGroupValue_NameFile = "จากระบบ";
  String Value_Report = ' ';
  String NameFile_ = '';
  String Pre_and_Dow = '';
  ///////////--------------------------------------------->
  List<String> YE_Th = [];
  List<String> Mont_Th = [];
  ///////////--------------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<ExpModel> expModels = [];
  List<ExpModel> expModels_Mini = [];
  List<AreaModel> areaModels = [];
  ///////////--------------------------------------------->

  // late List<List<QuotxSelectModel>> quotxSelectModels;

  // List<QuotxSelectModel> quotxSelectModels_Select = [];
  ///////////--------------------------------------------->
  String? zone_ser_Pe_Mon, zone_name_Pe_Mon;
  String? zone_ser_Area, zone_name_Area;
  String? YE_Pe_Mon, Mon_Pe_Mon;
  ///////////--------------------------------------------->
  String? renTal_user, renTal_name, zone_ser, zone_name;
  DateTime now = DateTime.now();
  String? rtname, type, typex, renname, bill_name, bill_addr, bill_tax;
  String? bill_tel, bill_email, expbill, expbill_name, bill_default;
  String? bill_tser, foder, bills_name_;
  String? Status_pe,
      Status_pe_ser,
      Value_Chang_Zone_People,
      Value_Chang_Zone_People_Ser;
  String? YE_Cid_ldate, Mon_Cid_ldate;
////////--------------------------------------------->>
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

  List Status = [
    'ปัจจุบัน',
    'หมดสัญญา',
    'ใกล้หมดสัญญา',
    // 'ผู้สนใจ',
  ];
  int Ser_Cid_ldate = 0;
  List Cid_ldate = [
    'ทั้งหมด',
    'ระบุ (ด/ป)',
  ];
  ////////--------------------------------------------->
  List<TextEditingController> Dropdown_Controller_zone = [];
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    // TODO: implement initState
    super.initState();
    checkPreferance();
    read_GC_rental();
    read_GC_zone();
    read_GC_Exp();
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
      // //print(result);
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
      // //print(result);
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
          var pen_set_datex = int.parse(renTalModel.open_set_date!);

          setState(() {
            open_set_date = pen_set_datex == 0 ? 30 : pen_set_datex;
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
      // //print('Error-Dis(read_GC_rental) : ${e}');
    }
    // //print('name>>>>>  $renname');
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
      // //print(result);
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

////////////----------------------------------------Status------------->(รายงาน พื้นที่เช่าที่ข้อมูลผู้เช่ามากกว่า 1)
  Future<Null> read_GC_tenant() async {
    if (teNantModels.isNotEmpty) {
      teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Pe_Mon == null || zone_ser_Pe_Mon.toString() == '')
        ? '0'
        : '$zone_ser_Pe_Mon';

    String url = zone == null || zone == '0'
        ? '${MyConstant().domain}/GC_Repeatspace_ChoiceReport.php?isAdd=true&ren=$ren&zone=0'
        : '${MyConstant().domain}/GC_Repeatspace_ChoiceReport.php?isAdd=true&ren=$ren&zone=$zone';
    // //print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModelss = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModelss);
          });
        }
      } else {}
    } catch (e) {}
  }

////////////----------------------------------------Status------------->(รายงาน พื้นที่เช่าที่)
  Future<Null> read_GC_AreaAll() async {
    if (areaModels.isNotEmpty) {
      areaModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Area == null || zone_ser_Area.toString() == '')
        ? '0'
        : '$zone_ser_Area';

    String url = zone == null || zone == '0'
        ? '${MyConstant().domain}/GC_AreaAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=0'
        : '${MyConstant().domain}/GC_AreaAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=$zone';
    // //print(url);

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);
          });
        }
      } else {}
    } catch (e) {}
  }

///////////------------------------------------------>
  Future<Null> read_GC_tenantSelect() async {
    if (teNantModels.isNotEmpty) {
      setState(() {
        teNantModels.clear();
        _teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = Value_Chang_Zone_People_Ser;

    // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $Status_pe_ser');   Mon_Cid_ldate   YE_Cid_ldate Ser_Cid_ldate
    String url = zone == null
        ? '${MyConstant().domain}/GC_tenantAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=0&type=$Ser_Cid_ldate&Mon=$Mon_Cid_ldate&YE=$YE_Cid_ldate'
        : zone == '0'
            ? '${MyConstant().domain}/GC_tenantAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=0&type=$Ser_Cid_ldate&Mon=$Mon_Cid_ldate&YE=$YE_Cid_ldate'
            : '${MyConstant().domain}/GC_tenantAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=$zone&type=$Ser_Cid_ldate&Mon=$Mon_Cid_ldate&YE=$YE_Cid_ldate';
    // //print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (Status_pe_ser.toString() == '1') {
            if (datex.isAfter(
                    DateTime.parse('${teNantModel.ldate} 00:00:00.000')
                        .subtract(const Duration(days: 0))) ==
                true) {
            } else {
              setState(() {
                teNantModels.add(teNantModel);
              });
            }
          } else if (Status_pe_ser.toString() == '2') {
            if (datex.isAfter(
                    DateTime.parse('${teNantModel.ldate} 00:00:00.000')
                        .subtract(const Duration(days: 0))) ==
                true) {
              setState(() {
                teNantModels.add(teNantModel);
              });
            }
          } else if (Status_pe_ser.toString() == '3') {
            if (datex.isAfter(
                    DateTime.parse('${teNantModel.ldate} 00:00:00.000')
                        .subtract(const Duration(days: 0))) ==
                true) {
            } else if (datex.isAfter(
                    DateTime.parse('${teNantModel.ldate} 00:00:00.000')
                        .subtract(Duration(days: open_set_date))) ==
                true) {
              setState(() {
                teNantModels.add(teNantModel);
              });
            } else {}
          }
          // setState(() {
          //   teNantModels.add(teNantModel);
          // });
        }
      } else {}

      setState(() {
        _teNantModels = teNantModels;
      });
    } catch (e) {}

    // quotxSelectModels = List.generate(teNantModels.length, (_) => []);
    // red_quotx();
  }

////////------------------------------------->
  // ///  String? YE_Cid_ldate, Mon_Cid_ldate;
  // Future<Null> read_GC_tenantSelect2_ldate() async {
  //   if (teNantModels.isNotEmpty) {
  //     setState(() {
  //       teNantModels.clear();
  //       _teNantModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var ren = preferences.getString('renTalSer');
  //   var zone = Value_Chang_Zone_People_Ser;

  //   // //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $Status_pe_ser');

  //   if (Status_pe_ser == '1') {
  //     String url = zone == null
  //         ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //         : zone == '0'
  //             ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //             : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // //print(result);
  //       if (result != null) {
  //         for (var map in result) {
  //           TeNantModel teNantModel = TeNantModel.fromJson(map);
  //           if (teNantModel.quantity == '1') {
  //             var daterx = teNantModel.ldate == null
  //                 ? teNantModel.ldate_q
  //                 : teNantModel.ldate;

  //             if (daterx != null) {
  //               int daysBetween(DateTime from, DateTime to) {
  //                 from = DateTime(from.year, from.month, from.day);
  //                 to = DateTime(to.year, to.month, to.day);
  //                 return (to.difference(from).inHours / 24).round();
  //               }

  //               var birthday = DateTime.parse('$daterx 00:00:00.000')
  //                   .add(const Duration(days: -30));
  //               var date2 = DateTime.now();
  //               var difference = daysBetween(birthday, date2);

  //               // //print('difference == $difference');

  //               var daterx_now = DateTime.now();

  //               var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

  //               final now = DateTime.now();
  //               final earlier = daterx_ldate.subtract(const Duration(days: 0));
  //               var daterx_A = now.isAfter(earlier);
  //               // //print(now.isAfter(earlier)); // true
  //               // //print(now.isBefore(earlier)); // true

  //               if (daterx_A != true) {
  //                 setState(() {
  //                   teNantModels.add(teNantModel);
  //                 });
  //               }
  //             }
  //           }
  //         }
  //       } else {}

  //       setState(() {
  //         _teNantModels = teNantModels;
  //       });
  //     } catch (e) {}
  //   } else if (Status_pe_ser == '2') {
  //     String url = zone == null
  //         ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //         : zone == '0'
  //             ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //             : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // //print(result);
  //       if (result != null) {
  //         for (var map in result) {
  //           TeNantModel teNantModel = TeNantModel.fromJson(map);
  //           var daterx = teNantModel.ldate == null
  //               ? teNantModel.ldate_q
  //               : teNantModel.ldate;

  //           if (daterx != null) {
  //             int daysBetween(DateTime from, DateTime to) {
  //               from = DateTime(from.year, from.month, from.day);
  //               to = DateTime(to.year, to.month, to.day);
  //               return (to.difference(from).inHours / 24).round();
  //             }

  //             var birthday = DateTime.parse('$daterx 00:00:00.000')
  //                 .add(const Duration(days: -30));
  //             var date2 = DateTime.now();
  //             var difference = daysBetween(birthday, date2);

  //             // //print('difference == $difference');

  //             var daterx_now = DateTime.now();

  //             var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

  //             final now = DateTime.now();
  //             final earlier = daterx_ldate.subtract(const Duration(days: 0));
  //             var daterx_A = now.isAfter(earlier);
  //             // //print(now.isAfter(earlier)); // true
  //             // //print(now.isBefore(earlier)); // true

  //             if (daterx_A == true) {
  //               setState(() {
  //                 if (teNantModel.quantity == '1') {
  //                   teNantModels.add(teNantModel);
  //                 }
  //               });
  //             }
  //           }
  //         }
  //       } else {}
  //       setState(() {
  //         _teNantModels = teNantModels;
  //       });
  //     } catch (e) {}
  //   } else if (Status_pe_ser == '3') {
  //     String url = zone == null
  //         ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //         : zone == '0'
  //             ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //             : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // //print(result);
  //       if (result != null) {
  //         for (var map in result) {
  //           TeNantModel teNantModel = TeNantModel.fromJson(map);
  //           if (teNantModel.quantity == '1') {
  //             if (datex.isAfter(
  //                     DateTime.parse('${teNantModel.ldate} 00:00:00.000')
  //                         .subtract(Duration(days: open_set_date))) ==
  //                 true) {
  //               var daterx = teNantModel.ldate == null
  //                   ? teNantModel.ldate_q
  //                   : teNantModel.ldate;

  //               if (daterx != null) {
  //                 int daysBetween(DateTime from, DateTime to) {
  //                   from = DateTime(from.year, from.month, from.day);
  //                   to = DateTime(to.year, to.month, to.day);
  //                   return (to.difference(from).inHours / 24).round();
  //                 }

  //                 var birthday = DateTime.parse('$daterx 00:00:00.000')
  //                     .add(const Duration(days: -30));
  //                 var date2 = DateTime.now();
  //                 var difference = daysBetween(birthday, date2);

  //                 // //print('difference == $difference');

  //                 var daterx_now = DateTime.now();

  //                 var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

  //                 final now = DateTime.now();
  //                 final earlier =
  //                     daterx_ldate.subtract(const Duration(days: 0));
  //                 var daterx_A = now.isAfter(earlier);
  //                 // //print(now.isAfter(earlier)); // true
  //                 // //print(now.isBefore(earlier)); // true

  //                 if (daterx_A != true) {
  //                   setState(() {
  //                     teNantModels.add(teNantModel);
  //                   });
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       } else {}
  //       setState(() {
  //         _teNantModels = teNantModels;
  //       });
  //     } catch (e) {}
  //   } else if (Status_pe_ser == '4') {
  //     String url = zone == null
  //         ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //         : zone == '0'
  //             ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
  //             : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // //print(result);
  //       if (result != null) {
  //         for (var map in result) {
  //           TeNantModel teNantModel = TeNantModel.fromJson(map);
  //           if (teNantModel.quantity == '2' || teNantModel.quantity == '3') {
  //             setState(() {
  //               teNantModels.add(teNantModel);
  //             });
  //           }
  //         }
  //       } else {}
  //       setState(() {
  //         _teNantModels = teNantModels;
  //       });
  //     } catch (e) {}
  //   }

  //   quotxSelectModels = List.generate(teNantModels.length, (_) => []);
  //   red_quotx();
  // }

  // //////////----------------------------------------->(รายละเอียดค่าบริการ)
  // Future<Null> red_quotx() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   for (int index = 0; index < teNantModels.length; index++) {
  //     setState(() {
  //       quotxSelectModels[index].clear();
  //     });
  //     var ciddoc = teNantModels[index].docno == null
  //         ? teNantModels[index].cid == null
  //             ? ''
  //             : '${teNantModels[index].cid}'
  //         : '${teNantModels[index].docno}';
  //     var qutser = teNantModels[index].quantity;

  //     String url =
  //         '${MyConstant().domain}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // //print(result);
  //       if (result != null) {
  //         for (var map in result) {
  //           QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
  //           setState(() {
  //             quotxSelectModels[index].add(quotxSelectModel);
  //           });
  //         }
  //       } else {}
  //     } catch (e) {}
  //   }
  // }

////////--------------------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
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
                                value: (zone_name_Pe_Mon == null)
                                    ? null
                                    : zone_name_Pe_Mon,
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
                                hint: (zone_name_Pe_Mon == null)
                                    ? null
                                    : Text(
                                        '$zone_name_Pe_Mon',
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
                                    zone_name_Pe_Mon = value.toString();
                                    zone_ser_Pe_Mon =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // //print(
                                  //     'Selected Index: $zone_name_Cannotice_Mon  //${zone_ser_Cannotice_Mon}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[0].clear();
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
                              Await_Status_Report3 = 0;
                            });
                            Dia_log();
                            try {
                              read_GC_tenant().then((result) {
                                // //print('red_InvoiceMonFull_bill');
                                // //print('red_InvoiceMonFull_bill');
                                setState(() {
                                  Await_Status_Report3 = 1;
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

                            // read_GC_tenant_Cancel();
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
                        ),
                        onTap:
                            (zone_name_Pe_Mon == null || teNantModels.isEmpty)
                                ? null
                                : () async {
                                    Insert_log.Insert_logs('รายงาน',
                                        'กดดูรายงานรายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน');
                                    Pep_Widget();
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
                                    'กำลังโหลดรายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน...',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (teNantModels.isEmpty || Await_Status_Report3 == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (Mon_Pe_Mon != null &&
                                            YE_Pe_Mon != null &&
                                            zone_name_Pe_Mon != null &&
                                            teNantModels.isEmpty &&
                                            Await_Status_Report3 != null)
                                        ? 'รายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน (ไม่พบข้อมูล ✖️)'
                                        : 'รายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน',
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
                                    'รายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน ✔️',
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
//               ScrollConfiguration(
//                 behavior:
//                     ScrollConfiguration.of(context).copyWith(dragDevices: {
//                   PointerDeviceKind.touch,
//                   PointerDeviceKind.mouse,
//                 }),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Translate.TranslateAndSetText(
//                             'ผู้เช่า :',
//                             ReportScreen_Color.Colors_Text2_,
//                             TextAlign.center,
//                             FontWeight.w500,
//                             Font_.Fonts_T,
//                             Text_Size,
//                             1),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: AppbackgroundColor.Sub_Abg_Colors,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                             // border: Border.all(color: Colors.grey, width: 1),
//                           ),
//                           width: 150,
//                           padding: const EdgeInsets.all(8.0),
//                           child: DropdownButtonFormField2(
//                             value: Status_pe,

//                             alignment: Alignment.center,
//                             focusColor: Colors.white,
//                             autofocus: false,
//                             decoration: InputDecoration(
//                               enabled: true,
//                               hoverColor: Colors.brown,
//                               prefixIconColor: Colors.blue,
//                               fillColor: Colors.white.withOpacity(0.05),
//                               filled: false,
//                               isDense: true,
//                               contentPadding: EdgeInsets.zero,
//                               border: OutlineInputBorder(
//                                 borderSide: const BorderSide(color: Colors.red),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(10),
//                                   topLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   width: 1,
//                                   color: Color.fromARGB(255, 231, 227, 227),
//                                 ),
//                               ),
//                             ),
//                             isExpanded: false,
//                             // hint: StreamBuilder(
//                             //     stream: Stream.periodic(const Duration(seconds: 1)),
//                             //     builder: (context, snapshot) {
//                             //       return Text(
//                             //         Status_pe == null ? 'เลือก' : '$Status_pe',
//                             //         maxLines: 2,
//                             //         textAlign: TextAlign.center,
//                             //         style: const TextStyle(
//                             //           overflow: TextOverflow.ellipsis,
//                             //           fontSize: 14,
//                             //           color: Colors.grey,
//                             //         ),
//                             //       );
//                             //     }),
//                             icon: const Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.black,
//                             ),
//                             style: const TextStyle(
//                               color: Colors.grey,
//                             ),
//                             iconSize: 20,
//                             buttonHeight: 40,
//                             buttonWidth: 250,
//                             // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                             dropdownDecoration: BoxDecoration(
//                               // color: Colors
//                               //     .amber,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.white, width: 1),
//                             ),
//                             items:
//                                 Status.map((item) => DropdownMenuItem<String>(
//                                       value: '${item}',
//                                       child: Translate.TranslateAndSetText(
//                                           '${item}',
//                                           Colors.grey,
//                                           TextAlign.center,
//                                           FontWeight.w500,
//                                           Font_.Fonts_T,
//                                           Text_Size,
//                                           1),
//                                     )).toList(),

//                             onChanged: (value) async {
//                               int selectedIndex =
//                                   Status.indexWhere((item) => item == value);
//                               setState(() {
//                                 Status_pe = Status[selectedIndex]!;
//                                 Status_pe_ser = '${selectedIndex + 1}';
//                               });
//                               // //print(selectedIndex);
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Translate.TranslateAndSetText(
//                             'โซน :',
//                             ReportScreen_Color.Colors_Text2_,
//                             TextAlign.center,
//                             FontWeight.w500,
//                             Font_.Fonts_T,
//                             Text_Size,
//                             1),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: AppbackgroundColor.Sub_Abg_Colors,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                             border: Border.all(color: Colors.grey, width: 1),
//                           ),
//                           width: 300,
//                           // padding: const EdgeInsets.all(8.0),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton2<String>(
//                                 isExpanded: false,
//                                 searchController: Dropdown_Controller_zone[0],
//                                 value: (Value_Chang_Zone_People == null)
//                                     ? null
//                                     : Value_Chang_Zone_People,
//                                 alignment: Alignment.center,
//                                 focusColor: Colors.white,
//                                 searchInnerWidget: Container(
//                                   // width: 200,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: Colors.red[100]!.withOpacity(0.5),
//                                     borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(8),
//                                         topRight: Radius.circular(8),
//                                         bottomLeft: Radius.circular(8),
//                                         bottomRight: Radius.circular(8)),
//                                     border: Border.all(
//                                         color: Colors.grey, width: 1),
//                                   ),
//                                   child: TextFormField(
//                                     expands: true,
//                                     maxLines: null,
//                                     controller: Dropdown_Controller_zone[0],
//                                     decoration: InputDecoration(
//                                       isDense: true,
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 8,
//                                       ),
//                                       hintText: 'Search...',
//                                       // fillColor: Colors.red[300],
//                                       hintStyle: const TextStyle(fontSize: 12),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Color.fromARGB(
//                                               255, 231, 227, 227),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 hint: (Value_Chang_Zone_People == null)
//                                     ? null
//                                     : Text(
//                                         '$Value_Chang_Zone_People',
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                             fontSize: Text_Size,
//                                             color: PeopleChaoScreen_Color
//                                                 .Colors_Text2_,
//                                             fontFamily: Font_.Fonts_T),
//                                       ),
//                                 icon: const Icon(
//                                   Icons.arrow_drop_down,
//                                   color: TextHome_Color.TextHome_Colors,
//                                 ),
//                                 style: TextStyle(
//                                     fontSize: Text_Size,
//                                     color: Colors.grey,
//                                     fontFamily: Font_.Fonts_T),
//                                 iconSize: 20,
//                                 buttonHeight: 35,
//                                 buttonWidth: 250,
//                                 dropdownDecoration: BoxDecoration(
//                                   // color: Colors.red[100]!.withOpacity(0.5),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border:
//                                       Border.all(color: Colors.grey, width: 1),
//                                 ),
//                                 //  BoxDecoration(
//                                 //   borderRadius: BorderRadius.circular(10),
//                                 // ),
//                                 items: zoneModels_report
//                                     .map((item) => DropdownMenuItem<String>(
//                                           value: '${item.zn}',
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 item.zn!,
//                                                 maxLines: 2,
//                                                 style: TextStyle(
//                                                     fontSize: Text_Size,
//                                                     fontFamily: Font_.Fonts_T),
//                                               ),
//                                               Divider(
//                                                 color: Colors.grey[300],
//                                                 height: 4.0,
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                     .toList(),

//                                 // value: selectedValue,

//                                 onChanged: (value) async {
//                                   int selectedIndex = zoneModels_report
//                                       .indexWhere((item) => item.zn == value);

//                                   setState(() {
//                                     Value_Chang_Zone_People = value!;
//                                     Value_Chang_Zone_People_Ser =
//                                         zoneModels_report[selectedIndex].ser!;
//                                   });
//                                   // //print(
//                                   //     'Selected Index: $Value_Chang_Zone_People  //${Value_Chang_Zone_People_Ser}');
//                                 },
//                                 onMenuStateChange: (isOpen) {
//                                   if (!isOpen) {
//                                     Dropdown_Controller_zone[0].clear();
//                                   }
//                                 }),
//                           ),

//                           //  DropdownButtonFormField2(
//                           //   alignment: Alignment.center,
//                           //   focusColor: Colors.white,
//                           //   autofocus: false,
//                           //   decoration: InputDecoration(
//                           //     enabled: true,
//                           //     hoverColor: Colors.brown,
//                           //     prefixIconColor: Colors.blue,
//                           //     fillColor: Colors.white.withOpacity(0.05),
//                           //     filled: false,
//                           //     isDense: true,
//                           //     contentPadding: EdgeInsets.zero,
//                           //     border: OutlineInputBorder(
//                           //       borderSide: const BorderSide(color: Colors.red),
//                           //       borderRadius: BorderRadius.circular(10),
//                           //     ),
//                           //     focusedBorder: const OutlineInputBorder(
//                           //       borderRadius: BorderRadius.only(
//                           //         topRight: Radius.circular(10),
//                           //         topLeft: Radius.circular(10),
//                           //         bottomRight: Radius.circular(10),
//                           //         bottomLeft: Radius.circular(10),
//                           //       ),
//                           //       borderSide: BorderSide(
//                           //         width: 1,
//                           //         color: Color.fromARGB(255, 231, 227, 227),
//                           //       ),
//                           //     ),
//                           //   ),
//                           //   isExpanded: false,
//                           //   value: Value_Chang_Zone_People,
//                           //   icon: const Icon(
//                           //     Icons.arrow_drop_down,
//                           //     color: Colors.black,
//                           //   ),
//                           //   style: const TextStyle(
//                           //     color: Colors.grey,
//                           //   ),
//                           //   iconSize: 20,
//                           //   buttonHeight: 40,
//                           //   buttonWidth: 250,
//                           //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                           //   dropdownDecoration: BoxDecoration(
//                           //     // color: Colors
//                           //     //     .amber,
//                           //     borderRadius: BorderRadius.circular(10),
//                           //     border: Border.all(color: Colors.white, width: 1),
//                           //   ),
//                           //   items: zoneModels_report
//                           //       .map((item) => DropdownMenuItem<String>(
//                           //             value: '${item.zn}',
//                           //             child: Text(
//                           //               '${item.zn}',
//                           //               textAlign: TextAlign.center,
//                           //               style: const TextStyle(
//                           //                 overflow: TextOverflow.ellipsis,
//                           //                 fontSize: 14,
//                           //                 color: Colors.grey,
//                           //               ),
//                           //             ),
//                           //           ))
//                           //       .toList(),

//                           //   onChanged: (value) async {
//                           //     int selectedIndex = zoneModels_report
//                           //         .indexWhere((item) => item.zn == value);

//                           //     setState(() {
//                           //       Value_Chang_Zone_People = value!;
//                           //       Value_Chang_Zone_People_Ser =
//                           //           zoneModels_report[selectedIndex].ser!;
//                           //     });
//                           //     // //print(
//                           //     //     'Selected Index: $Value_Chang_Zone_People  //${Value_Chang_Zone_People_Ser}');
//                           //   },
//                           // ),
//                         ),
//                       ),

//                       //                     int Ser_Cid_ldate = 0;
//                       // List Cid_ldate = [
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Translate.TranslateAndSetText(
//                             'วันที่ใกล้หมดสัญญา :',
//                             ReportScreen_Color.Colors_Text2_,
//                             TextAlign.center,
//                             FontWeight.w500,
//                             Font_.Fonts_T,
//                             Text_Size,
//                             1),
//                       ),
// /////----------------------------->

//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: AppbackgroundColor.Sub_Abg_Colors,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                             // border: Border.all(color: Colors.grey, width: 1),
//                           ),
//                           width: 150,
//                           padding: const EdgeInsets.all(8.0),
//                           child: DropdownButtonFormField2(
//                             value: Cid_ldate[Ser_Cid_ldate].toString(),

//                             alignment: Alignment.center,
//                             focusColor: Colors.white,
//                             autofocus: false,
//                             decoration: InputDecoration(
//                               enabled: true,
//                               hoverColor: Colors.brown,
//                               prefixIconColor: Colors.blue,
//                               fillColor: Colors.white.withOpacity(0.05),
//                               filled: false,
//                               isDense: true,
//                               contentPadding: EdgeInsets.zero,
//                               border: OutlineInputBorder(
//                                 borderSide: const BorderSide(color: Colors.red),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(10),
//                                   topLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   width: 1,
//                                   color: Color.fromARGB(255, 231, 227, 227),
//                                 ),
//                               ),
//                             ),
//                             isExpanded: false,
//                             // hint: StreamBuilder(
//                             //     stream: Stream.periodic(const Duration(seconds: 1)),
//                             //     builder: (context, snapshot) {
//                             //       return Text(
//                             //         Status_pe == null ? 'เลือก' : '$Status_pe',
//                             //         maxLines: 2,
//                             //         textAlign: TextAlign.center,
//                             //         style: const TextStyle(
//                             //           overflow: TextOverflow.ellipsis,
//                             //           fontSize: 14,
//                             //           color: Colors.grey,
//                             //         ),
//                             //       );
//                             //     }),
//                             icon: const Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.black,
//                             ),
//                             style: const TextStyle(
//                               color: Colors.grey,
//                             ),
//                             iconSize: 20,
//                             buttonHeight: 40,
//                             buttonWidth: 250,
//                             // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                             dropdownDecoration: BoxDecoration(
//                               // color: Colors
//                               //     .amber,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.white, width: 1),
//                             ),
//                             items: Cid_ldate.map(
//                                 (item) => DropdownMenuItem<String>(
//                                       value: '${item}',
//                                       child: Text(
//                                         '${item}',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           overflow: TextOverflow.ellipsis,
//                                           fontSize: Text_Size,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     )).toList(),

//                             onChanged: (value) async {
//                               int selectedIndex =
//                                   Cid_ldate.indexWhere((item) => item == value);
//                               setState(() {
//                                 teNantModels.clear();
//                                 // contractPhotoModels.clear();

//                                 Mon_Cid_ldate = null;
//                                 YE_Cid_ldate = null;
//                               });
//                               setState(() {
//                                 Ser_Cid_ldate = selectedIndex;
//                                 YE_Cid_ldate = null;
//                                 Mon_Cid_ldate = null;
//                               });

//                               // //print(Ser_Cid_ldate);
//                             },
//                           ),
//                         ),
//                       ),

//                       if (Ser_Cid_ldate == 1)
//                         Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Translate.TranslateAndSetText(
//                               'เดือน :',
//                               ReportScreen_Color.Colors_Text2_,
//                               TextAlign.center,
//                               FontWeight.w500,
//                               Font_.Fonts_T,
//                               Text_Size,
//                               1),
//                         ),
//                       if (Ser_Cid_ldate == 1)
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               color: AppbackgroundColor.Sub_Abg_Colors,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                               // border: Border.all(color: Colors.grey, width: 1),
//                             ),
//                             width: 120,
//                             padding: const EdgeInsets.all(8.0),
//                             child: DropdownButtonFormField2(
//                               alignment: Alignment.center,
//                               focusColor: Colors.white,
//                               autofocus: false,
//                               decoration: InputDecoration(
//                                 floatingLabelAlignment:
//                                     FloatingLabelAlignment.center,
//                                 enabled: true,
//                                 hoverColor: Colors.brown,
//                                 prefixIconColor: Colors.blue,
//                                 fillColor: Colors.white.withOpacity(0.05),
//                                 filled: false,
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 border: OutlineInputBorder(
//                                   borderSide:
//                                       const BorderSide(color: Colors.red),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 focusedBorder: const OutlineInputBorder(
//                                   borderRadius: BorderRadius.only(
//                                     topRight: Radius.circular(10),
//                                     topLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                   ),
//                                   borderSide: BorderSide(
//                                     width: 1,
//                                     color: Color.fromARGB(255, 231, 227, 227),
//                                   ),
//                                 ),
//                               ),
//                               isExpanded: false,
//                               value: (Mon_Cid_ldate == null)
//                                   ? null
//                                   : Mon_Cid_ldate,

//                               icon: const Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.black,
//                               ),
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                               iconSize: 20,
//                               buttonHeight: 40,
//                               buttonWidth: 200,
//                               // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                               dropdownDecoration: BoxDecoration(
//                                 // color: Colors
//                                 //     .amber,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border:
//                                     Border.all(color: Colors.white, width: 1),
//                               ),
//                               items: [
//                                 for (int item = 1; item < 13; item++)
//                                   DropdownMenuItem<String>(
//                                     value: '${item}',
//                                     child: Text(
//                                       '${monthsInThai[item - 1]}',
//                                       // '${item}',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         overflow: TextOverflow.ellipsis,
//                                         fontSize: Text_Size,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   )
//                               ],

//                               onChanged: (value) async {
//                                 Mon_Cid_ldate = value.toString();
//                               },
//                             ),
//                           ),
//                         ),
//                       if (Ser_Cid_ldate == 1)
//                         Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Translate.TranslateAndSetText(
//                               'ปี :',
//                               ReportScreen_Color.Colors_Text2_,
//                               TextAlign.center,
//                               FontWeight.w500,
//                               Font_.Fonts_T,
//                               Text_Size,
//                               1),
//                         ),
//                       if (Ser_Cid_ldate == 1)
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               color: AppbackgroundColor.Sub_Abg_Colors,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                               // border: Border.all(color: Colors.grey, width: 1),
//                             ),
//                             width: 120,
//                             padding: const EdgeInsets.all(8.0),
//                             child: DropdownButtonFormField2(
//                               alignment: Alignment.center,
//                               focusColor: Colors.white,
//                               autofocus: false,
//                               decoration: InputDecoration(
//                                 floatingLabelAlignment:
//                                     FloatingLabelAlignment.center,
//                                 enabled: true,
//                                 hoverColor: Colors.brown,
//                                 prefixIconColor: Colors.blue,
//                                 fillColor: Colors.white.withOpacity(0.05),
//                                 filled: false,
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 border: OutlineInputBorder(
//                                   borderSide:
//                                       const BorderSide(color: Colors.red),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 focusedBorder: const OutlineInputBorder(
//                                   borderRadius: BorderRadius.only(
//                                     topRight: Radius.circular(10),
//                                     topLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                   ),
//                                   borderSide: BorderSide(
//                                     width: 1,
//                                     color: Color.fromARGB(255, 231, 227, 227),
//                                   ),
//                                 ),
//                               ),
//                               isExpanded: false,
//                               value:
//                                   (YE_Cid_ldate == null) ? null : YE_Cid_ldate,

//                               icon: const Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.black,
//                               ),
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                               iconSize: 20,
//                               buttonHeight: 40,
//                               buttonWidth: 200,
//                               // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                               dropdownDecoration: BoxDecoration(
//                                 // color: Colors
//                                 //     .amber,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border:
//                                     Border.all(color: Colors.white, width: 1),
//                               ),
//                               items: [
//                                 DropdownMenuItem<String>(
//                                   value: '${int.parse('${YE_Th[0]}') + 1}',
//                                   child: Text(
//                                     '${int.parse('${YE_Th[0]}') + 1}',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       overflow: TextOverflow.ellipsis,
//                                       fontSize: Text_Size,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                                 for (int index = 0;
//                                     index < YE_Th.length;
//                                     index++)
//                                   DropdownMenuItem<String>(
//                                     value: '${YE_Th[index]}',
//                                     child: Text(
//                                       '${YE_Th[index]}',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         overflow: TextOverflow.ellipsis,
//                                         fontSize: Text_Size,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ),
//                                 // YE_Th.map((item) => DropdownMenuItem<String>(
//                                 //                               value: '${item}',
//                                 //                               child: Text(
//                                 //                                 '${item}',
//                                 //                                 // '${int.parse(item) + 543}',
//                                 //                                 textAlign: TextAlign.center,
//                                 //                                 style: const TextStyle(
//                                 //                                   overflow: TextOverflow.ellipsis,
//                                 //                                   fontSize: 14,
//                                 //                                   color: Colors.grey,
//                                 //                                 ),
//                                 //                               ),
//                                 //                             )).toList(),
//                               ],

//                               onChanged: (value) async {
//                                 YE_Cid_ldate = value.toString();
//                               },
//                             ),
//                           ),
//                         ),

//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: InkWell(
//                           onTap: () async {
//                             Dia_log();
//                             if (Ser_Cid_ldate == 0) {
//                               if (Status_pe != null &&
//                                   Value_Chang_Zone_People != null) {
//                                 setState(() {
//                                   Await_Status_Report2 = 0;
//                                 });
//                               }
//                             } else {
//                               if (Status_pe != null &&
//                                   Value_Chang_Zone_People != null &&
//                                   Mon_Cid_ldate != null &&
//                                   YE_Cid_ldate != null) {
//                                 setState(() {
//                                   Await_Status_Report2 = 0;
//                                 });
//                               }
//                             }

//                             if (Ser_Cid_ldate == 0) {
//                               try {
//                                 read_GC_tenantSelect().then((result) {
//                                   // //print('red_InvoiceMonFull_bill');
//                                   // //print('red_InvoiceMonFull_bill');
//                                   setState(() {
//                                     Await_Status_Report2 = 1;
//                                   });
//                                   Timer(const Duration(seconds: 1), () {
//                                     Navigator.of(context).pop();
//                                   });
//                                 });
//                               } catch (e) {
//                                 Timer(const Duration(seconds: 1), () {
//                                   Navigator.of(context).pop();
//                                 });
//                               }
//                             } else {
//                               try {
//                                 read_GC_tenantSelect().then((result) {
//                                   // //print('red_InvoiceMonFull_bill');
//                                   // //print('red_InvoiceMonFull_bill');
//                                   setState(() {
//                                     Await_Status_Report2 = 1;
//                                   });
//                                   Timer(const Duration(seconds: 1), () {
//                                     Navigator.of(context).pop();
//                                   });
//                                 });
//                               } catch (e) {
//                                 Timer(const Duration(seconds: 1), () {
//                                   Navigator.of(context).pop();
//                                 });
//                               }
//                             }
//                           },
//                           child: Container(
//                               width: 100,
//                               padding: const EdgeInsets.all(6.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.green[700],
//                                 borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10)),
//                               ),
//                               child: Center(
//                                 child: Translate.TranslateAndSetText(
//                                     'ค้นหา',
//                                     Colors.white,
//                                     TextAlign.center,
//                                     FontWeight.w500,
//                                     Font_.Fonts_T,
//                                     Text_Size,
//                                     1),
//                               )),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     InkWell(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.yellow[600],
//                             borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                             border: Border.all(color: Colors.grey, width: 1),
//                           ),
//                           padding: const EdgeInsets.all(4.0),
//                           child: Center(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Translate.TranslateAndSetText(
//                                     'เรียกดู',
//                                     ReportScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.w500,
//                                     Font_.Fonts_T,
//                                     Text_Size,
//                                     1),
//                                 Icon(
//                                   Icons.navigate_next,
//                                   color: Colors.grey,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         onTap: (Ser_Cid_ldate == 0)
//                             ? (Status_pe == null ||
//                                     Value_Chang_Zone_People == null ||
//                                     teNantModels.isEmpty)
//                                 ? null
//                                 : () async {
//                                     Insert_log.Insert_logs(
//                                         'รายงาน', 'กดดูรายงานข้อมูลผู้เช่า');
//                                     RE_People_Widget();
//                                   }
//                             : (Status_pe == null ||
//                                     Value_Chang_Zone_People == null ||
//                                     teNantModels.isEmpty ||
//                                     Mon_Cid_ldate == null ||
//                                     YE_Cid_ldate == null)
//                                 ? null
//                                 : () async {
//                                     Insert_log.Insert_logs(
//                                         'รายงาน', 'กดดูรายงานข้อมูลผู้เช่า');
//                                     RE_People_Widget();
//                                   }),
//                     (teNantModels.isEmpty || Await_Status_Report2 == null)
//                         ? Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: (Ser_Cid_ldate == 0)
//                                 ? Translate.TranslateAndSetText(
//                                     (Status_pe !=
//                                                 null &&
//                                             teNantModels.isEmpty &&
//                                             Value_Chang_Zone_People != null &&
//                                             Await_Status_Report2 != null)
//                                         ? 'รายงานข้อมูลผู้เช่า (ไม่พบข้อมูล ✖️)'
//                                         : 'รายงานข้อมูลผู้เช่า',
//                                     ReportScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.w500,
//                                     Font_.Fonts_T,
//                                     Text_Size,
//                                     1)
//                                 : Translate.TranslateAndSetText(
//                                     (Status_pe != null &&
//                                             teNantModels.isEmpty &&
//                                             Value_Chang_Zone_People != null &&
//                                             Await_Status_Report2 != null &&
//                                             Mon_Cid_ldate != null &&
//                                             YE_Cid_ldate != null)
//                                         ? 'รายงานข้อมูลผู้เช่า (ไม่พบข้อมูล ✖️)'
//                                         : 'รายงานข้อมูลผู้เช่า',
//                                     ReportScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.w500,
//                                     Font_.Fonts_T,
//                                     Text_Size,
//                                     1),
//                           )
//                         : (Await_Status_Report2 == 0)
//                             ? SizedBox(
//                                 // height: 20,
//                                 child: Row(
//                                 children: [
//                                   Container(
//                                       padding: const EdgeInsets.all(4.0),
//                                       child: const CircularProgressIndicator()),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Translate.TranslateAndSetText(
//                                         'กำลังโหลดรายงานข้อมูลผู้เช่า...',
//                                         ReportScreen_Color.Colors_Text1_,
//                                         TextAlign.center,
//                                         FontWeight.w500,
//                                         Font_.Fonts_T,
//                                         Text_Size,
//                                         1),
//                                   ),
//                                 ],
//                               ))
//                             : Padding(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: Translate.TranslateAndSetText(
//                                     'รายงานข้อมูลผู้เช่า ✔️',
//                                     ReportScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.w500,
//                                     Font_.Fonts_T,
//                                     Text_Size,
//                                     1),
//                               )
//                   ],
//                 ),
//               ),
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
                                value: (zone_name_Area == null)
                                    ? null
                                    : zone_name_Area,
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
                                hint: (zone_name_Area == null)
                                    ? null
                                    : Text(
                                        '$zone_name_Area',
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
                                    zone_name_Area = value.toString();
                                    zone_ser_Area =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // //print(
                                  //     'Selected Index: $zone_name_Cannotice_Mon  //${zone_ser_Cannotice_Mon}');
                                },
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    Dropdown_Controller_zone[0].clear();
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
                              Await_Status_Report4 = 0;
                            });
                            Dia_log();
                            try {
                              read_GC_AreaAll().then((result) {
                                // //print('red_InvoiceMonFull_bill');
                                // //print('red_InvoiceMonFull_bill');
                                setState(() {
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

                            // read_GC_tenant_Cancel();
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
                        ),
                        onTap: (zone_name_Area == null || teNantModels.isEmpty)
                            ? null
                            : () async {
                                Insert_log.Insert_logs('รายงาน',
                                    'กดดูรายงานรายงานพื้นที่เช่า_ผู้เช่า');
                                RE_People_Widget();
                                // RE_ChoArea_Widget();
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
                                    'กำลังโหลดรายงานพื้นที่เช่า_ผู้เช่า...',
                                    ReportScreen_Color.Colors_Text2_,
                                    TextAlign.center,
                                    FontWeight.w500,
                                    Font_.Fonts_T,
                                    Text_Size,
                                    1),
                              ),
                            ],
                          ))
                        : (teNantModels.isEmpty || Await_Status_Report4 == null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSetText(
                                    (zone_name_Area != null &&
                                            teNantModels.isEmpty &&
                                            Await_Status_Report4 != null)
                                        ? 'รายงานพื้นที่เช่า_ผู้เช่า(ไม่พบข้อมูล ✖️)'
                                        : 'รายงานพื้นที่เช่า_ผู้เช่า',
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
                                    'รายงานพื้นที่เช่า_ผู้เช่า ✔️',
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
            ])));
  }

///////////////////////////----------------------------------------------->(รายงานข้อมูลผู้เช่า)
  Pep_Widget() {
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
                      // 'รายงานข้อมูลผู้เช่าเริ่มสัญญา (โซน : ทั้งหมด)',
                      (zone_name_Pe_Mon == null)
                          ? 'รายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน (กรุณาเลือกโซน)'
                          : 'รายงานพื้นที่เช่า ที่มีสัญญาทับซ้อน (โซน : $zone_name_Pe_Mon)',
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
                              '',
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
                    // Container(
                    //   width: MediaQuery.of(context).size.width,
                    //   // padding: EdgeInsets.all(10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       Expanded(
                    //         child: _searchBar_tenantSelect(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
                              ? MediaQuery.of(context).size.width * 0.93
                              : (teNantModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,teNantModels
                          child: (teNantModels.length == 0)
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
                                              'จำนวนสัญญา',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รหัสโซน',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'โซนหลัก',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'โซนรอง',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ล็อก',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'สัญญาทั้งหมด',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                      itemBuilder:
                                          (BuildContext context, int index) {
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
                                            child: Row(children: [
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${teNantModels[index].qty}',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      '${teNantModels[index].qty}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  (teNantModels[index]
                                                              .znn!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels[index].znn!.split('_')[0]}'
                                                      : 'CMN${teNantModels[index].znn!.split('_')[0]}',
                                                  // (teNantModels_New[index].zser !=
                                                  //         null)
                                                  //     ? '${teNantModels_New[index].zser}'
                                                  //     : '${teNantModels_New[index].zser1}',
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${teNantModels[index].zn}',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      '${teNantModels[index].zn}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${teNantModels[index].znn}',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      '${teNantModels[index].znn}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${teNantModels[index].ln}',
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels[index].cid}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                            ]),
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
                              Value_Report =
                                  'รายงานพื้นที่เช่าที่มีสัญญาทับซ้อน';
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
                            // formKey.currentState?.reset();
                            zone_ser_Pe_Mon = null;

                            zone_name_Pe_Mon = null;

                            Await_Status_Report3 = null;
                            teNantModels.clear();
                            Mon_Pe_Mon = null;
                            YE_Pe_Mon = null;

                            // contractPhotoModels.clear();
                            // Ser_Cid_ldate = 0;
                            // Mon_Cid_ldate = null;
                            // YE_Cid_ldate = null;
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

///////////////////////////----------------------------------------------->(รายงานผู้เช่า)
  RE_People_Widget() {
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
                      (Value_Chang_Zone_People == null)
                          ? 'รายงานข้อมูลพื้นที่เช่า/ผู้เช่า (กรุณาเลือกโซน)'
                          : 'รายงานข้อมูลพื้นที่เช่า/ผู้เช่า (โซน : $Value_Chang_Zone_People)',
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
                              '',
                              // 'ผู้เช่า: ${Status_pe}',
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                          child: Container(
                            height: 30,
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
                                            int selectedIndex =
                                                expModels.indexWhere((items) =>
                                                    items.ser == item.ser);
                                            //print(expModels[selectedIndex]
                                            //  .expname);
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
                    const SizedBox(height: 1),
                    // Container(
                    //   width: MediaQuery.of(context).size.width,
                    //   // padding: EdgeInsets.all(10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       Expanded(
                    //         child: _searchBar_tenantSelect(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
                              ? MediaQuery.of(context).size.width * 0.98
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
                                              'โซนพื้นที่',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'รหัสพื้นที่',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ขนาดพื้นที่(ต.ร.ม.)',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'เลขที่สัญญา',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'เลขที่สัญญา(เดิม)',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ชื่อผู้ติดต่อ',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'TAX/ID',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ที่อยู่',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ประเภท',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'เบอร์ติดต่อ',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ระยะเวลาการเช่า',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'วันเริ่มสัญญา',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'วันสิ้นสุดสัญญา',
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 14.0
                                                  //fontSize: 10.0
                                                  //fontSize: 10.0
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ประเภทสัญญา',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                      itemBuilder:
                                          (BuildContext context, int index) {
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
                                            child: Row(children: [
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].zn == null
                                                      ? ''
                                                      : '${teNantModels[index].zn}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: teNantModels[index]
                                                                .ln ==
                                                            null
                                                        ? ''
                                                        : '${teNantModels[index].ln}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    teNantModels[index].ln ==
                                                            null
                                                        ? ''
                                                        : '${teNantModels[index].ln}',
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].area ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].area}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text: teNantModels[index]
                                                                  .cid ==
                                                              null
                                                          ? ''
                                                          : '${teNantModels[index].cid}',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      teNantModels[index].cid ==
                                                              null
                                                          ? ''
                                                          : '${teNantModels[index].cid}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text: teNantModels[index]
                                                                  .renew_cid ==
                                                              null
                                                          ? ''
                                                          : '${teNantModels[index].renew_cid}',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      teNantModels[index]
                                                                  .renew_cid ==
                                                              null
                                                          ? ''
                                                          : '${teNantModels[index].renew_cid}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    teNantModels[index].cname ==
                                                            null
                                                        ? ''
                                                        : '${teNantModels[index].cname}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].tax ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].tax}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].addr ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].addr}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].stype ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].stype}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].tel ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].tel}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].period ==
                                                          null
                                                      ? ''
                                                      : '${teNantModels[index].period}  ${teNantModels[index].rtname!.substring(3)}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      //fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    teNantModels[index].sdate ==
                                                            null
                                                        ? ''
                                                        : DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                '${teNantModels[index].sdate} 00:00:00'))
                                                            .toString(),
                                                    textAlign: TextAlign.end,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    teNantModels[index].ldate ==
                                                            null
                                                        ? ''
                                                        : DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                '${teNantModels[index].ldate} 00:00:00'))
                                                            .toString(),
                                                    textAlign: TextAlign.end,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  (teNantModels[index]
                                                                  .type_cid ==
                                                              null ||
                                                          teNantModels[index]
                                                                  .type_cid ==
                                                              '')
                                                      ? '-'
                                                      : '${teNantModels[index].type_cid}',
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  teNantModels[index].sdate ==
                                                          null
                                                      ? 'ว่าง'
                                                      : (datex.isAfter(DateTime
                                                                      .parse(
                                                                          '${teNantModels[index].ldate} 00:00:00.000')
                                                                  .subtract(
                                                                      const Duration(
                                                                          days:
                                                                              0))) ==
                                                              true)
                                                          ? 'หมดสัญญา'
                                                          : datex.isAfter(DateTime
                                                                          .parse(
                                                                              '${teNantModels[index].ldate} 00:00:00.000')
                                                                      .subtract(
                                                                          Duration(
                                                                              days: open_set_date))) ==
                                                                  true
                                                              ? 'ใกล้หมดสัญญา'
                                                              : '${teNantModels[index].st}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ]),
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
                              Value_Report = 'รายงานข้อมูลผู้เช่า';
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
                            // formKey.currentState?.reset();
                            Value_Chang_Zone_People_Ser = null;

                            Value_Chang_Zone_People = null;
                            Status_pe = null;
                            Await_Status_Report1 = null;
                            teNantModels.clear();
                            // contractPhotoModels.clear();
                            Ser_Cid_ldate = 0;
                            Mon_Cid_ldate = null;
                            YE_Cid_ldate = null;
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

  ///////////////////////////----------------------------------------------->(รายงานข้อมูลพื้นที่เช่า)
  RE_ChoArea_Widget() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Column(
            children: [
              Center(
                  child: Text(
                (zone_name_Area == null)
                    ? 'รายงานข้อมูลพื้นที่เช่า (กรุณาเลือกโซน)'
                    : 'รายงานข้อมูลพื้นที่เช่า (โซน : $zone_name_Area) ',
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
                        'ทั้งหมด: ${areaModels.length}',
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
                              ? MediaQuery.of(context).size.width
                              : (areaModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (areaModels.length == 0)
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
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'รหัสโซน',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'โซนพื้นที่',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ชื้อพื้นที่',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ขนาดพื้นที่(ต.ร.ม.)',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ค่าเช่าต่องวด',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่สัญญา',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ประเภทสัญญา',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'วันที่เริ่มสัญญา',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'วันที่สิ้นสุดเริ่มสัญญา',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'สถานะ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T
                                                    //fontSize: 10.0
                                                    ),
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
                                      itemCount: areaModels.length,
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
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (areaModels[index]
                                                                      .zn ==
                                                                  null ||
                                                              areaModels[index]
                                                                      .zn ==
                                                                  '' ||
                                                              areaModels[index]
                                                                      .zn ==
                                                                  'null')
                                                          ? ''
                                                          : (areaModels[index]
                                                                      .zn!
                                                                      .split(
                                                                          '_')[0]
                                                                      .length <=
                                                                  4)
                                                              ? 'CMN0${areaModels[index].zn!.split('_')[0]}'
                                                              : 'CMN${areaModels[index].zn!.split('_')[0]}',
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (areaModels[index].zn ==
                                                              null)
                                                          ? ''
                                                          : '${areaModels[index].zn}',
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      (areaModels[index].ln ==
                                                              null)
                                                          ? ''
                                                          : '${areaModels[index].ln}',
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (areaModels[index]
                                                                    .area ==
                                                                null ||
                                                            areaModels[index]
                                                                    .area ==
                                                                '' ||
                                                            areaModels[index]
                                                                    .area ==
                                                                'null')
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(areaModels[index].area!))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (areaModels[index]
                                                                    .rent ==
                                                                null ||
                                                            areaModels[index]
                                                                    .rent ==
                                                                '' ||
                                                            areaModels[index]
                                                                    .rent ==
                                                                'null')
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(areaModels[index].rent!))}',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (areaModels[index]
                                                                        .cid ==
                                                                    null ||
                                                                areaModels[index]
                                                                        .cid
                                                                        .toString() ==
                                                                    'null')
                                                            ? ''
                                                            : '${areaModels[index].cid}',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (areaModels[index]
                                                                        .cid ==
                                                                    null ||
                                                                areaModels[index]
                                                                        .type
                                                                        .toString() ==
                                                                    'null')
                                                            ? ''
                                                            : '${areaModels[index].type}',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        areaModels[index]
                                                                    .sdate ==
                                                                null
                                                            ? ''
                                                            : DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(DateTime
                                                                    .parse(
                                                                        '${areaModels[index].sdate} 00:00:00'))
                                                                .toString(),
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        areaModels[index]
                                                                    .ldate ==
                                                                null
                                                            ? ''
                                                            : DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(DateTime
                                                                    .parse(
                                                                        '${areaModels[index].ldate} 00:00:00'))
                                                                .toString(),
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (areaModels[index]
                                                                        .cid ==
                                                                    null ||
                                                                areaModels[index]
                                                                        .cid
                                                                        .toString() ==
                                                                    'null')
                                                            ? 'ว่าง'
                                                            : 'เช่าอยู่',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      )),
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
                              Value_Report = 'รายงานข้อมูลพื้นที่เช่า';
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
                            areaModels.clear();
                            zone_ser_Area = null;

                            zone_name_Area = null;

                            Await_Status_Report4 = null;
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

  ///////////////-------------------------------->
  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          // Timer(Duration(milliseconds: 6600), () {
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

///////////////-------------------------------->
  Dia_log_lod() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(milliseconds: 6600), () {
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

  ////////////------------------------------------------>
  void InkWell_onTap(context) async {
    // await red_Trans_selectIncomeAll();
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
        if (Value_Report == 'รายงานพื้นที่เช่าที่มีสัญญาทับซ้อน') {
          if (_ReportValue_type == 'ปกติ') {
            Excgen_AreaServiceFeeShortReport_Choice
                .exportExcel_AreaServiceFeeShortReport_Choice(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              Value_Report,
              teNantModels,
              renTal_name,
              zone_name_Pe_Mon,
              YE_Pe_Mon,
              Mon_Pe_Mon,
            );
          }
          Navigator.of(context).pop();
        } else if (Value_Report == 'รายงานข้อมูลผู้เช่า') {
          Excgen_PeopleChoChoiceReportNew.exportExcel_PeopleChoChoiceReportNew(
              expModels.where((element) => element.st! == '1').toList(),
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              zone_name_Area,
              (Status_pe == null) ? 'ปัจจุบัน' : Status_pe,
              teNantModels,
              open_set_date
              // expModels.where((element) => element.st! == '1').toList(),
              // context,
              // NameFile_,
              // _verticalGroupValue_NameFile,
              // renTal_name,
              // teNantModels,
              // // areaModels,
              // zone_name_Area,
              );
          // Excgen_PeopleChoChoiceReport.exportExcel_PeopleChoChoiceReport(
          //     expModels.where((element) => element.st! == '1').toList(),
          //     context,
          //     NameFile_,
          //     _verticalGroupValue_NameFile,
          //     Value_Chang_Zone_People,
          //     (Status_pe == null) ? 'ปัจจุบัน' : Status_pe,
          //     teNantModels,
          //     open_set_date);
        } else if (Value_Report == 'รายงานข้อมูลพื้นที่เช่า') {
          Excgen_PeopleChoChoiceReportNew.exportExcel_PeopleChoChoiceReportNew(
              expModels.where((element) => element.st! == '1').toList(),
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              zone_name_Area,
              (Status_pe == null) ? 'ปัจจุบัน' : Status_pe,
              teNantModels,
              open_set_date
              // expModels.where((element) => element.st! == '1').toList(),
              // context,
              // NameFile_,
              // _verticalGroupValue_NameFile,
              // renTal_name,
              // teNantModels,
              // // areaModels,
              // zone_name_Area,
              );
        }
      }
    }
  }
}
