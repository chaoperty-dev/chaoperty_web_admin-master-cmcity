import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
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
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetC_Syslog.dart';
import '../Model/GetContract_Photo_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Excel_BeforInvoice_Report.dart';
import 'Excel_ChaoArea_Report.dart';
import 'Excel_HistorybillsCancel_Report.dart';
import 'Excel_Historybills_Report.dart';
import 'Excel_PeopleCho_Cancel_Report.dart';
import 'Excel_PeopleCho_Report.dart';
import 'Excel_SystemLog_Report.dart';

class ReportScreen5 extends StatefulWidget {
  const ReportScreen5({super.key});

  @override
  State<ReportScreen5> createState() => _ReportScreen5State();
}

class _ReportScreen5State extends State<ReportScreen5> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  int? Await_Status_Report1,
      Await_Status_Report2,
      Await_Status_Report3,
      Await_Status_Report4;
  int open_set_date = 30;
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

  ///------------------------>
  String? renTal_user,
      renTal_name,
      Status_pe,
      Status_pe_ser,

      // Value_Chang_Mon_People,
      // Value_Chang_YE_People,
      Value_Chang_Zone_People,
      Value_Chang_Zone_People_Ser,
      Value_Chang_Zone_People_Cancel,
      Value_Chang_Zone_People_Ser_Cancel;
  String? YE_historybill;
  String? Mon_historybill;
  String? Value_Chang_Zone_historybill_Mon,
      Value_Chang_Zone_historybill_Ser_Mon;
  String? Value_Chang_Zone_historybill, Value_Chang_Zone_historybill_Ser;

  ///------>
  String? zone_ser_Invoice_Befor, zone_name_Invoice_Befor;
  String? Befor_YE_Invoice, Befor_Mon_Invoice;

  ///------>
  List<String> YE_Th = [];
  List<String> Mont_Th = [];
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<ExpModel> expModels = [];

  List<TeNantModel> teNantModels_Cancel = [];
  List<TeNantModel> _teNantModels_Cancel = <TeNantModel>[];

  List<ContractPhotoModel> contractPhotoModels = [];
  List<TransReBillModel> _TransReBillModels = [];
  List<TransReBillModel> TransReBillModels_ = <TransReBillModel>[];

  List<TransReBillModel> _TransReBillModels_Mon = [];
  List<TransReBillModel> _TransReBillModels_cancel = [];
  List<TransReBillModel> TransReBillModels_cancel_ = [];

  late List<List<QuotxSelectModel>> quotxSelectModels;

  List<QuotxSelectModel> quotxSelectModels_Select = [];
  List<TransModel> _TransModels = [];
  // List<QuotxSelectModel> quotxSelectModels = [];
  var Value_selectDate_Historybills;

  List Status = [
    'ปัจจุบัน',
    'หมดสัญญา',
    'ใกล้หมดสัญญา',
    // 'ผู้สนใจ',
  ];
  int Ser_Cid_ldate = 0;
  List Cid_ldate = [
    'ทั้งหมด',
    // 'ระบุ (ด/ป)',
  ];
  ///////////--------------------------------------------->
  String? YE_People_Cancel, Mon_People_Cancel;
  String? YE_Cid_ldate, Mon_Cid_ldate;
  // var Value_People_Cancel;
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
  List<TextEditingController> Dropdown_Controller_zone = [];
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    super.initState();
    checkPreferance();
    read_GC_zone();
    red_Exp();
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

  // System_New_Update() async {
  //   // String accept_ = showst_update_!;
  //   showDialog<String>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) => AlertDialog(
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //       title: Text(
  //         '📢ขออภัย !!!!!',
  //         textAlign: TextAlign.end,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.red,
  //           fontFamily: Font_.Fonts_T,
  //         ),
  //       ),
  //       content: Container(
  //         decoration: BoxDecoration(
  //           image: const DecorationImage(
  //             image: AssetImage("images/pngegg.png"),
  //             // fit: BoxFit.cover,
  //           ),
  //         ),
  //         child: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Text(
  //                   'ขออภัย ขณะนี้ฟังก์ชั่นก์ รายงานหน้า2  อยู่ในช่วงทดสอบ ..!!!!',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: Colors.red,
  //                     fontWeight: FontWeight.bold,
  //                     fontFamily: FontWeight_.Fonts_T,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       actions: <Widget>[
  //         StreamBuilder(
  //             stream: Stream.periodic(const Duration(seconds: 1)),
  //             builder: (context, snapshot) {
  //               return Column(
  //                 children: [
  //                   const SizedBox(
  //                     height: 5.0,
  //                   ),
  //                   const Divider(
  //                     color: Colors.grey,
  //                     height: 4.0,
  //                   ),
  //                   const SizedBox(
  //                     height: 5.0,
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.red,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: TextButton(
  //                             onPressed: () async {
  //                               Navigator.pop(context, 'OK');
  //                             },
  //                             child: const Text(
  //                               'รับทราบ',
  //                               style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: FontWeight_.Fonts_T),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             })
  //       ],
  //     ),
  //   );
  // }

/////////////////----------------------------------------->(
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

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า)

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

    // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $Status_pe_ser');
    String url = zone == null
        ? '${MyConstant().domain}/GC_tenantAll_Report.php?isAdd=true&ren=$ren&zone=0'
        : zone == '0'
            ? '${MyConstant().domain}/GC_tenantAll_Report.php?isAdd=true&ren=$ren&zone=0'
            : '${MyConstant().domain}/GC_tenantAll_Report.php?isAdd=true&ren=$ren&zone=$zone';
    // print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (Status_pe_ser.toString() == '1') {
            setState(() {
              teNantModels.add(teNantModel);
            });
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

// Future<Null> read_GC_tenantSelect() async {
//     if (teNantModels.isNotEmpty) {
//       setState(() {
//         teNantModels.clear();
//         _teNantModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     var zone = Value_Chang_Zone_People_Ser;

//     // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $Status_pe_ser');

//     if (Status_pe_ser == '1') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//               : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '1') {
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

//                 // print('difference == $difference');

//                 var daterx_now = DateTime.now();

//                 var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//                 final now = DateTime.now();
//                 final earlier = daterx_ldate.subtract(const Duration(days: 0));
//                 var daterx_A = now.isAfter(earlier);
//                 // print(now.isAfter(earlier)); // true
//                 // print(now.isBefore(earlier)); // true

//                 if (daterx_A != true) {
//                   setState(() {
//                     teNantModels.add(teNantModel);
//                   });
//                   read_GC_photo(
//                       teNantModel.docno == null
//                           ? teNantModel.cid == null
//                               ? ''
//                               : '${teNantModel.cid}'
//                           : '${teNantModel.docno}',
//                       teNantModel.quantity);
//                 }
//               }
//             }
//           }
//         } else {}

//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '2') {
//       String url = (zone == '0')
//           ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//           : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
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

//               // print('difference == $difference');

//               var daterx_now = DateTime.now();

//               var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//               final now = DateTime.now();
//               final earlier = daterx_ldate.subtract(const Duration(days: 0));
//               var daterx_A = now.isAfter(earlier);
//               // print(now.isAfter(earlier)); // true
//               // print(now.isBefore(earlier)); // true

//               if (daterx_A == true) {
//                 setState(() {
//                   if (teNantModel.quantity == '1') {
//                     teNantModels.add(teNantModel);
//                   }
//                 });
//                 read_GC_photo(
//                     teNantModel.docno == null
//                         ? teNantModel.cid == null
//                             ? ''
//                             : '${teNantModel.cid}'
//                         : '${teNantModel.docno}',
//                     teNantModel.quantity);
//               }
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '3') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//               : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '1') {
//               if (datex.isAfter(
//                       DateTime.parse('${teNantModel.ldate} 00:00:00.000')
//                           .subtract(Duration(days: open_set_date))) ==
//                   true) {
//                 var daterx = teNantModel.ldate == null
//                     ? teNantModel.ldate_q
//                     : teNantModel.ldate;

//                 if (daterx != null) {
//                   int daysBetween(DateTime from, DateTime to) {
//                     from = DateTime(from.year, from.month, from.day);
//                     to = DateTime(to.year, to.month, to.day);
//                     return (to.difference(from).inHours / 24).round();
//                   }

//                   var birthday = DateTime.parse('$daterx 00:00:00.000')
//                       .add(const Duration(days: -30));
//                   var date2 = DateTime.now();
//                   var difference = daysBetween(birthday, date2);

//                   // print('difference == $difference');

//                   var daterx_now = DateTime.now();

//                   var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//                   final now = DateTime.now();
//                   final earlier =
//                       daterx_ldate.subtract(const Duration(days: 0));
//                   var daterx_A = now.isAfter(earlier);
//                   // print(now.isAfter(earlier)); // true
//                   // print(now.isBefore(earlier)); // true

//                   if (daterx_A != true) {
//                     setState(() {
//                       teNantModels.add(teNantModel);
//                     });
//                     read_GC_photo(
//                         teNantModel.docno == null
//                             ? teNantModel.cid == null
//                                 ? ''
//                                 : '${teNantModel.cid}'
//                             : '${teNantModel.docno}',
//                         teNantModel.quantity);
//                   }
//                 }
//               }
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '4') {
//       String url = (zone == '0')
//           ? '${MyConstant().domain}/GC_tenantAll.php?isAdd=true&ren=$ren&zone=$zone'
//           : '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&zone=$zone';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '2' || teNantModel.quantity == '3') {
//               setState(() {
//                 teNantModels.add(teNantModel);
//               });
//               read_GC_photo(
//                   teNantModel.docno == null
//                       ? teNantModel.cid == null
//                           ? ''
//                           : '${teNantModel.cid}'
//                       : '${teNantModel.docno}',
//                   teNantModel.quantity);
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     }

//     quotxSelectModels = List.generate(teNantModels.length, (_) => []);
//     red_report();
//   }

// ////////------------------------------------->
//   ///  String? YE_Cid_ldate, Mon_Cid_ldate;
//   Future<Null> read_GC_tenantSelect2_ldate() async {
//     if (teNantModels.isNotEmpty) {
//       setState(() {
//         teNantModels.clear();
//         _teNantModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     var zone = Value_Chang_Zone_People_Ser;

//     // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $Status_pe_ser');

//     if (Status_pe_ser == '1') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//               : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '1') {
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

//                 // print('difference == $difference');

//                 var daterx_now = DateTime.now();

//                 var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//                 final now = DateTime.now();
//                 final earlier = daterx_ldate.subtract(const Duration(days: 0));
//                 var daterx_A = now.isAfter(earlier);
//                 // print(now.isAfter(earlier)); // true
//                 // print(now.isBefore(earlier)); // true

//                 if (daterx_A != true) {
//                   setState(() {
//                     teNantModels.add(teNantModel);
//                   });
//                   read_GC_photo(
//                       teNantModel.docno == null
//                           ? teNantModel.cid == null
//                               ? ''
//                               : '${teNantModel.cid}'
//                           : '${teNantModel.docno}',
//                       teNantModel.quantity);
//                 }
//               }
//             }
//           }
//         } else {}

//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '2') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//               : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
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

//               // print('difference == $difference');

//               var daterx_now = DateTime.now();

//               var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//               final now = DateTime.now();
//               final earlier = daterx_ldate.subtract(const Duration(days: 0));
//               var daterx_A = now.isAfter(earlier);
//               // print(now.isAfter(earlier)); // true
//               // print(now.isBefore(earlier)); // true

//               if (daterx_A == true) {
//                 setState(() {
//                   if (teNantModel.quantity == '1') {
//                     teNantModels.add(teNantModel);
//                   }
//                 });
//                 read_GC_photo(
//                     teNantModel.docno == null
//                         ? teNantModel.cid == null
//                             ? ''
//                             : '${teNantModel.cid}'
//                         : '${teNantModel.docno}',
//                     teNantModel.quantity);
//               }
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '3') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//               : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '1') {
//               if (datex.isAfter(
//                       DateTime.parse('${teNantModel.ldate} 00:00:00.000')
//                           .subtract(Duration(days: open_set_date))) ==
//                   true) {
//                 var daterx = teNantModel.ldate == null
//                     ? teNantModel.ldate_q
//                     : teNantModel.ldate;

//                 if (daterx != null) {
//                   int daysBetween(DateTime from, DateTime to) {
//                     from = DateTime(from.year, from.month, from.day);
//                     to = DateTime(to.year, to.month, to.day);
//                     return (to.difference(from).inHours / 24).round();
//                   }

//                   var birthday = DateTime.parse('$daterx 00:00:00.000')
//                       .add(const Duration(days: -30));
//                   var date2 = DateTime.now();
//                   var difference = daysBetween(birthday, date2);

//                   // print('difference == $difference');

//                   var daterx_now = DateTime.now();

//                   var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

//                   final now = DateTime.now();
//                   final earlier =
//                       daterx_ldate.subtract(const Duration(days: 0));
//                   var daterx_A = now.isAfter(earlier);
//                   // print(now.isAfter(earlier)); // true
//                   // print(now.isBefore(earlier)); // true

//                   if (daterx_A != true) {
//                     setState(() {
//                       teNantModels.add(teNantModel);
//                     });
//                     read_GC_photo(
//                         teNantModel.docno == null
//                             ? teNantModel.cid == null
//                                 ? ''
//                                 : '${teNantModel.cid}'
//                             : '${teNantModel.docno}',
//                         teNantModel.quantity);
//                   }
//                 }
//               }
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     } else if (Status_pe_ser == '4') {
//       String url = zone == null
//           ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//           : zone == '0'
//               ? '${MyConstant().domain}/GC_tenantAll_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate'
//               : '${MyConstant().domain}/GC_tenant_Selectldate.php?isAdd=true&ren=$ren&zone=$zone&mon_s=$Mon_Cid_ldate&ye_s=$YE_Cid_ldate';

//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             TeNantModel teNantModel = TeNantModel.fromJson(map);
//             if (teNantModel.quantity == '2' || teNantModel.quantity == '3') {
//               setState(() {
//                 teNantModels.add(teNantModel);
//               });
//               read_GC_photo(
//                   teNantModel.docno == null
//                       ? teNantModel.cid == null
//                           ? ''
//                           : '${teNantModel.cid}'
//                       : '${teNantModel.docno}',
//                   teNantModel.quantity);
//             }
//           }
//         } else {}
//         setState(() {
//           _teNantModels = teNantModels;
//         });
//       } catch (e) {}
//     }

//     quotxSelectModels = List.generate(teNantModels.length, (_) => []);
//     red_report();
//   }
// ////////////////////------------------------------------------------>(รูปผู้เช่า)

//   Future<Null> read_GC_photo(ciddoc_, qutser_) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');

//     String url =
//         '${MyConstant().domain}/GC_photo_cont.php?isAdd=true&ren=$ren&ciddoc=$ciddoc_&qutser=$qutser_';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           ContractPhotoModel contractPhotoModel =
//               ContractPhotoModel.fromJson(map);

//           var pic_tenantx = contractPhotoModel.pic_tenant!.trim();
//           var pic_shopx = contractPhotoModel.pic_shop!.trim();
//           var pic_planx = contractPhotoModel.pic_plan!.trim();
//           setState(() {
//             // pic_tenant = pic_tenantx;
//             // pic_shop = pic_shopx;
//             // pic_plan = pic_planx;
//             contractPhotoModels.add(contractPhotoModel);
//           });
//           // print('pic_tenantx');
//           // print(pic_tenantx);
//         }
//       }
//     } catch (e) {}
//   }

// /////////----------------------------------------------------->
  Future<Null> red_Exp() async {
    setState(() {
      expModels.clear();
    });
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
      // quotxSelectModels[index].sort((a, b) => a.expser!.compareTo(b.expser!));
    } catch (e) {}
  }

//   //////////----------------------------------------->(รายละเอียดค่าบริการ)
//   Future<Null> red_report() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     for (int index = 0; index < teNantModels.length; index++) {
//       setState(() {
//         quotxSelectModels[index].clear();
//       });
//       var ciddoc = teNantModels[index].docno == null
//           ? teNantModels[index].cid == null
//               ? ''
//               : '${teNantModels[index].cid}'
//           : '${teNantModels[index].docno}';
//       var qutser = teNantModels[index].quantity;

