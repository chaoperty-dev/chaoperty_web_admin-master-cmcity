import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
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
import '../Model/GetExp_Model.dart';
import '../Model/GetInvoiceRe_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNantRenew_Choice_Model.dart';
import '../Model/GetTeNant_ChoiceModel.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Model/Getexp_sz_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Report/Excel_BankDaily_Report.dart';
import '../Report/Excel_Bankmovemen_Report.dart';
import '../Report/Excel_Daily_Report.dart';
import '../Report/Excel_Income_Report.dart';
import '../Report/Excel_teNantnoti.dart';
import '../Report/Report_Mini/MIni_Ex_BankDaily_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Bankmovemen_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Daily_Re.dart';
import '../Report/Report_Mini/MIni_Ex_Income_Re.dart';
import '../Report_Ortorkor/Excel_invoiceOrtor_Report.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Excel_BeforInvoice_Report.dart';
import 'Excel_invoiceChoice_Report.dart';
import 'Excel_teNantDate_Choice.dart';
import 'Excel_teNantnoti_Choice.dart';
import 'Excel_transMeterChoice_Report.dart';
import 'Report_Mini/Mini_Ex_invoiceChoice_Report.dart';

class Report_Choice_ScreenD extends StatefulWidget {
  const Report_Choice_ScreenD({super.key});

  @override
  State<Report_Choice_ScreenD> createState() => _Report_Choice_ScreenDState();
}

class _Report_Choice_ScreenDState extends State<Report_Choice_ScreenD> {
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
  String? Status_pe_History = 'สัญญาปัจจุบัน', Status_pe_ser_History = '1';
  String? Status_Datex_History = 'วันที่เริ่มสัญญา',
      Status_Datex_ser_History = '1';
  final _formKey = GlobalKey<FormState>();
  final FormNameFile_text = TextEditingController();
  String? Type_search;
  int Status_ = 1, open_set_date = 30;
  double Text_Size = 13.00;