//       String url =
//           '${MyConstant().domain}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
//       try {
//         var response = await http.get(Uri.parse(url));

//         var result = json.decode(response.body);
//         // print(result);
//         if (result != null) {
//           for (var map in result) {
//             QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
//             setState(() {
//               quotxSelectModels[index].add(quotxSelectModel);
//             });
//           }
//         } else {}
//         // quotxSelectModels[index].sort((a, b) => a.expser!.compareTo(b.expser!));
//       } catch (e) {}
//     }
//     setState(() {
//       Await_Status_Report1 = 1;
//     });
//   }

//   Future<Null> red_report_Select(index) async {
//     setState(() {
//       quotxSelectModels_Select.clear();
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
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
//       // print(result);
//       if (result != null) {
//         for (var map in result) {
//           QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
//           setState(() {
//             quotxSelectModels_Select.add(quotxSelectModel);
//           });
//         }
//       } else {}
//       // quotxSelectModels[index].sort((a, b) => a.expser!.compareTo(b.expser!));
//     } catch (e) {}
//   }

//   _searchBar_tenantSelect() {
//     return StreamBuilder(
//         stream: Stream.periodic(const Duration(seconds: 0)),
//         builder: (context, snapshot) {
//           return TextField(
//             autofocus: false,
//             keyboardType: TextInputType.text,
//             style: const TextStyle(
//               // fontSize: 22.0,
//               color: TextHome_Color.TextHome_Colors,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               // fillColor: Colors.white,
//               hintText: ' Search...',
//               hintStyle: const TextStyle(
//                   color: CustomerScreen_Color.Colors_Text2_,
//                   // fontWeight: FontWeight.bold,
//                   fontFamily: Font_.Fonts_T),
//               contentPadding:
//                   const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
//               // focusedBorder: OutlineInputBorder(
//               //   borderSide: const BorderSide(color: Colors.white),
//               //   borderRadius: BorderRadius.circular(10),
//               // ),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.white),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onChanged: (text) {
//               text = text.toLowerCase();
//               // print(text);_teNantModels

//               // print(customerModels.map((e) => e.docno));
//               // print(_customerModels.map((e) => e.docno));

//               setState(() {
//                 teNantModels = _teNantModels.where((teNantModel) {
//                   var notTitle = teNantModel.cid.toString().toLowerCase();
//                   var notTitle2 = teNantModel.cname.toString().toLowerCase();
//                   var notTitle3 = teNantModel.cname_q.toString().toLowerCase();
//                   var notTitle4 = teNantModel.sname.toString().toLowerCase();
//                   var notTitle5 = teNantModel.ln_c.toString().toLowerCase();
//                   var notTitle6 = teNantModel.area_c.toString().toLowerCase();
//                   return notTitle.contains(text) ||
//                       notTitle2.contains(text) ||
//                       notTitle3.contains(text) ||
//                       notTitle4.contains(text) ||
//                       notTitle5.contains(text) ||
//                       notTitle6.contains(text);
//                 }).toList();
//               });
//             },
//           );
//         });
//   }

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า(ยกเลิกสัญญา))
  Future<Null> read_GC_tenant_Cancel() async {
    if (teNantModels_Cancel.isNotEmpty) {
      teNantModels_Cancel.clear();
      _teNantModels_Cancel.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = Value_Chang_Zone_People_Ser_Cancel;

    // print('zone>>>>>>zone>>>>>$zone');

    String url = (zone != '0')
        ? '${MyConstant().domain}/GC_tenant_Cancel_ZoneReport.php?isAdd=true&ren=$ren&ser_zone=$zone&mon_s=$Mon_People_Cancel&ye_s=$YE_People_Cancel'
        : '${MyConstant().domain}/GC_tenant_Cancel_AllReport.php?isAdd=true&ren=$ren&mon_s=$Mon_People_Cancel&ye_s=$YE_People_Cancel';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModelsCancel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels_Cancel.add(teNantModelsCancel);
          });
        }
      } else {}
      // print('result ${teNantModels_Cancel.length}');
      setState(() {
        _teNantModels_Cancel = teNantModels_Cancel;
      });
    } catch (e) {}
    setState(() {
      Await_Status_Report2 = 1;
    });
  }

  _searchBar_tenantSelect_Cancel() {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return TextField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              // fontSize: 22.0,
              color: TextHome_Color.TextHome_Colors,
            ),
            decoration: InputDecoration(
              filled: true,
              // fillColor: Colors.white,
              hintText: ' Search...',
              hintStyle: const TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              // focusedBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(color: Colors.white),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (text) {
              text = text.toLowerCase();
              // print(text);_teNantModels

              // print(customerModels.map((e) => e.docno));
              // print(_customerModels.map((e) => e.docno));

              setState(() {
                teNantModels_Cancel =
                    _teNantModels_Cancel.where((teNantModels_Cancels) {
                  var notTitle =
                      teNantModels_Cancels.cid.toString().toLowerCase();
                  var notTitle2 =
                      teNantModels_Cancels.cname.toString().toLowerCase();
                  var notTitle3 =
                      teNantModels_Cancels.cname_q.toString().toLowerCase();
                  var notTitle4 =
                      teNantModels_Cancels.sname.toString().toLowerCase();
                  var notTitle5 =
                      teNantModels_Cancels.ln_c.toString().toLowerCase();
                  var notTitle6 =
                      teNantModels_Cancels.area_c.toString().toLowerCase();
                  return notTitle.contains(text) ||
                      notTitle2.contains(text) ||
                      notTitle3.contains(text) ||
                      notTitle4.contains(text) ||
                      notTitle5.contains(text) ||
                      notTitle6.contains(text);
                }).toList();
              });
            },
          );
        });
  }

/////////////////////----------------------------------------->(รายงาน ประวัติบิล)

  // Future<Null> red_Trans_bill_Mon() async {
  //   if (_TransReBillModels_Mon.length != 0) {
  //     setState(() {
  //       _TransReBillModels_Mon.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   // var ciddoc = widget.Get_Value_cid;
  //   // var qutser = widget.Get_Value_NameShop_index;GC_bill_pay_BC_ReportHistoryBill_mont_All

  //   String url =
  //       '${MyConstant().domain}/GC_bill_pay_BC_ReportHistoryBill_mont_All.php?isAdd=true&ren=$ren&yex=$YE_historybill&monx=$Mon_historybill';

  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     print('$result');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransReBillModel transReBillModel_mon =
  //             TransReBillModel.fromJson(map);

  //         if (Value_Chang_Zone_historybill_Ser_Mon.toString() == '0') {
  //           setState(() {
  //             _TransReBillModels_Mon.add(transReBillModel_mon);
  //           });
  //         } else {
  //           if (transReBillModel_mon.zn == null) {
  //             if (Value_Chang_Zone_historybill_Ser_Mon.toString() ==
  //                 transReBillModel_mon.zser.toString()) {
  //               setState(() {
  //                 _TransReBillModels_Mon.add(transReBillModel_mon);
  //               });
  //             }
  //           } else {
  //             if (Value_Chang_Zone_historybill_Ser_Mon.toString() ==
  //                 transReBillModel_mon.zser1.toString()) {
  //               setState(() {
  //                 _TransReBillModels_Mon.add(transReBillModel_mon);
  //               });
  //             }
  //           }
  //         }
  //       }
  //       setState(() {
  //         TransReBillModels_ = _TransReBillModels;
  //       });
  //       print('result ${_TransReBillModels.length}');
  //     }
  //   } catch (e) {}

  //   setState(() {
  //     Await_Status_Report3 = 1;
  //   });
  // }

  Future<Null> red_Trans_bill() async {
    if (_TransReBillModels.length != 0) {
      setState(() {
        _TransReBillModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;GC_bill_pay_BC_ReportHistoryBill_mont_All
    var zone = (Value_Chang_Zone_historybill_Ser == null)
        ? '0'
        : Value_Chang_Zone_historybill_Ser;
    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_ReportHistoryBill.php?isAdd=true&ren=$ren&datex=$Value_selectDate_Historybills&zser=$zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);

          if (Value_Chang_Zone_historybill_Ser.toString() == '0') {
            setState(() {
              _TransReBillModels.add(transReBillModel);
            });
          } else {
            if (transReBillModel.zn == null) {
              if (Value_Chang_Zone_historybill_Ser.toString() ==
                  transReBillModel.zser.toString()) {
                setState(() {
                  _TransReBillModels.add(transReBillModel);
                });
              }
            } else {
              if (Value_Chang_Zone_historybill_Ser.toString() ==
                  transReBillModel.zser1.toString()) {
                setState(() {
                  _TransReBillModels.add(transReBillModel);
                });
              }
            }
          }
        }
        setState(() {
          TransReBillModels_ = _TransReBillModels;
        });
        print('result ${_TransReBillModels.length}');
      }
    } catch (e) {}

    setState(() {
      Await_Status_Report3 = 1;
    });
  }

  _searchBar_Trans_bill() {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return TextField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              // fontSize: 22.0,
              color: TextHome_Color.TextHome_Colors,
            ),
            decoration: InputDecoration(
              filled: true,
              // fillColor: Colors.white,
              hintText: ' Search...',
              hintStyle: const TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              // focusedBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(color: Colors.white),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (text) {
              text = text.toLowerCase();
              // print(text);_teNantModels

              // print(customerModels.map((e) => e.docno));
              // print(_customerModels.map((e) => e.docno));

              setState(() {
                _TransReBillModels =
                    TransReBillModels_.where((TransReBillModel) {
                  var notTitle = TransReBillModel.cid.toString().toLowerCase();
                  var notTitle2 =
                      TransReBillModel.cname.toString().toLowerCase();
                  var notTitle3 =
                      TransReBillModel.docno.toString().toLowerCase();
                  var notTitle4 =
                      TransReBillModel.sname.toString().toLowerCase();
                  var notTitle5 = TransReBillModel.zn.toString().toLowerCase();
                  var notTitle6 = TransReBillModel.ln.toString().toLowerCase();
                  return notTitle.contains(text) ||
                      notTitle2.contains(text) ||
                      notTitle3.contains(text) ||
                      notTitle4.contains(text) ||
                      notTitle5.contains(text) ||
                      notTitle6.contains(text);
                }).toList();
              });
            },
          );
        });
  }

  //////////------------------------------------------------------->(รายงาน ประวัติบิล (ยกเลิก))
  Future<Null> red_Trans_billCancel() async {
    if (_TransReBillModels_cancel.length != 0) {
      setState(() {
        _TransReBillModels_cancel.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;
    var zone = (Value_Chang_Zone_historybill_Ser == null)
        ? '0'
        : Value_Chang_Zone_historybill_Ser;
    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Report_HistoryBillCancel.php?isAdd=true&ren=$ren&datex=$Value_selectDate_Historybills&zser=$zone';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModelcancel =
              TransReBillModel.fromJson(map);

          if (Value_Chang_Zone_historybill_Ser.toString() == '0') {
            setState(() {
              _TransReBillModels_cancel.add(transReBillModelcancel);
            });
          } else {
            if (transReBillModelcancel.zn == null) {
              if (Value_Chang_Zone_historybill_Ser.toString() ==
                  transReBillModelcancel.zser.toString()) {
                setState(() {
                  _TransReBillModels_cancel.add(transReBillModelcancel);
                });
              }
            } else {
              if (Value_Chang_Zone_historybill_Ser.toString() ==
                  transReBillModelcancel.zser1.toString()) {
                setState(() {
                  _TransReBillModels_cancel.add(transReBillModelcancel);
                });
              }
            }
          }
        }

        // print('result ${_TransReBillModels_cancel.length}');
      }
      setState(() {
        TransReBillModels_cancel_ = _TransReBillModels_cancel;
      });
    } catch (e) {}
    setState(() {
      Await_Status_Report4 = 1;
    });
  }
////////--------------------------------------------------------------->

  Future<Null> read_Trans_invoice_Befor() async {
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    //  String? zone_ser_Invoice_Befor, zone_name_Invoice_Befor;
    // String? Befor_YE_Invoice, Befor_Mon_Invoice;

    var serMONTH = Befor_Mon_Invoice;
    var serYEAR = Befor_YE_Invoice;

    // print('zone_ser >> $zone_ser $zone');

    String url =
        '${MyConstant().domain}/GC_InvoiceBefor_Report.php?isAdd=true&ren=$ren&serMONTH=$serMONTH&serYEAR=$serYEAR&zone_ser=$zone_ser_Invoice_Befor';
    // print('read_Trans_invoice_all   $url');

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'true') {
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);
          setState(() {
            _TransModels.add(_TransModel);
          });
        }
      }
    } catch (e) {}
  }

////////--------------------------------------------------------------->
  _searchBar_Trans_billCancel() {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return TextField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              // fontSize: 22.0,
              color: TextHome_Color.TextHome_Colors,
            ),
            decoration: InputDecoration(
              filled: true,
              // fillColor: Colors.white,
              hintText: ' Search...',
              hintStyle: const TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              // focusedBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(color: Colors.white),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (text) {
              text = text.toLowerCase();
              // print(text);_teNantModels

              // print(customerModels.map((e) => e.docno));
              // print(_customerModels.map((e) => e.docno));

              setState(() {
                _TransReBillModels_cancel =
                    TransReBillModels_cancel_.where((TransReBillModels_cancel) {
                  var notTitle =
                      TransReBillModels_cancel.cid.toString().toLowerCase();
                  var notTitle2 =
                      TransReBillModels_cancel.cname.toString().toLowerCase();
                  var notTitle3 =
                      TransReBillModels_cancel.docno.toString().toLowerCase();
                  var notTitle4 =
                      TransReBillModels_cancel.sname.toString().toLowerCase();
                  var notTitle5 =
                      TransReBillModels_cancel.zn.toString().toLowerCase();
                  var notTitle6 =
                      TransReBillModels_cancel.ln.toString().toLowerCase();
                  return notTitle.contains(text) ||
                      notTitle2.contains(text) ||
                      notTitle3.contains(text) ||
                      notTitle4.contains(text) ||
                      notTitle5.contains(text) ||
                      notTitle6.contains(text);
                }).toList();
              });
            },
          );
        });
  }

  ///----------------------------------------------------------->(วันที่ ประวัติบิล)
  Future<Null> _select_Date_HistoryBills(BuildContext context) async {
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
        var formatter = DateFormat('y-MM-d');
        print("${formatter.format(result!)}");
        setState(() {
          Value_selectDate_Historybills = "${formatter.format(result)}";
        });

        // red_Trans_bill_Groptype_daly();
      }
    });
  }

  ///----------------------------------------------------------->

  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(milliseconds: 3600), () {
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

//////////////------------------------------------->
  final DateRangePickerController _controller = DateRangePickerController();
  Widget getDateRangePicker(type) {
    // final localeObj = Locale('th');
    return Container(
      height: 250,
      width: 300,
      child: Column(
        children: [
          if (type != 1)
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
                allowViewNavigation: (type == 1 || type == 2) ? false : true,
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
                        ? selectionChanged_month2
                        : selectionChanged,
                // backgroundColor: AppBarColors.ABar_Colors,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget getDateRangePicker(type) {
  //   // final localeObj = Locale('th');
  //   return Container(
  //     height: 250,
  //     width: 300,
  //     child: Card(
  //       child: SfDateRangePicker(
  //         allowViewNavigation: (type == 1 || type == 2) ? false : true,
  //         startRangeSelectionColor: Colors.purple,
  //         endRangeSelectionColor: Colors.deepPurple,
  //         rangeSelectionColor: Colors.green[100],
  //         view: DateRangePickerView.year,
  //         // monthViewSettings:
  //         //     DateRangePickerMonthViewSettings(viewHeaderHeight: 100),
  //         selectionMode: DateRangePickerSelectionMode.single,
  //         enableMultiView: false,
  //         toggleDaySelection: false,
  //         // showTodayButton: true,
  //         onSelectionChanged: (type == 1)
  //             ? selectionChanged_month1
  //             : (type == 2)
  //                 ? selectionChanged_month2
  //                 : selectionChanged,
  //         // backgroundColor: AppBarColors.ABar_Colors,
  //       ),
  //     ),
  //   );
  // }

  /////////////////---------------------------->
  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;

      setState(() {
        Value_selectDate_Historybills =
            DateFormat('yyyy-MM-dd').format(args.value);
      });
    } else if (args.value is DateTime) {
      setState(() {
        Value_selectDate_Historybills =
            DateFormat('yyyy-MM-dd').format(args.value);
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });

    print(Value_selectDate_Historybills);
  }

  void selectionChanged_month1(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
//  (Mon_People_Cancel == null ||
//                                             YE_People_Cancel == '')
      setState(() {
        Mon_People_Cancel = DateFormat('MM').format(selectedDate);
        YE_People_Cancel = DateFormat('yyyy').format(selectedDate);
      });
      print('Selected month: ${Mon_People_Cancel}, Year: ${YE_People_Cancel}');
    }
  }

  void selectionChanged_month2(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;

      //  (Mon_Cannotice_Mon == null ||
      //                             YE_Cannotice_Mon == '')
      setState(() {
        Befor_Mon_Invoice = DateFormat('MM').format(selectedDate);
        Befor_YE_Invoice = DateFormat('yyyy').format(selectedDate);
        // Mon_Cannotice_Mon = DateFormat('MM').format(selectedDate);
        // YE_Cannotice_Mon = DateFormat('yyyy').format(selectedDate);
      });
      print('Selected month: ${Befor_Mon_Invoice}, Year: ${Befor_YE_Invoice}');
    }
  }

  //////////////------------------------------------->
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
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                          value: Status_pe,

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
                          items: Status.map((item) => DropdownMenuItem<String>(
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
                              Status_pe = Status[selectedIndex]!;
                              Status_pe_ser = '${selectedIndex + 1}';
                            });
                            // print(selectedIndex);
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
                              value: (Value_Chang_Zone_People == null)
                                  ? null
                                  : Value_Chang_Zone_People,
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
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: Dropdown_Controller_zone[0],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                        color:
                                            Color.fromARGB(255, 231, 227, 227),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              hint: (Value_Chang_Zone_People == null)
                                  ? null
                                  : Text(
                                      '$Value_Chang_Zone_People',
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
                                  Value_Chang_Zone_People = value!;
                                  Value_Chang_Zone_People_Ser =
                                      zoneModels_report[selectedIndex].ser!;
                                });
                                // print(
                                //     'Selected Index: $Value_Chang_Zone_People  //${Value_Chang_Zone_People_Ser}');
                              },
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  Dropdown_Controller_zone[0].clear();
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
                        //   value: Value_Chang_Zone_People,
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
                        //       Value_Chang_Zone_People = value!;
                        //       Value_Chang_Zone_People_Ser =
                        //           zoneModels_report[selectedIndex].ser!;
                        //     });
                        //     // print(
                        //     //     'Selected Index: $Value_Chang_Zone_People  //${Value_Chang_Zone_People_Ser}');
                        //   },
                        // ),
                      ),
                    ),

                    //                     int Ser_Cid_ldate = 0;
                    // List Cid_ldate = [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Translate.TranslateAndSetText(
                          'วันที่ใกล้หมดสัญญา :',
                          ReportScreen_Color.Colors_Text2_,
                          TextAlign.center,
                          FontWeight.w500,
                          Font_.Fonts_T,
                          Text_Size,
                          1),
                    ),
/////----------------------------->
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
                          value: Cid_ldate[Ser_Cid_ldate].toString(),

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
                              Cid_ldate.map((item) => DropdownMenuItem<String>(
                                    value: '${item}',
                                    child: Text(
                                      '${item}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: Text_Size,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )).toList(),

                          onChanged: (value) async {
                            int selectedIndex =
                                Cid_ldate.indexWhere((item) => item == value);
                            setState(() {
                              teNantModels.clear();
                              contractPhotoModels.clear();

                              Mon_Cid_ldate = null;
                              YE_Cid_ldate = null;
                            });
                            setState(() {
                              Ser_Cid_ldate = selectedIndex;
                              YE_Cid_ldate = null;
                              Mon_Cid_ldate = null;
                            });

                            // print(Ser_Cid_ldate);
                          },
                        ),
                      ),
                    ),

                    if (Ser_Cid_ldate == 1)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'เดือน :',
                            ReportScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                    if (Ser_Cid_ldate == 1)
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
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
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
                            value:
                                (Mon_Cid_ldate == null) ? null : Mon_Cid_ldate,

                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            iconSize: 20,
                            buttonHeight: 40,
                            buttonWidth: 200,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items: [
                              for (int item = 1; item < 13; item++)
                                DropdownMenuItem<String>(
                                  value: '${item}',
                                  child: Text(
                                    '${monthsInThai[item - 1]}',
                                    // '${item}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: Text_Size,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                            ],

                            onChanged: (value) async {
                              Mon_Cid_ldate = value.toString();
                            },
                          ),
                        ),
                      ),
                    if (Ser_Cid_ldate == 1)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'ปี :',
                            ReportScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            Text_Size,
                            1),
                      ),
                    if (Ser_Cid_ldate == 1)
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
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
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
                            value: (YE_Cid_ldate == null) ? null : YE_Cid_ldate,

                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            iconSize: 20,
                            buttonHeight: 40,
                            buttonWidth: 200,
                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                            dropdownDecoration: BoxDecoration(
                              // color: Colors
                              //     .amber,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: '${int.parse('${YE_Th[0]}') + 1}',
                                child: Text(
                                  '${int.parse('${YE_Th[0]}') + 1}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: Text_Size,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              for (int index = 0; index < YE_Th.length; index++)
                                DropdownMenuItem<String>(
                                  value: '${YE_Th[index]}',
                                  child: Text(
                                    '${YE_Th[index]}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: Text_Size,
                                      color: (index == 0)
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              // YE_Th.map((item) => DropdownMenuItem<String>(
                              //                               value: '${item}',
                              //                               child: Text(
                              //                                 '${item}',
                              //                                 // '${int.parse(item) + 543}',
                              //                                 textAlign: TextAlign.center,
                              //                                 style: const TextStyle(
                              //                                   overflow: TextOverflow.ellipsis,
                              //                                   fontSize: 14,
                              //                                   color: Colors.grey,
                              //                                 ),
                              //                               ),
                              //                             )).toList(),
                            ],

                            onChanged: (value) async {
                              YE_Cid_ldate = value.toString();
                            },
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          if (Ser_Cid_ldate == 0) {
                            if (Status_pe != null &&
                                Value_Chang_Zone_People != null) {
                              setState(() {
                                Await_Status_Report1 = 0;
                              });
                              Dia_log();
                            }
                          } else {
                            if (Status_pe != null &&
                                Value_Chang_Zone_People != null &&
                                Mon_Cid_ldate != null &&
                                YE_Cid_ldate != null) {
                              setState(() {
                                Await_Status_Report1 = 0;
                              });
                              Dia_log();
                            }
                          }

                          if (Ser_Cid_ldate == 0) {
                            if (Status_pe != null &&
                                Value_Chang_Zone_People != null) {
                              read_GC_tenantSelect().then((value) => {
                                    setState(() {
                                      Await_Status_Report1 = 1;
                                    })
                                  });
                            }
                          } else {
                            // if (Status_pe != null &&
                            //     Value_Chang_Zone_People != null &&
                            //     Mon_Cid_ldate != null &&
                            //     YE_Cid_ldate != null) {
                            //   read_GC_tenantSelect2_ldate().then((value) => {
                            //         setState(() {
                            //           Await_Status_Report1 = 1;
                            //         })
                            //       });
                            //   // read_GC_tenantSelect2_ldate();
                            // }
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
                      onTap: (Ser_Cid_ldate == 0)
                          ? (Status_pe == null ||
                                  Value_Chang_Zone_People == null ||
                                  teNantModels.isEmpty)
                              ? null
                              : () async {
                                  Insert_log.Insert_logs(
                                      'รายงาน', 'กดดูรายงานข้อมูลผู้เช่า');
                                  RE_People_Widget();
                                }
                          : (Status_pe == null ||
                                  Value_Chang_Zone_People == null ||
                                  teNantModels.isEmpty ||
                                  Mon_Cid_ldate == null ||
                                  YE_Cid_ldate == null)
                              ? null
                              : () async {
                                  Insert_log.Insert_logs(
                                      'รายงาน', 'กดดูรายงานข้อมูลผู้เช่า');
                                  RE_People_Widget();
                                }),
                  (teNantModels.isEmpty || Await_Status_Report1 == null)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (Ser_Cid_ldate == 0)
                              ? Translate.TranslateAndSetText(
                                  (Status_pe != null &&
                                          teNantModels.isEmpty &&
                                          Value_Chang_Zone_People != null &&
                                          Await_Status_Report1 != null)
                                      ? 'รายงานข้อมูลผู้เช่า (ไม่พบข้อมูล ✖️)'
                                      : 'รายงานข้อมูลผู้เช่า',
                                  ReportScreen_Color.Colors_Text1_,
                                  TextAlign.center,
                                  FontWeight.w500,
                                  Font_.Fonts_T,
                                  Text_Size,
                                  1)
                              : Translate.TranslateAndSetText(
                                  (Status_pe != null &&
                                          teNantModels.isEmpty &&
                                          Value_Chang_Zone_People != null &&
                                          Await_Status_Report1 != null &&
                                          Mon_Cid_ldate != null &&
                                          YE_Cid_ldate != null)
                                      ? 'รายงานข้อมูลผู้เช่า (ไม่พบข้อมูล ✖️)'
                                      : 'รายงานข้อมูลผู้เช่า',
                                  ReportScreen_Color.Colors_Text1_,
                                  TextAlign.center,
                                  FontWeight.w500,
                                  Font_.Fonts_T,
                                  Text_Size,
                                  1),
                        )
                      : (Await_Status_Report1 == 0)
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
                                      'กำลังโหลดรายงานข้อมูลผู้เช่า...',
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
                              padding: EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'รายงานข้อมูลผู้เช่า ✔️',
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
            // Row(
            //   children: [
            //     const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Text(
            //         'เดือน :',
            //         style: TextStyle(
            //           color: ReportScreen_Color.Colors_Text2_,
            //           // fontWeight: FontWeight.bold,
            //           fontFamily: Font_.Fonts_T,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Container(
            //         decoration: const BoxDecoration(
            //           color: AppbackgroundColor.Sub_Abg_Colors,
            //           borderRadius: BorderRadius.only(
            //               topLeft: Radius.circular(10),
            //               topRight: Radius.circular(10),
            //               bottomLeft: Radius.circular(10),
            //               bottomRight: Radius.circular(10)),
            //           // border: Border.all(color: Colors.grey, width: 1),
            //         ),
            //         width: 120,
            //         padding: const EdgeInsets.all(8.0),
            //         child: DropdownButtonFormField2(
            //           alignment: Alignment.center,
            //           focusColor: Colors.white,
            //           autofocus: false,
            //           decoration: InputDecoration(
            //             floatingLabelAlignment: FloatingLabelAlignment.center,
            //             enabled: true,
            //             hoverColor: Colors.brown,
            //             prefixIconColor: Colors.blue,
            //             fillColor: Colors.white.withOpacity(0.05),
            //             filled: false,
            //             isDense: true,
            //             contentPadding: EdgeInsets.zero,
            //             border: OutlineInputBorder(
            //               borderSide: const BorderSide(color: Colors.red),
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             focusedBorder: const OutlineInputBorder(
            //               borderRadius: BorderRadius.only(
            //                 topRight: Radius.circular(10),
            //                 topLeft: Radius.circular(10),
            //                 bottomRight: Radius.circular(10),
            //                 bottomLeft: Radius.circular(10),
            //               ),
            //               borderSide: BorderSide(
            //                 width: 1,
            //                 color: Color.fromARGB(255, 231, 227, 227),
            //               ),
            //             ),
            //           ),
            //           isExpanded: false,
            //           value: Mon_historybill,
            //           // hint: Text(
            //           //   Mon_Income == null
            //           //       ? 'เลือก'
            //           //       : '$Mon_Income',
            //           //   maxLines: 2,
            //           //   textAlign: TextAlign.center,
            //           //   style: const TextStyle(
            //           //     overflow:
            //           //         TextOverflow.ellipsis,
            //           //     fontSize: 14,
            //           //     color: Colors.grey,
            //           //   ),
            //           // ),
            //           icon: const Icon(
            //             Icons.arrow_drop_down,
            //             color: Colors.black,
            //           ),
            //           style: const TextStyle(
            //             color: Colors.grey,
            //           ),
            //           iconSize: 20,
            //           buttonHeight: 40,
            //           buttonWidth: 200,
            //           // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
            //           dropdownDecoration: BoxDecoration(
            //             // color: Colors
            //             //     .amber,
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: Colors.white, width: 1),
            //           ),
            //           items: [
            //             for (int item = 1; item < 13; item++)
            //               DropdownMenuItem<String>(
            //                 value: '${item}',
            //                 child: Text(
            //                   '${item}',
            //                   textAlign: TextAlign.center,
            //                   style: const TextStyle(
            //                     overflow: TextOverflow.ellipsis,
            //                     fontSize: 14,
            //                     color: Colors.grey,
            //                   ),
            //                 ),
            //               )
            //           ],

            //           onChanged: (value) async {
            //             Mon_historybill = value;

            //             // if (Value_Chang_Zone_Income !=
            //             //     null) {
            //             //   red_Trans_billIncome();
            //             //   red_Trans_billMovemen();
            //             // }
            //           },
            //         ),
            //       ),
            //     ),
            //     const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Text(
            //         'ปี :',
            //         style: TextStyle(
            //           color: ReportScreen_Color.Colors_Text2_,
            //           // fontWeight: FontWeight.bold,
            //           fontFamily: Font_.Fonts_T,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Container(
            //         decoration: const BoxDecoration(
            //           color: AppbackgroundColor.Sub_Abg_Colors,
            //           borderRadius: BorderRadius.only(
            //               topLeft: Radius.circular(10),
            //               topRight: Radius.circular(10),
            //               bottomLeft: Radius.circular(10),
            //               bottomRight: Radius.circular(10)),
            //           // border: Border.all(color: Colors.grey, width: 1),
            //         ),
            //         width: 120,
            //         padding: const EdgeInsets.all(8.0),
            //         child: DropdownButtonFormField2(
            //           alignment: Alignment.center,
            //           focusColor: Colors.white,
            //           autofocus: false,
            //           decoration: InputDecoration(
            //             floatingLabelAlignment: FloatingLabelAlignment.center,
            //             enabled: true,
            //             hoverColor: Colors.brown,
            //             prefixIconColor: Colors.blue,
            //             fillColor: Colors.white.withOpacity(0.05),
            //             filled: false,
            //             isDense: true,
            //             contentPadding: EdgeInsets.zero,
            //             border: OutlineInputBorder(
            //               borderSide: const BorderSide(color: Colors.red),
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             focusedBorder: const OutlineInputBorder(
            //               borderRadius: BorderRadius.only(
            //                 topRight: Radius.circular(10),
            //                 topLeft: Radius.circular(10),
            //                 bottomRight: Radius.circular(10),
            //                 bottomLeft: Radius.circular(10),
            //               ),
            //               borderSide: BorderSide(
            //                 width: 1,
            //                 color: Color.fromARGB(255, 231, 227, 227),
            //               ),
            //             ),
            //           ),
            //           isExpanded: false,
            //           value: YE_historybill,
            //           // hint: Text(
            //           //   YE_Income == null
            //           //       ? 'เลือก'
            //           //       : '$YE_Income',
            //           //   maxLines: 2,
            //           //   textAlign: TextAlign.center,
            //           //   style: const TextStyle(
            //           //     overflow:
            //           //         TextOverflow.ellipsis,
            //           //     fontSize: 14,
            //           //     color: Colors.grey,
            //           //   ),
            //           // ),
            //           icon: const Icon(
            //             Icons.arrow_drop_down,
            //             color: Colors.black,
            //           ),
            //           style: const TextStyle(
            //             color: Colors.grey,
            //           ),
            //           iconSize: 20,
            //           buttonHeight: 40,
            //           buttonWidth: 200,
            //           // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
            //           dropdownDecoration: BoxDecoration(
            //             // color: Colors
            //             //     .amber,
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: Colors.white, width: 1),
            //           ),
            //           items: YE_Th.map((item) => DropdownMenuItem<String>(
            //                 value: '${item}',
            //                 child: Text(
            //                   '${item}',
            //                   textAlign: TextAlign.center,
            //                   style: const TextStyle(
            //                     overflow: TextOverflow.ellipsis,
            //                     fontSize: 14,
            //                     color: Colors.grey,
            //                   ),
            //                 ),
            //               )).toList(),

            //           onChanged: (value) async {
            //             YE_historybill = value;

            //             // if (Value_Chang_Zone_Income !=
            //             //     null) {
            //             //   red_Trans_billIncome();
            //             //   red_Trans_billMovemen();
            //             // }
            //           },
            //         ),
            //       ),
            //     ),
            //     const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Text(
            //         'โซน :',
            //         style: TextStyle(
            //           color: ReportScreen_Color.Colors_Text2_,
            //           // fontWeight: FontWeight.bold,
            //           fontFamily: Font_.Fonts_T,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Container(
            //         decoration: const BoxDecoration(
            //           color: AppbackgroundColor.Sub_Abg_Colors,
            //           borderRadius: BorderRadius.only(
            //               topLeft: Radius.circular(10),
            //               topRight: Radius.circular(10),
            //               bottomLeft: Radius.circular(10),
            //               bottomRight: Radius.circular(10)),
            //           // border: Border.all(color: Colors.grey, width: 1),
            //         ),
            //         width: 260,
            //         padding: const EdgeInsets.all(8.0),
            //         child: DropdownButtonFormField2(
            //           value: Value_Chang_Zone_historybill_Mon,
            //           alignment: Alignment.center,
            //           focusColor: Colors.white,
            //           autofocus: false,
            //           decoration: InputDecoration(
            //             enabled: true,
            //             hoverColor: Colors.brown,
            //             prefixIconColor: Colors.blue,
            //             fillColor: Colors.white.withOpacity(0.05),
            //             filled: false,
            //             isDense: true,
            //             contentPadding: EdgeInsets.zero,
            //             border: OutlineInputBorder(
            //               borderSide: const BorderSide(color: Colors.red),
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             focusedBorder: const OutlineInputBorder(
            //               borderRadius: BorderRadius.only(
            //                 topRight: Radius.circular(10),
            //                 topLeft: Radius.circular(10),
            //                 bottomRight: Radius.circular(10),
            //                 bottomLeft: Radius.circular(10),
            //               ),
            //               borderSide: BorderSide(
            //                 width: 1,
            //                 color: Color.fromARGB(255, 231, 227, 227),
            //               ),
            //             ),
            //           ),
            //           isExpanded: false,

            //           icon: const Icon(
            //             Icons.arrow_drop_down,
            //             color: Colors.black,
            //           ),
            //           style: const TextStyle(
            //             color: Colors.grey,
            //           ),
            //           iconSize: 20,
            //           buttonHeight: 40,
            //           buttonWidth: 250,
            //           // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
            //           dropdownDecoration: BoxDecoration(
            //             // color: Colors
            //             //     .amber,
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: Colors.white, width: 1),
            //           ),
            //           items: zoneModels_report
            //               .map((item) => DropdownMenuItem<String>(
            //                     value: '${item.zn}',
            //                     child: Text(
            //                       '${item.zn}',
            //                       textAlign: TextAlign.center,
            //                       style: const TextStyle(
            //                         overflow: TextOverflow.ellipsis,
            //                         fontSize: 14,
            //                         color: Colors.grey,
            //                       ),
            //                     ),
            //                   ))
            //               .toList(),

            //           onChanged: (value) async {
            //             int selectedIndex = zoneModels_report
            //                 .indexWhere((item) => item.zn == value);

            //             setState(() {
            //               Value_Chang_Zone_historybill_Mon = value!;
            //               Value_Chang_Zone_historybill_Ser_Mon =
            //                   zoneModels_report[selectedIndex].ser!;
            //             });
            //             print(
            //                 'Selected Index: $Value_Chang_Zone_historybill_Mon  //${Value_Chang_Zone_historybill_Ser_Mon}');
            //           },
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: InkWell(
            //         onTap: () async {
            //           // setState(() {
            //           //   Await_Status_Report2 = 0;
            //           //   Await_Status_Report3 = 0;
            //           // });
            //           red_Trans_bill_Mon();
            //           // red_Trans_billCancel();
            //         },
            //         child: Container(
            //             width: 100,
            //             padding: const EdgeInsets.all(8.0),
            //             decoration: BoxDecoration(
            //               color: Colors.green[700],
            //               borderRadius: const BorderRadius.only(
            //                   topLeft: Radius.circular(10),
            //                   topRight: Radius.circular(10),
            //                   bottomLeft: Radius.circular(10),
            //                   bottomRight: Radius.circular(10)),
            //             ),
            //             child: Center(
            //               child: Text(
            //                 'ค้นหา',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold,
            //                   fontFamily: FontWeight_.Fonts_T,
            //                 ),
            //               ),
            //             )),
            //       ),
            //     ),
            //   ],
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
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                                    contentPadding: const EdgeInsets.all(10.0),
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
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            width: 180,
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Translate.TranslateAndSetText(
                                  (Mon_People_Cancel == null ||
                                          YE_People_Cancel == '')
                                      ? 'เลือก'
                                      : '$Mon_People_Cancel / $YE_People_Cancel',
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
                    //       value: (Mon_People_Cancel == null)
                    //           ? null
                    //           : Mon_People_Cancel,

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
                    //         Mon_People_Cancel = value.toString();
                    //       },
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.all(8.0),
                    //   child: Text(
                    //     'ปี :',
                    //     style: TextStyle(
                    //       fontSize: Text_Size,
                    //       color: ReportScreen_Color.Colors_Text2_,
                    //       // fontWeight: FontWeight.bold,
                    //       fontFamily: Font_.Fonts_T,
                    //     ),
                    //   ),
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
                    //       value: (YE_People_Cancel == null)
                    //           ? null
                    //           : YE_People_Cancel,

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
                    //         YE_People_Cancel = value.toString();
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
                              value: (Value_Chang_Zone_People_Cancel == null)
                                  ? null
                                  : Value_Chang_Zone_People_Cancel,
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
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: Dropdown_Controller_zone[1],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                        color:
                                            Color.fromARGB(255, 231, 227, 227),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              hint: (Value_Chang_Zone_People_Cancel == null)
                                  ? null
                                  : Text(
                                      '$Value_Chang_Zone_People_Cancel',
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
                                  Value_Chang_Zone_People_Cancel = value!;
                                  Value_Chang_Zone_People_Ser_Cancel =
                                      zoneModels_report[selectedIndex].ser!;
                                });
                                // print(
                                //     'Selected Index: $Value_Chang_Zone_People_Cancel  //${Value_Chang_Zone_People_Ser_Cancel}');
                              },
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  Dropdown_Controller_zone[1].clear();
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
                        //   value: Value_Chang_Zone_People_Cancel,
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
                        //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10), Excel_PeopleCho_Cancel_Report
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
                        //       Value_Chang_Zone_People_Cancel = value!;
                        //       Value_Chang_Zone_People_Ser_Cancel =
                        //           zoneModels_report[selectedIndex].ser!;
                        //     });
                        //     // print(
                        //     //     'Selected Index: $Value_Chang_Zone_People_Cancel  //${Value_Chang_Zone_People_Ser_Cancel}');
                        //   },
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          if (Value_Chang_Zone_People_Cancel != null) {
                            setState(() {
                              Await_Status_Report2 = 0;
                            });
                            Dia_log();
                          }

                          read_GC_tenant_Cancel();
                          // read_GC_tenantSelect();
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
                      onTap: (Value_Chang_Zone_People_Cancel == null ||
                              teNantModels_Cancel.isEmpty)
                          ? null
                          : () async {
                              Insert_log.Insert_logs('รายงาน',
                                  'กดดูรายงานข้อมูลผู้เช่า(ยกเลิกสัญญา)');
                              RE_People_Cancel_Widget();
                            }),
                  (teNantModels_Cancel.isEmpty || Await_Status_Report2 == null)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSetText(
                              (teNantModels_Cancel.isEmpty &&
                                      Value_Chang_Zone_People_Cancel != null &&
                                      Await_Status_Report2 != null)
                                  ? 'รายงานข้อมูลผู้เช่า(ยกเลิกสัญญา) (ไม่พบข้อมูล ✖️)'
                                  : 'รายงานข้อมูลผู้เช่า(ยกเลิกสัญญา)',
                              ReportScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              Text_Size,
                              1),
                        )
                      : (Await_Status_Report2 == 0)
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
                                      'กำลังโหลดรายงานข้อมูลผู้เช่า(ยกเลิกสัญญา)...',
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
                              padding: EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'รายงานข้อมูลผู้เช่า(ยกเลิกสัญญา) ✔️ ',
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
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                          'วันที่รับชำระ :',
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
                                    contentPadding: const EdgeInsets.all(10.0),
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
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            width: 180,
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Translate.TranslateAndSetText(
                                  (Value_selectDate_Historybills == null ||
                                          Value_selectDate_Historybills == '')
                                      ? 'เลือก'
                                      : '$Value_selectDate_Historybills',
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
                    //       _select_Date_HistoryBills(context);
                    //     },
                    //     child: Container(
                    //         decoration: BoxDecoration(
                    //           color: AppbackgroundColor.Sub_Abg_Colors,
                    //           borderRadius: const BorderRadius.only(
                    //               topLeft: Radius.circular(10),
                    //               topRight: Radius.circular(10),
                    //               bottomLeft: Radius.circular(10),
                    //               bottomRight: Radius.circular(10)),
                    //           border: Border.all(color: Colors.grey, width: 1),
                    //         ),
                    //         width: 120,
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Center(
                    //           child: Translate.TranslateAndSetText(
                    //               (Value_selectDate_Historybills == null)
                    //                   ? 'เลือก'
                    //                   : '$Value_selectDate_Historybills',
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
                          'โซนที่รับชำระ :',
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
                              value: (Value_Chang_Zone_historybill == null)
                                  ? null
                                  : Value_Chang_Zone_historybill,
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
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: Dropdown_Controller_zone[2],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                        color:
                                            Color.fromARGB(255, 231, 227, 227),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              hint: (Value_Chang_Zone_historybill == null)
                                  ? null
                                  : Text(
                                      '$Value_Chang_Zone_historybill',
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
                                  Value_Chang_Zone_historybill = value!;
                                  Value_Chang_Zone_historybill_Ser =
                                      zoneModels_report[selectedIndex].ser!;
                                });
                                // print(
                                //     'Selected Index: $Value_Chang_Zone_historybill  //${Value_Chang_Zone_historybill_Ser}');
                              },
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  Dropdown_Controller_zone[2].clear();
                                }
                              }),
                        ),

                        // DropdownButtonFormField2(
                        //   value: Value_Chang_Zone_historybill,
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
                        //       Value_Chang_Zone_historybill = value!;
                        //       Value_Chang_Zone_historybill_Ser =
                        //           zoneModels_report[selectedIndex].ser!;
                        //     });
                        //     // print(
                        //     //     'Selected Index: $Value_Chang_Zone_historybill  //${Value_Chang_Zone_historybill_Ser}');
                        //   },
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          if (Value_Chang_Zone_historybill != null &&
                              Value_selectDate_Historybills != null) {
                            setState(() {
                              Await_Status_Report3 = 0;
                              Await_Status_Report4 = 0;
                            });
                            Dia_log();
                          }

                          red_Trans_bill();
                          red_Trans_billCancel();
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
                      onTap: (Value_Chang_Zone_historybill == null ||
                              Value_selectDate_Historybills == null ||
                              _TransReBillModels.isEmpty)
                          ? null
                          : () async {
                              Insert_log.Insert_logs(
                                  'รายงาน', 'กดดูรายงานประวัติบิล');
                              RE_HistoryBills_Widget();
                            }),
                  (_TransReBillModels.isEmpty || Await_Status_Report3 == null)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSetText(
                              (Value_Chang_Zone_historybill != null &&
                                      Value_selectDate_Historybills != null &&
                                      _TransReBillModels.isEmpty &&
                                      Await_Status_Report3 != null)
                                  ? 'รายงานประวัติบิล (ไม่พบข้อมูล ✖️)'
                                  : 'รายงานประวัติบิล',
                              ReportScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              Text_Size,
                              1),
                        )
                      : (Await_Status_Report3 == 0)
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
                                      'กำลังโหลดรายงานประวัติบิล...',
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
                              padding: EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'รายงานประวัติบิล ✔️',
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
                      onTap: (Value_Chang_Zone_historybill == null ||
                              Value_selectDate_Historybills == null ||
                              _TransReBillModels_cancel.isEmpty)
                          ? null
                          : () async {
                              Insert_log.Insert_logs(
                                  'รายงาน', 'กดดูรายงานประวัติบิล(ยกเลิก)');
                              RE_HistoryBills_Cancel_Widget();
                            }),
                  (_TransReBillModels_cancel.isEmpty ||
                          Await_Status_Report4 == null)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSetText(
                              (Value_Chang_Zone_historybill != null &&
                                      Value_selectDate_Historybills != null &&
                                      _TransReBillModels_cancel.isEmpty &&
                                      Await_Status_Report4 != null)
                                  ? 'รายงานประวัติบิล(ยกเลิก) (ไม่พบข้อมูล ✖️)'
                                  : 'รายงานประวัติบิล(ยกเลิก)',
                              ReportScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              Text_Size,
                              1),
                        )
                      : (Await_Status_Report4 == 0)
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
                                      'กำลังโหลดรายงานประวัติบิล(ยกเลิก)...',
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
                              padding: EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'รายงานประวัติบิล(ยกเลิก)✔️',
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
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                                    contentPadding: const EdgeInsets.all(10.0),
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
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            width: 180,
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Translate.TranslateAndSetText(
                                  (Befor_Mon_Invoice == null ||
                                          Befor_Mon_Invoice == '')
                                      ? 'เลือก'
                                      : '$Befor_Mon_Invoice/$Befor_YE_Invoice',
                                  ReportScreen_Color.Colors_Text2_,
                                  TextAlign.center,
                                  FontWeight.w500,
                                  Font_.Fonts_T,
                                  Text_Size - 2,
                                  1),
                            )),
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
                              value: (zone_name_Invoice_Befor == null)
                                  ? null
                                  : zone_name_Invoice_Befor,
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
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: Dropdown_Controller_zone[0],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                        color:
                                            Color.fromARGB(255, 231, 227, 227),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              hint: (zone_name_Invoice_Befor == null)
                                  ? null
                                  : Text(
                                      '$zone_name_Invoice_Befor',
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
                                  zone_name_Invoice_Befor = value!;
                                  zone_ser_Invoice_Befor =
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: (zone_ser_Invoice_Befor == null)
                            ? null
                            : () async {
                                if (zone_ser_Invoice_Befor != null) {
                                  setState(() {
                                    // Ser_BodySta1 = 1;
                                    Await_Status_Report2 = 0;
                                  });
                                  Dia_log();
                                }
                                try {
                                  read_Trans_invoice_Befor().then((result) {
                                    // print('red_InvoiceMonFull_bill');
                                    // print('red_InvoiceMonFull_bill');
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
                          onTap: (zone_ser_Invoice_Befor == null ||
                                  _TransModels.isEmpty)
                              ? null
                              : () async {
                                  // Insert_log.Insert_logs(
                                  //     'รายงาน', 'กดดูรายงานการแจ้งซ่อม');
                                  Befor_Invoice_Widget();
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
                                      'กำลังโหลดรายงานข้อมูลก่อน แจ้งหนี้/วางบิล...',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                ),
                              ],
                            ))
                          : (_TransModels.isEmpty ||
                                  Await_Status_Report2 == null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      (_TransModels.isEmpty &&
                                              zone_ser_Invoice_Befor != null &&
                                              Await_Status_Report2 != null)
                                          ? 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล (ไม่พบข้อมูล ✖️)'
                                          : 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล',
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
                                      'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล✔️',
                                      ReportScreen_Color.Colors_Text1_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size,
                                      1),
                                ),
                    ],
                  ),
                )),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