  ///------------------------>
  int? Await_Status_Report1,
      Await_Status_Report2,
      Await_Status_Report3,
      Await_Status_Report4,
      Await_Status_Report5,
      Await_Status_Report6;
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<InvoiceReModel> InvoiceModels = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];
  List<TransReBillModel> TransReBillModels_ = [];
  List<TransReBillHistoryModel> TranHisBillModels = [];
  List<PayMentModel> payMentModels = [];
  List<ExpModel> expModels = [];
  List<ExpModel> expModels_Mini = [];
  List<TeNantChoiceModel> teNantModels_noti = [];
  ///////////--------------------------------------------->
  List<TeNantChoiceModel> teNantModels_New = [];
  List<TeNantChoiceModel> _teNantModels_New = <TeNantChoiceModel>[];

  ///////////////--------------------------------------> Renew_contract
  List<TeNantRenewChoiceModel> teNantModels_Renew = [];
  List<TeNantRenewChoiceModel> _teNantModels_Renew = <TeNantRenewChoiceModel>[];
  ///////////---------------------------------------------> 107,000.41

  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  ///////////--------------------------------------------->
  List<ExpSZModel> expSZModels = [];
  List<TransMeterModel> transMeterModels = [];
  List<TransMeterModel> _transMeterModels = <TransMeterModel>[];

  ///////////--------------------------------------------->
  List<String> YE_Th_noti = [];
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
  String? zone_ser_Invoice_Befor, zone_name_Invoice_Befor;
  String? Befor_YE_Invoice, Befor_Mon_Invoice;

  ///------>
  String? zone_ser_BillAwatCheck_Daily, zone_name_BillAwatCheck_Daily;
  String? zone_ser_BillAwatCheck_Mon, zone_name_BillAwatCheck_Mon;
  String? YE_BillAwatCheck_Mon, Mon_BillAwatCheck_Mon;
  ////////--------------------------------------------->
  String? zone_ser_Pe_Mon, zone_name_Pe_Mon;
  String? YE_Pe_Mon, Mon_Pe_Mon;
  ////////--------------------------------------------->
  String? zone_ser_Cannotice_Mon, zone_name_Cannotice_Mon;
  String? YE_Cannotice_Mon, Mon_Cannotice_Mon;

  String? Mon_transMeter_Mon, YE_transMeter_Mon;
  String? expSZ_name, expSZ_ser;
  String? zone_ser_transMeter,
      zone_name_transMeter,
      Status_transMeter_,
      Status_transMeter_ser;
  ////////--------------------------------------------->
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
  List Status = [
    'ทั้งหมด',
    'สัญญาปัจจุบัน',
    'ยกเลิกสัญญา',
    'ใกล้หมดสัญญา',
  ];
  List Status_Datex = [
    'วันที่เริ่มสัญญา',
    'วันที่หมดสัญญา',
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
    checkPreferance();
    read_GC_rental();
    read_GC_zone();
    read_GC_Exp();
    read_GC_PayMentModel();
    red_exp_sz();
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
      // //print('result $ciddoc');
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

///////------------------------------------------------------------------>
  Future<Null> read_GC_PayMentModel() async {
    if (payMentModels.length != 0) {
      payMentModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    // //print('ren >>>>>> $ren');

    String url =
        '${MyConstant().domain}/GC_Bank_Paytype.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
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
    int currentYearnoti = DateTime.now().year + 1;
    for (int i = currentYear; i >= currentYear - 11; i--) {
      YE_Th.add(i.toString());
    }
    for (int i = currentYearnoti; i >= currentYear - 11; i--) {
      YE_Th_noti.add(i.toString());
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
            open_set_date = int.parse(renTalModel.open_set_date!);
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
  System_New_Update() async {
    // String accept_ = showst_update_!;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Text(
          '📢ขออภัย !!!! ',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontFamily: Font_.Fonts_T,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("images/pngegg.png"),
              // fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
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

////////--------------------------------------------------------------->

  // Future<Null> red_InvoiceMon_bill() async {
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
  //       ? '${MyConstant().domain}/GC_bill_invoiceMonChoice_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Mon&_monts=$Mon_Invoice_Mon&yex=$YE_Invoice_Mon'
  //       : '${MyConstant().domain}/GC_bill_invoiceMonChoice_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Mon&_monts=$Mon_Invoice_Mon&yex=$YE_Invoice_Mon';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // //print('result $ciddoc');
  //     if (result.toString() != 'null') {
  //       setState(() {
  //         Await_Status_Report1 = 1;
  //       });
  //       for (var map in result) {
  //         InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
  //         setState(() {
  //           InvoiceModels.add(transMeterModel);
  //         });
  //       }
  //     }

  //     Future.delayed(Duration(milliseconds: 700), () async {
  //       setState(() {
  //         _InvoiceModels = InvoiceModels;
  //         Await_Status_Report1 = null;
  //       });
  //     });
  //   } catch (e) {
  //     //print(e);
  //   }
  // }

////////--------------------------------------------------------------->

  List<TransModel> _TransModels = [];
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

    // //print('zone_ser >> $zone_ser $zone');

    String url =
        '${MyConstant().domain}/GC_InvoiceBefor_Report.php?isAdd=true&ren=$ren&serMONTH=$serMONTH&serYEAR=$serYEAR&zone_ser=$zone_ser_Invoice_Befor';
    // //print('read_Trans_invoice_all   $url');

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
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

  Future<Null> red_InvoiceMonFull_bill() async {
    String Serdata =
        (zone_ser_Invoice_Mon.toString() == '0' || zone_ser_Invoice_Mon == null)
            ? 'All'
            : 'Allzone';
    setState(() {
      InvoiceModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = (Serdata.toString() == 'All')
        ? '${MyConstant().domain}/GC_bill_invoiceMonFullChoice_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Mon&sdate=$Mon_Invoice_Mon&ldate=$YE_Invoice_Mon'
        : '${MyConstant().domain}/GC_bill_invoiceMonFullChoice_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone_ser_Invoice_Mon&sdate=$Mon_Invoice_Mon&ldate=$YE_Invoice_Mon';
    ////print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result $ciddoc');
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

      Future.delayed(Duration(milliseconds: 700), () async {
        setState(() {
          _InvoiceModels = InvoiceModels;
          // Await_Status_Report1 = null;
        });
      });
    } catch (e) {
      //print(e);
    }
  }

//////////---------------------------------------->Value_teNantDate_Daily
  Future<Null> red_InvoiceDaily_bills() async {
    // String? zone_ser_Invoice_Daily, zone_name_Invoice_Daily;
    // String? zone_ser_Invoice_Mon, zone_name_Invoice_Mon;
    // String? YE_Invoice_Mon, Mon_Invoice_Mon;
    // var Value_InvoiceDate_Daily;
    String Serdata2 = (zone_ser_Invoice_Daily.toString() == '0' ||
            zone_ser_Invoice_Daily == null)
        ? 'All'
        : 'Allzone';
    setState(() {
      InvoiceModels.clear();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = (Serdata2.toString() == 'All')
        ? '${MyConstant().domain}/GC_bill_invoiceDaily_historyChoiceReport.php?isAdd=true&ren=$ren&Serdata=$Serdata2&serzone=$zone_ser_Invoice_Daily&datex=$Value_InvoiceDate_Daily'
        : '${MyConstant().domain}/GC_bill_invoiceDaily_historyChoiceReport.php?isAdd=true&ren=$ren&Serdata=$Serdata2&serzone=$zone_ser_Invoice_Daily&datex=$Value_InvoiceDate_Daily';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result $ciddoc');
      if (result.toString() != 'null') {
        setState(() {
          Await_Status_Report2 = 1;
        });
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceModels.add(transMeterModel);
          });
        }
      }

      Future.delayed(Duration(milliseconds: 700), () async {
        setState(() {
          _InvoiceModels = InvoiceModels;
          Await_Status_Report1 = null;
        });
      });
    } catch (e) {
      //print(e);
    }
  }

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า(ยกเลิกสัญญา))GC_tenant_CanceNoticeAll
  Future<Null> read_GC_tenant_Cancel() async {
    if (teNantModels_noti.isNotEmpty) {
      teNantModels_noti.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Cannotice_Mon == null ||
            zone_ser_Cannotice_Mon.toString() == '')
        ? '0'
        : '$zone_ser_Cannotice_Mon';

    // //print('zone>>>>>>zone>>>>>$zone');

    String url = zone == null || zone == '0'
        ? '${MyConstant().domain}/GC_tenant_CanceNoticeAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=0&mont_h=$Mon_Cannotice_Mon&yea_r=$YE_Cannotice_Mon'
        : '${MyConstant().domain}/GC_tenant_CanceNoticeAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=$zone&mont_h=$Mon_Cannotice_Mon&yea_r=$YE_Cannotice_Mon';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantChoiceModel teNantModelsCancel =
              TeNantChoiceModel.fromJson(map);
          setState(() {
            teNantModels_noti.add(teNantModelsCancel);
          });
        }
      } else {}
      // setState(() {
      //   Await_Status_Report2 = 1;
      // });
      // //print('teNantModels///result ${teNantModels_noti.length}');
    } catch (e) {}
  }

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า)
  Future<Null> read_GC_tenant() async {
    if (teNantModels.isNotEmpty) {
      teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Pe_Mon == null || zone_ser_Pe_Mon.toString() == '')
        ? '0'
        : '$zone_ser_Pe_Mon';

    // //print('zone>>>>>>zone>>>>>$zone');
//  String? Status_pe_History = 'สัญญาปัจจุบัน', Status_pe_ser_History = '1';
//   String? Status_Datex_History = 'วันที่เริ่มสัญญา',
//       Status_Datex_ser_History = '0';
    String url = zone == null || zone == '0'
        ? '${MyConstant().domain}/GC_tenantExdAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=0&mont_h=$Mon_Pe_Mon&yea_r=$YE_Pe_Mon&tyespe=$Status_pe_ser_History&tyesdate=$Status_Datex_ser_History'
        : '${MyConstant().domain}/GC_tenantExdAll_ChoiceReport.php?isAdd=true&ren=$ren&zone=$zone&mont_h=$Mon_Pe_Mon&yea_r=$YE_Pe_Mon&tyespe=$Status_pe_ser_History&tyesdate=$Status_Datex_ser_History';
    //print(url);
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
      // setState(() {
      //   Await_Status_Report2 = 1;
      // });
      // //print('teNantModels///result ${teNantModels_noti.length}');
    } catch (e) {}
  }

  ////////-------------------------------------------------------->(รายงานผู้เช่ารายใหม่)
  Future<Null> People_tenant_New() async {
    if (teNantModels_New.isNotEmpty) {
      teNantModels_New.clear();
      _teNantModels_New.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Pe_Mon == null || zone_ser_Pe_Mon.toString() == '')
        ? '0'
        : '$zone_ser_Pe_Mon';

    try {
      String url =
          '${MyConstant().domain}/GC_People_TenantNew_AllReport_Choice.php?isAdd=true&ren=$ren';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'zser': '$zone',
          'month_s': '$Mon_Pe_Mon',
          'year_s': '$YE_Pe_Mon',
          'month_p': '$Mon_Pe_Mon',
          'year_p': '$YE_Pe_Mon',
          'type_date': '0',
          'type_cid': '0',
          'type_pay': '0',
        },
      );

      var result = json.decode(response.body);

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
      //print('Error during image processing: $e');
    }
  }

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า(ต่อสัญญา))
  Future<Null> read_GC_tenant_Renew() async {
    if (teNantModels_Renew.isNotEmpty) {
      teNantModels_Renew.clear();
      _teNantModels_Renew.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = (zone_ser_Pe_Mon == null || zone_ser_Pe_Mon.toString() == '')
        ? '0'
        : '$zone_ser_Pe_Mon';

    // //print('zone>>>>>>zone>>>>>$zone');
    String url =
        '${MyConstant().domain}/GC_tenant_Renew_AllReport_Choice.php?isAdd=true&ren=$ren&zser=$zone&month_s=$Mon_Pe_Mon&year_s=$YE_Pe_Mon&type_date=0';
    // //print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantRenewChoiceModel teNantModels_Renewss =
              TeNantRenewChoiceModel.fromJson(map);
          setState(() {
            teNantModels_Renew.add(teNantModels_Renewss);
          });
        }
      } else {}

      setState(() {
        _teNantModels_Renew = teNantModels_Renew;
      });
    } catch (e) {}
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

        var formatter = DateFormat('y-MM-d');
        print("${formatter.format(result!)}");
        setState(() {
          Value_InvoiceDate_Daily = "${formatter.format(result)}";
        });
        //print("${Value_InvoiceDate_Daily}");
        // if (Value_Chang_Zone_Daily != null) {
        //   red_Trans_bill();
        //   red_Trans_billDailyBank();
        // }

        // red_Trans_bill_Groptype_daly();
      }
    });
  }

  ////////////------------------------------------------>
  Future<Null> red_Trans_bill() async {
    setState(() {
      transMeterModels.clear();
      // teNantModels.clear();
      Await_Status_Report4 = null;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var expSZ_ser_ = (expSZ_ser == null || expSZ_ser == '') ? 0 : expSZ_ser;

    String url = (expSZ_ser_.toString() == '0')
        ? '${MyConstant().domain}/GC_trans_mitterChoice_ReportNew.php?isAdd=true&ren=$ren&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon&sertype=0'
        : '${MyConstant().domain}/GC_trans_mitterZoneChoice_ReportNew.php?isAdd=true&ren=$ren&serzone=$zone_ser_transMeter&monx=$Mon_transMeter_Mon&yex=$YE_transMeter_Mon&sertype=$expSZ_ser_';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('result $url');
      if (result.toString() != 'null') {
        setState(() {
          Await_Status_Report4 = 1;
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
          Await_Status_Report4 = null;
        });
        // //print('mitter : ${transMeterModels.length}');
      });
    } catch (e) {}
  }

  ////////////------------------------------------------>
  String _selectedDate = '';
  var Value_InvDate_Daily;
  var Value_InvDate_Daily_S, Value_InvDate_Daily_L;
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
                controller: (type == 1) ? null : _controller,
                allowViewNavigation: (type == 1) ? true : false,
                startRangeSelectionColor: Colors.purple,
                endRangeSelectionColor: Colors.deepPurple,
                rangeSelectionColor: Colors.green[100],
                view: (type == 1)
                    ? DateRangePickerView.month
                    : DateRangePickerView.year,
                // monthViewSettings:
                //     DateRangePickerMonthViewSettings(viewHeaderHeight: 100),
                selectionMode: (type == 1)
                    ? DateRangePickerSelectionMode.range
                    : DateRangePickerSelectionMode.single,
                enableMultiView: false,
                toggleDaySelection: (type == 1) ? true : false,
                // showTodayButton: true,
                onSelectionChanged: (type == 1)
                    ? selectionChanged
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
      //print('Selected month: ${Befor_Mon_Invoice}, Year: ${Befor_YE_Invoice}');
    }
  }

  void selectionChanged_month3(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      // (Mon_Pe_Mon == null || YE_Pe_Mon == '')
      setState(() {
        Mon_Pe_Mon = DateFormat('MM').format(selectedDate);
        YE_Pe_Mon = DateFormat('yyyy').format(selectedDate);
      });
      //print('Selected month: ${Mon_Pe_Mon}, Year: ${YE_Pe_Mon}');
    }
  }

  void selectionChanged_month4(DateRangePickerSelectionChangedArgs args) {
    // Handle the selection change
    if (args.value is DateTime) {
      DateTime selectedDate = args.value;
      //  (Mon_transMeter_Mon == null || YE_transMeter_Mon == ')

      setState(() {
        Mon_transMeter_Mon = DateFormat('MM').format(selectedDate);
        YE_transMeter_Mon = DateFormat('yyyy').format(selectedDate);
      });
      //print(
      //  'Selected month: ${Mon_transMeter_Mon}, Year: ${YE_transMeter_Mon}');
    }
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;
      _selectedDate =
          '${DateFormat('dd-MM-yyyy').format(range.startDate!)} - ${DateFormat('dd-MM-yyyy').format(range.endDate ?? range.startDate!)}';
      Value_InvDate_Daily_S = DateFormat('yyyy-MM-dd').format(range.startDate!);

      Value_InvDate_Daily_L =
          DateFormat('yyyy-MM-dd').format(range.endDate ?? range.startDate!);
    } else if (args.value is DateTime) {
      _selectedDate = DateFormat('dd-MM-yyyy').format(args.value);
      Value_InvDate_Daily_S = DateFormat('yyyy-MM-dd').format(args.value);

      Value_InvDate_Daily_L = DateFormat('yyyy-MM-dd').format(args.value);
    }

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });
    setState(() {
      Value_InvDate_Daily = _selectedDate;
    });

    setState(() {
      zone_ser_Invoice_Daily = null;
      zone_name_Invoice_Daily = null;
      Value_InvoiceDate_Daily = null;
      Ser_BodySta1 = 0;
      Ser_BodySta2 = 0;
    });
    Mon_Invoice_Mon = Value_InvDate_Daily_S;
    YE_Invoice_Mon = Value_InvDate_Daily_L;
    //print(Mon_Invoice_Mon);
    //print(YE_Invoice_Mon);
  }