///////////////////////////----------------------------------------------->(รายงานผู้เช่า)
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
                          ? 'รายงานผู้เช่า (กรุณาเลือกโซน)'
                          : 'รายงานผู้เช่า (โซน : $Value_Chang_Zone_People)',
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
                              'ผู้เช่า: ${Status_pe}',
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
                                            print(expModels[selectedIndex]
                                                .expname);
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
                                                  (datex.isAfter(DateTime.parse(
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
                                                                          days:
                                                                              open_set_date))) ==
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
                            formKey.currentState?.reset();
                            Value_Chang_Zone_People_Ser = null;

                            Value_Chang_Zone_People = null;
                            Status_pe = null;
                            Await_Status_Report1 = null;
                            teNantModels.clear();
                            contractPhotoModels.clear();
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

  // RE_People_Widget() {
  //   int? ser_index;
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //         title: StreamBuilder(
  //             stream: Stream.periodic(const Duration(seconds: 0)),
  //             builder: (context, snapshot) {
  //               return Column(
  //                 children: [
  //                   Center(
  //                       child: Text(
  //                     (Value_Chang_Zone_People == null)
  //                         ? 'รายงานผู้เช่า (กรุณาเลือกโซน)'
  //                         : 'รายงานผู้เช่า (โซน : $Value_Chang_Zone_People)',
  //                     style: const TextStyle(
  //                       color: ReportScreen_Color.Colors_Text1_,
  //                       fontWeight: FontWeight.bold,
  //                       fontFamily: FontWeight_.Fonts_T,
  //                     ),
  //                   )),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                           flex: 1,
  //                           child: Text(
  //                             'ผู้เช่า: ${Status_pe}',
  //                             textAlign: TextAlign.start,
  //                             style: const TextStyle(
  //                               fontSize: 14,
  //                               color: ReportScreen_Color.Colors_Text1_,
  //                               // fontWeight: FontWeight.bold,
  //                               fontFamily: FontWeight_.Fonts_T,
  //                             ),
  //                           )),
  //                       Expanded(
  //                           flex: 1,
  //                           child: Text(
  //                             'ทั้งหมด: ${teNantModels.length}',
  //                             textAlign: TextAlign.end,
  //                             style: const TextStyle(
  //                               fontSize: 14,
  //                               color: ReportScreen_Color.Colors_Text1_,
  //                               // fontWeight: FontWeight.bold,
  //                               fontFamily: FontWeight_.Fonts_T,
  //                             ),
  //                           )),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 1),
  //                   const Divider(),
  //                   const SizedBox(height: 1),
  //                   Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     // padding: EdgeInsets.all(10),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Expanded(
  //                           child: _searchBar_tenantSelect(),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }),
  //         content: StreamBuilder(
  //             stream: Stream.periodic(const Duration(seconds: 0)),
  //             builder: (context, snapshot) {
  //               return ScrollConfiguration(
  //                 behavior:
  //                     ScrollConfiguration.of(context).copyWith(dragDevices: {
  //                   PointerDeviceKind.touch,
  //                   PointerDeviceKind.mouse,
  //                 }),
  //                 child: SingleChildScrollView(
  //                   scrollDirection: Axis.horizontal,
  //                   child: Row(
  //                     children: [
  //                       Container(
  //                         // color: Colors.grey[50],
  //                         width: (Responsive.isDesktop(context))
  //                             ? MediaQuery.of(context).size.width * 0.98
  //                             : (teNantModels.length == 0)
  //                                 ? MediaQuery.of(context).size.width
  //                                 : 1200,
  //                         // height:
  //                         //     MediaQuery.of(context)
  //                         //             .size
  //                         //             .height *
  //                         //         0.3,
  //                         child: (teNantModels.length == 0)
  //                             ? const Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Center(
  //                                     child: Text(
  //                                       'ไม่พบข้อมูล ณ วันที่เลือก',
  //                                       style: TextStyle(
  //                                         color:
  //                                             ReportScreen_Color.Colors_Text1_,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontFamily: FontWeight_.Fonts_T,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               )
  //                             : Column(
  //                                 children: <Widget>[
  //                                   Container(
  //                                     // width: 1050,
  //                                     decoration: BoxDecoration(
  //                                       color: AppbackgroundColor.TiTile_Colors,
  //                                       borderRadius: BorderRadius.only(
  //                                           topLeft: Radius.circular(10),
  //                                           topRight: Radius.circular(10),
  //                                           bottomLeft: Radius.circular(0),
  //                                           bottomRight: Radius.circular(0)),
  //                                     ),
  //                                     padding: const EdgeInsets.all(8.0),
  //                                     child: Row(
  //                                       children: [
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'เลขที่สัญญา/เสนอราคา',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'ชื่อผู้ติดต่อ',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'TAX/ID',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'ที่อยู่',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'ชื่อร้านค้า',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'โซนพื้นที่',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'รหัสพื้นที่',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'ขนาดพื้นที่(ต.ร.ม.)',
  //                                             textAlign: TextAlign.start,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'ระยะเวลาการเช่า',
  //                                             textAlign: TextAlign.end,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'วันเริ่มสัญญา',
  //                                             textAlign: TextAlign.end,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'วันสิ้นสุดสัญญา',
  //                                             textAlign: TextAlign.end,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: const Text(
  //                                             'สถานะ',
  //                                             textAlign: TextAlign.end,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                         Expanded(
  //                                           flex: 1,
  //                                           child: Text(
  //                                             '...',
  //                                             textAlign: TextAlign.end,
  //                                             style: TextStyle(
  //                                                 color: PeopleChaoScreen_Color
  //                                                     .Colors_Text1_,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 fontFamily:
  //                                                     FontWeight_.Fonts_T,
  //                                                 fontSize: 14.0
  //                                                 //fontSize: 10.0
  //                                                 //fontSize: 10.0
  //                                                 ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                       // height: (Responsive.isDesktop(context))
  //                                       //     ? MediaQuery.of(context).size.width * 0.255
  //                                       //     : MediaQuery.of(context).size.height * 0.45,
  //                                       child: ListView.builder(
  //                                     itemCount: teNantModels.length,
  //                                     itemBuilder:
  //                                         (BuildContext context, int index) {
  //                                       return (ser_index != index)
  //                                           ? ListTile(
  //                                               title: Container(
  //                                                 decoration: BoxDecoration(
  //                                                   // color: Colors.green[100]!
  //                                                   //     .withOpacity(0.5),
  //                                                   border: const Border(
  //                                                     bottom: BorderSide(
  //                                                       color: Colors.black12,
  //                                                       width: 1,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                                 child: Row(children: [
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: Tooltip(
  //                                                         richMessage: TextSpan(
  //                                                           text: teNantModels[
  //                                                                           index]
  //                                                                       .docno ==
  //                                                                   null
  //                                                               ? teNantModels[index]
  //                                                                           .cid ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${teNantModels[index].cid}'
  //                                                               : '${teNantModels[index].docno}',
  //                                                           style:
  //                                                               const TextStyle(
  //                                                             color: HomeScreen_Color
  //                                                                 .Colors_Text1_,
  //                                                             fontWeight:
  //                                                                 FontWeight
  //                                                                     .bold,
  //                                                             fontFamily:
  //                                                                 FontWeight_
  //                                                                     .Fonts_T,
  //                                                             //fontSize: 10.0
  //                                                           ),
  //                                                         ),
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       5),
  //                                                           color: Colors
  //                                                               .grey[200],
  //                                                         ),
  //                                                         child: AutoSizeText(
  //                                                           minFontSize: 10,
  //                                                           maxFontSize: 25,
  //                                                           maxLines: 1,
  //                                                           teNantModels[index]
  //                                                                       .docno ==
  //                                                                   null
  //                                                               ? teNantModels[index]
  //                                                                           .cid ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${teNantModels[index].cid}'
  //                                                               : '${teNantModels[index].docno}',
  //                                                           textAlign:
  //                                                               TextAlign.start,
  //                                                           overflow:
  //                                                               TextOverflow
  //                                                                   .ellipsis,
  //                                                           style:
  //                                                               const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily:
  //                                                                       Font_
  //                                                                           .Fonts_T),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: AutoSizeText(
  //                                                         minFontSize: 10,
  //                                                         maxFontSize: 25,
  //                                                         maxLines: 1,
  //                                                         teNantModels[index]
  //                                                                     .cname ==
  //                                                                 null
  //                                                             ? teNantModels[index]
  //                                                                         .cname_q ==
  //                                                                     null
  //                                                                 ? ''
  //                                                                 : '${teNantModels[index].cname_q}'
  //                                                             : '${teNantModels[index].cname}',
  //                                                         textAlign:
  //                                                             TextAlign.start,
  //                                                         overflow: TextOverflow
  //                                                             .ellipsis,
  //                                                         style:
  //                                                             const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 //fontWeight: FontWeight.bold,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       '${teNantModels[index].tax}',
  //                                                       textAlign:
  //                                                           TextAlign.start,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: const TextStyle(
  //                                                           color: PeopleChaoScreen_Color
  //                                                               .Colors_Text2_,
  //                                                           //fontWeight: FontWeight.bold,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       '${teNantModels[index].addr}',
  //                                                       textAlign:
  //                                                           TextAlign.start,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: const TextStyle(
  //                                                           color: PeopleChaoScreen_Color
  //                                                               .Colors_Text2_,
  //                                                           //fontWeight: FontWeight.bold,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: Tooltip(
  //                                                         richMessage: TextSpan(
  //                                                           text: teNantModels[
  //                                                                           index]
  //                                                                       .sname ==
  //                                                                   null
  //                                                               ? teNantModels[index]
  //                                                                           .sname_q ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${teNantModels[index].sname_q}'
  //                                                               : '${teNantModels[index].sname}',
  //                                                           style:
  //                                                               const TextStyle(
  //                                                             color: HomeScreen_Color
  //                                                                 .Colors_Text1_,
  //                                                             fontWeight:
  //                                                                 FontWeight
  //                                                                     .bold,
  //                                                             fontFamily:
  //                                                                 FontWeight_
  //                                                                     .Fonts_T,
  //                                                             //fontSize: 10.0
  //                                                           ),
  //                                                         ),
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       5),
  //                                                           color: Colors
  //                                                               .grey[200],
  //                                                         ),
  //                                                         child: AutoSizeText(
  //                                                           minFontSize: 10,
  //                                                           maxFontSize: 25,
  //                                                           maxLines: 1,
  //                                                           teNantModels[index]
  //                                                                       .sname ==
  //                                                                   null
  //                                                               ? teNantModels[index]
  //                                                                           .sname_q ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${teNantModels[index].sname_q}'
  //                                                               : '${teNantModels[index].sname}',
  //                                                           textAlign:
  //                                                               TextAlign.start,
  //                                                           overflow:
  //                                                               TextOverflow
  //                                                                   .ellipsis,
  //                                                           style:
  //                                                               const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily:
  //                                                                       Font_
  //                                                                           .Fonts_T),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       '${teNantModels[index].zn}',
  //                                                       textAlign:
  //                                                           TextAlign.start,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: const TextStyle(
  //                                                           color: PeopleChaoScreen_Color
  //                                                               .Colors_Text2_,
  //                                                           //fontWeight: FontWeight.bold,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Tooltip(
  //                                                       richMessage: TextSpan(
  //                                                         text: teNantModels[
  //                                                                         index]
  //                                                                     .ln_c ==
  //                                                                 null
  //                                                             ? teNantModels[index]
  //                                                                         .ln_q ==
  //                                                                     null
  //                                                                 ? ''
  //                                                                 : '${teNantModels[index].ln_q}'
  //                                                             : '${teNantModels[index].ln_c}',
  //                                                         style:
  //                                                             const TextStyle(
  //                                                           color: HomeScreen_Color
  //                                                               .Colors_Text1_,
  //                                                           fontWeight:
  //                                                               FontWeight.bold,
  //                                                           fontFamily:
  //                                                               FontWeight_
  //                                                                   .Fonts_T,
  //                                                           //fontSize: 10.0
  //                                                         ),
  //                                                       ),
  //                                                       decoration:
  //                                                           BoxDecoration(
  //                                                         borderRadius:
  //                                                             BorderRadius
  //                                                                 .circular(5),
  //                                                         color:
  //                                                             Colors.grey[200],
  //                                                       ),
  //                                                       child: AutoSizeText(
  //                                                         minFontSize: 10,
  //                                                         maxFontSize: 25,
  //                                                         maxLines: 1,
  //                                                         teNantModels[index]
  //                                                                     .ln_c ==
  //                                                                 null
  //                                                             ? teNantModels[index]
  //                                                                         .ln_q ==
  //                                                                     null
  //                                                                 ? ''
  //                                                                 : '${teNantModels[index].ln_q}'
  //                                                             : '${teNantModels[index].ln_c}',
  //                                                         textAlign:
  //                                                             TextAlign.start,
  //                                                         style:
  //                                                             const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 //fontWeight: FontWeight.bold,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       teNantModels[index]
  //                                                                   .area_c ==
  //                                                               null
  //                                                           ? teNantModels[index]
  //                                                                       .area_q ==
  //                                                                   null
  //                                                               ? ''
  //                                                               : '${teNantModels[index].area_q}'
  //                                                           : '${teNantModels[index].area_c}',
  //                                                       textAlign:
  //                                                           TextAlign.start,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: const TextStyle(
  //                                                           color: PeopleChaoScreen_Color
  //                                                               .Colors_Text2_,
  //                                                           //fontWeight: FontWeight.bold,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       teNantModels[index]
  //                                                                   .period ==
  //                                                               null
  //                                                           ? teNantModels[index]
  //                                                                       .period_q ==
  //                                                                   null
  //                                                               ? ''
  //                                                               : '${teNantModels[index].period_q}  ${teNantModels[index].rtname_q!.substring(3)}'
  //                                                           : '${teNantModels[index].period}  ${teNantModels[index].rtname!.substring(3)}',
  //                                                       textAlign:
  //                                                           TextAlign.end,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: const TextStyle(
  //                                                           color: PeopleChaoScreen_Color
  //                                                               .Colors_Text2_,
  //                                                           //fontWeight: FontWeight.bold,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: AutoSizeText(
  //                                                         minFontSize: 10,
  //                                                         maxFontSize: 25,
  //                                                         maxLines: 1,
  //                                                         teNantModels[index]
  //                                                                     .sdate_q ==
  //                                                                 null
  //                                                             ? teNantModels[index]
  //                                                                         .sdate ==
  //                                                                     null
  //                                                                 ? ''
  //                                                                 : DateFormat(
  //                                                                         'dd-MM-yyyy')
  //                                                                     .format(DateTime
  //                                                                         .parse(
  //                                                                             '${teNantModels[index].sdate} 00:00:00'))
  //                                                                     .toString()
  //                                                             : DateFormat(
  //                                                                     'dd-MM-yyyy')
  //                                                                 .format(DateTime
  //                                                                     .parse(
  //                                                                         '${teNantModels[index].sdate_q} 00:00:00'))
  //                                                                 .toString(),
  //                                                         textAlign:
  //                                                             TextAlign.end,
  //                                                         overflow: TextOverflow
  //                                                             .ellipsis,
  //                                                         style:
  //                                                             const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 //fontWeight: FontWeight.bold,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: AutoSizeText(
  //                                                         minFontSize: 10,
  //                                                         maxFontSize: 25,
  //                                                         maxLines: 1,
  //                                                         teNantModels[index]
  //                                                                     .ldate_q ==
  //                                                                 null
  //                                                             ? teNantModels[index]
  //                                                                         .ldate ==
  //                                                                     null
  //                                                                 ? ''
  //                                                                 : DateFormat(
  //                                                                         'dd-MM-yyyy')
  //                                                                     .format(DateTime
  //                                                                         .parse(
  //                                                                             '${teNantModels[index].ldate} 00:00:00'))
  //                                                                     .toString()
  //                                                             : DateFormat(
  //                                                                     'dd-MM-yyyy')
  //                                                                 .format(DateTime
  //                                                                     .parse(
  //                                                                         '${teNantModels[index].ldate_q} 00:00:00'))
  //                                                                 .toString(),
  //                                                         textAlign:
  //                                                             TextAlign.end,
  //                                                         overflow: TextOverflow
  //                                                             .ellipsis,
  //                                                         style:
  //                                                             const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 //fontWeight: FontWeight.bold,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: AutoSizeText(
  //                                                       minFontSize: 10,
  //                                                       maxFontSize: 25,
  //                                                       maxLines: 1,
  //                                                       teNantModels[index]
  //                                                                   .quantity ==
  //                                                               '1'
  //                                                           ? datex.isAfter(DateTime.parse(
  //                                                                           '${teNantModels[index].ldate} 00:00:00.000')
  //                                                                       .subtract(const Duration(
  //                                                                           days:
  //                                                                               0))) ==
  //                                                                   true
  //                                                               ? 'หมดสัญญา'
  //                                                               : datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(
  //                                                                           days:
  //                                                                               30))) ==
  //                                                                       true
  //                                                                   ? 'ใกล้หมดสัญญา'
  //                                                                   : 'เช่าอยู่'
  //                                                           : teNantModels[index]
  //                                                                       .quantity ==
  //                                                                   '2'
  //                                                               ? 'เสนอราคา'
  //                                                               : teNantModels[index]
  //                                                                           .quantity ==
  //                                                                       '3'
  //                                                                   ? 'เสนอราคา(มัดจำ)'
  //                                                                   : 'ว่าง',
  //                                                       textAlign:
  //                                                           TextAlign.end,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       style: TextStyle(
  //                                                           color: teNantModels[
  //                                                                           index]
  //                                                                       .quantity ==
  //                                                                   '1'
  //                                                               ? datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) ==
  //                                                                       true
  //                                                                   ? Colors.red
  //                                                                   : datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
  //                                                                           true
  //                                                                       ? Colors
  //                                                                           .orange
  //                                                                           .shade900
  //                                                                       : Colors
  //                                                                           .black
  //                                                               : teNantModels[index]
  //                                                                           .quantity ==
  //                                                                       '2'
  //                                                                   ? Colors
  //                                                                       .blue
  //                                                                   : teNantModels[index]
  //                                                                               .quantity ==
  //                                                                           '3'
  //                                                                       ? Colors
  //                                                                           .blue
  //                                                                       : Colors
  //                                                                           .green,
  //                                                           fontFamily:
  //                                                               Font_.Fonts_T
  //                                                           //fontSize: 10.0
  //                                                           ),
  //                                                     ),
  //                                                   ),
  //                                                   Expanded(
  //                                                     flex: 1,
  //                                                     child: Padding(
  //                                                       padding:
  //                                                           const EdgeInsets
  //                                                               .all(8.0),
  //                                                       child: InkWell(
  //                                                         child: Container(
  //                                                           decoration:
  //                                                               BoxDecoration(
  //                                                             color:
  //                                                                 Colors.green,
  //                                                             borderRadius: const BorderRadius
  //                                                                     .only(
  //                                                                 topLeft:
  //                                                                     Radius.circular(
  //                                                                         10),
  //                                                                 topRight: Radius
  //                                                                     .circular(
  //                                                                         10),
  //                                                                 bottomLeft: Radius
  //                                                                     .circular(
  //                                                                         10),
  //                                                                 bottomRight: Radius
  //                                                                     .circular(
  //                                                                         10)),
  //                                                           ),
  //                                                           padding:
  //                                                               const EdgeInsets
  //                                                                   .all(2.0),
  //                                                           child: Center(
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               minFontSize: 10,
  //                                                               maxFontSize: 25,
  //                                                               maxLines: 1,
  //                                                               'เพิ่มเติม',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               style:
  //                                                                   TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text1_,
  //                                                                 fontWeight:
  //                                                                     FontWeight
  //                                                                         .bold,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T,
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         onTap: () async {
  //                                                           setState(() {
  //                                                             ser_index = index;
  //                                                           });
  //                                                           red_report_Select(
  //                                                               index);
  //                                                         },
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                 ]),
  //                                               ),
  //                                             )
  //                                           : Container(
  //                                               child: Column(
  //                                                 children: [
  //                                                   ListTile(
  //                                                     title: Container(
  //                                                       decoration:
  //                                                           BoxDecoration(
  //                                                         color:
  //                                                             Colors.green[100],
  //                                                         border: const Border(
  //                                                           bottom: BorderSide(
  //                                                             color: Colors
  //                                                                 .black12,
  //                                                             width: 1,
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       child: Row(children: [
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child: Tooltip(
  //                                                               richMessage:
  //                                                                   TextSpan(
  //                                                                 text: teNantModels[index]
  //                                                                             .docno ==
  //                                                                         null
  //                                                                     ? teNantModels[index].cid ==
  //                                                                             null
  //                                                                         ? ''
  //                                                                         : '${teNantModels[index].cid}'
  //                                                                     : '${teNantModels[index].docno}',
  //                                                                 style:
  //                                                                     const TextStyle(
  //                                                                   color: HomeScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T,
  //                                                                   //fontSize: 10.0
  //                                                                 ),
  //                                                               ),
  //                                                               decoration:
  //                                                                   BoxDecoration(
  //                                                                 borderRadius:
  //                                                                     BorderRadius
  //                                                                         .circular(
  //                                                                             5),
  //                                                                 color: Colors
  //                                                                         .grey[
  //                                                                     200],
  //                                                               ),
  //                                                               child:
  //                                                                   AutoSizeText(
  //                                                                 minFontSize:
  //                                                                     10,
  //                                                                 maxFontSize:
  //                                                                     25,
  //                                                                 maxLines: 1,
  //                                                                 teNantModels[index]
  //                                                                             .docno ==
  //                                                                         null
  //                                                                     ? teNantModels[index].cid ==
  //                                                                             null
  //                                                                         ? ''
  //                                                                         : '${teNantModels[index].cid}'
  //                                                                     : '${teNantModels[index].docno}',
  //                                                                 textAlign:
  //                                                                     TextAlign
  //                                                                         .start,
  //                                                                 overflow:
  //                                                                     TextOverflow
  //                                                                         .ellipsis,
  //                                                                 style: const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily: Font_.Fonts_T),
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               minFontSize: 10,
  //                                                               maxFontSize: 25,
  //                                                               maxLines: 1,
  //                                                               teNantModels[index]
  //                                                                           .cname ==
  //                                                                       null
  //                                                                   ? teNantModels[index].cname_q ==
  //                                                                           null
  //                                                                       ? ''
  //                                                                       : '${teNantModels[index].cname_q}'
  //                                                                   : '${teNantModels[index].cname}',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               overflow:
  //                                                                   TextOverflow
  //                                                                       .ellipsis,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child: Tooltip(
  //                                                               richMessage:
  //                                                                   TextSpan(
  //                                                                 text: teNantModels[index]
  //                                                                             .sname ==
  //                                                                         null
  //                                                                     ? teNantModels[index].sname_q ==
  //                                                                             null
  //                                                                         ? ''
  //                                                                         : '${teNantModels[index].sname_q}'
  //                                                                     : '${teNantModels[index].sname}',
  //                                                                 style:
  //                                                                     const TextStyle(
  //                                                                   color: HomeScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T,
  //                                                                   //fontSize: 10.0
  //                                                                 ),
  //                                                               ),
  //                                                               decoration:
  //                                                                   BoxDecoration(
  //                                                                 borderRadius:
  //                                                                     BorderRadius
  //                                                                         .circular(
  //                                                                             5),
  //                                                                 color: Colors
  //                                                                         .grey[
  //                                                                     200],
  //                                                               ),
  //                                                               child:
  //                                                                   AutoSizeText(
  //                                                                 minFontSize:
  //                                                                     10,
  //                                                                 maxFontSize:
  //                                                                     25,
  //                                                                 maxLines: 1,
  //                                                                 teNantModels[index]
  //                                                                             .sname ==
  //                                                                         null
  //                                                                     ? teNantModels[index].sname_q ==
  //                                                                             null
  //                                                                         ? ''
  //                                                                         : '${teNantModels[index].sname_q}'
  //                                                                     : '${teNantModels[index].sname}',
  //                                                                 textAlign:
  //                                                                     TextAlign
  //                                                                         .start,
  //                                                                 overflow:
  //                                                                     TextOverflow
  //                                                                         .ellipsis,
  //                                                                 style: const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily: Font_.Fonts_T),
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: AutoSizeText(
  //                                                             minFontSize: 10,
  //                                                             maxFontSize: 25,
  //                                                             maxLines: 1,
  //                                                             '${teNantModels[index].zn}',
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .start,
  //                                                             overflow:
  //                                                                 TextOverflow
  //                                                                     .ellipsis,
  //                                                             style:
  //                                                                 const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color
  //                                                                         .Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily:
  //                                                                         Font_
  //                                                                             .Fonts_T),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Tooltip(
  //                                                             richMessage:
  //                                                                 TextSpan(
  //                                                               text: teNantModels[index]
  //                                                                           .ln_c ==
  //                                                                       null
  //                                                                   ? teNantModels[index].ln_q ==
  //                                                                           null
  //                                                                       ? ''
  //                                                                       : '${teNantModels[index].ln_q}'
  //                                                                   : '${teNantModels[index].ln_c}',
  //                                                               style:
  //                                                                   const TextStyle(
  //                                                                 color: HomeScreen_Color
  //                                                                     .Colors_Text1_,
  //                                                                 fontWeight:
  //                                                                     FontWeight
  //                                                                         .bold,
  //                                                                 fontFamily:
  //                                                                     FontWeight_
  //                                                                         .Fonts_T,
  //                                                                 //fontSize: 10.0
  //                                                               ),
  //                                                             ),
  //                                                             decoration:
  //                                                                 BoxDecoration(
  //                                                               borderRadius:
  //                                                                   BorderRadius
  //                                                                       .circular(
  //                                                                           5),
  //                                                               color: Colors
  //                                                                   .grey[200],
  //                                                             ),
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               minFontSize: 10,
  //                                                               maxFontSize: 25,
  //                                                               maxLines: 1,
  //                                                               teNantModels[index]
  //                                                                           .ln_c ==
  //                                                                       null
  //                                                                   ? teNantModels[index].ln_q ==
  //                                                                           null
  //                                                                       ? ''
  //                                                                       : '${teNantModels[index].ln_q}'
  //                                                                   : '${teNantModels[index].ln_c}',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: AutoSizeText(
  //                                                             minFontSize: 10,
  //                                                             maxFontSize: 25,
  //                                                             maxLines: 1,
  //                                                             teNantModels[index]
  //                                                                         .area_c ==
  //                                                                     null
  //                                                                 ? teNantModels[index]
  //                                                                             .area_q ==
  //                                                                         null
  //                                                                     ? ''
  //                                                                     : '${teNantModels[index].area_q}'
  //                                                                 : '${teNantModels[index].area_c}',
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .start,
  //                                                             overflow:
  //                                                                 TextOverflow
  //                                                                     .ellipsis,
  //                                                             style:
  //                                                                 const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color
  //                                                                         .Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily:
  //                                                                         Font_
  //                                                                             .Fonts_T),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: AutoSizeText(
  //                                                             minFontSize: 10,
  //                                                             maxFontSize: 25,
  //                                                             maxLines: 1,
  //                                                             teNantModels[index]
  //                                                                         .period ==
  //                                                                     null
  //                                                                 ? teNantModels[index]
  //                                                                             .period_q ==
  //                                                                         null
  //                                                                     ? ''
  //                                                                     : '${teNantModels[index].period_q}  ${teNantModels[index].rtname_q!.substring(3)}'
  //                                                                 : '${teNantModels[index].period}  ${teNantModels[index].rtname!.substring(3)}',
  //                                                             textAlign:
  //                                                                 TextAlign.end,
  //                                                             overflow:
  //                                                                 TextOverflow
  //                                                                     .ellipsis,
  //                                                             style:
  //                                                                 const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color
  //                                                                         .Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily:
  //                                                                         Font_
  //                                                                             .Fonts_T),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               minFontSize: 10,
  //                                                               maxFontSize: 25,
  //                                                               maxLines: 1,
  //                                                               teNantModels[index]
  //                                                                           .sdate_q ==
  //                                                                       null
  //                                                                   ? teNantModels[index].sdate ==
  //                                                                           null
  //                                                                       ? ''
  //                                                                       : DateFormat('dd-MM-yyyy')
  //                                                                           .format(DateTime.parse(
  //                                                                               '${teNantModels[index].sdate} 00:00:00'))
  //                                                                           .toString()
  //                                                                   : DateFormat(
  //                                                                           'dd-MM-yyyy')
  //                                                                       .format(
  //                                                                           DateTime.parse('${teNantModels[index].sdate_q} 00:00:00'))
  //                                                                       .toString(),
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               overflow:
  //                                                                   TextOverflow
  //                                                                       .ellipsis,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               minFontSize: 10,
  //                                                               maxFontSize: 25,
  //                                                               maxLines: 1,
  //                                                               teNantModels[index]
  //                                                                           .ldate_q ==
  //                                                                       null
  //                                                                   ? teNantModels[index].ldate ==
  //                                                                           null
  //                                                                       ? ''
  //                                                                       : DateFormat('dd-MM-yyyy')
  //                                                                           .format(DateTime.parse(
  //                                                                               '${teNantModels[index].ldate} 00:00:00'))
  //                                                                           .toString()
  //                                                                   : DateFormat(
  //                                                                           'dd-MM-yyyy')
  //                                                                       .format(
  //                                                                           DateTime.parse('${teNantModels[index].ldate_q} 00:00:00'))
  //                                                                       .toString(),
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               overflow:
  //                                                                   TextOverflow
  //                                                                       .ellipsis,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: AutoSizeText(
  //                                                             minFontSize: 10,
  //                                                             maxFontSize: 25,
  //                                                             maxLines: 1,
  //                                                             teNantModels[index]
  //                                                                         .quantity ==
  //                                                                     '1'
  //                                                                 ? datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(
  //                                                                             days:
  //                                                                                 0))) ==
  //                                                                         true
  //                                                                     ? 'หมดสัญญา'
  //                                                                     : datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
  //                                                                             true
  //                                                                         ? 'ใกล้หมดสัญญา'
  //                                                                         : 'เช่าอยู่'
  //                                                                 : teNantModels[index]
  //                                                                             .quantity ==
  //                                                                         '2'
  //                                                                     ? 'เสนอราคา'
  //                                                                     : teNantModels[index].quantity ==
  //                                                                             '3'
  //                                                                         ? 'เสนอราคา(มัดจำ)'
  //                                                                         : 'ว่าง',
  //                                                             textAlign:
  //                                                                 TextAlign.end,
  //                                                             overflow:
  //                                                                 TextOverflow
  //                                                                     .ellipsis,
  //                                                             style: TextStyle(
  //                                                                 color: teNantModels[index]
  //                                                                             .quantity ==
  //                                                                         '1'
  //                                                                     ? datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) ==
  //                                                                             true
  //                                                                         ? Colors
  //                                                                             .red
  //                                                                         : datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 30))) ==
  //                                                                                 true
  //                                                                             ? Colors
  //                                                                                 .orange.shade900
  //                                                                             : Colors
  //                                                                                 .black
  //                                                                     : teNantModels[index].quantity ==
  //                                                                             '2'
  //                                                                         ? Colors
  //                                                                             .blue
  //                                                                         : teNantModels[index].quantity ==
  //                                                                                 '3'
  //                                                                             ? Colors
  //                                                                                 .blue
  //                                                                             : Colors
  //                                                                                 .green,
  //                                                                 fontFamily:
  //                                                                     Font_
  //                                                                         .Fonts_T
  //                                                                 //fontSize: 10.0
  //                                                                 ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child: InkWell(
  //                                                               child:
  //                                                                   Container(
  //                                                                 decoration:
  //                                                                     BoxDecoration(
  //                                                                   color: Colors
  //                                                                       .red,
  //                                                                   borderRadius: const BorderRadius
  //                                                                           .only(
  //                                                                       topLeft:
  //                                                                           Radius.circular(
  //                                                                               10),
  //                                                                       topRight:
  //                                                                           Radius.circular(
  //                                                                               10),
  //                                                                       bottomLeft:
  //                                                                           Radius.circular(
  //                                                                               10),
  //                                                                       bottomRight:
  //                                                                           Radius.circular(10)),
  //                                                                 ),
  //                                                                 padding:
  //                                                                     const EdgeInsets
  //                                                                             .all(
  //                                                                         2.0),
  //                                                                 child: Center(
  //                                                                   child:
  //                                                                       AutoSizeText(
  //                                                                     minFontSize:
  //                                                                         10,
  //                                                                     maxFontSize:
  //                                                                         25,
  //                                                                     maxLines:
  //                                                                         1,
  //                                                                     'X',
  //                                                                     textAlign:
  //                                                                         TextAlign
  //                                                                             .end,
  //                                                                     style:
  //                                                                         TextStyle(
  //                                                                       color: PeopleChaoScreen_Color
  //                                                                           .Colors_Text1_,
  //                                                                       fontWeight:
  //                                                                           FontWeight.bold,
  //                                                                       fontFamily:
  //                                                                           Font_.Fonts_T,
  //                                                                     ),
  //                                                                   ),
  //                                                                 ),
  //                                                               ),
  //                                                               onTap: () {
  //                                                                 setState(() {
  //                                                                   ser_index =
  //                                                                       null;
  //                                                                 });
  //                                                               },
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                       ]),
  //                                                     ),
  //                                                   ),
  //                                                   Container(
  //                                                     decoration: BoxDecoration(
  //                                                       color:
  //                                                           Colors.green[100],
  //                                                       borderRadius:
  //                                                           BorderRadius.only(
  //                                                               topLeft: Radius
  //                                                                   .circular(
  //                                                                       8),
  //                                                               topRight:
  //                                                                   Radius
  //                                                                       .circular(
  //                                                                           8),
  //                                                               bottomLeft: Radius
  //                                                                   .circular(
  //                                                                       0),
  //                                                               bottomRight:
  //                                                                   Radius
  //                                                                       .circular(
  //                                                                           0)),
  //                                                     ),
  //                                                     padding:
  //                                                         const EdgeInsets.all(
  //                                                             2.0),
  //                                                     child: const Row(
  //                                                       children: [
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 EdgeInsets
  //                                                                     .all(2.0),
  //                                                             child: Text(
  //                                                               'งวด',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T
  //                                                                   //fontSize: 10.0
  //                                                                   //fontSize: 10.0
  //                                                                   ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 EdgeInsets
  //                                                                     .all(2.0),
  //                                                             child: Text(
  //                                                               'วันที่',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T
  //                                                                   //fontSize: 10.0
  //                                                                   //fontSize: 10.0
  //                                                                   ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 EdgeInsets
  //                                                                     .all(2.0),
  //                                                             child: Text(
  //                                                               'รายการ',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T
  //                                                                   //fontSize: 10.0
  //                                                                   //fontSize: 10.0
  //                                                                   ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 EdgeInsets
  //                                                                     .all(2.0),
  //                                                             child: Text(
  //                                                               'ยอด/งวด',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               style: TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T
  //                                                                   //fontSize: 10.0
  //                                                                   //fontSize: 10.0
  //                                                                   ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         Expanded(
  //                                                           flex: 1,
  //                                                           child: Padding(
  //                                                             padding:
  //                                                                 EdgeInsets
  //                                                                     .all(2.0),
  //                                                             child: Text(
  //                                                               'ยอด',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               style: TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T
  //                                                                   //fontSize: 10.0
  //                                                                   //fontSize: 10.0
  //                                                                   ),
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                       ],
  //                                                     ),
  //                                                   ),
  //                                                   if (quotxSelectModels_Select
  //                                                           .length ==
  //                                                       0)
  //                                                     Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           color: Colors
  //                                                               .green[50],
  //                                                           border:
  //                                                               const Border(
  //                                                             bottom:
  //                                                                 BorderSide(
  //                                                               color: Colors
  //                                                                   .black12,
  //                                                               width: 1,
  //                                                             ),
  //                                                           ),
  //                                                         ),
  //                                                         child: ListTile(
  //                                                             title: Row(
  //                                                                 mainAxisAlignment:
  //                                                                     MainAxisAlignment
  //                                                                         .center,
  //                                                                 children: [
  //                                                               Expanded(
  //                                                                 flex: 1,
  //                                                                 child:
  //                                                                     AutoSizeText(
  //                                                                   minFontSize:
  //                                                                       10,
  //                                                                   maxFontSize:
  //                                                                       25,
  //                                                                   maxLines: 1,
  //                                                                   'ไม่พบข้อมูล',
  //                                                                   textAlign:
  //                                                                       TextAlign
  //                                                                           .center,
  //                                                                   style: const TextStyle(
  //                                                                       color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                       //fontWeight: FontWeight.bold,
  //                                                                       fontFamily: Font_.Fonts_T),
  //                                                                 ),
  //                                                               ),
  //                                                             ]))),
  //                                                   for (int index2 = 0;
  //                                                       index2 <
  //                                                           quotxSelectModels_Select
  //                                                               .length;
  //                                                       index2++)
  //                                                     Container(
  //                                                       decoration:
  //                                                           BoxDecoration(
  //                                                         color:
  //                                                             Colors.green[50],
  //                                                         border: const Border(
  //                                                           bottom: BorderSide(
  //                                                             color: Colors
  //                                                                 .black12,
  //                                                             width: 1,
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       child: ListTile(
  //                                                           title: Row(
  //                                                         mainAxisAlignment:
  //                                                             MainAxisAlignment
  //                                                                 .center,
  //                                                         children: [
  //                                                           Expanded(
  //                                                             flex: 1,
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               maxLines: 2,
  //                                                               minFontSize: 8,
  //                                                               // maxFontSize: 15,
  //                                                               '${quotxSelectModels_Select[index2].unit} / ${quotxSelectModels_Select[index2].term} (งวด)',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                           Expanded(
  //                                                             flex: 1,
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               maxLines: 2,
  //                                                               minFontSize: 8,
  //                                                               // maxFontSize: 15,
  //                                                               '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels_Select[index2].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels_Select[index2].ldate!} 00:00:00'))}',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .start,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                           Expanded(
  //                                                             flex: 1,
  //                                                             child: Tooltip(
  //                                                               richMessage:
  //                                                                   TextSpan(
  //                                                                 text:
  //                                                                     '${quotxSelectModels_Select[index2].expname}',
  //                                                                 style:
  //                                                                     const TextStyle(
  //                                                                   color: HomeScreen_Color
  //                                                                       .Colors_Text1_,
  //                                                                   fontWeight:
  //                                                                       FontWeight
  //                                                                           .bold,
  //                                                                   fontFamily:
  //                                                                       FontWeight_
  //                                                                           .Fonts_T,
  //                                                                   //fontSize: 10.0
  //                                                                 ),
  //                                                               ),
  //                                                               decoration:
  //                                                                   BoxDecoration(
  //                                                                 borderRadius:
  //                                                                     BorderRadius
  //                                                                         .circular(
  //                                                                             5),
  //                                                                 color: Colors
  //                                                                         .grey[
  //                                                                     200],
  //                                                               ),
  //                                                               child:
  //                                                                   AutoSizeText(
  //                                                                 maxLines: 2,
  //                                                                 minFontSize:
  //                                                                     8,
  //                                                                 // maxFontSize: 15,
  //                                                                 '${quotxSelectModels_Select[index2].expname}',
  //                                                                 textAlign:
  //                                                                     TextAlign
  //                                                                         .start,
  //                                                                 style: const TextStyle(
  //                                                                     color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                     //fontWeight: FontWeight.bold,
  //                                                                     fontFamily: Font_.Fonts_T),
  //                                                               ),
  //                                                             ),
  //                                                           ),
  //                                                           Expanded(
  //                                                             flex: 1,
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               maxLines: 2,
  //                                                               minFontSize: 8,
  //                                                               // maxFontSize: 15,
  //                                                               '${nFormat.format(double.parse(quotxSelectModels_Select[index2].total!))}',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                           Expanded(
  //                                                             flex: 1,
  //                                                             child:
  //                                                                 AutoSizeText(
  //                                                               maxLines: 2,
  //                                                               minFontSize: 8,
  //                                                               // maxFontSize: 15,
  //                                                               '${nFormat.format(int.parse(quotxSelectModels_Select[index2].term!) * double.parse(quotxSelectModels_Select[index2].total!))}',
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                                                   //fontWeight: FontWeight.bold,
  //                                                                   fontFamily: Font_.Fonts_T),
  //                                                             ),
  //                                                           ),
  //                                                         ],
  //                                                       )),
  //                                                     )
  //                                                 ],
  //                                               ),
  //                                             );
  //                                     },
  //                                   )),
  //                                 ],
  //                               ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             }),
  //         actions: <Widget>[
  //           const SizedBox(height: 1),
  //           const Divider(),
  //           const SizedBox(height: 1),
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   if (teNantModels.length != 0)
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: InkWell(
  //                         child: Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.blue,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: const Center(
  //                             child: Text(
  //                               'Export file',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontFamily: Font_.Fonts_T,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         onTap: () async {
  //                           setState(() {
  //                             Value_Report = 'รายงานข้อมูลผู้เช่า';
  //                             Pre_and_Dow = 'Download';
  //                           });
  //                           _showMyDialog_SAVE();
  //                         },
  //                       ),
  //                     ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: InkWell(
  //                       child: Container(
  //                         width: 100,
  //                         decoration: const BoxDecoration(
  //                           color: Colors.black,
  //                           borderRadius: BorderRadius.only(
  //                               topLeft: Radius.circular(10),
  //                               topRight: Radius.circular(10),
  //                               bottomLeft: Radius.circular(10),
  //                               bottomRight: Radius.circular(10)),
  //                         ),
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: const Center(
  //                           child: Text(
  //                             'ปิด',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                               fontFamily: Font_.Fonts_T,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       onTap: () async {
  //                         setState(() {
  //                           formKey.currentState?.reset();
  //                           Value_Chang_Zone_People_Ser = null;

  //                           Value_Chang_Zone_People = null;
  //                           Status_pe = null;
  //                           Await_Status_Report1 = null;
  //                           teNantModels.clear();
  //                           contractPhotoModels.clear();
  //                           Ser_Cid_ldate = 0;
  //                           Mon_Cid_ldate = null;
  //                           YE_Cid_ldate = null;
  //                         });
  //                         // check_clear();
  //                         Navigator.of(context).pop();
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

///////////////////////////----------------------------------------------->(รายงานผู้เช่า)
  RE_People_Cancel_Widget() {
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
                      (Value_Chang_Zone_People_Cancel == null)
                          ? 'รายงานผู้เช่า (ยกเลิกสัญญา)'
                          : 'รายงานผู้เช่า (ยกเลิกสัญญา)',
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
                              (Value_Chang_Zone_People_Cancel == null)
                                  ? 'โซน : (กรุณาเลือกโซน)'
                                  : 'โซน : $Value_Chang_Zone_People_Cancel',
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
                              'ทั้งหมด: ${teNantModels_Cancel.length}',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _searchBar_tenantSelect_Cancel(),
                          ),
                        ],
                      ),
                    ),
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
                              : (teNantModels_Cancel.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (teNantModels_Cancel.length == 0)
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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: const Text(
                                              'เลขที่สัญญา/เสนอราคา',
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
                                            child: const Text(
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
                                            child: const Text(
                                              'ชื่อร้านค้า',
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
                                            child: const Text(
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
                                            child: const Text(
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
                                            child: const Text(
                                              'ขนาดพื้นที่(ต.ร.ม.)',
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
                                            child: const Text(
                                              'ประเภท',
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
                                            child: const Text(
                                              'วันที่ยกเลิก/ทำรายการ',
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
                                            child: const Text(
                                              'เหตุผล',
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
                                            child: const Text(
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
                                      itemCount: teNantModels_Cancel.length,
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
                                                      text: teNantModels_Cancel[
                                                                      index]
                                                                  .docno ==
                                                              null
                                                          ? teNantModels_Cancel[
                                                                          index]
                                                                      .cid ==
                                                                  null
                                                              ? ''
                                                              : '${teNantModels_Cancel[index].cid}'
                                                          : '${teNantModels_Cancel[index].docno}',
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
                                                      teNantModels_Cancel[index]
                                                                  .docno ==
                                                              null
                                                          ? teNantModels_Cancel[
                                                                          index]
                                                                      .cid ==
                                                                  null
                                                              ? ''
                                                              : '${teNantModels_Cancel[index].cid}'
                                                          : '${teNantModels_Cancel[index].docno}',
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
                                                    teNantModels_Cancel[index]
                                                                .cname ==
                                                            null
                                                        ? teNantModels_Cancel[
                                                                        index]
                                                                    .cname_q ==
                                                                null
                                                            ? ''
                                                            : '${teNantModels_Cancel[index].cname_q}'
                                                        : '${teNantModels_Cancel[index].cname}',
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
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text: teNantModels_Cancel[
                                                                      index]
                                                                  .sname ==
                                                              null
                                                          ? teNantModels_Cancel[
                                                                          index]
                                                                      .sname_q ==
                                                                  null
                                                              ? ''
                                                              : '${teNantModels_Cancel[index].sname_q}'
                                                          : '${teNantModels_Cancel[index].sname}',
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
                                                      teNantModels_Cancel[index]
                                                                  .sname ==
                                                              null
                                                          ? teNantModels_Cancel[
                                                                          index]
                                                                      .sname_q ==
                                                                  null
                                                              ? ''
                                                              : '${teNantModels_Cancel[index].sname_q}'
                                                          : '${teNantModels_Cancel[index].sname}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels_Cancel[index].zn}',
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
                                                    text:
                                                        '${teNantModels_Cancel[index].ln}',
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
                                                    '${teNantModels_Cancel[index].ln}',
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
                                                  '${teNantModels_Cancel[index].qty}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels_Cancel[index].rtname}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  (teNantModels_Cancel[index]
                                                                  .cc_date ==
                                                              null ||
                                                          teNantModels_Cancel[
                                                                      index]
                                                                  .cc_date
                                                                  .toString() ==
                                                              '')
                                                      ? '${teNantModels_Cancel[index].cc_date}'
                                                      : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_Cancel[index].cc_date} 00:00:00'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${teNantModels_Cancel[index].cc_date} 00:00:00'))}') + 543}',
                                                  //'${teNantModels_Cancel[index].cc_date}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels_Cancel[index].cc_remark}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels_Cancel[index].st}',
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
                    if (teNantModels_Cancel.length != 0)
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
                              Value_Report = 'รายงานข้อมูลผู้เช่า(ยกเลิกสัญญา)';
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
                            Value_Chang_Zone_People_Ser_Cancel = null;

                            Value_Chang_Zone_People_Cancel = null;

                            Await_Status_Report2 = null;
                            teNantModels_Cancel.clear();
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

///////////////////////////----------------------------------------------->(รายงานประวัติบิล)
  RE_HistoryBills_Widget() {
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
                      (Value_Chang_Zone_historybill == null)
                          ? 'รายงานประวัติบิล (กรุณาเลือกโซน)'
                          : 'รายงานประวัติบิล (โซน : $Value_Chang_Zone_historybill) ',
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
                              'วันที่รับชำระ : ${Value_selectDate_Historybills}',
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
                              'ทั้งหมด: ${_TransReBillModels.length}',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _searchBar_Trans_bill(),
                          ),
                        ],
                      ),
                    ),
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
                              : (_TransReBillModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (_TransReBillModels.length == 0)
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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่สัญญา',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                'วันที่ทำรายการ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'วันที่รับชำระ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่ใบเสร็จ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่ใบวางบิล',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                'โซน',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'รหัสพื้นที่',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ชื่อร้านค้า',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'จำนวนเงิน',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'กำหนดชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'รูปแบบชำระ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ทำรายการ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ประเภท',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                      itemCount: _TransReBillModels.length,
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
                                                      text: (_TransReBillModels[
                                                                      index]
                                                                  .cid ==
                                                              null)
                                                          ? ''
                                                          : '${_TransReBillModels[index].cid}',
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
                                                      (_TransReBillModels[index]
                                                                      .cid ==
                                                                  null ||
                                                              _TransReBillModels[
                                                                          index]
                                                                      .cid
                                                                      .toString() ==
                                                                  'null')
                                                          ? ''
                                                          : '${_TransReBillModels[index].cid}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
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
                                                    richMessage: const TextSpan(
                                                      text: '',
                                                      style: TextStyle(
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
                                                      (_TransReBillModels[index]
                                                                  .daterec ==
                                                              null)
                                                          ? ''
                                                          : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].daterec}'))}') + 543}',
                                                      // '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00').year + 543}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels[index]
                                                                .pdate ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}') + 543}',
                                                    // '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels[
                                                                    index]
                                                                .doctax ==
                                                            ''
                                                        ? '${_TransReBillModels[index].docno}'
                                                        : '${_TransReBillModels[index].doctax}',
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
                                                    _TransReBillModels[index]
                                                                .doctax ==
                                                            ''
                                                        ? '${_TransReBillModels[index].docno}'
                                                        : '${_TransReBillModels[index].doctax}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
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
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${_TransReBillModels[index].inv}',
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
                                                      '${_TransReBillModels[index].inv}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels[
                                                                    index]
                                                                .zn ==
                                                            null
                                                        ? '${_TransReBillModels[index].znn}'
                                                        : '${_TransReBillModels[index].zn}',
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
                                                    _TransReBillModels[index]
                                                                .zn ==
                                                            null
                                                        ? '${_TransReBillModels[index].znn}'
                                                        : '${_TransReBillModels[index].zn}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels[
                                                                    index]
                                                                .ln ==
                                                            null
                                                        ? '${_TransReBillModels[index].room_number}'
                                                        : '${_TransReBillModels[index].ln}',
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
                                                    _TransReBillModels[index]
                                                                .ln ==
                                                            null
                                                        ? '${_TransReBillModels[index].room_number}'
                                                        : '${_TransReBillModels[index].ln}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels[
                                                                    index]
                                                                .sname ==
                                                            null
                                                        ? '${_TransReBillModels[index].remark}'
                                                        : '${_TransReBillModels[index].sname}',
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
                                                    _TransReBillModels[index]
                                                                .sname ==
                                                            null
                                                        ? '${_TransReBillModels[index].remark}'
                                                        : '${_TransReBillModels[index].sname}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    _TransReBillModels[index]
                                                                .total_dis ==
                                                            null
                                                        ? (_TransReBillModels[
                                                                        index]
                                                                    .total_bill ==
                                                                null)
                                                            ? ''
                                                            : '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                                                        : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels[index]
                                                                .date ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].date}'))}') + 543}',
                                                    //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}- ${int.parse(DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))) + 543} }',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    _TransReBillModels[index]
                                                                .type ==
                                                            ''
                                                        ? ''
                                                        : '${_TransReBillModels[index].type}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    _TransReBillModels[index]
                                                                .shopno ==
                                                            '1'
                                                        ? 'ผ่านระบบผู้เช่า'
                                                        : 'ผ่านระบบแอดมิน',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    _TransReBillModels[index]
                                                                .doctax ==
                                                            ''
                                                        ? ''
                                                        : 'ใบกำกับภาษี',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels[index]
                                                                    .room_number
                                                                    .toString() ==
                                                                '' ||
                                                            _TransReBillModels[
                                                                        index]
                                                                    .room_number ==
                                                                null)
                                                        ? ''
                                                        : 'ล็อคเสียบ',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
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
                    if (_TransReBillModels.length != 0)
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
                              Value_Report = 'รายงานประวัติบิล';
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
                            TransReBillModels_.clear();
                            _TransReBillModels.clear();
                            _TransReBillModels_cancel.clear();
                            Await_Status_Report2 = null;
                            Value_selectDate_Historybills = null;
                            Value_Chang_Zone_historybill = null;
                            Value_Chang_Zone_historybill_Ser = null;
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

///////////////////////////----------------------------------------------->(รายงานประวัติบิล(ยกเลิก))
  RE_HistoryBills_Cancel_Widget() {
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
                      (Value_Chang_Zone_historybill == null)
                          ? 'รายงานประวัติบิล(ยกเลิก) (กรุณาเลือกโซน)'
                          : 'รายงานประวัติบิล(ยกเลิก) (โซน : $Value_Chang_Zone_historybill) ',
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
                              'วันที่รับชำระ : ${Value_selectDate_Historybills}',
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
                              'ทั้งหมด: ${_TransReBillModels_cancel.length}',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _searchBar_Trans_billCancel(),
                          ),
                        ],
                      ),
                    ),
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
                              ? MediaQuery.of(context).size.width * 0.95
                              : (_TransReBillModels_cancel.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1200,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (_TransReBillModels_cancel.length == 0)
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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่สัญญา',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                'วันที่ทำรายการ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'วันที่รับชำระ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่ใบเสร็จ',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เลขที่ใบวางบิล',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                'โซน',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'รหัสพื้นที่',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ชื่อร้านค้า',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'จำนวนเงิน',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'กำหนดชำระ',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'เหตุผล',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'รูปแบบชำระ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ทำรายการ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'ประเภท',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AccountScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
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
                                      itemCount:
                                          _TransReBillModels_cancel.length,
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
                                                      text: (_TransReBillModels_cancel[
                                                                      index]
                                                                  .cid ==
                                                              null)
                                                          ? ''
                                                          : '${_TransReBillModels_cancel[index].cid}',
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
                                                      (_TransReBillModels_cancel[
                                                                          index]
                                                                      .cid ==
                                                                  null ||
                                                              _TransReBillModels_cancel[
                                                                          index]
                                                                      .cid
                                                                      .toString() ==
                                                                  'null')
                                                          ? ''
                                                          : '${_TransReBillModels_cancel[index].cid}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
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
                                                    richMessage: const TextSpan(
                                                      text: '',
                                                      style: TextStyle(
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
                                                      (_TransReBillModels_cancel[
                                                                      index]
                                                                  .daterec ==
                                                              null)
                                                          ? ''
                                                          : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_cancel[index].daterec}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_cancel[index].daterec}'))}') + 543}',
                                                      // '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00').year + 543}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels_cancel[
                                                                    index]
                                                                .pdate ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_cancel[index].pdate} 00:00:00'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_cancel[index].pdate} 00:00:00'))}') + 543}',
                                                    // '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels_cancel[
                                                                    index]
                                                                .doctax ==
                                                            ''
                                                        ? '${_TransReBillModels_cancel[index].docno}'
                                                        : '${_TransReBillModels_cancel[index].doctax}',
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
                                                    _TransReBillModels_cancel[
                                                                    index]
                                                                .doctax ==
                                                            ''
                                                        ? '${_TransReBillModels_cancel[index].docno}'
                                                        : '${_TransReBillModels_cancel[index].doctax}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
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
                                                  child: Tooltip(
                                                    richMessage: TextSpan(
                                                      text:
                                                          '${_TransReBillModels_cancel[index].inv}',
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
                                                      '${_TransReBillModels_cancel[index].inv}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels_cancel[
                                                                    index]
                                                                .zn ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].room_number}'
                                                        : '${_TransReBillModels_cancel[index].zn}',
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
                                                    _TransReBillModels_cancel[
                                                                    index]
                                                                .zn ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].room_number}'
                                                        : '${_TransReBillModels_cancel[index].zn}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels_cancel[
                                                                    index]
                                                                .ln ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].room_number}'
                                                        : '${_TransReBillModels_cancel[index].ln}',
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
                                                    _TransReBillModels_cancel[
                                                                    index]
                                                                .ln ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].room_number}'
                                                        : '${_TransReBillModels_cancel[index].ln}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text: _TransReBillModels_cancel[
                                                                    index]
                                                                .sname ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].remark}'
                                                        : '${_TransReBillModels_cancel[index].sname}',
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
                                                    _TransReBillModels_cancel[
                                                                    index]
                                                                .sname ==
                                                            null
                                                        ? '${_TransReBillModels_cancel[index].remark}'
                                                        : '${_TransReBillModels_cancel[index].sname}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    _TransReBillModels_cancel[
                                                                    index]
                                                                .total_dis ==
                                                            null
                                                        ? (_TransReBillModels_cancel[
                                                                        index]
                                                                    .total_bill ==
                                                                null)
                                                            ? ''
                                                            : '${nFormat.format(double.parse(_TransReBillModels_cancel[index].total_bill!))}'
                                                        : '${nFormat.format(double.parse(_TransReBillModels_cancel[index].total_dis!))}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels_cancel[
                                                                    index]
                                                                .date ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels_cancel[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels_cancel[index].date}'))}') + 543}',
                                                    //'${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}- ${int.parse(DateFormat('yyyy').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))) + 543} }',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    'ยกเลิก',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: TextSpan(
                                                    text:
                                                        '${_TransReBillModels_cancel[index].remark}',
                                                    style: TextStyle(
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
                                                    '${_TransReBillModels_cancel[index].remark}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels_cancel[
                                                                    index]
                                                                .type ==
                                                            '')
                                                        ? ' '
                                                        : '${_TransReBillModels_cancel[index].type}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels_cancel[
                                                                    index]
                                                                .shopno ==
                                                            '1')
                                                        ? 'ผ่านระบบผู้เช่า'
                                                        : 'ผ่านระบบแอดมิน',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Tooltip(
                                                  richMessage: const TextSpan(
                                                    text: '',
                                                    style: TextStyle(
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
                                                    (_TransReBillModels_cancel[
                                                                        index]
                                                                    .room_number
                                                                    .toString() ==
                                                                '' ||
                                                            _TransReBillModels_cancel[
                                                                        index]
                                                                    .room_number ==
                                                                null)
                                                        ? ''
                                                        : 'ล็อคเสียบ',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
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
                    if (_TransReBillModels_cancel.length != 0)
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
                              Value_Report = 'รายงานประวัติบิล(ยกเลิก)';
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
                            TransReBillModels_.clear();
                            _TransReBillModels.clear();
                            _TransReBillModels_cancel.clear();
                            Value_selectDate_Historybills = null;
                            Value_Chang_Zone_historybill = null;
                            Value_Chang_Zone_historybill_Ser = null;
                            Await_Status_Report3 = null;
                            Mon_People_Cancel = null;
                            YE_People_Cancel = null;
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

  ///////////////////////////----------------------------------------------->(รายงาน  Befor Invoice)
  Befor_Invoice_Widget() {
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
                (zone_name_Invoice_Befor == null)
                    ? 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิลรายเดือน (กรุณาเลือกโซน)'
                    : 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิลรายเดือน (โซน : $zone_name_Invoice_Befor) ',
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
                        (Befor_Mon_Invoice == null && Befor_YE_Invoice == null)
                            ? 'เดือน : ? (?) '
                            : (Befor_Mon_Invoice == null)
                                ? 'เดือน : ? ($Befor_YE_Invoice) '
                                : (Befor_YE_Invoice == null)
                                    ? 'เดือน : $Befor_Mon_Invoice (?) '
                                    : 'เดือน : $Befor_Mon_Invoice($Befor_YE_Invoice) ',
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
                        'ทั้งหมด: ${_TransModels.length}',
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
                              ? MediaQuery.of(context).size.width * 0.95
                              : (_TransModels.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1300,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (_TransModels.length == 0)
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
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ลำดับ',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'เลขที่สัญญา',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'โซนพื้นที่',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'รหัสพื้นที่',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ชื่อร้านค้า',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ชื่อผู้เช่า',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'เดือน/ปี',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Translate
                                          //       .TranslateAndSetText(
                                          //           'ปี',
                                          //           AccountScreen_Color
                                          //               .Colors_Text2_,
                                          //           TextAlign.left,
                                          //           FontWeight.bold,
                                          //           FontWeight_.Fonts_T,
                                          //           14,
                                          //           1),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'Qty/รายการ',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
                                                    TextAlign.end,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ยอดรวม',
                                                    AccountScreen_Color
                                                        .Colors_Text2_,
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
                                        // height: (Responsive.isDesktop(context))
                                        //     ? MediaQuery.of(context).size.width * 0.255
                                        //     : MediaQuery.of(context).size.height * 0.45,
                                        child: ListView.builder(
                                      itemCount: _TransModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Material(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          //  (show_more == index)
                                          //     ? tappedIndex_Color
                                          //         .tappedIndex_Colors
                                          //         .withOpacity(0.5)
                                          //     : AppbackgroundColor
                                          //         .Sub_Abg_Colors,
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
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${index + 1}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    '${_TransModels[index].refno}',
                                                    textAlign: TextAlign.left,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    '${_TransModels[index].zn}',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    '${_TransModels[index].ln}',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    '${_TransModels[index].sname}',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    '${_TransModels[index].cname}',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    (_TransModels[index].date ==
                                                            null)
                                                        ? '-'
                                                        : DateFormat(
                                                                    'MMM', 'th')
                                                                .format(DateTime.parse(
                                                                    _TransModels[
                                                                            index]
                                                                        .date!))
                                                                .toString() +
                                                            '' +
                                                            DateFormat.y(
                                                                    'th_TH')
                                                                .format(DateTime
                                                                    .parse(
                                                                        '${_TransModels[index].date} 00:00:00'))
                                                                .toString(),
                                                    textAlign: TextAlign.left,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child:
                                                //       Text((_TransModels[index].date == null)
                                                //         ? '-'
                                                //         :
                                                //     DateFormat.y('th_TH')
                                                //         .format(DateTime.parse('${_TransModels[index].date} 00:00:00'))
                                                //         .toString(),
                                                //     textAlign:
                                                //         TextAlign.left,
                                                //     maxLines:
                                                //         1,
                                                //     style:
                                                //         const TextStyle( fontSize:
                                                //           14,
                                                //       color:
                                                //           AccountScreen_Color.Colors_Text2_,
                                                //       // fontWeight:
                                                //       //     FontWeight.bold,
                                                //       fontFamily:
                                                //           Font_.Fonts_T,
                                                //     ),
                                                //   ),
                                                // ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (_TransModels[index]
                                                                .count_ser ==
                                                            null)
                                                        ? '0 รายการ'
                                                        : '${_TransModels[index].count_ser} รายการ',
                                                    textAlign: TextAlign.end,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                                                    (_TransModels[index]
                                                                .c_amt ==
                                                            null)
                                                        ? '0.00'
                                                        : '${nFormat.format(double.parse(_TransModels[index].c_amt!))}',
                                                    textAlign: TextAlign.end,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AccountScreen_Color
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
                    if (_TransModels.length != 0)
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
                              Value_Report = 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล';
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
                            zone_ser_Invoice_Befor = null;
                            zone_name_Invoice_Befor = null;
                            Befor_YE_Invoice = null;
                            Befor_Mon_Invoice = null;

                            _TransModels.clear();
                            // Ser_BodySta1 = 0;
                            // Ser_BodySta2 = 0;
                            // YE_Invoice_Mon = null;
                            // Mon_Invoice_Mon = null;
                            // zone_ser_Invoice_Daily = null;
                            // zone_name_Invoice_Daily = null;
                            // zone_ser_Invoice_Mon = null;
                            // zone_name_Invoice_Mon = null;
                            // Value_InvoiceDate_Daily = null;
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
        if (Value_Report == 'รายงานข้อมูลผู้เช่า') {
          Excgen_PeopleChoReport.exportExcel_PeopleChoReport(
              expModels.where((element) => element.st! == '1').toList(),
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              Value_Chang_Zone_People,
              (Status_pe == null) ? 'ปัจจุบัน' : Status_pe,
              teNantModels,
              open_set_date);
        } else if (Value_Report == 'รายงานข้อมูลผู้เช่า(ยกเลิกสัญญา)') {
          Excgen_PeopleCho_Cancel_Report.exportExcel_PeopleCho_Cancel_Report(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              Value_Chang_Zone_People_Cancel,
              teNantModels_Cancel,
              contractPhotoModels);
        } else if (Value_Report == 'รายงานประวัติบิล') {
          Excgen_HistorybillsReport.exportExcel_HistorybillsReport(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              _TransReBillModels,
              Value_selectDate_Historybills,
              Value_Chang_Zone_historybill);
        } else if (Value_Report == 'รายงานประวัติบิล(ยกเลิก)') {
          Excgen_Historybills_Cancel_Report
              .exportExcel_Historybills_Cancel_Report(
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  renTal_name,
                  _TransReBillModels_cancel,
                  Value_selectDate_Historybills,
                  Value_Chang_Zone_historybill);
        } else if (Value_Report == 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล') {
          Excel_BeforInvoice_Report.exportExcel_BeforInvoiceReport(
              context,
              NameFile_,
              _verticalGroupValue_NameFile,
              renTal_name,
              zone_name_Invoice_Befor,
              _TransModels,
              Befor_Mon_Invoice,
              Befor_YE_Invoice);
        }

        Navigator.of(context).pop();
      }
    }
  }

  ///------------------------------------------------->
}