////////////------------------------------------------>
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
                            'วันที่/ช่วงวันที่ที่ครบกำหนดชำระ :',
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
                                    (_selectedDate == null ||
                                            _selectedDate == '')
                                        ? 'เลือก'
                                        : '$_selectedDate',
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
                      //   padding: EdgeInsets.all(8.0),
                      //   child: Translate.TranslateAndSetText(
                      //       'เดือนที่ครบกำหนดชำระ :',
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
                                  // //print(
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
                          //     // //print(
                          //     //     'Selected Index: $zone_ser_Invoice_Mon  //${zone_name_Invoice_Mon}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (zone_name_Invoice_Mon == null)
                              ? null
                              : () async {
                                  if (zone_name_Invoice_Mon != null) {
                                    setState(() {
                                      Ser_BodySta1 = 1;
                                      Await_Status_Report1 = 0;
                                    });
                                    Dia_log();
                                  }
                                  try {
                                    red_InvoiceMonFull_bill().then((result) {
                                      // //print('red_InvoiceMonFull_bill');
                                      // //print('red_InvoiceMonFull_bill');
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
                                  // setState(() {
                                  //   Ser_BodySta1 = 1;
                                  // });

                                  // if (Mon_Invoice_Mon != null &&
                                  //     YE_Invoice_Mon != null &&
                                  //     zone_name_Invoice_Mon != null &&
                                  //     Ser_BodySta1 == 1) {
                                  //   setState(() {
                                  //     Await_Status_Report1 = 0;
                                  //   });
                                  //   Dia_log();
                                  //   try {
                                  //     red_InvoiceMonFull_bill().then((result) {
                                  //       // //print('red_InvoiceMonFull_bill');
                                  //       // //print('red_InvoiceMonFull_bill');
                                  //       setState(() {
                                  //         Await_Status_Report1 = 1;
                                  //       });
                                  //       Timer(const Duration(seconds: 1), () {
                                  //         Navigator.of(context).pop();
                                  //       });
                                  //     });
                                  //   } catch (e) {
                                  //     Timer(const Duration(seconds: 1), () {
                                  //       Navigator.of(context).pop();
                                  //     });
                                  //   }
                                  //   // red_InvoiceMonFull_bill();
                                  //   // red_InvoiceMon_bill();
                                  // }

                                  // // red_Trans_c_maintenance();
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
                      // (Ser_BodySta1 != 1)
                      //     ? Padding(
                      //         padding: EdgeInsets.all(8.0),
                      //         child: Translate.TranslateAndSetText(
                      //             'รายงานข้อมูลใบแจ้งหนี้/วางบิล ',
                      //             ReportScreen_Color.Colors_Text1_,
                      //             TextAlign.center,
                      //             FontWeight.w500,
                      //             Font_.Fonts_T,
                      //             16,
                      //             1),
                      //       )
                      //     : (InvoiceModels.isEmpty)
                      //         ? Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Translate.TranslateAndSetText(
                      //                 (InvoiceModels.isEmpty &&
                      //                         zone_name_Invoice_Mon != null &&
                      //                         Await_Status_Report1 != null)
                      //                     ? 'รายงานข้อมูลใบแจ้งหนี้/วางบิล (ไม่พบข้อมูล ✖️)'
                      //                     : 'รายงานข้อมูลใบแจ้งหนี้/วางบิล ',
                      //                 ReportScreen_Color.Colors_Text1_,
                      //                 TextAlign.center,
                      //                 FontWeight.w500,
                      //                 Font_.Fonts_T,
                      //                 16,
                      //                 1),
                      //           )
                      //         : (InvoiceModels.length != 0 &&
                      //                 Await_Status_Report1 != null &&
                      //                 Ser_BodySta1 == 1)
                      //             ? SizedBox(
                      //                 // height: 20,
                      //                 child: Row(
                      //                 children: [
                      //                   Container(
                      //                       padding: const EdgeInsets.all(4.0),
                      //                       child:
                      //                           const CircularProgressIndicator()),
                      //                   Padding(
                      //                     padding: EdgeInsets.all(8.0),
                      //                     child: Translate.TranslateAndSetText(
                      //                         'กำลังโหลดรายงานข้อมูลใบแจ้งหนี้/วางบิล...',
                      //                         ReportScreen_Color.Colors_Text1_,
                      //                         TextAlign.center,
                      //                         FontWeight.w500,
                      //                         Font_.Fonts_T,
                      //                         16,
                      //                         1),
                      //                   ),
                      //                 ],
                      //               ))
                      //             : Padding(
                      //                 padding: EdgeInsets.all(8.0),
                      //                 child: Translate.TranslateAndSetText(
                      //                     'รายงานข้อมูลใบแจ้งหนี้/วางบิล ✔️',
                      //                     ReportScreen_Color.Colors_Text1_,
                      //                     TextAlign.center,
                      //                     FontWeight.w500,
                      //                     Font_.Fonts_T,
                      //                     16,
                      //                     1),
                      //               ),
                      // Padding(
                      //   padding: EdgeInsets.all(4.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.lime[200],

                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       // border: Border.all(color: Colors.grey, width: 1),
                      //     ),
                      //     padding: EdgeInsets.all(4.0),
                      //     child: Translate.TranslateAndSetText(
                      //         'พิเศษ',
                      //         Colors.red,
                      //         TextAlign.center,
                      //         FontWeight.w500,
                      //         Font_.Fonts_T,
                      //         16,
                      //         1),
                      //   ),
                      // ),
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
                                    zone_name_Invoice_Befor = value!;
                                    zone_ser_Invoice_Befor =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // //print(
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
                                      // //print('red_InvoiceMonFull_bill');
                                      // //print('red_InvoiceMonFull_bill');
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
                                                zone_ser_Invoice_Befor !=
                                                    null &&
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
              //         Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Translate.TranslateAndSetText(
              //               'เดือน/ปี ที่กำหนดยกเลิกสัญญา :',
              //               ReportScreen_Color.Colors_Text1_,
              //               TextAlign.center,
              //               FontWeight.w500,
              //               Font_.Fonts_T,
              //               Text_Size,
              //               1),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: InkWell(
              //             onTap: () {
              //               showDialog(
              //                   context: context,
              //                   builder: (BuildContext context) {
              //                     return AlertDialog(
              //                         shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(20),
              //                         ),
              //                         backgroundColor:
              //                             AppbackgroundColor.Sub_Abg_Colors,
              //                         titlePadding: const EdgeInsets.all(0.0),
              //                         contentPadding:
              //                             const EdgeInsets.all(10.0),
              //                         actionsPadding: const EdgeInsets.all(6.0),
              //                         title: Text(''),
              //                         content: Container(
              //                           height: 300,
              //                           child: Column(
              //                             children: <Widget>[
              //                               getDateRangePicker(2),
              //                               MaterialButton(
              //                                 child: Text("OK"),
              //                                 onPressed: () {
              //                                   Navigator.pop(context);
              //                                 },
              //                               )
              //                             ],
              //                           ),
              //                         ));
              //                   });
              //               // _select_Date_Daily(context);
              //             },
              //             child: Container(
              //                 decoration: BoxDecoration(
              //                   color: AppbackgroundColor.Sub_Abg_Colors,
              //                   borderRadius: const BorderRadius.only(
              //                       topLeft: Radius.circular(10),
              //                       topRight: Radius.circular(10),
              //                       bottomLeft: Radius.circular(10),
              //                       bottomRight: Radius.circular(10)),
              //                   border:
              //                       Border.all(color: Colors.grey, width: 1),
              //                 ),
              //                 width: 180,
              //                 padding: const EdgeInsets.all(8.0),
              //                 child: Center(
              //                   child: Translate.TranslateAndSetText(
              //                       (Mon_Cannotice_Mon == null ||
              //                               YE_Cannotice_Mon == '')
              //                           ? 'เลือก'
              //                           : '$Mon_Cannotice_Mon / $YE_Cannotice_Mon',
              //                       ReportScreen_Color.Colors_Text2_,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size - 2,
              //                       1),
              //                 )),
              //           ),
              //         ),
              //         // Padding(
              //         //   padding: const EdgeInsets.all(8.0),
              //         //   child: Container(
              //         //     decoration: const BoxDecoration(
              //         //       color: AppbackgroundColor.Sub_Abg_Colors,
              //         //       borderRadius: BorderRadius.only(
              //         //           topLeft: Radius.circular(10),
              //         //           topRight: Radius.circular(10),
              //         //           bottomLeft: Radius.circular(10),
              //         //           bottomRight: Radius.circular(10)),
              //         //       // border: Border.all(color: Colors.grey, width: 1),
              //         //     ),
              //         //     width: 120,
              //         //     padding: const EdgeInsets.all(8.0),
              //         //     child: DropdownButtonFormField2(
              //         //       alignment: Alignment.center,
              //         //       focusColor: Colors.white,
              //         //       autofocus: false,
              //         //       decoration: InputDecoration(
              //         //         floatingLabelAlignment:
              //         //             FloatingLabelAlignment.center,
              //         //         enabled: true,
              //         //         hoverColor: Colors.brown,
              //         //         prefixIconColor: Colors.blue,
              //         //         fillColor: Colors.white.withOpacity(0.05),
              //         //         filled: false,
              //         //         isDense: true,
              //         //         contentPadding: EdgeInsets.zero,
              //         //         border: OutlineInputBorder(
              //         //           borderSide: const BorderSide(color: Colors.red),
              //         //           borderRadius: BorderRadius.circular(10),
              //         //         ),
              //         //         focusedBorder: const OutlineInputBorder(
              //         //           borderRadius: BorderRadius.only(
              //         //             topRight: Radius.circular(10),
              //         //             topLeft: Radius.circular(10),
              //         //             bottomRight: Radius.circular(10),
              //         //             bottomLeft: Radius.circular(10),
              //         //           ),
              //         //           borderSide: BorderSide(
              //         //             width: 1,
              //         //             color: Color.fromARGB(255, 231, 227, 227),
              //         //           ),
              //         //         ),
              //         //       ),
              //         //       isExpanded: false,
              //         //       value: (Mon_Cannotice_Mon == null)
              //         //           ? null
              //         //           : Mon_Cannotice_Mon,
              //         //       // hint: Text(
              //         //       //   Mon_Income == null
              //         //       //       ? 'เลือก'
              //         //       //       : '$Mon_Income',
              //         //       //   maxLines: 2,
              //         //       //   textAlign: TextAlign.center,
              //         //       //   style: const TextStyle(
              //         //       //     overflow:
              //         //       //         TextOverflow.ellipsis,
              //         //       //     fontSize: 14,
              //         //       //     color: Colors.grey,
              //         //       //   ),
              //         //       // ),
              //         //       icon: const Icon(
              //         //         Icons.arrow_drop_down,
              //         //         color: Colors.black,
              //         //       ),
              //         //       style: const TextStyle(
              //         //         color: Colors.grey,
              //         //       ),
              //         //       iconSize: 20,
              //         //       buttonHeight: 40,
              //         //       buttonWidth: 200,
              //         //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //         //       dropdownDecoration: BoxDecoration(
              //         //         // color: Colors
              //         //         //     .amber,
              //         //         borderRadius: BorderRadius.circular(10),
              //         //         border: Border.all(color: Colors.white, width: 1),
              //         //       ),
              //         //       items: [
              //         //         for (int item = 1; item < 13; item++)
              //         //           DropdownMenuItem<String>(
              //         //             value: '${item}',
              //         //             child: Translate.TranslateAndSetText(
              //         //                 '${monthsInThai[item - 1]}',
              //         //                 Colors.grey,
              //         //                 TextAlign.center,
              //         //                 FontWeight.w500,
              //         //                 Font_.Fonts_T,
              //         //                 Text_Size,
              //         //                 1),
              //         //           )
              //         //       ],

              //         //       onChanged: (value) async {
              //         //         Mon_Cannotice_Mon = value.toString();
              //         //       },
              //         //     ),
              //         //   ),
              //         // ),
              //         // Padding(
              //         //   padding: EdgeInsets.all(8.0),
              //         //   child: Translate.TranslateAndSetText(
              //         //       'ปีที่กำหนดยกเลิกสัญญา :',
              //         //       ReportScreen_Color.Colors_Text2_,
              //         //       TextAlign.center,
              //         //       FontWeight.w500,
              //         //       Font_.Fonts_T,
              //         //       Text_Size,
              //         //       1),
              //         // ),
              //         // Padding(
              //         //   padding: const EdgeInsets.all(8.0),
              //         //   child: Container(
              //         //     decoration: const BoxDecoration(
              //         //       color: AppbackgroundColor.Sub_Abg_Colors,
              //         //       borderRadius: BorderRadius.only(
              //         //           topLeft: Radius.circular(10),
              //         //           topRight: Radius.circular(10),
              //         //           bottomLeft: Radius.circular(10),
              //         //           bottomRight: Radius.circular(10)),
              //         //       // border: Border.all(color: Colors.grey, width: 1),
              //         //     ),
              //         //     width: 120,
              //         //     padding: const EdgeInsets.all(8.0),
              //         //     child: DropdownButtonFormField2(
              //         //       alignment: Alignment.center,
              //         //       focusColor: Colors.white,
              //         //       autofocus: false,
              //         //       decoration: InputDecoration(
              //         //         floatingLabelAlignment:
              //         //             FloatingLabelAlignment.center,
              //         //         enabled: true,
              //         //         hoverColor: Colors.brown,
              //         //         prefixIconColor: Colors.blue,
              //         //         fillColor: Colors.white.withOpacity(0.05),
              //         //         filled: false,
              //         //         isDense: true,
              //         //         contentPadding: EdgeInsets.zero,
              //         //         border: OutlineInputBorder(
              //         //           borderSide: const BorderSide(color: Colors.red),
              //         //           borderRadius: BorderRadius.circular(10),
              //         //         ),
              //         //         focusedBorder: const OutlineInputBorder(
              //         //           borderRadius: BorderRadius.only(
              //         //             topRight: Radius.circular(10),
              //         //             topLeft: Radius.circular(10),
              //         //             bottomRight: Radius.circular(10),
              //         //             bottomLeft: Radius.circular(10),
              //         //           ),
              //         //           borderSide: BorderSide(
              //         //             width: 1,
              //         //             color: Color.fromARGB(255, 231, 227, 227),
              //         //           ),
              //         //         ),
              //         //       ),
              //         //       isExpanded: false,
              //         //       value: (YE_Cannotice_Mon == null)
              //         //           ? null
              //         //           : YE_Cannotice_Mon,
              //         //       // hint: Text(
              //         //       //   YE_Income == null
              //         //       //       ? 'เลือก'
              //         //       //       : '$YE_Income',
              //         //       //   maxLines: 2,
              //         //       //   textAlign: TextAlign.center,
              //         //       //   style: const TextStyle(
              //         //       //     overflow:
              //         //       //         TextOverflow.ellipsis,
              //         //       //     fontSize: 14,
              //         //       //     color: Colors.grey,
              //         //       //   ),
              //         //       // ),
              //         //       icon: const Icon(
              //         //         Icons.arrow_drop_down,
              //         //         color: Colors.black,
              //         //       ),
              //         //       style: const TextStyle(
              //         //         color: Colors.grey,
              //         //       ),
              //         //       iconSize: 20,
              //         //       buttonHeight: 40,
              //         //       buttonWidth: 200,
              //         //       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //         //       dropdownDecoration: BoxDecoration(
              //         //         // color: Colors
              //         //         //     .amber,
              //         //         borderRadius: BorderRadius.circular(10),
              //         //         border: Border.all(color: Colors.white, width: 1),
              //         //       ),
              //         //       items: YE_Th_noti.map(
              //         //           (item) => DropdownMenuItem<String>(
              //         //                 value: '${item}',
              //         //                 child: Text(
              //         //                   '${item}',
              //         //                   // '${int.parse(item) + 543}',
              //         //                   textAlign: TextAlign.center,
              //         //                   style: TextStyle(
              //         //                     overflow: TextOverflow.ellipsis,
              //         //                     fontSize: Text_Size,
              //         //                     color: Colors.grey,
              //         //                   ),
              //         //                 ),
              //         //               )).toList(),

              //         //       onChanged: (value) async {
              //         //         YE_Cannotice_Mon = value.toString();
              //         //       },
              //         //     ),
              //         //   ),
              //         // ),
              //         Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Translate.TranslateAndSetText(
              //               'โซนที่กำหนดยกเลิกสัญญา :',
              //               ReportScreen_Color.Colors_Text2_,
              //               TextAlign.center,
              //               FontWeight.w500,
              //               Font_.Fonts_T,
              //               Text_Size,
              //               1),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Container(
              //             decoration: BoxDecoration(
              //               color: AppbackgroundColor.Sub_Abg_Colors,
              //               borderRadius: BorderRadius.only(
              //                   topLeft: Radius.circular(10),
              //                   topRight: Radius.circular(10),
              //                   bottomLeft: Radius.circular(10),
              //                   bottomRight: Radius.circular(10)),
              //               border: Border.all(color: Colors.grey, width: 1),
              //             ),
              //             width: 300,
              //             // padding: const EdgeInsets.all(8.0),
              //             child: DropdownButtonHideUnderline(
              //               child: DropdownButton2<String>(
              //                   isExpanded: false,
              //                   searchController: Dropdown_Controller_zone[0],
              //                   value: (zone_name_Cannotice_Mon == null)
              //                       ? null
              //                       : zone_name_Cannotice_Mon,
              //                   alignment: Alignment.center,
              //                   focusColor: Colors.white,
              //                   searchInnerWidget: Container(
              //                     // width: 200,
              //                     height: 40,
              //                     decoration: BoxDecoration(
              //                       color: Colors.red[100]!.withOpacity(0.5),
              //                       borderRadius: const BorderRadius.only(
              //                           topLeft: Radius.circular(8),
              //                           topRight: Radius.circular(8),
              //                           bottomLeft: Radius.circular(8),
              //                           bottomRight: Radius.circular(8)),
              //                       border: Border.all(
              //                           color: Colors.grey, width: 1),
              //                     ),
              //                     child: TextFormField(
              //                       expands: true,
              //                       maxLines: null,
              //                       controller: Dropdown_Controller_zone[0],
              //                       decoration: InputDecoration(
              //                         isDense: true,
              //                         contentPadding:
              //                             const EdgeInsets.symmetric(
              //                           horizontal: 10,
              //                           vertical: 8,
              //                         ),
              //                         hintText: 'Search...',
              //                         // fillColor: Colors.red[300],
              //                         hintStyle: const TextStyle(fontSize: 12),
              //                         border: OutlineInputBorder(
              //                           borderRadius: BorderRadius.circular(8),
              //                           borderSide: BorderSide(
              //                             width: 1,
              //                             color: Color.fromARGB(
              //                                 255, 231, 227, 227),
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   hint: (zone_name_Cannotice_Mon == null)
              //                       ? null
              //                       : Text(
              //                           '$zone_name_Cannotice_Mon',
              //                           maxLines: 1,
              //                           style: TextStyle(
              //                               fontSize: Text_Size,
              //                               color: PeopleChaoScreen_Color
              //                                   .Colors_Text2_,
              //                               fontFamily: Font_.Fonts_T),
              //                         ),
              //                   icon: const Icon(
              //                     Icons.arrow_drop_down,
              //                     color: TextHome_Color.TextHome_Colors,
              //                   ),
              //                   style: TextStyle(
              //                       fontSize: Text_Size,
              //                       color: Colors.grey,
              //                       fontFamily: Font_.Fonts_T),
              //                   iconSize: 20,
              //                   buttonHeight: 35,
              //                   buttonWidth: 250,
              //                   dropdownDecoration: BoxDecoration(
              //                     // color: Colors.red[100]!.withOpacity(0.5),
              //                     borderRadius: BorderRadius.circular(10),
              //                     border:
              //                         Border.all(color: Colors.grey, width: 1),
              //                   ),
              //                   //  BoxDecoration(
              //                   //   borderRadius: BorderRadius.circular(10),
              //                   // ),
              //                   items: zoneModels_report
              //                       .map((item) => DropdownMenuItem<String>(
              //                             value: '${item.zn}',
              //                             child: Column(
              //                               crossAxisAlignment:
              //                                   CrossAxisAlignment.start,
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.center,
              //                               children: [
              //                                 Text(
              //                                   item.zn!,
              //                                   maxLines: 2,
              //                                   style: TextStyle(
              //                                       fontSize: Text_Size,
              //                                       fontFamily: Font_.Fonts_T),
              //                                 ),
              //                                 Divider(
              //                                   color: Colors.grey[300],
              //                                   height: 4.0,
              //                                 ),
              //                               ],
              //                             ),
              //                           ))
              //                       .toList(),

              //                   // value: selectedValue,

              //                   onChanged: (value) async {
              //                     int selectedIndex = zoneModels_report
              //                         .indexWhere((item) => item.zn == value);

              //                     setState(() {
              //                       zone_name_Cannotice_Mon = value.toString();
              //                       zone_ser_Cannotice_Mon =
              //                           zoneModels_report[selectedIndex].ser!;
              //                     });
              //                     // //print(
              //                     //     'Selected Index: $zone_name_Cannotice_Mon  //${zone_ser_Cannotice_Mon}');
              //                   },
              //                   onMenuStateChange: (isOpen) {
              //                     if (!isOpen) {
              //                       Dropdown_Controller_zone[0].clear();
              //                     }
              //                   }),
              //             ),

              //             //  DropdownButtonFormField2(
              //             //   value: (zone_name_Cannotice_Mon == null)
              //             //       ? null
              //             //       : zone_name_Cannotice_Mon,
              //             //   alignment: Alignment.center,
              //             //   focusColor: Colors.white,
              //             //   autofocus: false,
              //             //   decoration: InputDecoration(
              //             //     enabled: true,
              //             //     hoverColor: Colors.brown,
              //             //     prefixIconColor: Colors.blue,
              //             //     fillColor: Colors.white.withOpacity(0.05),
              //             //     filled: false,
              //             //     isDense: true,
              //             //     contentPadding: EdgeInsets.zero,
              //             //     border: OutlineInputBorder(
              //             //       borderSide: const BorderSide(color: Colors.red),
              //             //       borderRadius: BorderRadius.circular(10),
              //             //     ),
              //             //     focusedBorder: const OutlineInputBorder(
              //             //       borderRadius: BorderRadius.only(
              //             //         topRight: Radius.circular(10),
              //             //         topLeft: Radius.circular(10),
              //             //         bottomRight: Radius.circular(10),
              //             //         bottomLeft: Radius.circular(10),
              //             //       ),
              //             //       borderSide: BorderSide(
              //             //         width: 1,
              //             //         color: Color.fromARGB(255, 231, 227, 227),
              //             //       ),
              //             //     ),
              //             //   ),
              //             //   isExpanded: false,

              //             //   icon: const Icon(
              //             //     Icons.arrow_drop_down,
              //             //     color: Colors.black,
              //             //   ),
              //             //   style: const TextStyle(
              //             //     color: Colors.grey,
              //             //   ),
              //             //   iconSize: 20,
              //             //   buttonHeight: 40,
              //             //   buttonWidth: 250,
              //             //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
              //             //   dropdownDecoration: BoxDecoration(
              //             //     // color: Colors
              //             //     //     .amber,
              //             //     borderRadius: BorderRadius.circular(10),
              //             //     border: Border.all(color: Colors.white, width: 1),
              //             //   ),
              //             //   items: zoneModels_report
              //             //       .map((item) => DropdownMenuItem<String>(
              //             //             value: '${item.zn}',
              //             //             child: Text(
              //             //               '${item.zn}',
              //             //               textAlign: TextAlign.center,
              //             //               style: const TextStyle(
              //             //                 overflow: TextOverflow.ellipsis,
              //             //                 fontSize: 14,
              //             //                 color: Colors.grey,
              //             //               ),
              //             //             ),
              //             //           ))
              //             //       .toList(),

              //             //   onChanged: (value) async {
              //             //     int selectedIndex = zoneModels_report
              //             //         .indexWhere((item) => item.zn == value);

              //             //     setState(() {
              //             //       zone_name_Cannotice_Mon = value.toString();
              //             //       zone_ser_Cannotice_Mon =
              //             //           zoneModels_report[selectedIndex].ser!;
              //             //     });
              //             //     // //print(
              //             //     //     'Selected Index: $zone_name_Cannotice_Mon  //${zone_ser_Cannotice_Mon}');
              //             //   },
              //             // ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: InkWell(
              //             onTap: (zone_name_Cannotice_Mon == null)
              //                 ? null
              //                 : () async {
              //                     setState(() {
              //                       Await_Status_Report2 = 0;
              //                     });
              //                     Dia_log();
              //                     try {
              //                       read_GC_tenant_Cancel().then((result) {
              //                         // //print('red_InvoiceMonFull_bill');
              //                         // //print('red_InvoiceMonFull_bill');
              //                         setState(() {
              //                           Await_Status_Report2 = 1;
              //                         });
              //                         Timer(const Duration(seconds: 1), () {
              //                           Navigator.of(context).pop();
              //                         });
              //                       });
              //                     } catch (e) {
              //                       Timer(const Duration(seconds: 1), () {
              //                         Navigator.of(context).pop();
              //                       });
              //                     }

              //                     // read_GC_tenant_Cancel();
              //                   },
              //             child: Container(
              //                 width: 100,
              //                 padding: const EdgeInsets.all(6.0),
              //                 decoration: BoxDecoration(
              //                   color: Colors.green[700],
              //                   borderRadius: const BorderRadius.only(
              //                       topLeft: Radius.circular(10),
              //                       topRight: Radius.circular(10),
              //                       bottomLeft: Radius.circular(10),
              //                       bottomRight: Radius.circular(10)),
              //                 ),
              //                 child: Center(
              //                   child: Translate.TranslateAndSetText(
              //                       'ค้นหา',
              //                       Colors.white,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size,
              //                       1),
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
              //             padding: const EdgeInsets.all(4.0),
              //             child: Center(
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Translate.TranslateAndSetText(
              //                       'เรียกดู',
              //                       ReportScreen_Color.Colors_Text1_,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size,
              //                       1),
              //                   Icon(
              //                     Icons.navigate_next,
              //                     color: Colors.grey,
              //                   )
              //                 ],
              //               ),
              //             ),
              //           ),
              //           onTap: (zone_name_Cannotice_Mon == null ||
              //                   teNantModels_noti.isEmpty)
              //               ? null
              //               : () async {
              //                   Insert_log.Insert_logs('รายงาน',
              //                       'กดดูรายงานยกเลิกสัญญาผู้เช่าล่วงหน้า');
              //                   RE_PeopleCancelNoti_WidgetStart();
              //                 }),
              //       (Await_Status_Report2 == 0)
              //           ? SizedBox(
              //               // height: 20,
              //               child: Row(
              //               children: [
              //                 Container(
              //                     padding: const EdgeInsets.all(4.0),
              //                     child: const CircularProgressIndicator()),
              //                 Padding(
              //                   padding: EdgeInsets.all(8.0),
              //                   child: Translate.TranslateAndSetText(
              //                       'กำลังโหลดรายงานยกเลิกสัญญาผู้เช่าล่วงหน้า...',
              //                       ReportScreen_Color.Colors_Text2_,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size,
              //                       1),
              //                 ),
              //               ],
              //             ))
              //           : (teNantModels_noti.isEmpty ||
              //                   Await_Status_Report2 == null)
              //               ? Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Translate.TranslateAndSetText(
              //                       (Mon_Cannotice_Mon != null &&
              //                               YE_Cannotice_Mon != null &&
              //                               zone_name_Cannotice_Mon != null &&
              //                               teNantModels_noti.isEmpty &&
              //                               Await_Status_Report2 != null)
              //                           ? 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า (ไม่พบข้อมูล ✖️)'
              //                           : 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า',
              //                       ReportScreen_Color.Colors_Text2_,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size,
              //                       1),
              //                 )
              //               : Padding(
              //                   padding: EdgeInsets.all(8.0),
              //                   child: Translate.TranslateAndSetText(
              //                       'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า ✔️',
              //                       ReportScreen_Color.Colors_Text2_,
              //                       TextAlign.center,
              //                       FontWeight.w500,
              //                       Font_.Fonts_T,
              //                       Text_Size,
              //                       1),
              //                 )
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
                                Status_pe_ser_History = '${selectedIndex}';
                              });
                              // //print(selectedIndex);
                            },
                          ),
                        ),
                      ),
                      if (Status_pe_ser_History != '3')
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSetText(
                              'ประภทวันที่ :',
                              ReportScreen_Color.Colors_Text2_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              Text_Size,
                              1),
                        ),
                      if (Status_pe_ser_History != '3')
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
                              value: Status_Datex_History,

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
                                  borderSide:
                                      const BorderSide(color: Colors.red),
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
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                              items: Status_Datex.map(
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
                                int selectedIndex = Status_Datex.indexWhere(
                                    (item) => item == value);
                                setState(() {
                                  Status_Datex_History =
                                      Status_Datex[selectedIndex]!;
                                  Status_Datex_ser_History =
                                      '${selectedIndex + 1}';
                                });
                                // //print(selectedIndex);
                              },
                            ),
                          ),
                        ),
                      if (Status_pe_ser_History != '3')
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
                      if (Status_pe_ser_History != '3')
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
                                      (Mon_Pe_Mon == null || YE_Pe_Mon == '')
                                          ? 'เลือก'
                                          : '$Mon_Pe_Mon / $YE_Pe_Mon',
                                      ReportScreen_Color.Colors_Text2_,
                                      TextAlign.center,
                                      FontWeight.w500,
                                      Font_.Fonts_T,
                                      Text_Size - 2,
                                      1),
                                )),
                          ),
                        ),
                      // if (Status_pe_ser_History != '3')
                      //   Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Container(
                      //       decoration: const BoxDecoration(
                      //         color: AppbackgroundColor.Sub_Abg_Colors,
                      //         borderRadius: BorderRadius.only(
                      //             topLeft: Radius.circular(10),
                      //             topRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10)),
                      //         // border: Border.all(color: Colors.grey, width: 1),
                      //       ),
                      //       width: 120,
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: DropdownButtonFormField2(
                      //         alignment: Alignment.center,
                      //         focusColor: Colors.white,
                      //         autofocus: false,
                      //         decoration: InputDecoration(
                      //           floatingLabelAlignment:
                      //               FloatingLabelAlignment.center,
                      //           enabled: true,
                      //           hoverColor: Colors.brown,
                      //           prefixIconColor: Colors.blue,
                      //           fillColor: Colors.white.withOpacity(0.05),
                      //           filled: false,
                      //           isDense: true,
                      //           contentPadding: EdgeInsets.zero,
                      //           border: OutlineInputBorder(
                      //             borderSide:
                      //                 const BorderSide(color: Colors.red),
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           focusedBorder: const OutlineInputBorder(
                      //             borderRadius: BorderRadius.only(
                      //               topRight: Radius.circular(10),
                      //               topLeft: Radius.circular(10),
                      //               bottomRight: Radius.circular(10),
                      //               bottomLeft: Radius.circular(10),
                      //             ),
                      //             borderSide: BorderSide(
                      //               width: 1,
                      //               color: Color.fromARGB(255, 231, 227, 227),
                      //             ),
                      //           ),
                      //         ),
                      //         isExpanded: false,
                      //         value: (Mon_Pe_Mon == null) ? null : Mon_Pe_Mon,
                      //         // hint: Text(
                      //         //   Mon_Income == null
                      //         //       ? 'เลือก'
                      //         //       : '$Mon_Income',
                      //         //   maxLines: 2,
                      //         //   textAlign: TextAlign.center,
                      //         //   style: const TextStyle(
                      //         //     overflow:
                      //         //         TextOverflow.ellipsis,
                      //         //     fontSize: 14,
                      //         //     color: Colors.grey,
                      //         //   ),
                      //         // ),
                      //         icon: const Icon(
                      //           Icons.arrow_drop_down,
                      //           color: Colors.black,
                      //         ),
                      //         style: const TextStyle(
                      //           color: Colors.grey,
                      //         ),
                      //         iconSize: 20,
                      //         buttonHeight: 40,
                      //         buttonWidth: 200,
                      //         // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //         dropdownDecoration: BoxDecoration(
                      //           // color: Colors
                      //           //     .amber,
                      //           borderRadius: BorderRadius.circular(10),
                      //           border:
                      //               Border.all(color: Colors.white, width: 1),
                      //         ),
                      //         items: [
                      //           for (int item = 1; item < 13; item++)
                      //             DropdownMenuItem<String>(
                      //               value: '${item}',
                      //               child: Translate.TranslateAndSetText(
                      //                   '${monthsInThai[item - 1]}',
                      //                   Colors.grey,
                      //                   TextAlign.center,
                      //                   FontWeight.w500,
                      //                   Font_.Fonts_T,
                      //                   Text_Size,
                      //                   1),
                      //             )
                      //         ],

                      //         onChanged: (value) async {
                      //           Mon_Pe_Mon = value.toString();
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // if (Status_pe_ser_History != '3')
                      //   Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: Translate.TranslateAndSetText(
                      //         'ปี :',
                      //         ReportScreen_Color.Colors_Text2_,
                      //         TextAlign.center,
                      //         FontWeight.w500,
                      //         Font_.Fonts_T,
                      //         Text_Size,
                      //         1),
                      //   ),
                      // if (Status_pe_ser_History != '3')
                      //   Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Container(
                      //       decoration: const BoxDecoration(
                      //         color: AppbackgroundColor.Sub_Abg_Colors,
                      //         borderRadius: BorderRadius.only(
                      //             topLeft: Radius.circular(10),
                      //             topRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10)),
                      //         // border: Border.all(color: Colors.grey, width: 1),
                      //       ),
                      //       width: 120,
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: DropdownButtonFormField2(
                      //         alignment: Alignment.center,
                      //         focusColor: Colors.white,
                      //         autofocus: false,
                      //         decoration: InputDecoration(
                      //           floatingLabelAlignment:
                      //               FloatingLabelAlignment.center,
                      //           enabled: true,
                      //           hoverColor: Colors.brown,
                      //           prefixIconColor: Colors.blue,
                      //           fillColor: Colors.white.withOpacity(0.05),
                      //           filled: false,
                      //           isDense: true,
                      //           contentPadding: EdgeInsets.zero,
                      //           border: OutlineInputBorder(
                      //             borderSide:
                      //                 const BorderSide(color: Colors.red),
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           focusedBorder: const OutlineInputBorder(
                      //             borderRadius: BorderRadius.only(
                      //               topRight: Radius.circular(10),
                      //               topLeft: Radius.circular(10),
                      //               bottomRight: Radius.circular(10),
                      //               bottomLeft: Radius.circular(10),
                      //             ),
                      //             borderSide: BorderSide(
                      //               width: 1,
                      //               color: Color.fromARGB(255, 231, 227, 227),
                      //             ),
                      //           ),
                      //         ),
                      //         isExpanded: false,
                      //         value: (YE_Pe_Mon == null) ? null : YE_Pe_Mon,
                      //         // hint: Text(
                      //         //   YE_Income == null
                      //         //       ? 'เลือก'
                      //         //       : '$YE_Income',
                      //         //   maxLines: 2,
                      //         //   textAlign: TextAlign.center,
                      //         //   style: const TextStyle(
                      //         //     overflow:
                      //         //         TextOverflow.ellipsis,
                      //         //     fontSize: 14,
                      //         //     color: Colors.grey,
                      //         //   ),
                      //         // ),
                      //         icon: const Icon(
                      //           Icons.arrow_drop_down,
                      //           color: Colors.black,
                      //         ),
                      //         style: const TextStyle(
                      //           color: Colors.grey,
                      //         ),
                      //         iconSize: 20,
                      //         buttonHeight: 40,
                      //         buttonWidth: 200,
                      //         // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      //         dropdownDecoration: BoxDecoration(
                      //           // color: Colors
                      //           //     .amber,
                      //           borderRadius: BorderRadius.circular(10),
                      //           border:
                      //               Border.all(color: Colors.white, width: 1),
                      //         ),
                      //         items: YE_Th_noti.map(
                      //             (item) => DropdownMenuItem<String>(
                      //                   value: '${item}',
                      //                   child: Text(
                      //                     '${item}',
                      //                     // '${int.parse(item) + 543}',
                      //                     textAlign: TextAlign.center,
                      //                     style: TextStyle(
                      //                       overflow: TextOverflow.ellipsis,
                      //                       fontSize: Text_Size,
                      //                       color: Colors.grey,
                      //                     ),
                      //                   ),
                      //                 )).toList(),

                      //         onChanged: (value) async {
                      //           YE_Pe_Mon = value.toString();
                      //         },
                      //       ),
                      //     ),
                      //   ),
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

                          //  DropdownButtonFormField2(
                          //   value: (zone_name_Cannotice_Mon == null)
                          //       ? null
                          //       : zone_name_Cannotice_Mon,
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
                          //       zone_name_Cannotice_Mon = value.toString();
                          //       zone_ser_Cannotice_Mon =
                          //           zoneModels_report[selectedIndex].ser!;
                          //     });
                          //     // //print(
                          //     //     'Selected Index: $zone_name_Cannotice_Mon  //${zone_ser_Cannotice_Mon}');
                          //   },
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (zone_name_Pe_Mon == null)
                              ? null
                              : () async {
                                  setState(() {
                                    Await_Status_Report3 = 0;
                                  });
                                  Dia_log();
                                  try {
                                    read_GC_tenant().then((result) {
                                      // //print('red_InvoiceMonFull_bill');
                                      // //print('red_InvoiceMonFull_bill');
                                      if (Status_pe_ser_History != '3') {
                                        People_tenant_New().then((result) {
                                          read_GC_tenant_Renew().then((result) {
                                            setState(() {
                                              Await_Status_Report3 = 1;
                                            });
                                            Timer(const Duration(seconds: 1),
                                                () {
                                              Navigator.of(context).pop();
                                            });
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          teNantModels_Renew.clear();
                                          teNantModels_New.clear();
                                          Await_Status_Report3 = 1;
                                        });
                                        Timer(const Duration(seconds: 1), () {
                                          Navigator.of(context).pop();
                                        });
                                      }
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
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Row(children: [
                  Translate.TranslateAndSetText(
                      (Status_pe_History.toString() == 'ใกล้หมดสัญญา')
                          ? '#หมายเหตุ : ผู้เช่าเข้าใหม่-ต่อสัญญา จะไม่สามารถเรียกดูได้ถ้าเรียกดูรายงาน ใกล้หมดสัญญา '
                          : '#หมายเหตุ : ผู้เช่าเข้าใหม่-ต่อสัญญา(ค้นหาจากวันที่ทำรายการและเป็นสัญญาปัจจุบัน)',
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
                                        'กดดูรายงานรายงานผู้เช่า$Status_pe_Historyค้นจาก$Status_Datex_History');
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
                                    (Status_pe_History.toString() ==
                                            'ใกล้หมดสัญญา')
                                        ? 'รายงานผู้เช่า$Status_pe_History ....'
                                        : 'กำลังโหลดรายงานผู้เช่า$Status_pe_History ค้นจาก$Status_Datex_History...',
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
                                        ? (Status_pe_History.toString() ==
                                                'ใกล้หมดสัญญา')
                                            ? 'รายงานผู้เช่า$Status_pe_History (ไม่พบข้อมูล ✖️)'
                                            : 'รายงานผู้เช่า$Status_pe_History ค้นจาก$Status_Datex_History (ไม่พบข้อมูล ✖️)'
                                        : (Status_pe_History.toString() ==
                                                'ใกล้หมดสัญญา')
                                            ? 'รายงานผู้เช่า$Status_pe_History'
                                            : 'รายงานผู้เช่า$Status_pe_History ค้นจาก$Status_Datex_History',
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
                                    (Status_pe_History.toString() ==
                                            'ใกล้หมดสัญญา')
                                        ? 'รายงานผู้เช่า$Status_pe_History ✔️'
                                        : 'รายงานผู้เช่า$Status_pe_History ค้นจาก$Status_Datex_History ✔️',
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
                              // //print(
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
                                    zone_name_transMeter = value!;
                                    zone_ser_transMeter =
                                        zoneModels_report[selectedIndex].ser!;
                                  });
                                  // //print(
                                  //     'Selected Index: $zone_name_transMeter  //${zone_ser_transMeter}');
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
                          onTap: (zone_name_transMeter == null)
                              ? null
                              : () async {
                                  // setState(() {
                                  //   Ser_BodySta1 = 1;
                                  // });

                                  if (Mon_transMeter_Mon != null &&
                                      YE_transMeter_Mon != null &&
                                      zone_name_transMeter != null) {
                                    setState(() {
                                      Await_Status_Report4 = 0;
                                    });
                                    Dia_log();
                                    red_Trans_bill().then(
                                        (value) => Navigator.of(context).pop());
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
                                            Await_Status_Report4 != null)
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
                                    Await_Status_Report4 != null)
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
            ])));
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
                        (Mon_Invoice_Mon == null && YE_Invoice_Mon == null)
                            ? 'เดือน : ? (?) '
                            : (Mon_Invoice_Mon == null)
                                ? 'เดือน : ? ($YE_Invoice_Mon) '
                                : (YE_Invoice_Mon == null)
                                    ? 'เดือน : $Mon_Invoice_Mon (?) '
                                    : 'เดือน : $Mon_Invoice_Mon ($YE_Invoice_Mon) ',
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
                                      //print(expModels[selectedIndex].expname);
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
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'แอดมิน',
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
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${InvoiceModels[index].name_user}',
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
                              Value_Report = (Ser_BodySta1 == 1)
                                  ? 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล'
                                  : 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล';
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

  /////////////------------------------>
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

//  Widget someWidget = await _json(index);

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

///////////////////////////----------------------------------------------->(รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า)
  RE_PeopleCancelNoti_WidgetStart() {
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
                      (zone_name_Cannotice_Mon == null)
                          ? 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า (กรุณาเลือกโซน)'
                          : 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า (โซน : $zone_name_Cannotice_Mon)',
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
                              'ทั้งหมด: ${teNantModels_noti.length}',
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
                              ? MediaQuery.of(context).size.width * 1.2
                              : (teNantModels_noti.length == 0)
                                  ? MediaQuery.of(context).size.width
                                  : 1300,
                          // height:
                          //     MediaQuery.of(context)
                          //             .size
                          //             .height *
                          //         0.3,
                          child: (teNantModels_noti.length == 0)
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
                                              'เลขที่สัญญาเดิม',
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
                                              'รหัสสาขา',
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
                                              'กำหนดยกเลิกล่วงหน้า',
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
                                              'วันที่เริ่มสัญญา',
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
                                              'วันสิ้นสุดสัญญา',
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
                                              'ใบเสร็จเงินประกัน',
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
                                              'เงินประกัน',
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
                                              'VAT เงินประกัน',
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
                                              'เงินประกันทั้งหมด(+VAT)',
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
                                            flex: 2,
                                            child: Text(
                                              'เหตุผล',
                                              textAlign: TextAlign.start,
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
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ผู้ดูแล',
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
                                              'อ้างอิง',
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
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        // height: (Responsive.isDesktop(context))
                                        //     ? MediaQuery.of(context).size.width * 0.255
                                        //     : MediaQuery.of(context).size.height * 0.45,
                                        child: ListView.builder(
                                      itemCount: teNantModels_noti.length,
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
                                                          '${teNantModels_noti[index].cid}',
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
                                                      '${teNantModels_noti[index].cid}',
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
                                                          '${teNantModels_noti[index].renew_cid}',
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
                                                      '${teNantModels_noti[index].renew_cid}',
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
                                                          '${teNantModels_noti[index].sname}',
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
                                                      '${teNantModels_noti[index].sname}',
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
                                                          '${teNantModels_noti[index].cname}',
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
                                                      '${teNantModels_noti[index].cname}',
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
                                                  (teNantModels_noti[index]
                                                              .zn!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels_noti[index].zn!.split('_')[0]}'
                                                      : 'CMN${teNantModels_noti[index].zn!.split('_')[0]}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels_noti[index].zn}',
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
                                                        '${teNantModels_noti[index].ln}',
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
                                                    '${teNantModels_noti[index].ln}',
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
                                                  '${teNantModels_noti[index].rtname}',
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
                                                  (teNantModels_noti[index]
                                                              .cc_date ==
                                                          null)
                                                      ? '${teNantModels_noti[index].cc_date}'
                                                      : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].cc_date} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].cc_date} 00:00:00').year + 0}',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.red,
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
                                                    (teNantModels_noti[index]
                                                                .sdate ==
                                                            null)
                                                        ? '${teNantModels_noti[index].sdate}'
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].sdate} 00:00:00').year + 0}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    (teNantModels_noti[index]
                                                                .ldate ==
                                                            null)
                                                        ? '${teNantModels_noti[index].ldate}'
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels_noti[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels_noti[index].ldate} 00:00:00').year + 0}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.orange,
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
                                                    (teNantModels_noti[index]
                                                                .min_docno ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels_noti[index].min_docno}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    (teNantModels_noti[index]
                                                                .pakan_pvat ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels_noti[index].pakan_pvat}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    (teNantModels_noti[index]
                                                                .pakan_pvat ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels_noti[index].pakan_vat}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    (teNantModels_noti[index]
                                                                .pakan_total ==
                                                            null)
                                                        ? ''
                                                        : '${teNantModels_noti[index].pakan_total}',
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
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    '${teNantModels_noti[index].cc_remark}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.red,
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
                                                  '${teNantModels_noti[index].st}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                                                  '${teNantModels_noti[index].name_user}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                                                  '${teNantModels_noti[index].wnote}',
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                    if (teNantModels_noti.length != 0)
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
                              Value_Report = 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า';
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
                            zone_ser_Cannotice_Mon = null;

                            zone_name_Cannotice_Mon = null;

                            Await_Status_Report1 = null;
                            teNantModels_noti.clear();
                            Mon_Cannotice_Mon = null;
                            YE_Cannotice_Mon = null;

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
                          ? (Status_pe_History.toString() == 'ใกล้หมดสัญญา')
                              ? 'รายงานผู้เช่า$Status_pe_History (กรุณาเลือกโซน)'
                              : 'รายงานรายงานผู้เช่า$Status_pe_Historyค้นจาก$Status_Datex_History (กรุณาเลือกโซน)'
                          : (Status_pe_History.toString() == 'ใกล้หมดสัญญา')
                              ? 'รายงานผู้เช่า$Status_pe_History'
                              : 'รายงานรายงานผู้เช่า$Status_pe_Historyค้นจาก$Status_Datex_History (โซน : $zone_name_Cannotice_Mon)',
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
                              (Status_pe_ser_History == '3')
                                  ? '#ระยะเวลาใกล้หมดสัญญาภายใน $open_set_date วัน'
                                  : '',
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
                                              'เลขที่สัญญาเดิม',
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
                                              'รหัสสาขา',
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
                                              'วันที่เริ่มสัญญา',
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
                                              'วันสิ้นสุดสัญญา',
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
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'ผู้ดูแล',
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
                                              'อ้างอิง',
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
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      '${teNantModels[index].cid}',
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
                                                          '${teNantModels[index].renew_cid}',
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
                                                      '${teNantModels[index].renew_cid}',
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
                                                          '${teNantModels[index].cname}',
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
                                                      '${teNantModels[index].cname}',
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
                                                              .zn!
                                                              .split('_')[0]
                                                              .length <=
                                                          4)
                                                      ? 'CMN0${teNantModels[index].zn!.split('_')[0]}'
                                                      : 'CMN${teNantModels[index].zn!.split('_')[0]}',
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
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels[index].zn}',
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
                                                        '${teNantModels[index].ln}',
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
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 25,
                                                  maxLines: 1,
                                                  '${teNantModels[index].rtname}',
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
                                                  (teNantModels[index].sdate ==
                                                          null)
                                                      ? '${teNantModels[index].sdate}'
                                                      : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].sdate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].sdate} 00:00:00').year + 0}',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 25,
                                                    maxLines: 1,
                                                    (teNantModels[index]
                                                                .ldate ==
                                                            null)
                                                        ? '${teNantModels[index].ldate}'
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].ldate} 00:00:00').year + 0}',
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
                                                  '${teNantModels[index].st}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                                                  '${teNantModels[index].name_user}',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                                                  '${teNantModels[index].wnote}',
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                              Value_Report = 'รายงานสัญญาผู้เช่าแบบเลือกวันที่';
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
                                              'ชื่อผู้เช่า',
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
                                                    '${transMeterModels[index].cname}',
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
                                                    (transMeterModels[index]
                                                                .date ==
                                                            null)
                                                        ? ''
                                                        : '${DateFormat('dd-MM').format(DateTime.parse('${transMeterModels[index].date}'))}-${int.parse('${DateFormat('yyyy').format(DateTime.parse('${transMeterModels[index].date}'))}') + 0}',
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
                                                    (transMeterModels[index]
                                                                .ovalue ==
                                                            null)
                                                        ? ''
                                                        : '${nFormat2.format(double.parse(transMeterModels[index].ovalue!))}',
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
                                                    (transMeterModels[index]
                                                                .nvalue ==
                                                            null)
                                                        ? ''
                                                        : '${nFormat2.format(double.parse(transMeterModels[index].nvalue!))}',
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
                                                    (transMeterModels[index]
                                                                .qty ==
                                                            null)
                                                        ? '0'
                                                        : '${nFormat.format(double.parse(transMeterModels[index].qty!))}',
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
                                                        ? (transMeterModels[
                                                                        index]
                                                                    .c_qty ==
                                                                null)
                                                            ? '0'
                                                            : '${nFormat.format(double.parse(transMeterModels[index].c_qty!))}'
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
                                                    (transMeterModels[index]
                                                                .c_amt ==
                                                            null)
                                                        ? '0'
                                                        : '${nFormat.format(double.parse(transMeterModels[index].c_amt!))}',
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
        if (Value_Report == 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายเดือน' ||
            Value_Report == 'รายงานข้อมูลใบแจ้งหนี้/วางบิล รายวัน') {
          if (_ReportValue_type == 'ปกติ') {
            Excgen_InvoiceChoiceReport.exportExcel_invoiceChoiceReport(
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
            Mini_Ex_InvoiceChoiceReport.mini_exportExcel_invoiceChoiceReport(
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
          }
        } else if (Value_Report == 'รายงานข้อมูลก่อน แจ้งหนี้/วางบิล') {
          Excel_BeforInvoice_Report_Choice
              .exportExcel_BeforInvoiceReport_Choice(
                  context,
                  NameFile_,
                  _verticalGroupValue_NameFile,
                  renTal_name,
                  zone_name_Invoice_Befor,
                  _TransModels,
                  Befor_Mon_Invoice,
                  Befor_YE_Invoice);
        } else if (Value_Report == 'รายงานยกเลิกสัญญาผู้เช่าล่วงหน้า') {
          Excgen_teNantnoti_Report_Choice.exportExcel_teNantnoti_Report_Choice(
            context,
            renTal_name,
            teNantModels_noti,
            zone_name_Cannotice_Mon,
            YE_Cannotice_Mon,
            monthsInThai[int.parse(Mon_Cannotice_Mon.toString()) - 1],
          );
        } else if (Value_Report == 'รายงานสัญญาผู้เช่าแบบเลือกวันที่') {
          Excgen_teNanDtae_Report_Choice.exportExcel_teNantDate_Report_Choice(
              context,
              renTal_name,
              teNantModels,
              zone_name_Pe_Mon,
              YE_Pe_Mon,
              (Mon_Pe_Mon == null)
                  ? 'null'
                  : monthsInThai[int.parse(Mon_Pe_Mon.toString()) - 1],
              (Status_pe_History.toString() == 'ใกล้หมดสัญญา')
                  ? 'รายงานรายงานผู้เช่า$Status_pe_History'
                  : 'รายงานรายงานผู้เช่า$Status_pe_Historyค้นจาก$Status_Datex_History',
              teNantModels_New,
              teNantModels_Renew);
        } else if (Value_Report == 'รายงานมิเตอร์น้ำ-ไฟฟ้า') {
          Excgen_transMeterChoiceReport.exportExcel_transMeterChoiceReport(
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
        Navigator.of(context).pop();
      }
    }
  }
}
