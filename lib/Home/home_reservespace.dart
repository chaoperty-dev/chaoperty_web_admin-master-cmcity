import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:intl/intl.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';
import '../Model/GetCustomer_Model.dart';
import '../Account/Verifi_Payment_History.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Beam/Beam_apiPassw.dart';
import '../Beam/Beam_api_check_Pay.dart';
import '../Beam/Beam_api_disabled.dart';
import '../Beam/webviewPay_beamcheckout.dart';
import '../Canvas/Type_Node.dart';
import '../Canvas/Type_Node_map.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../Man_PDF/Man_Receipt_Market_PDF.dart';
import '../Man_PDF/Man_Temporary_Receipt_PDF.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetCFinnancetrans_Model.dart';
import '../Model/GetC_rantaldata_Model.dart';
import '../Model/GetContract_Book_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_prebook_Model.dart';
import '../Model/areak_model.dart';
import '../PeopleChao/webviewPay.dart';
import '../PeopleChao/webview_show.dart';
import '../Responsive/responsive.dart';
import '../Setting/Webview.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'dart:html' as html;
import '../Account/Ac_Main_CancelBils.dart';
import '../Style/view_pagenow.dart';
import '../Style/downloadImage.dart';

class HomeReserveSpace extends StatefulWidget {
  const HomeReserveSpace({super.key});

  @override
  State<HomeReserveSpace> createState() => _HomeReserveSpaceState();
}

class _HomeReserveSpaceState extends State<HomeReserveSpace> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime newDatetime = DateTime.now();
  List<GlobalKey> _btnKeys = [];
  List<ZoneModel> zoneModels = [];
  List<AreaModel> areaModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<RenTalModel> renTalModels = [];
  List<ExpModel> expModels = [];
  List<ContractBookModel> contractBookModels = [];
  List<RenTaldataModel> renTaldataModels = [];
  List<CustomerModel> customerModels = [];
  List<CustomerModel> _customerModels = <CustomerModel>[];
  List<CustomerModel> customerModelsEx = [];
  List<CustomerModel> _customerModelsEx = <CustomerModel>[];
  List Customer_stype = [];
  List<AreakModel> selected_Area = [];
  List<AreakModel> move_Area = [];

  List<dynamic> allowedWeekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<dynamic> allo_days = [];
  List<dynamic> Date_list_selected = [];
  List<dynamic> Date_list_selectedmove = [];
  String? day_ds1, day_ds2, day_ds3, day_ds4, day_ds5;
  ////////------------------------------------>
  final _formKey = GlobalKey<FormState>();
  final TextForm_name = TextEditingController();
  final TextForm_tel = TextEditingController();
  final TextForm_tax = TextEditingController();
  final TextForm_email = TextEditingController();
  final TextForm_time = TextEditingController();
  final Form_payment1 = TextEditingController();
  final TextForm_nametype = TextEditingController();
  final TextForm_time_hr = TextEditingController();
  final TextForm_time_min = TextEditingController();
  final TextForm_time_sec = TextEditingController();

  final Formbecause_ = TextEditingController();
  List<PayMentModel> _PayMentModels = [];
  int zone_ser = 0, open_set_date = 30, _viewmap = 0, _Stap = 1, count_book = 0;
  double sum_total_book = 0;
  int ser_data_Detail = 0, conbook = -1, History_ = 0, Ser_Tap = 0, move = 0;
  DateTime now = DateTime.now();
  String? SDatex_total1_,
      LDatex_total1_,
      zone_img,
      name_img,
      naem_book,
      docno_book,
      tax_book,
      tel_book,
      date_book,
      slip_book,
      payserby,
      user_book,
      type_book,
      payref1,
      move_pay_book,
      re_book;
  String? base64_Imgmap, foder, cFinn;
  String? rtname, type, typex, renname, pkname, ser_Zonex, img_;
  String? paymentSer1,
      payment_Ptser,
      paymentName1,
      Pay_Ke,
      selectedValue,
      bname1,
      paymentBank;
  String? renTal_user,
      renTal_name,
      zone_name,
      Value_cid,
      fname_,
      pdate,
      number_custno,
      img_logo,
      img_zone,
      img_map;

  String? bill_name,
      bill_addr,
      bill_tax,
      bill_tel,
      bill_email,
      expbill,
      expbill_name,
      bill_default,
      bill_tser,
      bills_name_,
      numinvoice,
      newValuePDFimg_QR,
      tem_page_ser;
  String? base64_Slip, fileName_Slip, Slip_status;
  late InfiniteCanvasController controller;
  String prebook_bdate = '';
  String prebook_bldate = '';
  List<PrebookModel> prebookModels = [];
  List<NodeData2> nodeDatas = [];
  final TextEditingController Dropdown_Controller = TextEditingController();
  String type_book_look = 'Look';
  ////////------------------------------------>
  List Default_ = [
    'บิลธรรมดา',
  ];
  List Default2_ = [
    'บิลธรรมดา',
    'ใบกำกับภาษี',
  ];
  ////////------------------------------------>
  int Default_Receipt_type = 0;
  int TitleType_Default_Receipt = 0;
  List Default_Receipt_ = [
    'ออกใบเสร็จ',
    'ไม่ออกใบเสร็จ',
  ];

  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'สำเนา',
  ];
  ////////------------------------------------>
  @override
  void initState() {
    super.initState();
    // SDatex_total1_ = DateFormat('yyyy-MM-dd').format(now);
    read_GC_rental();
    read_GC_zone();
    // read_GC_area();
    read_GC_rental_data_All();
    read_GC_Exp();
    red_payMent();
    CG_Prebook();
    read_Customer_stype();
  }

///////////////--------------------------------------------->
  Future<Null> read_Customer_stype() async {
    if (Customer_stype.length != 0) {
      Customer_stype.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_customer_type.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      for (var map in result) {
        CustomerModel customerModelss = CustomerModel.fromJson(map);
        setState(() {
          Customer_stype.add(customerModelss.stype);
        });
      }
    } catch (e) {}
  }

///////////////--------------------------------------------->
  Future<Null> CG_Prebook() async {
    if (prebookModels.isNotEmpty) {
      setState(() {
        prebookModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_prebook_market.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          PrebookModel prebookModelss = PrebookModel.fromJson(map);

          setState(() {
            prebookModels.add(prebookModelss);
            prebook_bdate = prebookModelss.bdate.toString();
            prebook_bldate = prebookModelss.bldate.toString();
          });
          // read_check(prebookModelss.bdate, prebookModelss.bldate);
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> read_check(Sd, Ld) async {
    DateTime datex = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    // var result_data = '${formatter.format(DateTime.parse(result.toString()))}';
    // print('object');
    DateTime dateTime1 =
        DateTime.parse(Sd).isBefore(datex) ? datex : DateTime.parse(Sd);

    DateTime dateTime2 = DateTime.parse(Ld.toString());

    // Loop through the dates and print each one
    DateTime currentDate = dateTime1;
    while (currentDate.isBefore(dateTime2) ||
        currentDate.isAtSameMomentAs(dateTime2)) {
      if (allo_days.contains(DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(currentDate.toString().substring(0, 10))))) {
      } else {
        String weekday =
            DateFormat('EEEE').format(currentDate); // Get the weekday name
        if (allowedWeekdays.contains(weekday)) {
          // //(currentDate.toString().substring(0, 10));

          // Date_list_selected.add(currentDate.toString().substring(0, 10));
          // Ldatex_selected =
          //     '${formatter.format(DateTime.parse(result.toString()))}';
        }
      }
      // //print only the date part
      currentDate = currentDate.add(Duration(days: 1)); // Move to the next day
    }
    setState(() {
      if (DateTime.parse(Sd).isBefore(datex)) {
        allo_days.add(Sd);
      }
    });
  }

  Future<Null> read_GC_rental() async {
    DateTime datex = DateTime.now();
    // read_GC_areak();

    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }
    setState(() {
      if (TextForm_time_hr.text != '') {
      } else {
        // var Time = DateTime.now();

        setState(() {
          TextForm_time_hr.text = (datex.hour.toString().length < 2)
              ? '0${datex.hour}'
              : '${datex.hour}';

          TextForm_time_min.text = (datex.minute.toString().length < 2)
              ? '0${datex.minute}'
              : '${datex.minute}';
          TextForm_time_sec.text = (datex.second.toString().length < 2)
              ? '0${datex.second}'
              : '${datex.second}';
        });
      }
    });

    setState(() {
      SDatex_total1_ = '${DateFormat('yyyy-MM-dd').format(datex)}';
      LDatex_total1_ = '${DateFormat('yyyy-MM-dd').format(datex)}';
      TextForm_time.text =
          '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
    });
    read_GC_area();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //(result);
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
          var open_set_datex = int.parse(renTalModel.open_set_date!);
          setState(() {
            pkname = renTalModel.pk!.trim();
            img_ = renTalModel.img;

            open_set_date = open_set_datex == 0 ? 30 : open_set_datex;
            tem_page_ser = renTalModel.tem_page!.trim();
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
            img_logo = renTalModel.imglogo;
            img_map = renTalModel.img;
            renTalModels.add(renTalModel);
            if (bill_defaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    // //('name>>>>>  $renname');
  }

  Future<Null> move_lockpayMent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String Area_Ser1 =
        (move_Area.length > 0) ? move_Area[0].ser.toString() : '0';
    String Area_Ser2 =
        (move_Area.length > 1) ? move_Area[1].ser.toString() : '0';
    String Area_Ser3 =
        (move_Area.length > 2) ? move_Area[2].ser.toString() : '0';
    String Area_Ser4 =
        (move_Area.length > 3) ? move_Area[3].ser.toString() : '0';
    String Area_Ser5 =
        (move_Area.length > 4) ? move_Area[4].ser.toString() : '0';
    String Area_Ser6 =
        (move_Area.length > 5) ? move_Area[5].ser.toString() : '0';
    String Area_Ser7 =
        (move_Area.length > 6) ? move_Area[6].ser.toString() : '0';
    String Area_Ser8 =
        (move_Area.length > 7) ? move_Area[7].ser.toString() : '0';
    String Area_Ser9 =
        (move_Area.length > 8) ? move_Area[8].ser.toString() : '0';
    String Area_Ser10 =
        (move_Area.length > 9) ? move_Area[9].ser.toString() : '0';
    String Area_Ser11 =
        (move_Area.length > 10) ? move_Area[10].ser.toString() : '0';
    String Area_Ser12 =
        (move_Area.length > 11) ? move_Area[11].ser.toString() : '0';
    String Area_Ser13 =
        (move_Area.length > 12) ? move_Area[12].ser.toString() : '0';
    String Area_Ser14 =
        (move_Area.length > 13) ? move_Area[13].ser.toString() : '0';
    String Area_Ser15 =
        (move_Area.length > 14) ? move_Area[14].ser.toString() : '0';
    String Area_Ser16 =
        (move_Area.length > 15) ? move_Area[15].ser.toString() : '0';
    String Area_Ser17 =
        (move_Area.length > 16) ? move_Area[16].ser.toString() : '0';
    String Area_Ser18 =
        (move_Area.length > 17) ? move_Area[17].ser.toString() : '0';
    String Area_Ser19 =
        (move_Area.length > 18) ? move_Area[18].ser.toString() : '0';
    String Area_Ser20 =
        (move_Area.length > 19) ? move_Area[19].ser.toString() : '0';

    //--------------------> random_1
    int randomMilliseconds = Random().nextInt(401) + 200;
    Duration randomDuration = Duration(milliseconds: randomMilliseconds);

    int formattedMilliseconds = randomDuration.inMilliseconds % 1000;
    //--------------------> random_2

    int randomMilliseconds2 = Random().nextInt(901) + 100;
    Duration randomDuration2 = Duration(milliseconds: randomMilliseconds2);

    int formattedMilliseconds2 = randomDuration2.inMilliseconds % 1000;
    Dia_log(formattedMilliseconds);
    Future.delayed(Duration(milliseconds: formattedMilliseconds), () async {
      // //print(
      //     ' random1 : ${formattedMilliseconds}');

      Future.delayed(Duration(milliseconds: formattedMilliseconds2), () async {
        try {
          String url =
              '${MyConstant().domain}/GC_UsercheckLock_Market.php?isAdd=true&ren=$ren';
          ////print('  _Stap = 3 $url');
          var response = await http.post(
            Uri.parse(url),
            body: {
              'pdatex': SDatex_total1_.toString(),
              'aser1': Area_Ser1.toString(),
              'aser2': Area_Ser2.toString(),
              'aser3': Area_Ser3.toString(),
              'aser4': Area_Ser4.toString(),
              'aser5': Area_Ser5.toString(),
              'aser6': Area_Ser6.toString(),
              'aser7': Area_Ser7.toString(),
              'aser8': Area_Ser8.toString(),
              'aser9': Area_Ser9.toString(),
              'aser10': Area_Ser10.toString(),
              'aser11': Area_Ser11.toString(),
              'aser12': Area_Ser12.toString(),
              'aser13': Area_Ser13.toString(),
              'aser14': Area_Ser14.toString(),
              'aser15': Area_Ser15.toString(),
              'aser16': Area_Ser16.toString(),
              'aser17': Area_Ser17.toString(),
              'aser18': Area_Ser18.toString(),
              'aser19': Area_Ser19.toString(),
              'aser20': Area_Ser20.toString(),
              'Arealength': move_Area.length.toString(),
            },
          ).then((response) async {
            var result = json.decode(response.body);
            // //print(result);
            //print('  _Stap = 3 response $result');
            if (result.toString() == 'null' || result == null) {
              // print(
              //     ' Y random2 : ${formattedMilliseconds2}');
              setState(() {
                TextForm_time.text =
                    '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
              });

              in_Trans_moveselect();
            } else {
              Dialog_error();
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              var ren = preferences.getString('renTalSer');
              var ser_user = preferences.getString('ser');

              var numin = docno_book;
              var Formbecause = '';

              String url_1 =
                  '${MyConstant().domain}/UPC_finant_bill_move.php?isAdd=true&ren=$ren&user=$ser_user&numin=$numin&because=$Formbecause&stap=E';
              try {
                var response = await http.get(Uri.parse(url_1));

                var result = json.decode(response.body);
                // print(result);
                if (result.toString() == 'true') {
                  setState(() {
                    move_Area.clear();
                    move = 0;
                    contractBookModels.clear();
                    count_book = 0;
                    docno_book = null;
                    Date_list_selectedmove.clear();
                    sum_total_book = 0;
                    read_GC_area();
                  });
                }
              } catch (e) {}
            }
          }).catchError((e) async {
            Dialog_error();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            var ren = preferences.getString('renTalSer');
            var ser_user = preferences.getString('ser');

            var numin = docno_book;
            var Formbecause = '';

            String url_1 =
                '${MyConstant().domain}/UPC_finant_bill_move.php?isAdd=true&ren=$ren&user=$ser_user&numin=$numin&because=$Formbecause&stap=E';
            try {
              var response = await http.get(Uri.parse(url_1));

              var result = json.decode(response.body);
              // print(result);
              if (result.toString() == 'true') {
                setState(() {
                  move_Area.clear();
                  move = 0;
                  contractBookModels.clear();
                  count_book = 0;
                  docno_book = null;
                  Date_list_selectedmove.clear();
                  sum_total_book = 0;
                  read_GC_area();
                });
              }
            } catch (e) {}
          });
        } catch (e) {}
      });
    });
  }

  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          var paykey = _PayMentModel.key_b;
          setState(() {
            _PayMentModels.add(_PayMentModel);
            if (_PayMentModel.maket_pay! == '1') {
              // if (autox == '1') {
              Pay_Ke = paykey.toString();
              paymentSer1 = serx.toString();
              paymentName1 = ptnamex.toString();
              selectedValue = _PayMentModel.bno.toString();
              payment_Ptser = _PayMentModel.ptser.toString();
              bname1 = _PayMentModel.bname.toString();
              paymentBank = _PayMentModel.bank.toString();
              // Form_payment1.text =
              //     (sum_amt - sum_disamt).toStringAsFixed(2).toString();
              // }
              newValuePDFimg_QR = (_PayMentModel.img == null ||
                      _PayMentModel.img.toString() == '')
                  ? '${MyConstant().domain}/Awaitdownload/imagenot.png'
                  : '${MyConstant().domain}/files/$foder/payment/${_PayMentModel.img}';
            }
          });
        }
        // if (paymentName1 == null) {
        //   paymentSer1 = 0.toString();
        //   paymentName1 = 'เลือก'.toString();
        //   setState(() {
        //     Form_payment1.text =
        //         (sum_amt - sum_disamt).toStringAsFixed(2).toString();
        //   });
        // }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_Exp() async {
    if (expModels.isNotEmpty) {
      expModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_exp_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //(result);
      if (result != null) {
        for (var map in result) {
          ExpModel expModel = ExpModel.fromJson(map);
          if (expModel.show_book.toString() == '1') {
            setState(() {
              expModels.add(expModel);
            });
          } else {}
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> read_GC_rental_data_All() async {
    setState(() {
      renTaldataModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_rental_data_All.php?isAdd=true&serren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //(result);
      for (var map in result) {
        RenTaldataModel renTaldataModel = RenTaldataModel.fromJson(map);

        setState(() {
          renTaldataModels.add(renTaldataModel);
        });
/////-------------------------->
        setState(() {
          if (renTaldataModel.d1.toString() == '0') {
            allowedWeekdays.remove('Sunday');
          }
          if (renTaldataModel.d2.toString() == '0') {
            allowedWeekdays.remove('Monday');
          }
          if (renTaldataModel.d3.toString() == '0') {
            allowedWeekdays.remove('Tuesday');
          }
          if (renTaldataModel.d4.toString() == '0') {
            allowedWeekdays.remove('Wednesday');
          }
          if (renTaldataModel.d5.toString() == '0') {
            allowedWeekdays.remove('Thursday');
          }
          if (renTaldataModel.d6.toString() == '0') {
            allowedWeekdays.remove('Friday');
          }
          if (renTaldataModel.d7.toString() == '0') {
            allowedWeekdays.remove('Saturday');
          }
          ////////------------->
          if (renTaldataModel.ds1.toString() != '0000-00-00') {
            day_ds1 = renTaldataModel.ds1.toString();
            allo_days.add(day_ds1);
          }
          if (renTaldataModel.ds2.toString() != '0000-00-00') {
            day_ds2 = renTaldataModel.ds2.toString();
            allo_days.add(day_ds2);
          }
          if (renTaldataModel.ds3.toString() != '0000-00-00') {
            day_ds3 = renTaldataModel.ds3.toString();
            allo_days.add(day_ds3);
          }
          if (renTaldataModel.ds4.toString() != '0000-00-00') {
            day_ds4 = renTaldataModel.ds4.toString();
            allo_days.add(day_ds4);
          }
          if (renTaldataModel.ds5.toString() != '0000-00-00') {
            day_ds5 = renTaldataModel.ds5.toString();
            allo_days.add(day_ds5);
          }
        });
      }
      Check_AutoLdate(LDatex_total1_);
    } catch (e) {}
  }

  double _scaleFactor = 1.0; // define the initial scale factor

  void _zoomIn() {
    setState(() {
      _scaleFactor *= 1.2; // increase the scale factor by 20%
    });
  }

  void _zoomOut() {
    setState(() {
      _scaleFactor /= 1.2; // decrease the scale factor by 20%
    });
  }

  // Future<Null> read_GC_rental() async {
  //   if (renTalModels.isNotEmpty) {
  //     setState(() {
  //       renTalModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   String url =
  //       '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // //(result);
  //     if (result != null) {
  //       for (var map in result) {
  //         RenTalModel renTalModel = RenTalModel.fromJson(map);
  //         var rtnamex = renTalModel.rtname;
  //         var typexs = renTalModel.type;
  //         var typexx = renTalModel.typex;
  //         var name = renTalModel.pn!.trim();
  //         var pkqtyx = int.parse(renTalModel.pkqty!);
  //         var pkuserx = int.parse(renTalModel.pkuser!);
  //         var pkx = renTalModel.pk!.trim();
  //         var foderx = renTalModel.dbn;
  //         var img = renTalModel.img;
  //         var imglogo = renTalModel.imglogo;
  //         var open_setx = int.parse(renTalModel.open_set!);
  //         var open_set_datex = int.parse(renTalModel.open_set_date!);
  //         var mass_onx = int.parse(renTalModel.mass_on!);
  //         var imglineqrx = renTalModel.imglineqr;
  //         setState(() {
  //           // acc_2 = renTalModel.acc2!;
  //           foder = foderx;
  //           rtname = rtnamex;
  //           type = typexs;
  //           typex = typexx;
  //           renname = name;
  //           // pkqty = pkqtyx;
  //           // pkuser = pkuserx;
  //           pkname = pkx;
  //           img_ = img;
  //           // img_logo = imglogo;
  //           // open_set = open_setx;
  //           open_set_date = open_set_datex == 0 ? 30 : open_set_datex;
  //           // mass_on = mass_onx;
  //           // lineqr = imglineqrx;
  //           renTalModels.add(renTalModel);
  //         });
  //       }
  //     } else {}
  //   } catch (e) {}
  //   // //('name>>>>>  $renname');
  // }

  Future<Null> read_GC_area() async {
    if (areaModels.isNotEmpty) {
      setState(() {
        contractBookModels.clear();
        areaModels.clear();
        _areaModels.clear();
        selected_Area.clear();
      });
    }
    setState(() {
      contractBookModels.clear();
      areaModels.clear();
      _areaModels.clear();
      selected_Area.clear();
    });
    setState(() {
      contractBookModels.clear();
      areaModels.clear();
      _areaModels.clear();
      selected_Area.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zonex = zone_ser == 0 ? int.parse(zoneModels[0].ser!) : zone_ser;

    var type_b = (SDatex_total1_.toString() == LDatex_total1_.toString())
        ? 'Look'
        : type_book_look;

    String url =
        '${MyConstant().domain}/GC_areaAll_booking.php?isAdd=true&ren=$ren&zone=$zonex&datelok=$SDatex_total1_&Ldate_x=$LDatex_total1_&type=$type_b';
   //  print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //(result);
      if (result != null) {
        for (var map in result) {
          AreaModel areaModel = AreaModel.fromJson(map);

          setState(() {
            areaModels.add(areaModel);
          });
        }
      }
      setState(() {
        _areaModels = areaModels;
      });
      setState(() {
        controller = InfiniteCanvasController(nodes: [], edges: []);
      });
      red_Node_Accessories().then((value) => {red_Node()});
    } catch (e) {}
  }

  Future<void> red_Node_Accessories() async {
    setState(() {
      nodeDatas.clear();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');
    // var ren = '${widget.Ser_}';
    // var zone = ser_zn;
    String url =
        '${MyConstant().domain}/GC_nodes_area_Accessories.php?isAdd=true&ren=$ren&zser=$zone_ser';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          NodeData2 nodeData = NodeData2.fromJson(map);

          setState(() {
            nodeDatas.add(nodeData);
            // areaModels.add(areaModel);
          });
        }
        // _btnKeys = List.generate(nodeDatas.length, (_) => GlobalKey());

        // _updateNodes();
      }
    } catch (e) {
      //print('Error fetching data: $e');
    }
  }

  Future<void> red_Node() async {
    for (int index = 0; index < _areaModels.length; index++) {
      if (_areaModels[index].dy != 'null' &&
          _areaModels[index].dy != '' &&
          _areaModels[index].dy != null) {
        // //print(
        //     'Error>>>>1 ${areakModels[index].dy} ${areakModels[index].ser} ${nodeDatas.length}');
        Map<String, dynamic> map = Map();
        map['ser'] = _areaModels[index].ser;
        // map['user'] = areakModels[index].user;
        map['datex'] = _areaModels[index].datex;
        map['timex'] = _areaModels[index].timex;
        map['zser'] = _areaModels[index].zser;
        map['aser'] = _areaModels[index].aser;

        map['lncode'] = _areaModels[index].lncode;
        map['stype'] = _areaModels[index].stype;
        map['cidx'] = _areaModels[index].docno_book;
        // map['size'] = areakModels[index].size;
        // map['color'] = areakModels[index].color;
        // map['st'] = areakModels[index].st;
        map['dx'] = _areaModels[index].dx;
        map['dy'] = _areaModels[index].dy;
        map['width'] = _areaModels[index].width;
        map['height'] = _areaModels[index].height;
        map['type'] = _areaModels[index].type;
        // map['data_update'] = areakModels[index].data_update;
        // map['custno'] = areakModels[index].custno;
        // map['dtype'] = areakModels[index].dtype;
        // map['date'] = areakModels[index].date;
        // map['total'] = areakModels[index].total;
        // map['refno'] = areakModels[index].refno;
        // map['no'] = areakModels[index].no;
        // map['sname'] = areakModels[index].sname;
        map['zn'] = _areaModels[index].zn;
        // map['ln_c'] = areakModels[index].ln_c;
        // map['in_docno'] = areakModels[index].in_docno;
        // map['docno'] = areakModels[index].docno;
        // map['ser_docno'] = areakModels[index].ser_docno;
        map['quantity'] = _areaModels[index].quantity;
        // map['id'] = areakModels[index].id;
        // map['path'] = areakModels[index].path;
        // map['name'] = areakModels[index].name;
        map['ser_area'] = _areaModels[index].aser;
        // map['cid'] = areakModels[index].cid;
        map['ldate'] = _areaModels[index].ldate;
        map['rent'] = _areaModels[index].rent;
        map['con_book'] = _areaModels[index].con_book;

        NodeData2 nodeData2x = NodeData2.fromJson(map);

        setState(() {
          nodeDatas.add(nodeData2x);
        });
      }
    }

    // //print('Error ${nodeDatas.length}');
    _btnKeys = List.generate(nodeDatas.length, (_) => GlobalKey());
    _updateNodes();
  }

  void _updateNodes() {
    final nodes = nodeDatas.map((nodeData) {
      int Index = nodeDatas
          .indexWhere((item) => item.ser.toString() == nodeData.ser.toString());
      int Index_area = _areaModels
          .indexWhere((item) => item.ser.toString() == nodeData.ser.toString());
      // //print(
      //     '${nodeDatas.length} ${_btnKeys.length} ///  _btnKeys : ${_btnKeys[Index]} *,*  aser : ${nodeDatas[Index].aser}  ,  Index: $Index, NodeData: ${nodeData.ser}');
      // //print('Index --${nodeData.aser}');
      // //print(Index);
      // //print('-------------------------');areaModels
      // final color = Colors.blueGrey[200]!.withOpacity(0.9);
      final color = (selected_Area.any((area) => area.ser == nodeData.ser))
          ? Colors.yellow.shade600
          : nodeData.quantity == '' || nodeData.quantity == null
              ? Colors.green.shade200
              : nodeData.quantity == '4'
                  ? nodeData.con_book == '0'
                      ? Colors.blue.shade900
                      : nodeData.con_book == '1'
                          ? Colors.red.shade900
                          : Colors.green.shade200
                  : Colors.grey.shade100;
      //  (selected_Area.any((area) => area.ser == nodeData.ser))
      //     ? Colors.green[900]
      //     : nodeData.quantity.toString() == '' || nodeData.quantity == null
      //         ? Colors.white
      //         : Colors.grey.shade300;

      final color_text = (selected_Area.any((area) => area.ser == nodeData.ser))
          ? Colors.white
          : nodeData.quantity.toString() == '' || nodeData.quantity == null
              ? Colors.black
              : nodeData.quantity == '4'
                  ? Colors.white
                  : Colors.grey.shade500;
      return InfiniteCanvasNode(
        key: UniqueKey(),
        value: nodeDatas[Index].aser.toString(),
        allowMove: false,
        offset: Offset(
          double.parse(nodeData.dx.toString()),
          double.parse(nodeData.dy.toString()),
        ),
        size: Size(
          double.parse(nodeData.width.toString()),
          double.parse(nodeData.height.toString()),
        ),
        child: MaterialButton(
          key: _btnKeys[Index],
          onPressed: (nodeDatas[Index].aser.toString() == '0')
              ? null
              : (nodeDatas[Index].quantity == '4')
                  ? () async {
                      if (move == 0) {
                        setState(() {
                          // selected_Area.clear();
                          zone_ser = int.parse(nodeDatas[Index].zser!);
                          var doccid = nodeDatas[Index].cidx;
                          conbook = int.parse(nodeDatas[Index].con_book!);
                          read_GC_contractBook(doccid);
                          printNodeAtIndex(Index, color_text, nodeData);
                          // contractBookModels.clear();
                          // sum_total_book = 0;
                        });
                        for (int index = 0;
                            index < selected_Area.length;
                            index++) {
                          //print('nodeDatas[index].ln');
                          //print(selected_Area.length);
                          //print(index);

                          try {
                            int Indexx = nodeDatas.indexWhere((item) =>
                                item.ser.toString() ==
                                selected_Area[index].aser);

                            if (Indexx != -1) {
                              setState(() {
                                selected_Area.removeWhere((area) =>
                                    area.ser == nodeDatas[Indexx].aser);
                              });

                              printNodeAtIndex(
                                  Indexx, color_text, nodeDatas[Indexx]);
                            }
                          } catch (e) {
                            //print('Error: $e');
                          }
                        }
                      } else {
                        // PanaraConfirmDialog.showAnimatedGrow(
                        //   context,
                        //   title: "ย้ายพื้นที่",
                        //   message: "ยืนยันการย้ายพื้นที่",
                        //   confirmButtonText: "ดำเนินการต่อ",
                        //   cancelButtonText: "ยกเลิก",
                        //   onTapCancel: () {
                        //     Navigator.pop(context);
                        //   },
                        //   onTapConfirm: () {
                        //     Navigator.pop(context);
                        //   },
                        //   panaraDialogType: PanaraDialogType.success,
                        // );
                        PanaraInfoDialog.showAnimatedGrow(
                          context,
                          title: "Oops",
                          message: "พื้นที่ถูกจองแล้วกรุณาพื้นที่ว่าง!!!",
                          buttonText: "รับทราบ",
                          onTapDismiss: () async {
                            Navigator.pop(context);
                          },
                          panaraDialogType: PanaraDialogType.error,
                          barrierDismissible:
                              false, // optional parameter (default is true)
                        );
                        // setState(() {
                        //   // selected_Area.clear();
                        //   zone_ser = int.parse(nodeDatas[Index].zser!);
                        //   var doccid = nodeDatas[Index].cidx;
                        //   conbook = int.parse(nodeDatas[Index].con_book!);
                        //   read_GC_contractBook(doccid);
                        //   printNodeAtIndex(Index, color_text, nodeData);
                        //   // contractBookModels.clear();
                        //   // sum_total_book = 0;
                        // });
                        // for (int index = 0; index < move_Area.length; index++) {
                        //   //print('nodeDatas[index].ln');
                        //   //print(selected_Area.length);
                        //   //print(index);

                        //   try {
                        //     int Indexx = nodeDatas.indexWhere((item) =>
                        //         item.ser.toString() == move_Area[index].aser);

                        //     if (Indexx != -1) {
                        //       setState(() {
                        //         move_Area.removeWhere((area) =>
                        //             area.ser == nodeDatas[Indexx].aser);
                        //       });

                        //       printNodeAtIndex(
                        //           Indexx, color_text, nodeDatas[Indexx]);
                        //     }
                        //   } catch (e) {
                        //     //print('Error: $e');
                        //   }
                        // }
                      }
                    }
                  : (nodeDatas[Index].quantity == '' ||
                          nodeDatas[Index].quantity == null)
                      ? () async {
                          if (move == 0) {
                            setState(() {
                              zone_ser = int.parse(nodeDatas[Index].zser!);
                            });

                            setState(() {
                              contractBookModels.clear();
                              sum_total_book = 0;
                              conbook = -1;
                              // read_GC_contractBook(0);
                            });
                            if (selected_Area.length >= 18) {
                              /////---------------->
                              setState(() {
                                selected_Area.removeWhere(
                                    (area) => area.ser == nodeDatas[Index].ser);
                              });
                              /////---------------->
                              if ((selected_Area.length >= 18)) {
                                Dialog_errorMax();
                              } else {}
                              /////---------------->
                            } else {
                              Map<String, dynamic> map = Map();
                              map['ser'] = '${nodeDatas[Index].ser}';
                              map['datex'] = '${nodeDatas[Index].datex}';
                              map['timex'] = '${nodeDatas[Index].timex}';
                              // map['cser'] = '${nodeDatas[Index].cser}';
                              map['aser'] = '${nodeDatas[Index].aser}';
                              map['aserQout'] = '${nodeDatas[Index].quantity}';
                              map['type'] = '${nodeDatas[Index].lncode}';

                              map['rent'] = '${nodeDatas[Index].rent}';
                              map['area'] = '${nodeDatas[Index].ser_area}';
                              map['zn'] = '${nodeDatas[Index].zn}';

                              AreakModel areakModel_add =
                                  AreakModel.fromJson(map);

                              bool exists = selected_Area.any(
                                  (area) => area.ser == areakModel_add.ser);
                              if (!exists) {
                                setState(() {
                                  selected_Area.add(areakModel_add);
                                });
                              } else {
                                setState(() {
                                  selected_Area.removeWhere((area) =>
                                      area.ser == nodeDatas[Index].ser);
                                });
                              }
                            }

                            printNodeAtIndex(Index, color_text, nodeData);
                          } else {
                            setState(() {
                              zone_ser = int.parse(nodeDatas[Index].zser!);
                            });

                            // setState(() {
                            //   contractBookModels.clear();
                            //   sum_total_book = 0;
                            //   conbook = -1;
                            //   // read_GC_contractBook(0);
                            // });
                           //  print(
                             //    'contractBookModels split ${move_Area.length} >>>  ${contractBookModels[0].ln!.split(',').length}');
                            if (move_Area.length >=
                                contractBookModels[0].ln!.split(',').length) {
                              /////---------------->
                              setState(() {
                                move_Area.removeWhere(
                                    (area) => area.ser == nodeDatas[Index].ser);
                              });
                              /////---------------->
                              if ((move_Area.length >=
                                  contractBookModels[0]
                                      .ln!
                                      .split(',')
                                      .length)) {
                                Dialog_errormove();
                              } else {}
                              /////---------------->
                            } else {
                              Map<String, dynamic> map = Map();
                              map['ser'] = '${nodeDatas[Index].ser}';
                              map['datex'] = '${nodeDatas[Index].datex}';
                              map['timex'] = '${nodeDatas[Index].timex}';
                              // map['cser'] = '${nodeDatas[Index].cser}';
                              map['aser'] = '${nodeDatas[Index].aser}';
                              map['aserQout'] = '${nodeDatas[Index].quantity}';
                              map['type'] = '${nodeDatas[Index].lncode}';

                              map['rent'] = '${nodeDatas[Index].rent}';
                              map['area'] = '${nodeDatas[Index].ser_area}';
                              map['zn'] = '${nodeDatas[Index].zn}';

                              AreakModel areakModel_add =
                                  AreakModel.fromJson(map);

                              bool exists = move_Area.any(
                                  (area) => area.ser == areakModel_add.ser);
                              if (!exists) {
                                setState(() {
                                  move_Area.add(areakModel_add);
                                });
                              } else {
                                setState(() {
                                  move_Area.removeWhere((area) =>
                                      area.ser == nodeDatas[Index].ser);
                                });
                              }
                            }

                            printNodeAtIndex(Index, color_text, nodeData);
                          }
                        }
                      : () async {
                          if (move == 0) {
                            setState(() {
                              // selected_Area.clear();
                              contractBookModels.clear();
                              sum_total_book = 0;
                              conbook = -1;
                              printNodeAtIndex(Index, color_text, nodeData);
                              // read_GC_contractBook(0);
                            });
                            for (int index = 0;
                                index < selected_Area.length;
                                index++) {
                              //print('nodeDatas[index].ln');
                              //print(selected_Area.length);
                              //print(index);

                              try {
                                int Indexx = nodeDatas.indexWhere((item) =>
                                    item.ser.toString() ==
                                    selected_Area[index].aser);

                                if (Indexx != -1) {
                                  setState(() {
                                    selected_Area.removeWhere((area) =>
                                        area.ser == nodeDatas[Indexx].aser);
                                  });

                                  printNodeAtIndex(
                                      Indexx, color_text, nodeDatas[Indexx]);
                                }
                              } catch (e) {
                                //print('Error: $e');
                              }
                            }
                          } else {
                            setState(() {
                              printNodeAtIndex(Index, color_text, nodeData);
                              // read_GC_contractBook(0);
                            });
                            for (int index = 0;
                                index < move_Area.length;
                                index++) {
                              //print('nodeDatas[index].ln');
                              //print(selected_Area.length);
                              //print(index);

                              try {
                                int Indexx = nodeDatas.indexWhere((item) =>
                                    item.ser.toString() ==
                                    move_Area[index].aser);

                                if (Indexx != -1) {
                                  setState(() {
                                    move_Area.removeWhere((area) =>
                                        area.ser == nodeDatas[Indexx].aser);
                                  });

                                  printNodeAtIndex(
                                      Indexx, color_text, nodeDatas[Indexx]);
                                }
                              } catch (e) {
                                //print('Error: $e');
                              }
                            }
                          }
                        },
          child:
              TypeNodeMap(context, color, color_text, nodeData, nodeData.type),
        ),
      );
    }).toList();

    setState(() {
      controller = InfiniteCanvasController(nodes: nodes, edges: []);
      // controller.mouseDown = true;
      // controller.checkSelection(_startOffset);
      //  controller.pan(_startOffset2);
      // controller.formatter = (node) {
      //   node.offset = Offset(
      //     (node.offset.dx / gridSize.width).roundToDouble() * gridSize.width,
      //     (node.offset.dy / gridSize.height).roundToDouble() * gridSize.height,
      //   );

      // };
    });
  }

  void printNodeAtIndex(Index, color_text, nodeData) {
    var node = controller.nodes[Index].size;
    //print('Node at index $Index: $node');
    setState(() {
      // if (nodeDatas[Index].quantity == '4') {
      //   selected_Area.clear();
      // } else if (nodeDatas[Index].quantity == '' ||
      //     nodeDatas[Index].quantity == null) {
      // } else {
      //   selected_Area.clear();
      // }
      controller.nodes[Index] = CC_UP(Index, color_text, nodeData);
    });
  }

  CC_UP(Index, color_text, nodeData) {
    // final color = (selected_Area.any((area) => area.ser == nodeData.ser))
    //     ? Colors.green[900]
    //     : nodeData.quantity.toString() == '' || nodeData.quantity == null
    //         ? Colors.white
    //         : Colors.grey.shade300;

    final color = move_Area.length == 0
        ? (selected_Area.any((area) => area.ser == nodeData.ser))
            ? Colors.yellow.shade600
            : nodeData.quantity == '' || nodeData.quantity == null
                ? Colors.green.shade200
                : nodeData.quantity == '4'
                    ? nodeData.con_book == '0'
                        ? Colors.blue.shade900
                        : nodeData.con_book == '1'
                            ? Colors.red.shade900
                            : Colors.green.shade200
                    : Colors.grey.shade100
        : (move_Area.any((area) => area.ser == nodeData.ser))
            ? Colors.yellow.shade600
            : nodeData.quantity == '' || nodeData.quantity == null
                ? Colors.green.shade200
                : nodeData.quantity == '4'
                    ? nodeData.con_book == '0'
                        ? Colors.blue.shade900
                        : nodeData.con_book == '1'
                            ? Colors.red.shade900
                            : Colors.green.shade200
                    : Colors.grey.shade100;
    final color_text1 = (selected_Area.any((area) => area.ser == nodeData.ser))
        ? Colors.white
        : nodeData.quantity.toString() == '' || nodeData.quantity == null
            ? Colors.black
            : nodeData.quantity == '4'
                ? Colors.white
                : Colors.grey.shade500;
    return InfiniteCanvasNode(
      key: UniqueKey(),
      value: nodeDatas[Index].aser.toString(),
      // label: nodeData.lncode.toString(),
      // allowResize: false,
      allowMove: false,
      offset: Offset(
        double.parse(nodeData.dx.toString()),
        double.parse(nodeData.dy.toString()),
      ),
      size: Size(
        double.parse(nodeData.width.toString()),
        double.parse(nodeData.height.toString()),
      ),
      child: MaterialButton(
        key: _btnKeys[Index],
        onPressed: (nodeDatas[Index].aser.toString() == '0')
            ? null
            : (nodeDatas[Index].quantity == '4')
                ? () async {
                    if (move == 0) {
                      setState(() {
                        // selected_Area.clear();
                        zone_ser = int.parse(nodeDatas[Index].zser!);
                        var doccid = nodeDatas[Index].cidx;
                        conbook = int.parse(nodeDatas[Index].con_book!);
                        read_GC_contractBook(doccid);
                        printNodeAtIndex(Index, color_text, nodeData);
                        // contractBookModels.clear();
                        // sum_total_book = 0;
                      });

                      for (int index = 0;
                          index < selected_Area.length;
                          index++) {
                        //print('nodeDatas[index].ln');
                        //print(selected_Area.length);
                        //print(index);

                        try {
                          int Indexx = nodeDatas.indexWhere((item) =>
                              item.ser.toString() == selected_Area[index].aser);

                          if (Indexx != -1) {
                            setState(() {
                              selected_Area.removeWhere(
                                  (area) => area.ser == nodeDatas[Indexx].aser);
                            });

                            printNodeAtIndex(
                                Indexx, color_text, nodeDatas[Indexx]);
                          }
                        } catch (e) {
                          //print('Error: $e');
                        }
                      }
                    } else {
                      PanaraInfoDialog.showAnimatedGrow(
                        context,
                        title: "Oops",
                        message: "พื้นที่ถูกจองแล้วกรุณาพื้นที่ว่าง!!!",
                        buttonText: "รับทราบ",
                        onTapDismiss: () async {
                          Navigator.pop(context);
                        },
                        panaraDialogType: PanaraDialogType.error,
                        barrierDismissible:
                            false, // optional parameter (default is true)
                      );
                      // setState(() {
                      //   // selected_Area.clear();
                      //   zone_ser = int.parse(nodeDatas[Index].zser!);
                      //   var doccid = nodeDatas[Index].cidx;
                      //   conbook = int.parse(nodeDatas[Index].con_book!);
                      //   read_GC_contractBook(doccid);
                      //   printNodeAtIndex(Index, color_text, nodeData);
                      //   // contractBookModels.clear();
                      //   // sum_total_book = 0;
                      // });

                      // for (int index = 0; index < move_Area.length; index++) {
                      //   //print('nodeDatas[index].ln');
                      //   //print(selected_Area.length);
                      //   //print(index);

                      //   try {
                      //     int Indexx = nodeDatas.indexWhere((item) =>
                      //         item.ser.toString() == move_Area[index].aser);

                      //     if (Indexx != -1) {
                      //       setState(() {
                      //         move_Area.removeWhere(
                      //             (area) => area.ser == nodeDatas[Indexx].aser);
                      //       });

                      //       printNodeAtIndex(
                      //           Indexx, color_text, nodeDatas[Indexx]);
                      //     }
                      //   } catch (e) {
                      //     //print('Error: $e');
                      //   }
                      // }
                    }
                  }
                : (nodeDatas[Index].quantity == '' ||
                        nodeDatas[Index].quantity == null)
                    ? () async {
                        if (move == 0) {
                          setState(() {
                            zone_ser = int.parse(nodeDatas[Index].zser!);
                          });
                          // if (nodeDatas[Index].quantity == '4') {
                          //   print('${nodeDatas[Index].cidx}');
                          //   setState(() {
                          //     var doccid = nodeDatas[Index].cidx;
                          //     conbook = int.parse(nodeDatas[Index].con_book!);
                          //     read_GC_contractBook(doccid);
                          //     selected_Area.clear();
                          //     // contractBookModels.clear();
                          //     // sum_total_book = 0;
                          //   });
                          // } else if (nodeDatas[Index].quantity == '' ||
                          //     nodeDatas[Index].quantity == null) {
                          setState(() {
                            contractBookModels.clear();
                            sum_total_book = 0;
                            conbook = -1;
                            // read_GC_contractBook(0);
                          });
                          if (selected_Area.length >= 18) {
                            /////---------------->
                            setState(() {
                              selected_Area.removeWhere(
                                  (area) => area.ser == nodeDatas[Index].ser);
                            });
                            /////---------------->
                            if ((selected_Area.length >= 18)) {
                              Dialog_errorMax();
                            } else {}
                            /////---------------->
                          } else {
                            Map<String, dynamic> map = Map();
                            map['ser'] = '${nodeDatas[Index].ser}';
                            map['datex'] = '${nodeDatas[Index].datex}';
                            map['timex'] = '${nodeDatas[Index].timex}';
                            // map['cser'] = '${nodeDatas[Index].cser}';
                            map['aser'] = '${nodeDatas[Index].aser}';
                            map['aserQout'] = '${nodeDatas[Index].quantity}';
                            map['type'] = '${nodeDatas[Index].lncode}';
                            // map['sdate'] = '${nodeDatas[Index].sdate}';
                            // map['ldate'] = '${nodeDatas[Index].ldate}';
                            // map['dataUpdate'] =
                            //     '${nodeDatas[Index].dataUpdate}';
                            map['rent'] = '${nodeDatas[Index].rent}';
                            map['area'] = '${nodeDatas[Index].ser_area}';
                            map['zn'] = '${nodeDatas[Index].zn}';

                            AreakModel areakModel_add =
                                AreakModel.fromJson(map);

                            bool exists = selected_Area
                                .any((area) => area.ser == areakModel_add.ser);
                            if (!exists) {
                              setState(() {
                                selected_Area.add(areakModel_add);
                              });
                            } else {
                              setState(() {
                                selected_Area.removeWhere(
                                    (area) => area.ser == nodeDatas[Index].ser);
                              });
                            }
                          }
                          // } else {
                          //   setState(() {
                          //     selected_Area.clear();
                          //     contractBookModels.clear();
                          //     sum_total_book = 0;
                          //     conbook = -1;
                          //     // read_GC_contractBook(0);
                          //   });
                          // }

                          printNodeAtIndex(Index, color_text, nodeData);
                        } else {
                          setState(() {
                            zone_ser = int.parse(nodeDatas[Index].zser!);
                          });

                          if (move_Area.length >=
                              contractBookModels[0].ln!.split(',').length) {
                            /////---------------->
                            setState(() {
                              move_Area.removeWhere(
                                  (area) => area.ser == nodeDatas[Index].ser);
                            });
                            /////---------------->
                            if ((move_Area.length >=
                                contractBookModels[0].ln!.split(',').length)) {
                              Dialog_errormove();
                            } else {}
                            /////---------------->
                          } else {
                            Map<String, dynamic> map = Map();
                            map['ser'] = '${nodeDatas[Index].ser}';
                            map['datex'] = '${nodeDatas[Index].datex}';
                            map['timex'] = '${nodeDatas[Index].timex}';
                            // map['cser'] = '${nodeDatas[Index].cser}';
                            map['aser'] = '${nodeDatas[Index].aser}';
                            map['aserQout'] = '${nodeDatas[Index].quantity}';
                            map['type'] = '${nodeDatas[Index].lncode}';
                            // map['sdate'] = '${nodeDatas[Index].sdate}';
                            // map['ldate'] = '${nodeDatas[Index].ldate}';
                            // map['dataUpdate'] =
                            //     '${nodeDatas[Index].dataUpdate}';
                            map['rent'] = '${nodeDatas[Index].rent}';
                            map['area'] = '${nodeDatas[Index].ser_area}';
                            map['zn'] = '${nodeDatas[Index].zn}';

                            AreakModel areakModel_add =
                                AreakModel.fromJson(map);

                            bool exists = move_Area
                                .any((area) => area.ser == areakModel_add.ser);
                            if (!exists) {
                              setState(() {
                                move_Area.add(areakModel_add);
                              });
                            } else {
                              setState(() {
                                move_Area.removeWhere(
                                    (area) => area.ser == nodeDatas[Index].ser);
                              });
                            }
                          }
                          // } else {
                          //   setState(() {
                          //     selected_Area.clear();
                          //     contractBookModels.clear();
                          //     sum_total_book = 0;
                          //     conbook = -1;
                          //     // read_GC_contractBook(0);
                          //   });
                          // }

                          printNodeAtIndex(Index, color_text, nodeData);
                        }
                      }
                    : () async {
                        if (move == 0) {
                          setState(() {
                            // selected_Area.clear();
                            contractBookModels.clear();
                            sum_total_book = 0;
                            conbook = -1;
                            printNodeAtIndex(Index, color_text, nodeData);
                            // read_GC_contractBook(0);
                          });
                          for (int index = 0;
                              index < selected_Area.length;
                              index++) {
                            //print('nodeDatas[index].ln');
                            //print(selected_Area.length);
                            //print(index);

                            try {
                              int Indexx = nodeDatas.indexWhere((item) =>
                                  item.ser.toString() ==
                                  selected_Area[index].aser);

                              if (Indexx != -1) {
                                setState(() {
                                  selected_Area.removeWhere((area) =>
                                      area.ser == nodeDatas[Indexx].aser);
                                });

                                printNodeAtIndex(
                                    Indexx, color_text, nodeDatas[Indexx]);
                              }
                            } catch (e) {
                              //print('Error: $e');
                            }
                          }
                        } else {
                          setState(() {
                            printNodeAtIndex(Index, color_text, nodeData);
                            // read_GC_contractBook(0);
                          });
                          for (int index = 0;
                              index < move_Area.length;
                              index++) {
                            //print('nodeDatas[index].ln');
                            //print(selected_Area.length);
                            //print(index);

                            try {
                              int Indexx = nodeDatas.indexWhere((item) =>
                                  item.ser.toString() == move_Area[index].aser);

                              if (Indexx != -1) {
                                setState(() {
                                  move_Area.removeWhere((area) =>
                                      area.ser == nodeDatas[Indexx].aser);
                                });

                                printNodeAtIndex(
                                    Indexx, color_text, nodeDatas[Indexx]);
                              }
                            } catch (e) {
                              //print('Error: $e');
                            }
                          }
                        }
                      },
        child:
            TypeNodeMap(context, color, color_text1, nodeData, nodeData.type),
      ),
    );
  }

  Future<Null> read_GC_contractBook(doccid) async {
    if (contractBookModels.isNotEmpty) {
      setState(() {
        Date_list_selectedmove.clear();
        contractBookModels.clear();
        sum_total_book = 0;
        count_book = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var cid = doccid;

    //print('zone >>>>>> $zone');

    String url =
        '${MyConstant().domain}/GC_area_bookcid.php?isAdd=true&ren=$ren&cid=$cid';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          int cou = 1;
          ContractBookModel contractBookModel = ContractBookModel.fromJson(map);
          var total = double.parse(contractBookModel.total!);
          setState(() {
            count_book = count_book + cou;
            naem_book = contractBookModel.sname;
            sum_total_book = sum_total_book + total;
            docno_book = contractBookModel.cid;
            tax_book = contractBookModel.tax;
            type_book = contractBookModel.stype;
            tel_book = contractBookModel.tel;
            user_book = contractBookModel.user;
            date_book = contractBookModel.daterec;
            slip_book = contractBookModel.slip;
            payserby = contractBookModel.payser;
            payref1 = contractBookModel.ref1;
            re_book = contractBookModel.remark_book;
            move_pay_book = contractBookModel.move_pay;
            contractBookModels.add(contractBookModel);
          });
        }
      }
    } catch (e) {}

    contractBookModels.forEach((u) {
      if (Date_list_selectedmove.contains(u.date_book))
        print("duplicate ${u.date_book}");
      else
        Date_list_selectedmove.add(u.date_book);
    });
    // print('${Date_list_selectedmove.map((e) => e)}');
    // print('${Date_list_selectedmove.length}');
  }

  // bool isAllowedDate(DateTime date) {
  //   String weekday = DateFormat('EEEE').format(date); // Get the weekday name
  //   return allowedWeekdays.contains(weekday);
  // }
  bool isAllowedDate(DateTime date) {
    String weekday = DateFormat('EEEE').format(date); // Get the weekday name
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(date); // Format date as yyyy-MM-dd

    // Check if the date is a valid weekday and not contained in allo_days
    return allowedWeekdays.contains(weekday) &&
        !allo_days.contains(formattedDate);
  }

  Future<Null> _select_financial_StartDate(BuildContext context) async {
    // DateTime initialDate;
    // // String selectedDate = '2024-05-02';
    // if (allowedWeekdays.contains(DateFormat('EEEE')
    //         .format(DateTime.parse(SDatex_total1_.toString()))) &&
    //     !allo_days.contains(SDatex_total1_.toString())) {
    //   initialDate = DateTime.parse(SDatex_total1_.toString());
    // } else {
    //   // Find the next valid weekday
    //   initialDate =
    //       DateTime.parse(SDatex_total1_.toString()).add(Duration(days: 1));
    //   while (
    //       !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate)) ||
    //           allo_days.contains(DateFormat('yyyy-MM-dd')
    //               .format(DateTime.parse(initialDate.toString())))) {
    //     initialDate = initialDate.add(Duration(days: 1));
    //   }
    // }

    DateTime initialDate;
    // String selectedDate = '2024-05-02';
    if (prebook_bdate == '' ||
        prebook_bdate == null ||
        prebookModels.length == 0) {
      DateTime datex = DateTime.now();
      // setState(() {
      var Datex_selected = (SDatex_total1_ == null)
          ? '${DateFormat('yyyy-MM-dd').format(datex)}'
          : SDatex_total1_;
      // var Ldatex_selected = '${DateFormat('yyyy-MM-dd').format(datex)}';
      // });
      if (allowedWeekdays.contains(DateFormat('EEEE')
              .format(DateTime.parse(Datex_selected.toString()))) &&
          !allo_days.contains(Datex_selected.toString())) {
        initialDate = DateTime.parse(Datex_selected.toString());
      } else {
        // Find the next valid weekday
        initialDate =
            DateTime.parse(Datex_selected.toString()).add(Duration(days: 1));
        while (
            !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate)) ||
                allo_days.contains(DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(initialDate.toString())))) {
          initialDate = initialDate.add(Duration(days: 1));
        }
      }
    } else {
      if (allowedWeekdays.contains(DateFormat('EEEE')
              .format(DateTime.parse(prebook_bdate.toString()))) &&
          !allo_days.contains(prebook_bdate.toString())) {
        initialDate = DateTime.parse(prebook_bdate.toString());
      } else {
        // Find the next valid weekday
        initialDate =
            DateTime.parse(prebook_bdate.toString()).add(Duration(days: 1));
        while (
            !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate)) ||
                allo_days.contains(DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(initialDate.toString())))) {
          initialDate = initialDate.add(Duration(days: 1));
        }
      }
    }

    final Future<DateTime?> picked = showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: initialDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      //  (prebook_bdate == '' || prebook_bdate == null)
      //     ? DateTime(
      //         DateTime.now().year, DateTime.now().month, DateTime.now().day)
      //     : DateTime.parse(DateFormat('yyyy-MM-dd')
      //         .format(DateTime.parse(prebook_bdate.toString()))),

      lastDate: (prebook_bdate == '' || prebook_bdate == null)
          ? DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 25)
          : DateTime.parse(DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(prebook_bldate.toString()))),
      // DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day + 35),
      // selectableDayPredicate: _decideWhichDayToEnable,
      selectableDayPredicate: (DateTime date) {
        return isAllowedDate(date);
      },
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
      // setState(() {
      //   areaModels.clear();
      //   _areaModels.clear();
      //   selected_Area.clear();
      // });
      // if (picked != null) {
      //   var formatter = DateFormat('yyyy-MM-dd');
      //   print("${formatter.format(result!)}");
      //   setState(() {
      //     SDatex_total1_ = "${formatter.format(result)}";
      //     LDatex_total1_ = "${formatter.format(result)}";
      //   });
      //   read_GC_area();
      // }

      setState(() {
        areaModels.clear();
        _areaModels.clear();
        selected_Area.clear();
        Date_list_selected.clear();
      });

      if (picked != null) {
        var formatter = DateFormat('yyyy-MM-dd');
        var result_data =
            '${formatter.format(DateTime.parse(result.toString()))}';
        // print('${day_ds1}');
        // print('${formatter.format(DateTime.parse(result.toString()))}');

        if (day_ds1.toString() == result_data.toString() ||
            day_ds2.toString() == result_data.toString() ||
            day_ds3.toString() == result_data.toString() ||
            day_ds4.toString() == result_data.toString() ||
            day_ds5.toString() == result_data.toString()) {
          read_GC_rental();
          Dialog_Datelock();
          read_GC_area();
        } else {
          setState(() {
            SDatex_total1_ =
                '${formatter.format(DateTime.parse(result.toString()))}';
            LDatex_total1_ =
                '${formatter.format(DateTime.parse(result.toString()))}';
          });
          Check_AutoLdate(LDatex_total1_);
          // read_GC_areak();
        }
      }
    });
  }

  Future<Null> _select_financial_LtartDate(BuildContext context) async {
    // DateTime initialDate;
    // if (allowedWeekdays.contains(
    //     DateFormat('EEEE').format(DateTime.parse(datex_selected.toString())))) {
    //   initialDate = DateTime.parse(datex_selected.toString());
    // } else {
    //   // Find the next valid weekday
    //   initialDate =
    //       DateTime.parse(datex_selected.toString()).add(Duration(days: 1));
    //   while (
    //       !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate))) {
    //     initialDate = initialDate.add(Duration(days: 1));
    //   }
    // }
    DateTime initialDate;
    // String selectedDate = '2024-05-02';
    // if (allowedWeekdays.contains(DateFormat('EEEE')
    //         .format(DateTime.parse(LDatex_total1_.toString()))) &&
    //     !allo_days.contains(LDatex_total1_.toString())) {
    //   initialDate = DateTime.parse(LDatex_total1_.toString());
    // } else {
    //   // Find the next valid weekday
    //   initialDate =
    //       DateTime.parse(LDatex_total1_.toString()).add(Duration(days: 1));
    //   while (
    //       !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate)) ||
    //           allo_days.contains(DateFormat('yyyy-MM-dd')
    //               .format(DateTime.parse(initialDate.toString())))) {
    //     initialDate = initialDate.add(Duration(days: 1));
    //   }
    // }

    if (allowedWeekdays.contains(DateFormat('EEEE')
            .format(DateTime.parse(LDatex_total1_.toString()))) &&
        !allo_days.contains(LDatex_total1_.toString())) {
      initialDate = DateTime.parse(LDatex_total1_.toString());
    } else {
      // Find the next valid weekday
      initialDate =
          DateTime.parse(LDatex_total1_.toString()).add(Duration(days: 1));
      while (
          !allowedWeekdays.contains(DateFormat('EEEE').format(initialDate)) ||
              allo_days.contains(DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(initialDate.toString())))) {
        initialDate = initialDate.add(Duration(days: 1));
      }
    }

    final Future<DateTime?> picked = showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: initialDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(
          DateTime.parse(SDatex_total1_.toString()).year,
          DateTime.parse(SDatex_total1_.toString()).month,
          DateTime.parse(SDatex_total1_.toString()).day),
      lastDate: DateTime(
          DateTime.parse(SDatex_total1_.toString()).year,
          DateTime.parse(SDatex_total1_.toString()).month,
          DateTime.parse(SDatex_total1_.toString()).day + 40),
      //  (prebook_bdate == '' || prebook_bdate == null)
      //     ? DateTime(DateTime.now().year, DateTime.now().month,
      //         DateTime.now().day + 40)
      //     : DateTime.parse(DateFormat('yyyy-MM-dd')
      //         .format(DateTime.parse(prebook_bldate.toString()))),
      //  DateTime(
      //     DateTime.parse(SDatex_total1_.toString()).year,
      //     DateTime.parse(SDatex_total1_.toString()).month,
      //     DateTime.parse(SDatex_total1_.toString()).day + 40),
      // selectableDayPredicate: _decideWhichDayToEnable,
      selectableDayPredicate: (DateTime date) {
        return isAllowedDate(date);
      },
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
      setState(() {
        areaModels.clear();
        _areaModels.clear();
        selected_Area.clear();
        Date_list_selected.clear();
      });

      if (picked != null) {
        Check_AutoLdate(result);
      }
    });
  }

////--------------------------------------------------->
  Future<Null> Check_AutoLdate(result) async {
    var formatter = DateFormat('yyyy-MM-dd');
    var result_data = '${formatter.format(DateTime.parse(result.toString()))}';
    int max_now = await Check_maxdate(result);
    if (allo_days.contains(DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(result_data.toString().substring(0, 10))))) {
      read_GC_rental();
      Dialog_Datelock();
      read_GC_area();
    } else if (max_now >= 17) {
      read_GC_rental();

      read_GC_area();
      Dialog_DateMax();
    } else if (max_now < 17) {
      setState(() {
        Date_list_selected.clear();
        LDatex_total1_ =
            '${formatter.format(DateTime.parse(result.toString()))}';
      });
      read_GC_area();

      DateTime dateTime1 = DateTime.parse(SDatex_total1_.toString());
      DateTime dateTime2 = DateTime.parse(LDatex_total1_.toString());

      // Loop through the dates and print each one
      DateTime currentDate = dateTime1;
      while (currentDate.isBefore(dateTime2) ||
          currentDate.isAtSameMomentAs(dateTime2)) {
        if (allo_days.contains(DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(currentDate.toString().substring(0, 10))))) {
        } else {
          String weekday =
              DateFormat('EEEE').format(currentDate); // Get the weekday name
          if (allowedWeekdays.contains(weekday)) {
            //print(currentDate.toString().substring(0, 10));

            Date_list_selected.add(currentDate.toString().substring(0, 10));
            LDatex_total1_ =
                '${formatter.format(DateTime.parse(result.toString()))}';
          }
        }
        // Print only the date part
        currentDate =
            currentDate.add(Duration(days: 1)); // Move to the next day
      }

      //print('--------------->Date_list.length----');
      //print(max_now);
    }
  }

////--------------------------------------------------->
  Future<int> Check_maxdate(result) async {
    int date_max_Now = 0;
    var formatter = DateFormat('yyyy-MM-dd');
    DateTime dateTime1 = DateTime.parse(SDatex_total1_.toString());
    DateTime dateTime2 = DateTime.parse(result.toString());

    // Loop through the dates and print each one
    DateTime currentDate = dateTime1;
    while (currentDate.isBefore(dateTime2) ||
        currentDate.isAtSameMomentAs(dateTime2)) {
      if (allo_days.contains(DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(currentDate.toString().substring(0, 10))))) {
      } else {
        String weekday =
            DateFormat('EEEE').format(currentDate); // Get the weekday name
        if (allowedWeekdays.contains(weekday)) {
          date_max_Now++;
        }
      }
      // Print only the date part
      currentDate = currentDate.add(Duration(days: 1)); // Move to the next day
    }
    return date_max_Now;
  }

  /////////////////////////////////-------------------------------------------->
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      zoneModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var zoneSubSer = preferences.getString('zoneSubSer');
    var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      // Map<String, dynamic> map = Map();
      // map['ser'] = '0';
      // map['rser'] = '0';
      // map['zn'] = 'ทั้งหมด';
      // map['qty'] = '0';
      // map['img'] = '0';
      // map['data_update'] = '0';

      // ZoneModel zoneModelx = ZoneModel.fromJson(map);

      // setState(() {
      //   // zone_img = '${MyConstant().domain}/files/$foder/contract/$img_';
      //   zoneModels.add(zoneModelx);
      // });

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        var sub = zoneModel.sub_zone;
        // print(zoneModel.st);
        if (zoneModel.status == '0') {
          setState(() {
            zoneModels.add(zoneModel);
          });
        }
      }
      setState(() {
        zone_ser = int.parse(zoneModels[0].ser!);
        zone_name = zoneModels[0].zn;
      });
    } catch (e) {}
  }

  ///////////////////////------------------------------------------------>
  var extension_;
  var file_;

  Future<void> uploadFile_Slip() async {
    DateTime datex = DateTime.now();
    setState(() {
      TextForm_time_hr.text = (datex.hour.toString().length < 2)
          ? '0${datex.hour}'
          : '${datex.hour}';
      TextForm_time_min.text = (datex.minute.toString().length < 2)
          ? '0${datex.minute}'
          : '${datex.minute}';
      TextForm_time_sec.text = (datex.second.toString().length < 2)
          ? '0${datex.second}'
          : '${datex.second}';
    });

    setState(() {
      TextForm_time.text =
          '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
    });
    try {
      // 1. Get multiple images as bytes
      // var mediaData = await ImagePickerWeb.getMultiImagesAsBytes();

      // if (mediaData!.isEmpty) {
      //   // User canceled image selection
      //   return;
      // }

      // // 2. Convert each image to base64
      // List<String> base64Images = [];
      // for (var imageBytes in mediaData) {
      //   final String base64Image = base64Encode(imageBytes);
      //   base64Images.add(base64Image);
      // }

      // // 3. Update state with the base64-encoded images
      // setState(() {
      //   base64_Slip = base64Images.join(','); // Combine multiple base64 strings
      //   extension_ = 'png'; // Assuming the extension is always PNG
      // });
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.getImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        //print('User canceled image selection');
        return;
      } else {
        // 2. Read the image as bytes
        final imageBytes = await pickedFile.readAsBytes();
        // Define the target width and height
        final int targetWidth = 100;
        final int targetHeight = 100;

        // Resize the image to the target width and height
        // final img.Image resizedImage = img.copyResize(
        //   img.decodeImage(imageBytes)!,
        //   width: targetWidth,
        //   height: targetHeight,
        // );
        // 3. Encode the resized image as a base64 string
        //  final base64Image = base64Encode(img.encodePng(resizedImage));

        // 3. Encode the image as a base64 string
        final base64Image = base64Encode(imageBytes);
        setState(() {
          base64_Slip = base64Image;
          extension_ = 'png';
        });
      }
    } catch (e) {
      // print('Error uploading file: $e');
    }
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

      setState(() {
        fileName_Slip = 'MarKetslip_${cFinn}_${date}_$Time_.$extension_';
      });
      // 1. Capture an image from the device's gallery or camera
      // final imagePicker = ImagePicker();
      // final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

      // if (pickedFile == null) {
      //   print('User canceled image selection');
      //   return;
      // }

      try {
        // 2. Read the image as bytes
        // final imageBytes = await pickedFile.readAsBytes();

        // 3. Encode the image as a base64 string
        // final base64Image = base64Encode(imageBytes);

        // 4. Make an HTTP POST request to your server
        final url =
            '${MyConstant().domain}/File_uploadSlip_NewEdit.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

        final response = await http.post(
          Uri.parse(url),
          body: {
            'image': base64_Slip,
            'Foder': foder,
            'name': fileName_Slip,
            'ex': extension_.toString()
          }, // Send the image as a form field named 'image'
        );

        if (response.statusCode == 200) {
          OKuploadName_Slip(cFinn);
          //print('Image uploaded successfully');
        } else {
          //print('Image upload failed');
        }
      } catch (e) {
        //print('Error during image processing: $e');
      }
    } else {
      //print('ยังไม่ได้เลือกรูปภาพ');
    }
  }

  Future<void> OKuploadName_Slip(cFinn) async {
    String? TitleType_Default_Receipt_Name;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    //print('fileName_Slip > $fileName_Slip');
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
/////////-------------->
    if (TitleType_Default_Receipt == 0) {
    } else {
      setState(() {
        TitleType_Default_Receipt_Name =
            '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}';
      });
    }
    /////////-------------->
    String url_1 =
        '${MyConstant().domain}/UP_Slip_OkPay.php?isAdd=true&serren=$ren&iddocno=$cFinn&slip=$fileName_Slip&ser_payment=$paymentSer1&ser_admin=Admin';
    //print('url_1 > $url_1');

    try {
      var response = await http.get(Uri.parse(url_1));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        Future.delayed(Duration(milliseconds: 200), () async {
          Future.delayed(Duration(seconds: 1), () {
            if (Default_Receipt_type == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('ทำรายการเสร็จสิ้น ...!!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T))),
              );
            } else {
              ManPay_Receipt_PDF.ManPayReceipt_PDF(
                  '$cFinn',
                  context,
                  foder,
                  renTal_name,
                  // Form_nameshop,
                  // Form_bussshop,
                  // Form_address,
                  // Form_tax,
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  newValuePDFimg,
                  TitleType_Default_Receipt_Name,
                  tem_page_ser,
                  bills_name_,
                  '0');
            }
            setState(() {
              base64_Slip = null;
              _Stap = 1;
            });
            // Navigator.pop(context, 'OK');
            read_GC_rental();
            read_GC_zone();
            // read_GC_area();

            read_GC_rental_data_All();
            read_GC_Exp();
            red_payMent();

            // ManPay_ReceiptMarket_PDF.ManPayReceiptMarket_PDF(
            //   context,
            //   ren,
            //   foder,
            //   cFinn,
            //   bill_addr,
            //   bill_email,
            //   bill_tel,
            //   bill_tax,
            //   bill_name,
            // );
            // ManPay_Receipt_PDF.ManPayReceipt_PDF(context, ren, foder, '$cFinn',
            //     bill_addr, bill_email, bill_tel, bill_tax, bill_name, '1');
          });
        });
        // print(
        //     'testUP_Slip_OkPay--------${result.toString()}---->$ren---->$cFinn---->$fileName_Slip---->$paymentSer1---->');
      }
      // print(
      //     'UP_Slip_OkPay--------${result.toString()}---->$ren---->$cFinn---->$fileName_Slip---->$paymentSer1---->');
    } catch (e) {}
  }

  ///---------------------------------------------------------------->
  _searchBarAll() {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return TextField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              // fontSize: 22.0,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: ' Search...',
              hintStyle: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text1_,
                // fontWeight: FontWeight.bold,
                fontFamily: Font_.Fonts_T,
              ),
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
              // print(text);

              // print(customerModels.map((e) => e.docno));
              // print(_customerModels.map((e) => e.docno));

              setState(() {
                customerModels = _customerModels.where((customerModel) {
                  var notTitle = customerModel.custno.toString().toLowerCase();
                  var notTitle2 = customerModel.cname.toString().toLowerCase();
                  var notTitle3 = customerModel.scname.toString().toLowerCase();
                  var notTitle4 = customerModel.stype.toString().toLowerCase();
                  return notTitle.contains(text) ||
                      notTitle2.contains(text) ||
                      notTitle3.contains(text) ||
                      notTitle4.contains(text);
                }).toList();
              });

              // print(customerModels.map((e) => e.scname));
              // print(_customerModels.map((e) => e.scname));
            },
          );
        });
  }

  ///---------------------------------------------------------------->
  Future<Null> select_coutumerAll(Ser_Loc) async {
    if (customerModels.isNotEmpty) {
      setState(() {
        customerModels.clear();
        _customerModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? ren = preferences.getString('renTalSer');
    String url = (Ser_Loc.toString() == '1')
        ? '${MyConstant().domain}/GC_custo_se.php?isAdd=true&ren=$ren'
        : '${MyConstant().domain}/GC_custo_seLoc.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          CustomerModel customerModel = CustomerModel.fromJson(map);
          setState(() {
            customerModels.add(customerModel);
          });
        }
      }
      setState(() {
        _customerModels = customerModels;
      });
    } catch (e) {}

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
          // stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    (Ser_Loc.toString() == '1')
                        ? 'เลือกรายชื่อจากทะเบียน'
                        : ' ทะเบียนลูกค้า-ล็อกเสียบ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: [
                    if (Ser_Loc.toString() == '1')
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            customerModels
                                .sort((a, b) => a.custno!.compareTo(b.custno!));

                            setState(() {
                              _customerModels = customerModels;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.blue,
                              ),
                              Text(
                                'เรียงตามรหัสสมาชิก',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            customerModels
                                .sort((a, b) => a.stype!.compareTo(b.stype!));

                            setState(() {
                              _customerModels = customerModels;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.deepPurple,
                              ),
                              Text(
                                'เรียงตามประเภทร้านค้า',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (Ser_Loc.toString() == '1')
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              customerModels
                                  .sort((a, b) => a.sname!.compareTo(b.sname!));

                              setState(() {
                                _customerModels = customerModels;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort,
                                  color: Colors.orange,
                                ),
                                Text(
                                  'เรียงตามชื่อร้านค้า',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            if (Ser_Loc.toString() == '1') {
                              customerModels
                                  .sort((a, b) => a.cname!.compareTo(b.cname!));
                            } else {
                              customerModels
                                  .sort((a, b) => a.sname!.compareTo(b.sname!));
                            }

                            setState(() {
                              _customerModels = customerModels;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.green,
                              ),
                              Text(
                                'เรียงตามชื่อผู้เช่า/บริษัท',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (Ser_Loc.toString() == '1')
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              customerModels
                                  .sort((a, b) => a.type!.compareTo(b.type!));

                              setState(() {
                                _customerModels = customerModels;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort,
                                  color: Colors.red,
                                ),
                                Text(
                                  'เรียงตามประเภท',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                  ),
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(

                            // decoration: BoxDecoration(
                            //   color: Colors.grey.shade600,
                            //   borderRadius: const BorderRadius.only(
                            //       topLeft: Radius.circular(15),
                            //       topRight: Radius.circular(15),
                            //       bottomLeft: Radius.circular(0),
                            //       bottomRight: Radius.circular(0)),
                            // ),
                            padding: const EdgeInsets.all(4.0),
                            child: _searchBarAll()),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      //   child: CircleAvatar(
                      //     backgroundColor: Colors.black,
                      //     radius: 20,
                      //     backgroundImage:
                      //         const AssetImage('images/excel_icon.gif'),
                      //   ),
                      // ),
                    ],
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
                    dragStartBehavior: DragStartBehavior.start,
                    child: Row(
                      children: [
                        Container(
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 0.85
                              : 1000,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade600,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              '...',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Ser_Loc.toString() == '1')
                                            Expanded(
                                              flex: 2,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 18,
                                                'Img',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          if (Ser_Loc.toString() == '1')
                                            Expanded(
                                              flex: 2,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 18,
                                                'รหัสสมาชิก',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            flex: 3,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ประเภทร้านค้า',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Ser_Loc.toString() == '1')
                                            Expanded(
                                              flex: 3,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 18,
                                                'ชื่อร้าน',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            flex: 3,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ชื่อผู่เช่า/บริษัท',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              (Ser_Loc.toString() == '1')
                                                  ? 'ประเภท'
                                                  : 'ID/TAX ID',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          if (Ser_Loc.toString() == '2')
                                            Expanded(
                                              flex: 3,
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 18,
                                                'โทร',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'Select',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85
                                            : 1000,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 0)),
                                            builder: (context, snapshot) {
                                              return ListView.builder(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      customerModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        // color: Colors.green[100]!
                                                        //     .withOpacity(0.5),
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color:
                                                                Colors.black12,
                                                            width: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: ListTile(
                                                        onTap: () {
                                                          setState(() {
                                                            TextForm_name.text = (customerModels[index]
                                                                            .cname ==
                                                                        null ||
                                                                    customerModels[index]
                                                                            .cname
                                                                            .toString() ==
                                                                        'null' ||
                                                                    customerModels[index]
                                                                            .cname
                                                                            .toString() ==
                                                                        '')
                                                                ? '${customerModels[index].sname}'
                                                                : '${customerModels[index].cname}';
                                                            TextForm_tel.text =
                                                                '${customerModels[index].tel}';
                                                            TextForm_tax.text =
                                                                '${customerModels[index].tax}';
                                                            TextForm_email
                                                                    .text =
                                                                '${customerModels[index].email}';
                                                            // TextForm_time.text =
                                                            //     '${customerModels[index].addr2}';
                                                            //  Form_payment1.text = '';
                                                            TextForm_nametype
                                                                    .text =
                                                                '${customerModels[index].stype}';
                                                            //  TextForm_time_hr.text = '';
                                                            //  TextForm_time_min.text = '';
                                                            //  TextForm_time_sec.text = '';
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        title: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 100,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 18,
                                                                '${index + 1} ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  // fontWeight: FontWeight.bold,
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            if (Ser_Loc
                                                                    .toString() ==
                                                                '1')
                                                              Expanded(
                                                                flex: 2,
                                                                child: (customerModels[index].addr2 ==
                                                                            null ||
                                                                        customerModels[index].addr2 ==
                                                                            '')
                                                                    ? Container(
                                                                        // padding:
                                                                        //     const EdgeInsets
                                                                        //             .all(
                                                                        //         2.0),
                                                                        // decoration: BoxDecoration(
                                                                        //     color: Colors
                                                                        //             .grey[
                                                                        //         200],
                                                                        //     borderRadius:
                                                                        //         BorderRadius.all(
                                                                        //             Radius.circular(100))),
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Icon(Icons.image_not_supported_rounded),
                                                                        ),
                                                                      )
                                                                    : InkWell(
                                                                        child:
                                                                            Container(
                                                                          // color: Colors
                                                                          //     .black,
                                                                          child:
                                                                              CircleAvatar(
                                                                            radius:
                                                                                30.0,
                                                                            backgroundImage:
                                                                                NetworkImage(
                                                                              '${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}',
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          // setState(() {
                                                                          //   tappedIndex_ = index.toString();
                                                                          // });
                                                                          showDialog<
                                                                              String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                              // title: Container(
                                                                              //     width: MediaQuery.of(context).size.width * 0.25,
                                                                              //     height: MediaQuery.of(context).size.width * 0.35,
                                                                              //     child: Image.network(
                                                                              //       '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
                                                                              //       fit: BoxFit.contain,
                                                                              //     )),
                                                                              content: Container(
                                                                                // width: MediaQuery.of(context).size.width * 0.25,
                                                                                // height: MediaQuery.of(context).size.width * 0.32,
                                                                                child: SingleChildScrollView(
                                                                                  child: ListBody(
                                                                                    children: <Widget>[
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width * 0.25,
                                                                                        height: MediaQuery.of(context).size.width * 0.32,
                                                                                        child: Image.network(
                                                                                          '${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}',
                                                                                          fit: BoxFit.contain,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[
                                                                                Column(
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
                                                                                              color: Colors.redAccent,
                                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: TextButton(
                                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                                              child: const Text(
                                                                                                'ปิด',
                                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                              ),
                                                            if (Ser_Loc
                                                                    .toString() ==
                                                                '1')
                                                              Expanded(
                                                                flex: 2,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      18,
                                                                  customerModels[index]
                                                                              .custno ==
                                                                          null
                                                                      ? ''
                                                                      : '${customerModels[index].custno}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    // fontWeight: FontWeight.bold,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 3,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 18,
                                                                '${customerModels[index].stype}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  // fontWeight: FontWeight.bold,
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            if (Ser_Loc
                                                                    .toString() ==
                                                                '1')
                                                              Expanded(
                                                                flex: 3,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      18,
                                                                  '${customerModels[index].scname}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    // fontWeight: FontWeight.bold,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 3,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 18,
                                                                (customerModels[index].cname == null ||
                                                                        customerModels[index].cname.toString() ==
                                                                            'null' ||
                                                                        customerModels[index].cname.toString() ==
                                                                            '')
                                                                    ? '${customerModels[index].sname}'
                                                                    : '${customerModels[index].cname}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  // fontWeight: FontWeight.bold,
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 18,
                                                                (Ser_Loc.toString() ==
                                                                        '1')
                                                                    ? '${customerModels[index].type}'
                                                                    : '${customerModels[index].tax}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  // fontWeight: FontWeight.bold,
                                                                  // fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            if (Ser_Loc
                                                                    .toString() ==
                                                                '2')
                                                              Expanded(
                                                                flex: 3,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      18,
                                                                  '${customerModels[index].tel}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    // fontWeight: FontWeight.bold,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      500],
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10)),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      18,
                                                                  'Select',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    // fontWeight: FontWeight.bold,
                                                                    // fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            })),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            const Column(
              children: [
                Divider(),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Container(
                //         width: 100,
                //         decoration: const BoxDecoration(
                //           color: Colors.black,
                //           borderRadius: BorderRadius.only(
                //               topLeft: Radius.circular(10),
                //               topRight: Radius.circular(10),
                //               bottomLeft: Radius.circular(10),
                //               bottomRight: Radius.circular(10)),
                //         ),
                //         padding: const EdgeInsets.all(8.0),
                //         child: TextButton(
                //           onPressed: () {
                //             Navigator.pop(context);
                //           },
                //           child: const Text(
                //             'ยกเลิก',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //               fontFamily: FontWeight_.Fonts_T,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        );
      }),
    );
  }

//////////------------------------------------------------------>

  Future<void> downloadAndSaveFile() async {
    final url =
        '${MyConstant().domain}/Awaitdownload/ไฟล์ตัวอย่างในการเพิ่มข้อมูลลูกค้าล็อกเสียบ(เมนูหลัก).xlsx';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Uint8List data = response.bodyBytes;
      final MimeType type = MimeType.MICROSOFTEXCEL;
      final String fileName =
          "ไฟล์ตัวอย่างในการเพิ่มข้อมูลลูกค้าล็อกเสียบ(เมนูหลัก).xlsx";

      final Blob blob = Blob([data]);

      FileSaver.instance.saveFile(
        fileName,
        data,
        "xlsx",
        mimeType: type,
      );
    } else {
      throw Exception('Failed to download file');
    }
  }

  ///---------------------------------------------------------------->
  Future<void> selectFileAndReadExcel() async {
    int index = 0;
    setState(() {
      customerModelsEx.clear();
      index = 0;
    });
    setState(() {
      // Select_Cus_index.clear();
      // Select_Cus_index.clear();
      customerModelsEx.clear();
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xlsx',
          // 'csv'
        ], // Add the file extensions you want to allow
      );

      if (result != null) {
        final file = result.files.single;
        //print('Selected file: ${file.name}');

        // Access the file bytes
        final Uint8List bytes = file.bytes!;

        // Decode the Excel file using the excel package
        final excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            if (index == 0) {
              index++;
              //print(index);
            } else {
              // var type = '${row[0]!.value}';
              var nameshop = '${row[0]!.value}';
              var typeshop = '${row[1]!.value}';
              var bussshop = '${row[2]!.value}';
              // var bussscontact = '${row[2]!.value}';
              var address = '${row[3]!.value}';
              var tel = '${row[4]!.value}';
              var email = '${row[5]!.value}';
              var tax = '${row[6]!.value}';

              Map<String, dynamic> map = Map();

              map['ser'] = '';
              map['user'] = '';
              map['rser'] = '';
              map['datex'] = '';
              map['timex'] = '';
              map['custno'] = '';
              map['taxno'] = '';
              map['scname'] = '${nameshop.toString().trim()}';
              map['stype'] = '${typeshop.toString().trim()}';
              map['tser'] = '';
              map['typeser'] =
                  (type.toString().trim() == 'ส่วนตัว/บุคคลธรรมดา') ? '0' : '1';
              map['type'] = '${type.toString().trim()}';
              map['cname'] = '${bussshop.toString().trim()}';
              map['branch'] = '';
              map['attn'] = '';
              map['addr_1'] = '${address.toString().trim()}';
              map['addr_2'] = '';
              map['zip'] = '';
              map['tel'] = '${tel.toString().trim()}';
              map['tax'] = '${tax.toString().trim()}';
              map['fax'] = '';
              map['email'] = '${email.toString().trim()}';
              map['lineid'] = '';
              map['lastday'] = '';
              map['status'] = '';
              map['st'] = '';
              map['map_update'] = '';
              map['cid'] = '';
              map['docno'] = '';
              map['sdate'] = '';
              map['ldate'] = '';
              map['period'] = '';
              map['nday'] = '';
              map['ctype'] = '';
              map['zser'] = '';
              map['zn'] = '';
              map['aser'] = '';
              map['ln'] = '';
              map['qty'] = '';
              map['area'] = '';
              map['rtser'] = '';
              map['rtname'] = '';
              map['user_name'] = '';
              map['passw'] = '';
              map['sname'] = '';

              try {
                CustomerModel customerModel = CustomerModel.fromJson(map);

                setState(() {
                  customerModelsEx.add(customerModel);
                });
                // print('table ---------------- >${sname}');
              } catch (e) {}
              //print(map);
            }
          }
        }
      } else {
        // User canceled the file selection.
        //print('File selection canceled.');
      }
    } catch (e) {
      ////print('Error selecting or reading the file: $e');
    }
  }

  ///---------------------------------------------------------------->
  Future<Null> select_coutumer_Ex() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
          // stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'เลือกรายชื่อจาก Excel',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          downloadAndSaveFile();
                        },
                        child: Container(
                          width: 200,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: Center(
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 14,
                              'ตัวอย่าง/รูปแบบไฟล์',
                              style: TextStyle(
                                color: Colors.white,
                                // fontWeight: FontWeight.bold,
                                // fontFamily: FontWeight_.Fonts_T,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          selectFileAndReadExcel();
                        },
                        child: Container(
                          width: 150,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: Center(
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 14,
                              'เลือกไฟล์/นำเข้าไฟล์',
                              style: TextStyle(
                                color: Colors.white,
                                // fontWeight: FontWeight.bold,
                                // fontFamily: FontWeight_.Fonts_T,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            customerModels
                                .sort((a, b) => a.sname!.compareTo(b.sname!));

                            setState(() {
                              _customerModelsEx = customerModelsEx;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.orange,
                              ),
                              Text(
                                'เรียงตามชื่อร้านค้า',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            customerModels
                                .sort((a, b) => a.cname!.compareTo(b.cname!));

                            setState(() {
                              _customerModelsEx = customerModelsEx;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.green,
                              ),
                              Text(
                                'เรียงตามชื่อผู้เช่า/บริษัท',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            customerModelsEx
                                .sort((a, b) => a.stype!.compareTo(b.stype!));

                            setState(() {
                              _customerModelsEx = customerModelsEx;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.deepPurple,
                              ),
                              Text(
                                'เรียงตามประเภทร้านค้า',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                  ),
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(

                            // decoration: BoxDecoration(
                            //   color: Colors.grey.shade600,
                            //   borderRadius: const BorderRadius.only(
                            //       topLeft: Radius.circular(15),
                            //       topRight: Radius.circular(15),
                            //       bottomLeft: Radius.circular(0),
                            //       bottomRight: Radius.circular(0)),
                            // ),
                            padding: const EdgeInsets.all(4.0),
                            child: _searchBarAll()),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      //   child: CircleAvatar(
                      //     backgroundColor: Colors.black,
                      //     radius: 20,
                      //     backgroundImage:
                      //         const AssetImage('images/excel_icon.gif'),
                      //   ),
                      // ),
                    ],
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
                    dragStartBehavior: DragStartBehavior.start,
                    child: Row(
                      children: [
                        Container(
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 0.85
                              : 1000,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade600,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      child: Row(
                                        children: const [
                                          SizedBox(
                                            width: 100,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              '...',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ประเภทร้านค้า',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ชื่อร้าน',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ชื่อผู่เช่า/บริษัท',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'ID/TAX ID',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'เบอร์โทร',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 18,
                                              'Select',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85
                                            : 1000,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 0)),
                                            builder: (context, snapshot) {
                                              return (customerModelsEx.length ==
                                                      0)
                                                  ? Center(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.red[100],
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(0),
                                                              topRight: Radius
                                                                  .circular(0),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        // width: 100,
                                                        child: Center(
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 18,
                                                            'ไม่พบข้อมูล/กรุณาอัพโหลด Excel',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          customerModelsEx
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Container(
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
                                                                  .all(0),
                                                          child: ListTile(
                                                            onTap: () {
                                                              setState(() {
                                                                TextForm_name
                                                                        .text =
                                                                    '${customerModelsEx[index].cname}';
                                                                TextForm_tel
                                                                        .text =
                                                                    '${customerModelsEx[index].tel}';
                                                                TextForm_tax
                                                                        .text =
                                                                    '${customerModelsEx[index].tax}';
                                                                TextForm_email
                                                                        .text =
                                                                    '${customerModelsEx[index].email}';
                                                                // TextForm_time.text =
                                                                //     '${customerModels[index].addr2}';
                                                                //  Form_payment1.text = '';
                                                                TextForm_nametype
                                                                        .text =
                                                                    '${customerModelsEx[index].stype}';
                                                                //  TextForm_time_hr.text = '';
                                                                //  TextForm_time_min.text = '';
                                                                //  TextForm_time_sec.text = '';
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            title: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${index + 1} ',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${customerModelsEx[index].stype}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${customerModelsEx[index].scname}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${customerModelsEx[index].cname}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${customerModelsEx[index].tax}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        18,
                                                                    '${customerModelsEx[index].tel}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontWeight: FontWeight.bold,
                                                                      // fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      minFontSize:
                                                                          10,
                                                                      maxFontSize:
                                                                          18,
                                                                      'Select',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                        // fontWeight: FontWeight.bold,
                                                                        // fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                            })),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            const Column(
              children: [
                Divider(),
              ],
            ),
          ],
        );
      }),
    );
  }

  ///---------------------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            width: (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width
                : 1200,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.TiTile_Box,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();

                              String? _route = preferences.getString('route');

                              MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) =>
                                    AdminScafScreen(route: _route),
                              );
                              Navigator.pushAndRemoveUntil(
                                  context, route, (route) => false);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              // Icons.home_filled,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: viewpage(context, '0'),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: ListBody(children: <Widget>[
                Container(
                  width: (Responsive.isDesktop(context))
                      ? MediaQuery.of(context).size.width
                      : 1200,
                  // height: MediaQuery.of(context).size.height * 0.65,
                  child: SizedBox(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        dragStartBehavior: DragStartBehavior.start,
                        child: Row(
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [area_show(context)],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  (History_ == 0)
                                      ? Row(
                                          crossAxisAlignment:
                                              (type_book_look.toString() ==
                                                      'Look')
                                                  ? CrossAxisAlignment.start
                                                  : CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            area_showbook2(context),
                                            // (type_book_look.toString() ==
                                            //             'Look' &&
                                            //         contractBookModels.length ==
                                            //             0)
                                            //     ? Text(
                                            //         '123',
                                            //         textAlign: TextAlign.start,
                                            //         style: TextStyle(
                                            //             fontSize: 14,
                                            //             color: Colors.blue[
                                            //                 700], //Colors.white,
                                            //             fontWeight:
                                            //                 FontWeight.bold,
                                            //             fontFamily: FontWeight_
                                            //                 .Fonts_T),
                                            //       )
                                            //     :
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                setState(() {
                                                                  LDatex_total1_ =
                                                                      SDatex_total1_;
                                                                });
                                                                setState(() {
                                                                  type_book_look =
                                                                      'Look';
                                                                  selected_Area
                                                                      .clear();
                                                                  contractBookModels
                                                                      .clear();

                                                                  read_GC_area();
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 150,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: (type_book_look
                                                                              .toString() ==
                                                                          'Look')
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .grey,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8)),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child: Center(
                                                                  child: Text(
                                                                    'ดูประวัติการจอง',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.white, //Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontFamily: FontWeight_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                setState(() {
                                                                  LDatex_total1_ =
                                                                      SDatex_total1_;
                                                                });
                                                                setState(() {
                                                                  type_book_look =
                                                                      'Book';
                                                                  selected_Area
                                                                      .clear();
                                                                  contractBookModels
                                                                      .clear();
                                                                  read_GC_area();
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 150,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: (type_book_look
                                                                              .toString() ==
                                                                          'Book')
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .grey,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
                                                                      topLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              8),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              8),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              8)),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child: Center(
                                                                  child: Text(
                                                                    'จองพื้นที่',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.white, //Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontFamily: FontWeight_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]),
                                                  ),
                                                  (contractBookModels.length ==
                                                              0 &&
                                                          type_book_look
                                                                  .toString() ==
                                                              'Look')
                                                      ? Container(
                                                          width: (Responsive
                                                                  .isDesktop(
                                                                      context))
                                                              ? (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >=
                                                                      1200)
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.3
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4
                                                              : 800,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              2,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .receipt,
                                                                    size: 100,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'โซนพื้นที่ $zone_name',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black, //Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontFamily: FontWeight_.Fonts_T),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          4.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppbackgroundColor
                                                                          .Sub_Abg_Colors,
                                                                      borderRadius: const BorderRadius
                                                                              .only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .red,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            4.0),
                                                                    child: Text(
                                                                      'กรุณา เลือกวันที่และพื้นที่ๆ ท่านต้องการดู',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: Colors.red, //Colors.white,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontFamily: FontWeight_.Fonts_T),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : area_show2(context),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : (History_ == 1)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 0),
                                              child: Verifi_Payment_History(),
                                            )
                                          : MainCancelBilsScreen(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]))),
            ])));
  }

  // ///---------------------------------------------------------------->
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: MediaQuery.of(context).size.height,
  //     padding: EdgeInsets.all(8),
  //     child: ScrollConfiguration(
  //       behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
  //         PointerDeviceKind.touch,
  //         PointerDeviceKind.mouse,
  //       }),
  //       child: SingleChildScrollView(
  //         child:
  //             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
  //             child: Container(
  //               width: MediaQuery.of(context).size.width,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.5),
  //                 borderRadius: const BorderRadius.only(
  //                     topLeft: Radius.circular(10),
  //                     topRight: Radius.circular(10),
  //                     bottomLeft: Radius.circular(10),
  //                     bottomRight: Radius.circular(10)),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Padding(
  //                     padding: EdgeInsets.all(4.0),
  //                     child: Row(
  //                       children: [
  //                         Container(
  //                           height: 40,
  //                           width: 40,
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(7),
  //                             color: Colors.blue[700],
  //                           ),
  //                           child: IconButton(
  //                             onPressed: () async {
  //                               SharedPreferences preferences =
  //                                   await SharedPreferences.getInstance();

  //                               String? _route = preferences.getString('route');

  //                               MaterialPageRoute route = MaterialPageRoute(
  //                                 builder: (context) =>
  //                                     AdminScafScreen(route: _route),
  //                               );
  //                               Navigator.pushAndRemoveUntil(
  //                                   context, route, (route) => false);
  //                             },
  //                             icon: Icon(
  //                               Icons.home_filled,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         // InkWell(
  //                         //   onTap: () async {
  //                         //     SharedPreferences preferences =
  //                         //         await SharedPreferences.getInstance();

  //                         //     String? _route = preferences.getString('route');

  //                         //     MaterialPageRoute route = MaterialPageRoute(
  //                         //       builder: (context) =>
  //                         //           AdminScafScreen(route: _route),
  //                         //     );
  //                         //     Navigator.pushAndRemoveUntil(
  //                         //         context, route, (route) => false);
  //                         //   },
  //                         //   child: Container(
  //                         //       width: 130,
  //                         //       padding: const EdgeInsets.all(8.0),
  //                         //       decoration: BoxDecoration(
  //                         //         color: Colors.green.shade900,
  //                         //         borderRadius: const BorderRadius.only(
  //                         //             topLeft: Radius.circular(8),
  //                         //             topRight: Radius.circular(8),
  //                         //             bottomLeft: Radius.circular(8),
  //                         //             bottomRight: Radius.circular(8)),
  //                         //         border: Border.all(
  //                         //             color: Colors.white, width: 1),
  //                         //       ),
  //                         //       child: const Center(
  //                         //         child: Text(
  //                         //           'Dashboard',
  //                         //           style: TextStyle(
  //                         //             color: Colors.white,
  //                         //             fontWeight: FontWeight.bold,
  //                         //             fontFamily: FontWeight_.Fonts_T,
  //                         //           ),
  //                         //         ),
  //                         //       )),
  //                         // ),
  //                       ],
  //                     ),
  //                   ),
  //                   Row(children: [
  //                     // const Padding(
  //                     //   padding: EdgeInsets.all(4.0),
  //                     //   child: Text(
  //                     //     'รายรับ :',
  //                     //     style: TextStyle(
  //                     //       color: ReportScreen_Color.Colors_Text2_,
  //                     //       fontWeight: FontWeight.bold,
  //                     //       fontFamily: FontWeight_.Fonts_T,
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                     Padding(
  //                       padding: EdgeInsets.all(8.0),
  //                       child: Text(
  //                         'วันที่ ',
  //                         style: TextStyle(
  //                           color: ReportScreen_Color.Colors_Text2_,
  //                           // fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T,
  //                         ),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
  //                       child: InkWell(
  //                         onTap: () {
  //                           CG_Prebook().then((result) {
  //                             _select_financial_StartDate(context);
  //                           });
  //                         },
  //                         child: Container(
  //                             decoration: BoxDecoration(
  //                               color: AppbackgroundColor.Sub_Abg_Colors,
  //                               borderRadius: const BorderRadius.only(
  //                                   topLeft: Radius.circular(10),
  //                                   topRight: Radius.circular(10),
  //                                   bottomLeft: Radius.circular(10),
  //                                   bottomRight: Radius.circular(10)),
  //                               border:
  //                                   Border.all(color: Colors.grey, width: 1),
  //                             ),
  //                             height: 25,
  //                             width: 120,
  //                             padding: const EdgeInsets.all(2.0),
  //                             child: Center(
  //                               child: Text(
  //                                 (SDatex_total1_ == null)
  //                                     ? 'เลือก'
  //                                     : '$SDatex_total1_',
  //                                 style: const TextStyle(
  //                                   fontSize: 12,
  //                                   color: ReportScreen_Color.Colors_Text2_,
  //                                   // fontWeight: FontWeight.bold,
  //                                   fontFamily: Font_.Fonts_T,
  //                                 ),
  //                               ),
  //                             )),
  //                       ),
  //                     ),
  //                   ]),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Container(
  //             width: MediaQuery.of(context).size.width,
  //             // height: MediaQuery.of(context).size.width,
  //             child: StreamBuilder(
  //                 stream: Stream.periodic(const Duration(seconds: 0)),
  //                 builder: (context, snapshot) {
  //                   return ScrollConfiguration(
  //                     behavior: ScrollConfiguration.of(context)
  //                         .copyWith(dragDevices: {
  //                       PointerDeviceKind.touch,
  //                       PointerDeviceKind.mouse,
  //                     }),
  //                     child: Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       // height: MediaQuery.of(context).size.width * 0.43,
  //                       child: SingleChildScrollView(
  //                         scrollDirection: Axis.horizontal,
  //                         child: Container(
  //                           // width: MediaQuery.of(context).size.width,
  //                           // height: MediaQuery.of(context).size.width * 0.43,
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             children: [
  //                               SizedBox(
  //                                 height: 5,
  //                               ),
  //                               Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 mainAxisAlignment: MainAxisAlignment.start,
  //                                 children: [
  //                                   // area_show2(context),
  //                                   area_show(context),
  //                                 ],
  //                               ),
  //                               SizedBox(
  //                                 height: 5,
  //                               ),
  //                               Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 mainAxisAlignment: MainAxisAlignment.start,
  //                                 children: [
  //                                   area_showbook2(context),
  //                                   area_show2(context),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }),
  //           ),
  //         ]),
  //       ),
  //     ),
  //   );
  // }

  Padding area_show(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
          padding: const EdgeInsets.all(2),
          width: (Responsive.isDesktop(context))
              ? (MediaQuery.of(context).size.width >= 1200)
                  ? MediaQuery.of(context).size.width * 0.85
                  : MediaQuery.of(context).size.width * 0.87
              : 1500,
          // height: MediaQuery.of(context).size.width *
          //     0.43,
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(10),
          //   color: Colors.white,
          //   // color: Color(0xFFA8BFDB),
          // ),
          decoration: BoxDecoration(
            color: AppbackgroundColor.TiTile_Box,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            // border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (History_ == 1)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Icon(
                            //   Icons.history,
                            //   color: Colors.black,
                            // ),
                            Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Translate.TranslateAndSetText(
                                  'ประวัติชำระรอตรวจสอบ',
                                  ChaoAreaScreen_Color.Colors_Text2_,
                                  TextAlign.center,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  16,
                                  2),
                            ),
                          ],
                        ),
                      )
                    : (History_ == 2)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Icon(
                                //   Icons.history,
                                //   color: Colors.black,
                                // ),
                                Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Translate.TranslateAndSetText(
                                      'ประวัติยกเลิกชำระ/จอง',
                                      ChaoAreaScreen_Color.Colors_Text2_,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      16,
                                      2),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Translate.TranslateAndSetText(
                                      'โซนพื้นที่เช่า :',
                                      ChaoAreaScreen_Color.Colors_Text2_,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      14,
                                      2),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      width: 200,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                            isExpanded: true,
                                            searchController:
                                                Dropdown_Controller,
                                            searchInnerWidget: Container(
                                              width: 200,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[100]!
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              child: TextFormField(
                                                expands: true,
                                                maxLines: null,
                                                controller: Dropdown_Controller,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                                  hintText: 'Search...',
                                                  // fillColor: Colors.red[300],
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            hint: Translate.TranslateAndSetText(
                                                zone_name == null
                                                    ? 'ทั้งหมด'
                                                    : '$zone_name',
                                                ChaoAreaScreen_Color
                                                    .Colors_Text2_,
                                                TextAlign.center,
                                                FontWeight.bold,
                                                FontWeight_.Fonts_T,
                                                14,
                                                2),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TextHome_Color
                                                  .TextHome_Colors,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontFamily: Font_.Fonts_T),
                                            iconSize: 30,
                                            buttonHeight: 35,
                                            dropdownDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            items: zoneModels
                                                .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          '${item.ser},${item.zn}',
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.zn!,
                                                            maxLines: 2,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          Divider(
                                                            color: Colors
                                                                .grey[300],
                                                            height: 4.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),

                                            // value: selectedValue,
                                            onChanged: (value) async {
                                              var zones = value!.indexOf(',');
                                              var zoneSer =
                                                  value.substring(0, zones);
                                              var zonesName =
                                                  value.substring(zones + 1);
                                              // //print('mmmmm ${zoneSer.toString()} $zonesName');

                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              preferences.setString('zoneSer',
                                                  zoneSer.toString());
                                              preferences.setString('zonesName',
                                                  zonesName.toString());

                                              int selectedIndex = zoneModels
                                                  .indexWhere((element) =>
                                                      element.ser == zoneSer &&
                                                      element.zn == zonesName);
                                              // if (selectedIndex == 0) {
                                              //   setState(() {
                                              //     zone_ser = 0;
                                              //     zone_name = null;
                                              //     name_img = null;
                                              //     zone_img = null;
                                              //     move = 0;
                                              //     move_Area.clear();
                                              //     read_GC_area();
                                              //     read_GC_contractBook(0);
                                              //     _Stap = 1;
                                              //   });
                                              // } else {
                                              setState(() {
                                                zone_name = zonesName;
                                                zone_ser = int.parse(
                                                    zoneModels[selectedIndex]
                                                        .ser!);
                                                name_img =
                                                    zoneModels[selectedIndex]
                                                        .img;
                                                zone_img = int.parse(zoneModels[
                                                                selectedIndex]
                                                            .ser!) ==
                                                        0
                                                    ? '${MyConstant().domain}/files/$foder/contract/$img_'
                                                    : '${MyConstant().domain}/files/$foder/zone/${zoneModels[selectedIndex].img}';
                                                read_GC_area();
                                                read_GC_contractBook(0);
                                                _Stap = 1;
                                                move = 0;
                                                move_Area.clear();
                                              });
                                              // }
                                            },
                                            searchMatchFn: (item, searchValue) {
                                              return item.value
                                                  .toString()
                                                  .contains(searchValue);
                                            },
                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                Dropdown_Controller.clear();
                                              }
                                            }),
                                      ),
                                    )),
                                if (type_book_look.toString() == 'Look')
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        'ประวัติการจอง วันที่ :',
                                        ChaoAreaScreen_Color.Colors_Text2_,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                  ),
                                if (type_book_look.toString() == 'Look')
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: InkWell(
                                      onTap: () {
                                        CG_Prebook().then((result) {
                                          setState(() {
                                            move = 0;
                                            move_Area.clear();
                                          });
                                          _select_financial_StartDate(context);
                                        });
                                      },
                                      child: Container(
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
                                          // height: 25,
                                          width: 120,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              (SDatex_total1_ == null)
                                                  ? 'เลือก'
                                                  : '$SDatex_total1_',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: ReportScreen_Color
                                                    .Colors_Text2_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    // width: 100,
                    // height: 50,
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                History_ = 0;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: (History_ == 0)
                                    ? Colors.blue[400]
                                    : Colors.blue[200],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                border: (History_ == 0)
                                    ? Border.all(color: Colors.white, width: 1)
                                    : null,
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pin_drop,
                                    color: Colors.blue[800],
                                  ),
                                  Text(
                                    'จองล็อกเสียบ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                History_ = 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: (History_ == 1)
                                    ? Colors.orange[400]
                                    : Colors.orange[200],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                border: (History_ == 1)
                                    ? Border.all(color: Colors.white, width: 1)
                                    : null,
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt,
                                    color: Colors.orange[800],
                                  ),
                                  Text(
                                    'ประวัติรอตรวจสอบ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                History_ = 2;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: (History_ == 2)
                                    ? Colors.red[400]
                                    : Colors.red[200],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                border: (History_ == 2)
                                    ? Border.all(color: Colors.white, width: 1)
                                    : null,
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: Colors.red[800],
                                  ),
                                  Text(
                                    'ประวัติยกเลิกชำระ/จอง',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                // Expanded(
                //     flex: 8,
                //     child:
                //      Padding(
                //       padding: const EdgeInsets.all(4.0),
                //       child: ScrollConfiguration(
                //         behavior: ScrollConfiguration.of(context)
                //             .copyWith(dragDevices: {
                //           PointerDeviceKind.touch,
                //           PointerDeviceKind.mouse,
                //         }),
                //         child: SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Row(children: [
                //             for (int index = 0;
                //                 index < zoneModels.length;
                //                 index++)
                //               Padding(
                //                   padding: const EdgeInsets.all(4.0),
                //                   child: InkWell(
                //                     onTap: () {
                //                       // read_GC_Pos();
                //                       setState(() {
                //                         zone_ser = int.parse(
                //                             zoneModels[index].ser!);
                //                         name_img = zoneModels[index].img;
                //                         zone_img = int.parse(
                //                                     zoneModels[index]
                //                                         .ser!) ==
                //                                 0
                //                             ? '${MyConstant().domain}/files/$foder/contract/$img_'
                //                             : '${MyConstant().domain}/files/$foder/zone/${zoneModels[index].img}';
                //                         read_GC_area();
                //                         read_GC_contractBook(0);
                //                         _Stap = 1;
                //                       });
                //                     },
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: zone_ser ==
                //                                 int.parse(
                //                                     zoneModels[index]
                //                                         .ser!)
                //                             ? Colors.blue[700]
                //                             : Colors.grey,
                //                         borderRadius:
                //                             const BorderRadius.only(
                //                                 topLeft:
                //                                     Radius.circular(10),
                //                                 topRight:
                //                                     Radius.circular(10),
                //                                 bottomLeft:
                //                                     Radius.circular(10),
                //                                 bottomRight:
                //                                     Radius.circular(10)),
                //                         border: Border.all(
                //                             color: Colors.white,
                //                             width: 1),
                //                       ),
                //                       padding: const EdgeInsets.all(8.0),
                //                       child: Center(
                //                         child: Text(
                //                           zoneModels[index].zn.toString(),
                //                           style: TextStyle(
                //                               color: Colors.white,
                //                               fontWeight: FontWeight.bold,
                //                               fontFamily:
                //                                   FontWeight_.Fonts_T),
                //                         ),
                //                       ),
                //                     ),
                //                   )),
                //           ]),
                //         ),
                //       ),
                //     ),
                //     ),
              ])),
    );
  }

  Padding area_show2(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(8),
          width: (Responsive.isDesktop(context))
              ? (MediaQuery.of(context).size.width >= 1200)
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.4
              : 800,

          // width: MediaQuery.of(context).size.width * 0.3,
          // // height: MediaQuery.of(context).size.width * 0.38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            // color: Color(0xFFA8BFDB),
          ),
          child: contractBookModels.length == 0
              ? area_showbook(context)
              : Container(
                  padding: const EdgeInsets.all(8),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 0.3,
                  // color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Text(
                          //   'ปิด',
                          //   textAlign: TextAlign.end,
                          //   style: TextStyle(
                          //       fontSize: 18,
                          //       color: Colors.red[700], //Colors.white,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T),
                          // ),
                          InkWell(
                            onTap: () async {
                              DateTime datex = DateTime.now();
                              setState(() {
                                SDatex_total1_ =
                                    '${DateFormat('yyyy-MM-dd').format(datex)}';
                                LDatex_total1_ =
                                    '${DateFormat('yyyy-MM-dd').format(datex)}';
                                read_GC_area();
                                contractBookModels.clear();
                              });
                              // Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.highlight_off,
                                  size: 30, color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                width: 40,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(7),
                                //   color: Colors.blue[700],
                                // ),
                                child: Text(
                                  'วันที่จอง : $SDatex_total1_',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700], //Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                width: 40,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(7),
                                //   color: Colors.blue[700],
                                // ),
                                child: Text(
                                  'วันที่ทำรายการ : $date_book',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700], //Colors.white,
                                      // fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            )
                          ]),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              // height: 40,
                              // width: 40,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(7),
                              //   color: Colors.blue[700],
                              // ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name : $naem_book',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .blue[700], //Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ประเภท : ${contractBookModels[0].stype}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .grey[700], //Colors.white,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tax : $tax_book',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .grey[700], //Colors.white,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'โซน : ${contractBookModels[0].zn}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .grey[700], //Colors.white,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              // height: 40,
                              // width: 40,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(7),
                              //   color: Colors.blue[700],
                              // ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'เลขที่การจอง : $docno_book',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .blue[700], //Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .grey[700], //Colors.white,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Tel : $tel_book',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors
                                                .grey[700], //Colors.white,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${contractBookModels[0].ln}',
                                          textAlign: TextAlign.end,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors
                                                  .grey[700], //Colors.white,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  re_book == ''
                                      ? SizedBox()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '$re_book',
                                                textAlign: TextAlign.end,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red[
                                                        700], //Colors.white,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      move == 1
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'พื้นที่',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black, //Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'ราคา',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Colors.black, //Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      move == 1 ? SizedBox() : Divider(),
                      move == 1
                          ? SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width / 5,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Column(
                                              children: [
                                                for (int index = 0;
                                                    index <
                                                        contractBookModels
                                                            .length;
                                                    index++)
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black12,
                                                          width: 1,
                                                        ),
                                                        // left: BorderSide(
                                                        //   color: Colors.black12,
                                                        //   width: 1,
                                                        // ),
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                (contractBookModels[index].date_book ==
                                                                            null ||
                                                                        contractBookModels[index].date_book.toString() ==
                                                                            '')
                                                                    ? '${index + 1}. วันที่ : ${contractBookModels[index].date_book}'
                                                                    : '${index + 1}. วันที่ : ${DateFormat('dd-MM').format(DateTime.parse('${contractBookModels[index].date_book} 00:00:00'))}-${DateTime.parse('${contractBookModels[index].date_book} 00:00:00').year + 543}',
                                                                // '${contractBookModels[index].date_book}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                '',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                '${contractBookModels[index].expname}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Colors.black, //Colors.white,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                '${contractBookModels[index].total}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    color: Colors.black, //Colors.white,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      move == 1 ? SizedBox() : Divider(),
                      move == 1
                          ? SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'รวม',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.black, //Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${nFormat.format(sum_total_book)}', //slip_book
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Colors.black, //Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                      Divider(),
                      move == 0
                          ? SizedBox()
                          : SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Card(
                                              color: Colors.blue.shade900,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                child: Center(
                                                  child: Text(
                                                    '${contractBookModels[0].ln}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white, //Colors.white,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                Text(
                                                  '>>>',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black, //Colors.white,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                                Text(
                                                  'ย้ายไป',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black, //Colors.white,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: move_Area.length == 0
                                                ? SizedBox()
                                                : Card(
                                                    color:
                                                        Colors.yellow.shade700,
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                      child: Center(
                                                        child: Text(
                                                          '${move_Area.map((data) => data.type.toString()).join(', ')}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white, //Colors.white,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
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
                            ),
                      move == 0
                          ? SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              9,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(1.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  for (int index =
                                                                          0;
                                                                      index <
                                                                          contractBookModels
                                                                              .length;
                                                                      index++)
                                                                    Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(
                                                                            color:
                                                                                Colors.black12,
                                                                            width:
                                                                                1,
                                                                          ),
                                                                          // left: BorderSide(
                                                                          //   color: Colors.black12,
                                                                          //   width: 1,
                                                                          // ),
                                                                        ),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              1.0),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  (contractBookModels[index].date_book == null || contractBookModels[index].date_book.toString() == '') ? '${index + 1}. วันที่ : ${contractBookModels[index].date_book}' : '${index + 1}. วันที่ : ${DateFormat('dd-MM').format(DateTime.parse('${contractBookModels[index].date_book} 00:00:00'))}-${DateTime.parse('${contractBookModels[index].date_book} 00:00:00').year + 543}',
                                                                                  // '${contractBookModels[index].date_book}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle(color: Colors.grey, fontFamily: Font_.Fonts_T, fontSize: 12),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  '',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: TextStyle(color: Colors.grey, fontFamily: Font_.Fonts_T, fontSize: 12),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  '${contractBookModels[index].expname}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle(
                                                                                      color: Colors.black, //Colors.white,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  '${contractBookModels[index].total}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: TextStyle(
                                                                                      color: Colors.black, //Colors.white,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              'รวม',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black, //Colors.white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              '${nFormat.format(sum_total_book)}', //slip_book
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black, //Colors.white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              9,
                                                      child: Text(
                                                        '>',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black, //Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: move_Area.length == 0
                                                      ? SizedBox()
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  9,
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: Colors.grey,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 0.5),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  for (int index =
                                                                          0;
                                                                      index <
                                                                          move_Area
                                                                              .length;
                                                                      index++)
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              2.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  '${index + 1}. พื้นที่ : ${move_Area[index].type.toString().trim()}',
                                                                                  textAlign: TextAlign.start,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontFamily: Font_.Fonts_T, fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '${nFormat.format(double.parse('${move_Area[index].rent}'))} ',
                                                                                  textAlign: TextAlign.end,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '1',
                                                                                  textAlign: TextAlign.end,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '${nFormat.format(double.parse('${move_Area[index].rent}'))} ฿',
                                                                                  textAlign: TextAlign.end,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  for (int indexexp =
                                                                          0;
                                                                      indexexp <
                                                                          expModels
                                                                              .length;
                                                                      indexexp++)
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              2.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  '${(move_Area.length) + (indexexp + 1)}. ${expModels[indexexp].expname}',
                                                                                  textAlign: TextAlign.start,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontFamily: Font_.Fonts_T, fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '${expModels[indexexp].pri_book}',
                                                                                  textAlign: TextAlign.end,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '${move_Area.length}',
                                                                                  maxLines: 1,
                                                                                  textAlign: TextAlign.end,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                Text(
                                                                                  '${nFormat.format(double.parse('${expModels[indexexp].pri_book}') * move_Area.length)} ฿',
                                                                                  textAlign: TextAlign.end,
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(
                                                                                      color: Colors.grey[700],
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Divider(
                                                                                  height: 2,
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
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      ((Date_list_selectedmove.length) <
                                                                              2)
                                                                          ? 'รวม '
                                                                          : 'รวม (x${Date_list_selectedmove.length} วัน)',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          color: Colors.black, //Colors.white,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      '${nFormat.format((Date_list_selectedmove.length) * (double.parse((move_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (move_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())))))} บาท',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style: TextStyle(
                                                                          color: Colors.black, //Colors.white,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      move == 0
                          ? SizedBox()
                          : Container(
                              decoration: BoxDecoration(
                                // color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                              ),
                              padding: EdgeInsets.all(8),
                              height: 90,
                              child: Column(
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          'ยอดชำระ (พื้นที่เดิม)',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '${nFormat.format(sum_total_book)}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    )
                                  ]),
                                  Row(children: [
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          'ยอดชำระ (พื้นที่เลือก)',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '${nFormat.format(((Date_list_selectedmove.length) * (double.parse((move_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (move_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString()))))).abs())}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    )
                                  ]),
                                  Row(children: [
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          sum_total_book -
                                                      (Date_list_selectedmove
                                                              .length) *
                                                          (double.parse((move_Area
                                                                  .fold(
                                                                      0.0,
                                                                      (previousValue,
                                                                              element) =>
                                                                          previousValue +
                                                                          ((element.rent != null)
                                                                              ? double.parse(element
                                                                                  .rent!)
                                                                              : 0))
                                                                  .toString())) +
                                                              (move_Area.length *
                                                                  double.parse((expModels
                                                                      .fold(
                                                                          0.0,
                                                                          (previousValue, element) =>
                                                                              previousValue +
                                                                              ((element.pri_book != null) ? double.parse(element.pri_book!) : 0))
                                                                      .toString())))) <
                                                  0
                                              ? 'ยอดชำระ (ส่วนต่างเพิ่มเติม)'
                                              : 'คืน (ยอดชำระส่วนต่าง)',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          '${nFormat.format((sum_total_book - (Date_list_selectedmove.length) * (double.parse((move_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (move_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString()))))).abs())}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                        ),
                                      ),
                                    )
                                  ]),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          conbook == 1
                              ? SizedBox()
                              : Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.purple[700],
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        if (move_pay_book == '2') {
                                          PanaraInfoDialog.showAnimatedGrow(
                                            context,
                                            title: "Oops",
                                            message:
                                                "ไม่สามารถทำการย้ายพื้นที่ได้มากกว่า 1 ครั้ง !!!",
                                            buttonText: "รับทราบ",
                                            onTapDismiss: () async {
                                              Navigator.pop(context);
                                            },
                                            panaraDialogType:
                                                PanaraDialogType.error,
                                            barrierDismissible:
                                                false, // optional parameter (default is true)
                                          );
                                        } else {
                                          if (move == 1) {
                                            setState(() {
                                              move = 0;
                                              move_Area.clear();
                                            });
                                            _updateNodes();
                                          } else {
                                            PanaraConfirmDialog
                                                .showAnimatedGrow(
                                              context,
                                              title: "ข้อควรระวัง",
                                              message:
                                                  "โปรดแจ้งให้ผู้เช่าทราบก่อนทำการย้ายพื้นที่ และ สามารถทำการย้ายพื้นที่ได้เพียง 1 ครั้ง เท่านั่น !!!",
                                              confirmButtonText: "ดำเนินการต่อ",
                                              cancelButtonText: "ยกเลิก",
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onTapConfirm: () {
                                                setState(() {
                                                  move = 1;
                                                });
                                                Navigator.pop(context);
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.error,
                                            );
                                          }
                                        }
                                      },
                                      child: Text(
                                        move == 0
                                            ? 'ย้ายพื้นที่'
                                            : 'ยกเลิกย้ายพื้นที่',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          move == 0
                              ? SizedBox()
                              : Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.orange[900],
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        PanaraConfirmDialog.showAnimatedGrow(
                                          context,
                                          title: "ย้ายพื้นที่",
                                          message: "ยืนยันการย้ายพื้นที่",
                                          confirmButtonText: "ดำเนินการต่อ",
                                          cancelButtonText: "ยกเลิก",
                                          onTapCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onTapConfirm: () async {
                                            if (move_Area.length ==
                                                contractBookModels[0]
                                                    .ln!
                                                    .split(',')
                                                    .length) {
                                              Navigator.pop(context);

                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var ren = preferences
                                                  .getString('renTalSer');
                                              var ser_user =
                                                  preferences.getString('ser');

                                              var numin = docno_book;
                                              var Formbecause =
                                                  'ย้าย ${contractBookModels[0].ln} ไป ${move_Area.map((e) => e.type).toString().substring(1, move_Area.map((e) => e.type).toString().length - 1)}';

                                              String url_1 =
                                                  '${MyConstant().domain}/UPC_finant_bill_move.php?isAdd=true&ren=$ren&user=$ser_user&numin=$numin&because=$Formbecause&stap=A';
                                              try {
                                                var response = await http
                                                    .get(Uri.parse(url_1));

                                                var result =
                                                    json.decode(response.body);
                                                // print(result);
                                                if (result.toString() ==
                                                    'true') {
                                                  move_lockpayMent();
                                                }
                                              } catch (e) {}
                                            } else {
                                              Navigator.pop(context);
                                              PanaraInfoDialog.showAnimatedGrow(
                                                context,
                                                title: "Oops",
                                                message:
                                                    "คุณเลือกพื้นที่น้อยกว่าจำนวนการจองพื้นที่ของผู้เช่า กรุณาเลือกพื้นที่เพิ่ม !!!",
                                                buttonText: "รับทราบ",
                                                onTapDismiss: () async {
                                                  Navigator.pop(context);
                                                },
                                                panaraDialogType:
                                                    PanaraDialogType.error,
                                                barrierDismissible:
                                                    false, // optional parameter (default is true)
                                              );
                                            }
                                          },
                                          panaraDialogType:
                                              PanaraDialogType.success,
                                        );
                                      },
                                      child: Text(
                                        'ตกลง',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                  ),
                                ),
                          move == 1
                              ? SizedBox()
                              : Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.orange[700],
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        // _launchURL();
                                        if (payserby == '7') {
                                          showDialog<String>(
                                              // barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) =>
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
                                                    content: _buildWebViewX(),
                                                  ));
                                        } else {
                                          if (payserby != '1') {
                                            showDialog<String>(
                                                // barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
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
                                                          Translate.TranslateAndSetText(
                                                              'เลขที่ : ${docno_book} ',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.start,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '${slip_book}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                    fontSize:
                                                                        12.0),
                                                              ),
                                                              InkWell(
                                                                onTap: () =>
                                                                    downloadImage_slip(
                                                                        '${MyConstant().domain}/files/$foder/slip/${slip_book}',
                                                                        '${docno_book}'),
                                                                child: Icon(
                                                                  Icons
                                                                      .download,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      content: Image.network(
                                                          '${MyConstant().domain}/files/$foder/slip/$slip_book',
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2),
                                                    ));
                                          } else {
                                            showDialog<String>(
                                                // barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
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
                                                          Translate.TranslateAndSetText(
                                                              'เลขที่ : ${docno_book} ',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.start,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                        ],
                                                      ),
                                                      content: Text(
                                                        'ไม่พบ หลักฐานการชำระ',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T),
                                                      ),
                                                    ));
                                          }
                                        }

                                        // showDialog(
                                        //     context: context,
                                        //     builder: (BuildContext context) {
                                        //       return _buildWebViewX();
                                        //     });

                                        //print('$slip_book');
                                      },
                                      child: const Text(
                                        'หลักฐานการชำระ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                  ),
                                ),
                          move == 1
                              ? SizedBox()
                              : SizedBox(
                                  width: 10,
                                ),
                          move == 1
                              ? SizedBox()
                              : conbook == 1
                                  ? SizedBox()
                                  : conbook == 0
                                      ? Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.blue[700],
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                //print('$docno_book');
                                                PanaraConfirmDialog
                                                    .showAnimatedGrow(
                                                  context,
                                                  title: "ยืนยันการจอง",
                                                  message:
                                                      "คุณต้องการยืนยันการจอง ใช่ หรือ ไม่ ?",
                                                  confirmButtonText: "Confirm",
                                                  cancelButtonText: "Cancel",
                                                  onTapCancel: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  onTapConfirm: () async {
                                                    Insert_log.Insert_logs(
                                                        'เมนูหลัก',
                                                        'ยืนยันการจอง $docno_book');
                                                    SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();

                                                    var ren = preferences
                                                        .getString('renTalSer');

                                                    var conbok = 1;
                                                    var remark = 'ยืนยันการจอง';

                                                    String url =
                                                        '${MyConstant().domain}/UP_financet_book.php?isAdd=true&ren=$ren&ciddoc=$docno_book&conbok=$conbok&remark=$remark';
                                                    try {
                                                      var response = await http
                                                          .get(Uri.parse(url));

                                                      var result = json.decode(
                                                          response.body);
                                                      // print(result);
                                                      if (result.toString() ==
                                                          'true') {
                                                        setState(() {
                                                          conbook = 1;
                                                          read_GC_contractBook(
                                                              docno_book);
                                                          read_GC_area();
                                                        });
                                                        Navigator.pop(context);
                                                      }
                                                    } catch (e) {}
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.normal,
                                                );
                                              },
                                              child: Text(
                                                'ยืนยันการจอง',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                          move == 1
                              ? SizedBox()
                              : SizedBox(
                                  width: 10,
                                ),
                          move == 1
                              ? SizedBox()
                              : conbook == 1
                                  ? SizedBox()
                                  : conbook == 0
                                      ? Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.red[700],
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                //print('$docno_book');
                                                // SharedPreferences preferences =
                                                //     await SharedPreferences
                                                //         .getInstance();

                                                // var ren = preferences
                                                //     .getString('renTalSer');

                                                // var conbok = 2;
                                                // var remark = 'ยกเลิกการจอง';

                                                // String url =
                                                //     '${MyConstant().domain}/UP_financet_book.php?isAdd=true&ren=$ren&ciddoc=$docno_book&conbok=$conbok&remark=$remark';
                                                // try {
                                                //   var response = await http
                                                //       .get(Uri.parse(url));

                                                //   var result =
                                                //       json.decode(response.body);
                                                //   // //print(result);
                                                //   if (result.toString() == 'true') {
                                                //     setState(() {
                                                //       read_GC_contractBook(0);
                                                //       read_GC_area();
                                                //       conbook = -1;
                                                //     });
                                                //   }
                                                // } catch (e) {}

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
                                                    title: const Center(
                                                        child: Text(
                                                      'ยกเลิกการจองพื้นที่',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    )),
                                                    content: Container(
                                                      height: 120,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 2.0,
                                                          ),
                                                          Text(
                                                            'บิลเลขที่ $docno_book',
                                                            style:
                                                                const TextStyle(
                                                                    color: AccountScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight:
                                                                    //     FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  Formbecause_,
                                                              validator:
                                                                  (value) {
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
                                                                            BorderRadius.only(
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
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      enabledBorder:
                                                                          const OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.only(
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
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      labelText:
                                                                          'หมายเหตุ',
                                                                      labelStyle:
                                                                          const TextStyle(
                                                                        color: AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
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
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          // ignore: deprecated_member_use
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                            ),
                                                            onPressed: () {
                                                              String
                                                                  Formbecause =
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
                                                                            BorderRadius.all(Radius.circular(20.0))),
                                                                    title: const Center(
                                                                        child: Text(
                                                                      'กรุณากรอกเหตุผล !!',
                                                                      style: TextStyle(
                                                                          color: AdminScafScreen_Color
                                                                              .Colors_Text1_,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontFamily:
                                                                              FontWeight_.Fonts_T),
                                                                    )),
                                                                    actions: <Widget>[
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              width: 100,
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.redAccent,
                                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                              ),
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: TextButton(
                                                                                onPressed: () => Navigator.pop(context, 'OK'),
                                                                                child: const Text(
                                                                                  'ปิด',
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                if (payserby !=
                                                                    '7') {
                                                                  pPC_finantIbillPAY(
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
                                                                          payref1,
                                                                          Pay_Ke,
                                                                          renTal_user,
                                                                          docno_book,
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
                                                            child: const Text(
                                                              'ยืนยัน',
                                                              style: TextStyle(
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: 150,
                                                          height: 40,
                                                          // ignore: deprecated_member_use
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
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
                                                                  context,
                                                                  'OK');
                                                            },
                                                            child: const Text(
                                                              'ปิด',
                                                              style: TextStyle(
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
                                                );
                                              },
                                              child: Text(
                                                'ยกเลิกการจอง',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
        ));
  }

  Future<Null> pPC_finantIbillPAY(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    var conbok = 2;
    var remark = 'ยกเลิกการจอง';

    String url =
        '${MyConstant().domain}/UP_financet_book.php?isAdd=true&ren=$ren&ciddoc=$docno_book&conbok=$conbok&remark=$remark';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs(
            'จองล็อคเสียบ', 'ยกเลิกการจอง($docno_book,เหตุผล:$Formbecause)');
        setState(() {
          read_GC_contractBook(0);
          read_GC_area();
          conbook = -1;
        });
        // Navigator.pop(context);
      }
    } catch (e) {}
  }

  Widget _buildWebViewX() {
    return Container(
        height: 1000,
        width: 1000,
        child: StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 0)),
            builder: (context, snapshot) {
              return WebViewX2ShowPage(name_ser: slip_book);
            }));
  }

  void _launchURL() async {
    final String url = slip_book!;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Padding area_showbook(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            padding: const EdgeInsets.all(4),
            width: MediaQuery.of(context).size.width * 0.3,
            // height: MediaQuery.of(context).size.width * 0.38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              // color: Color(0xFFA8BFDB),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (allo_days.isNotEmpty)
                                  Container(
                                    // color: Colors.deepOrange[50],
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '**วันหยุดปกติ : ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                        PopupMenuButton(
                                          // color:
                                          //     Colors.red[50]!.withOpacity(0.9),
                                          child: const Center(
                                              child: Icon(Icons.info)),
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.orange[900],
                                                child: Text(
                                                  '**วันหยุดปกติ : ',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: Font_.Fonts_T,
                                                    // fontWeight:
                                                    //     FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            for (int index = 0;
                                                index < allowedWeekdays.length;
                                                index++)
                                              PopupMenuItem(
                                                child: InkWell(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text(
                                                      'วัน : ${allowedWeekdays[index]}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                if (allo_days.isNotEmpty)
                                  Container(
                                    // color: Colors.deepOrange[50],
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '**วันหยุดพิเศษ/วันนักขัตฤกษ์ : ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                        PopupMenuButton(
                                          // color:
                                          //     Colors.red[50]!.withOpacity(0.9),
                                          child: const Center(
                                              child: Icon(Icons.info)),
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.orange[900],
                                                child: Text(
                                                  '**วันหยุดพิเศษ/วันนักขัตฤกษ์',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: Font_.Fonts_T,
                                                    // fontWeight:
                                                    //     FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            for (int index = 0;
                                                index < allo_days.length;
                                                index++)
                                              PopupMenuItem(
                                                child: InkWell(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text(
                                                      'วันที่ : ${DateFormat('dd-MM-').format(DateTime.parse(allo_days[index].toString()))}${DateTime.parse(allo_days[index].toString()).year + 543}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'ทะเบียนลูกค้า : ',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                        PopupMenuButton(
                                          // color:
                                          //     Colors.red[50]!.withOpacity(0.9),
                                          child: const Center(
                                              child: Icon(Icons.info)),
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  select_coutumerAll('1');
                                                  // if (selected_Area.length !=
                                                  //     0) {
                                                  //   select_coutumerAll();
                                                  // } else {
                                                  //   Dialog_Area();
                                                  // }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.menu_book,
                                                        color: Colors.grey,
                                                        size: 18,
                                                      ),
                                                      Text(
                                                        ' ทะเบียนลูกค้า',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[800],
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  select_coutumerAll('2');
                                                  // if (selected_Area.length !=
                                                  //     0) {
                                                  //   select_coutumerAll();
                                                  // } else {
                                                  //   Dialog_Area();
                                                  // }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.map_sharp,
                                                        color: Colors.grey,
                                                        size: 18,
                                                      ),
                                                      Text(
                                                        ' ทะเบียนลูกค้า-ล็อกเสียบ',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[800],
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  select_coutumer_Ex();
                                                  // if (selected_Area.length !=
                                                  //     0) {
                                                  //   select_coutumer_Ex();
                                                  // } else {
                                                  //   Dialog_Area();
                                                  // }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.grid_4x4,
                                                        color: Colors.grey,
                                                        size: 18,
                                                      ),
                                                      Text(
                                                        ' Excel',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[800],
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //         Padding(
                                //   padding: const EdgeInsets.all(4.0),
                                //   child: InkWell(
                                //     onTap: () {
                                //         if (selected_Area.length != 0) {
                                //         select_coutumerAll();
                                //       } else {
                                //         Dialog_Area();
                                //       }
                                //     },
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         color: Colors.blue,
                                //         borderRadius: BorderRadius.only(
                                //             topLeft: Radius.circular(10),
                                //             topRight: Radius.circular(10),
                                //             bottomLeft: Radius.circular(10),
                                //             bottomRight: Radius.circular(10)),
                                //         border: Border.all(
                                //             color: Colors.black, width: 1),
                                //       ),
                                //       padding: const EdgeInsets.all(2.0),
                                //       child: Row(
                                //         children: [
                                //           Icon(
                                //             Icons.menu_book,
                                //             color: Colors.white,
                                //             size: 18,
                                //           ),
                                //           Text(
                                //             ' ทะเบียนลูกค้า',
                                //             textAlign: TextAlign.start,
                                //             style: TextStyle(
                                //               color: Colors.white,
                                //               fontFamily: Font_.Fonts_T,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: _Stap == 1
                              ? _stap1()
                              : _Stap == 2
                                  ? _stap2()
                                  : _stap3(),
                        ),
                        // Align(
                        //   alignment: Alignment.topCenter,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(4.0),
                        //     child: Container(
                        //       // height: 65,
                        //       decoration: BoxDecoration(
                        //         // color: Colors.grey,
                        //         borderRadius: const BorderRadius.only(
                        //           topLeft: Radius.circular(8),
                        //           topRight: Radius.circular(8),
                        //           bottomLeft: Radius.circular(8),
                        //           bottomRight: Radius.circular(8),
                        //         ),
                        //         image: DecorationImage(
                        //           colorFilter: ColorFilter.mode(
                        //               Colors.white.withOpacity(0.08),
                        //               BlendMode.dstATop),
                        //           image: const AssetImage(
                        //             "images/box_cover_dark.png",
                        //           ),
                        //           fit: BoxFit.fill,
                        //         ),
                        //       ),
                        //       padding: const EdgeInsets.all(4.0),
                        //       child: Text(
                        //         'กรุณากรอกข้อมูล ผู้ที่ต้องการเช่า',
                        //         overflow: TextOverflow.ellipsis,
                        //         // minFontSize: 1,
                        //         // maxFontSize: 12,
                        //         maxLines: 1,
                        //         textAlign: TextAlign.left,
                        //         style: const TextStyle(
                        //             overflow: TextOverflow.ellipsis,
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T,
                        //             fontSize: 20.0),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Form(
                        //   key: _formKey,
                        //   child: Container(
                        //     // width: MediaQuery.of(context).size.width,
                        //     // height: 450,
                        //     child: Column(
                        //       children: [
                        //         Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Text(
                        //                   'ชื่อผู้เช่า/บริษัท',
                        //                   textAlign: TextAlign.start,
                        //                   style: TextStyle(
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: Font_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Container(
                        //                   height: 40,
                        //                   padding: const EdgeInsets.all(4.0),
                        //                   child: TextFormField(
                        //                     //keyboardType: TextInputType.none,
                        //                     controller: TextForm_name,
                        //                     // onChanged: (value) =>
                        //                     //     _Form_tel =
                        //                     //         value.trim(),
                        //                     //initialValue: _Form_tel,
                        //                     // validator: (value) {
                        //                     //   if (value == null || value.isEmpty) {
                        //                     //     return 'กรอกข้อมูลให้ครบถ้วน ';
                        //                     //   }
                        //                     //   // if (int.parse(value.toString()) < 13) {
                        //                     //   //   return '< 13';
                        //                     //   // }
                        //                     //   return null;
                        //                     // },
                        //                     // maxLength: 13,
                        //                     cursorColor: Colors.green,
                        //                     decoration: InputDecoration(
                        //                         fillColor: Colors.white
                        //                             .withOpacity(0.3),
                        //                         filled: true,
                        //                         // prefixIcon:
                        //                         //     const Icon(Icons.person, color: Colors.black),
                        //                         // suffixIcon: Icon(Icons.clear, color: Colors.black),
                        //                         focusedBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.black,
                        //                           ),
                        //                         ),
                        //                         enabledBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.grey,
                        //                           ),
                        //                         ),
                        //                         labelText: 'ชื่อผู้เช่า/บริษัท',
                        //                         labelStyle: const TextStyle(
                        //                           color: Colors.black,
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                         )),
                        //                     // inputFormatters: <TextInputFormatter>[
                        //                     //   // for below version 2 use this
                        //                     //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        //                     //   // for version 2 and greater youcan also use this
                        //                     //   FilteringTextInputFormatter.digitsOnly
                        //                     // ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Text(
                        //                   'เลขบัตรประชาชน 13 หลัก',
                        //                   textAlign: TextAlign.start,
                        //                   style: TextStyle(
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: Font_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Container(
                        //                   height: 60,
                        //                   padding: const EdgeInsets.all(4.0),
                        //                   child: TextFormField(
                        //                     keyboardType: TextInputType.number,
                        //                     controller: TextForm_tax,
                        //                     // onChanged: (value) =>
                        //                     //     _Form_tel =
                        //                     //         value.trim(),
                        //                     //initialValue: _Form_tel,
                        //                     // validator: (value) {
                        //                     //   if (value == null || value.isEmpty) {
                        //                     //     return 'กรอกข้อมูลให้ครบถ้วน ';
                        //                     //   }
                        //                     //   // if (int.parse(value.toString()) < 13) {
                        //                     //   //   return '< 13';
                        //                     //   // }
                        //                     //   return null;
                        //                     // },
                        //                     maxLength: 13,
                        //                     cursorColor: Colors.green,
                        //                     decoration: InputDecoration(
                        //                         fillColor: Colors.white
                        //                             .withOpacity(0.3),
                        //                         filled: true,
                        //                         // prefixIcon:
                        //                         //     const Icon(Icons.person, color: Colors.black),
                        //                         // suffixIcon: Icon(Icons.clear, color: Colors.black),
                        //                         focusedBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.black,
                        //                           ),
                        //                         ),
                        //                         enabledBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.grey,
                        //                           ),
                        //                         ),
                        //                         labelText: 'x-xxxx-xxxxx-xx-x',
                        //                         labelStyle: const TextStyle(
                        //                           color: Colors.black,
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                         )),
                        //                     inputFormatters: <TextInputFormatter>[
                        //                       // for below version 2 use this
                        //                       FilteringTextInputFormatter.allow(
                        //                           RegExp(r'[0-9]')),
                        //                       // for version 2 and greater youcan also use this
                        //                       FilteringTextInputFormatter
                        //                           .digitsOnly
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Text(
                        //                   'เบอร์โทร',
                        //                   textAlign: TextAlign.start,
                        //                   style: TextStyle(
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: Font_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Container(
                        //                   decoration: const BoxDecoration(
                        //                     // color: Colors.green,
                        //                     borderRadius: BorderRadius.only(
                        //                       topLeft: Radius.circular(6),
                        //                       topRight: Radius.circular(6),
                        //                       bottomLeft: Radius.circular(6),
                        //                       bottomRight: Radius.circular(6),
                        //                     ),
                        //                     // border: Border.all(color: Colors.grey, width: 1),
                        //                   ),
                        //                   height: 40,
                        //                   padding: const EdgeInsets.all(4.0),
                        //                   child: TextFormField(
                        //                     keyboardType: TextInputType.number,
                        //                     controller: TextForm_tel,
                        //                     // onChanged: (value) =>
                        //                     //     _Form_tel =
                        //                     //         value.trim(),
                        //                     //initialValue: _Form_tel,
                        //                     // validator: (value) {
                        //                     //   if (value == null || value.isEmpty) {
                        //                     //     return 'กรอกข้อมูลให้ครบถ้วน ';
                        //                     //   }
                        //                     //   // if (int.parse(value.toString()) < 13) {
                        //                     //   //   return '< 13';
                        //                     //   // }
                        //                     //   return null;
                        //                     // },
                        //                     // maxLength: 13,
                        //                     cursorColor: Colors.green,
                        //                     decoration: InputDecoration(
                        //                         fillColor: Colors.white
                        //                             .withOpacity(0.3),
                        //                         filled: true,
                        //                         // prefixIcon:
                        //                         //     const Icon(Icons.person, color: Colors.black),
                        //                         // suffixIcon: Icon(Icons.clear, color: Colors.black),
                        //                         focusedBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.black,
                        //                           ),
                        //                         ),
                        //                         enabledBorder:
                        //                             const OutlineInputBorder(
                        //                           borderRadius:
                        //                               BorderRadius.only(
                        //                             topLeft: Radius.circular(8),
                        //                             topRight:
                        //                                 Radius.circular(8),
                        //                             bottomLeft:
                        //                                 Radius.circular(8),
                        //                             bottomRight:
                        //                                 Radius.circular(8),
                        //                           ),
                        //                           borderSide: BorderSide(
                        //                             width: 1,
                        //                             color: Colors.grey,
                        //                           ),
                        //                         ),
                        //                         labelText: 'ระบุเบอร์โทร',
                        //                         labelStyle: const TextStyle(
                        //                           color: Colors.black,
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                         )),
                        //                     inputFormatters: <TextInputFormatter>[
                        //                       // for below version 2 use this
                        //                       FilteringTextInputFormatter.allow(
                        //                           RegExp(r'[0-9]')),
                        //                       // for version 2 and greater youcan also use this
                        //                       FilteringTextInputFormatter
                        //                           .digitsOnly
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Text(
                        //                   'เริ่ม-จองวันที่',
                        //                   textAlign: TextAlign.center,
                        //                   style: TextStyle(
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: Font_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Container(
                        //                   height: 40,
                        //                   decoration: const BoxDecoration(
                        //                     // color: Colors.green,
                        //                     borderRadius: BorderRadius.only(
                        //                       topLeft: Radius.circular(6),
                        //                       topRight: Radius.circular(6),
                        //                       bottomLeft: Radius.circular(6),
                        //                       bottomRight: Radius.circular(6),
                        //                     ),
                        //                     // border: Border.all(color: Colors.grey, width: 1),
                        //                   ),
                        //                   child: Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: InkWell(
                        //                       onTap: () async {
                        //                         // read_GC_rental_data_All();
                        //                         _select_financial_StartDate(
                        //                             context);
                        //                       },
                        //                       child: Container(
                        //                           decoration: BoxDecoration(
                        //                             color: Colors.orange[100],
                        //                             borderRadius:
                        //                                 const BorderRadius.only(
                        //                                     topLeft:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     topRight:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     bottomLeft:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     bottomRight:
                        //                                         Radius.circular(
                        //                                             10)),
                        //                             border: Border.all(
                        //                                 color: Colors.grey,
                        //                                 width: 1),
                        //                           ),
                        //                           width: 120,
                        //                           padding:
                        //                               const EdgeInsets.all(8.0),
                        //                           child: Center(
                        //                             child: Text(
                        //                               // (allowedWeekdays.contains(DateFormat(
                        //                               //                     'EEEE')
                        //                               //                 .format(DateTime
                        //                               //                     .now())) ==
                        //                               //             false &&
                        //                               //         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                               //                 DateTime.now()
                        //                               //                     .year,
                        //                               //                 DateTime.now()
                        //                               //                     .month,
                        //                               //                 DateTime.now()
                        //                               //                         .day +
                        //                               //                     1))) ==
                        //                               //             false)
                        //                               //     ? 'วันนี้และพรุ่งนี้ ไม่เปิดจอง'
                        //                               //     :
                        //                               (SDatex_total1_ == null)
                        //                                   ? 'เลือก'
                        //                                   : '$SDatex_total1_',
                        //                               style: TextStyle(
                        //                                 color:
                        //                                     //  (allowedWeekdays.contains(DateFormat('EEEE').format(
                        //                                     //                 DateTime
                        //                                     //                     .now())) ==
                        //                                     //             false &&
                        //                                     //         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                                     //                 DateTime.now()
                        //                                     //                     .year,
                        //                                     //                 DateTime.now()
                        //                                     //                     .month,
                        //                                     //                 DateTime.now().day +
                        //                                     //                     1))) ==
                        //                                     //             false)
                        //                                     //     ? Colors.red[300]
                        //                                     //     : (datex_selected ==
                        //                                     //             null)
                        //                                     //         ? Colors
                        //                                     //             .red[300]
                        //                                     //         :
                        //                                     Colors.black,
                        //                                 // fontWeight: FontWeight.bold,
                        //                                 fontFamily:
                        //                                     Font_.Fonts_T,
                        //                                 fontSize: (allowedWeekdays.contains(DateFormat(
                        //                                                     'EEEE')
                        //                                                 .format(DateTime
                        //                                                     .now())) ==
                        //                                             false &&
                        //                                         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                                                 DateTime.now()
                        //                                                     .year,
                        //                                                 DateTime.now()
                        //                                                     .month,
                        //                                                 DateTime.now().day +
                        //                                                     1))) ==
                        //                                             false)
                        //                                     ? 12
                        //                                     : null,
                        //                               ),
                        //                             ),
                        //                           )),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Text(
                        //                   'ถึง-วันที่',
                        //                   textAlign: TextAlign.center,
                        //                   style: TextStyle(
                        //                     color: Colors.grey[800],
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: Font_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Container(
                        //                   height: 40,
                        //                   decoration: const BoxDecoration(
                        //                     // color: Colors.green,
                        //                     borderRadius: BorderRadius.only(
                        //                       topLeft: Radius.circular(6),
                        //                       topRight: Radius.circular(6),
                        //                       bottomLeft: Radius.circular(6),
                        //                       bottomRight: Radius.circular(6),
                        //                     ),
                        //                     // border: Border.all(color: Colors.grey, width: 1),
                        //                   ),
                        //                   child: Padding(
                        //                     padding: const EdgeInsets.all(2.0),
                        //                     child: InkWell(
                        //                       onTap: () async {
                        //                         // read_GC_rental_data_All();
                        //                         _select_financial_LtartDate(
                        //                             context);
                        //                       },
                        //                       child: Container(
                        //                           decoration: BoxDecoration(
                        //                             color: Colors.orange[100],
                        //                             borderRadius:
                        //                                 const BorderRadius.only(
                        //                                     topLeft:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     topRight:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     bottomLeft:
                        //                                         Radius.circular(
                        //                                             10),
                        //                                     bottomRight:
                        //                                         Radius.circular(
                        //                                             10)),
                        //                             border: Border.all(
                        //                                 color: Colors.grey,
                        //                                 width: 1),
                        //                           ),
                        //                           width: 120,
                        //                           padding:
                        //                               const EdgeInsets.all(8.0),
                        //                           child: Center(
                        //                             child: Text(
                        //                               // (allowedWeekdays.contains(DateFormat(
                        //                               //                     'EEEE')
                        //                               //                 .format(DateTime
                        //                               //                     .now())) ==
                        //                               //             false &&
                        //                               //         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                               //                 DateTime.now()
                        //                               //                     .year,
                        //                               //                 DateTime.now()
                        //                               //                     .month,
                        //                               //                 DateTime.now()
                        //                               //                         .day +
                        //                               //                     1))) ==
                        //                               //             false)
                        //                               //     ? 'วันนี้และพรุ่งนี้ ไม่เปิดจอง'
                        //                               //     :
                        //                               (LDatex_total1_ == null)
                        //                                   ? 'เลือก'
                        //                                   : '$LDatex_total1_',
                        //                               style: TextStyle(
                        //                                 color:
                        //                                     //  (allowedWeekdays.contains(DateFormat('EEEE').format(
                        //                                     //                 DateTime
                        //                                     //                     .now())) ==
                        //                                     //             false &&
                        //                                     //         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                                     //                 DateTime.now()
                        //                                     //                     .year,
                        //                                     //                 DateTime.now()
                        //                                     //                     .month,
                        //                                     //                 DateTime.now().day +
                        //                                     //                     1))) ==
                        //                                     //             false)
                        //                                     //     ? Colors.red[300]
                        //                                     //     : (datex_selected ==
                        //                                     //             null)
                        //                                     //         ? Colors
                        //                                     //             .red[300]
                        //                                     //         :
                        //                                     Colors.black,
                        //                                 // fontWeight: FontWeight.bold,
                        //                                 fontFamily:
                        //                                     Font_.Fonts_T,
                        //                                 fontSize: (allowedWeekdays.contains(DateFormat(
                        //                                                     'EEEE')
                        //                                                 .format(DateTime
                        //                                                     .now())) ==
                        //                                             false &&
                        //                                         allowedWeekdays.contains(DateFormat('EEEE').format(DateTime(
                        //                                                 DateTime.now()
                        //                                                     .year,
                        //                                                 DateTime.now()
                        //                                                     .month,
                        //                                                 DateTime.now().day +
                        //                                                     1))) ==
                        //                                             false)
                        //                                     ? 12
                        //                                     : null,
                        //                               ),
                        //                             ),
                        //                           )),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         if (Date_list_selected.isNotEmpty)
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Container(
                        //               color: Colors.red[50],
                        //               padding: const EdgeInsets.all(2.0),
                        //               child: Row(
                        //                 children: [
                        //                   Text(
                        //                     'จำนวนวันที่ ท่านเลือกทั้งหมด : ${Date_list_selected.length} วัน',
                        //                     textAlign: TextAlign.start,
                        //                     style: TextStyle(
                        //                         color: Colors.red[800],
                        //                         fontFamily: Font_.Fonts_T,
                        //                         fontSize: 12),
                        //                   ),
                        //                   if (Date_list_selected.isNotEmpty)
                        //                     PopupMenuButton(
                        //                       // color: Colors.green[50]!
                        //                       //     .withOpacity(0.9),
                        //                       child: const Center(
                        //                           child: Icon(Icons.info)),
                        //                       itemBuilder:
                        //                           (BuildContext context) => [
                        //                         PopupMenuItem(
                        //                           child: Container(
                        //                             padding:
                        //                                 const EdgeInsets.all(2),
                        //                             width:
                        //                                 MediaQuery.of(context)
                        //                                     .size
                        //                                     .width,
                        //                             color: Colors.green,
                        //                             child: Text(
                        //                               'จำนวนวันที่ ท่านเลือกทั้งหมด  ${Date_list_selected.length} วัน',
                        //                               textAlign:
                        //                                   TextAlign.start,
                        //                               style: TextStyle(
                        //                                 color: Colors.white,
                        //                                 fontFamily:
                        //                                     Font_.Fonts_T,
                        //                                 // fontWeight:
                        //                                 //     FontWeight.w300,
                        //                               ),
                        //                             ),
                        //                           ),
                        //                         ),
                        //                         for (int index = 0;
                        //                             index <
                        //                                 Date_list_selected
                        //                                     .length;
                        //                             index++)
                        //                           PopupMenuItem(
                        //                             child: Container(
                        //                               padding:
                        //                                   const EdgeInsets.all(
                        //                                       10),
                        //                               width:
                        //                                   MediaQuery.of(context)
                        //                                       .size
                        //                                       .width,
                        //                               child: Text(
                        //                                 '${index + 1}. วันที่ : ${DateFormat('dd-MM-').format(DateTime.parse(Date_list_selected[index].toString()))}${DateTime.parse(Date_list_selected[index].toString()).year + 543}',
                        //                                 textAlign:
                        //                                     TextAlign.start,
                        //                                 style: TextStyle(
                        //                                   color:
                        //                                       Colors.grey[800],
                        //                                   fontFamily:
                        //                                       Font_.Fonts_T,
                        //                                   // fontWeight:
                        //                                   //     FontWeight.w300,
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                       ],
                        //                     ),
                        //                   // Expanded(
                        //                   //   flex: 1,
                        //                   //   child: Text(
                        //                   //     '[ ${Date_list_selected.map((model) => '${DateFormat('dd-MM-').format(DateTime.parse(model.toString()))}${DateTime.parse(model.toString()).year + 543}').join(', ')} ]',
                        //                   //     textAlign: TextAlign.start,
                        //                   //     style: TextStyle(
                        //                   //         color: Colors.grey[800],
                        //                   //         fontFamily: Font_.Fonts_T,
                        //                   //         fontSize: 12),
                        //                   //   ),
                        //                   // ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Divider(
                        //   height: 2,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         flex: 1,
                        //         child: Text(
                        //           'พื้นที่ที่เลือก',
                        //           textAlign: TextAlign.start,
                        //           style: TextStyle(
                        //             color: Colors.grey[800],
                        //             fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T,
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         flex: 2,
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(2.0),
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               // color: Colors.red[100]!.withOpacity(0.5),
                        //               borderRadius: const BorderRadius.only(
                        //                 topLeft: Radius.circular(6),
                        //                 topRight: Radius.circular(6),
                        //                 bottomLeft: Radius.circular(6),
                        //                 bottomRight: Radius.circular(6),
                        //               ),
                        //               border: Border.all(
                        //                   color: Colors.grey, width: 1),
                        //             ),
                        //             padding: const EdgeInsets.all(2.0),
                        //             child: Center(
                        //               child: Text(
                        //                 (selected_Area.length == 0)
                        //                     ? 'ไม่พบพื้นที่ ที่ท่านเลือก'
                        //                     : '${selected_Area.map((data) => data.type.toString()).join(', ')}',
                        //                 textAlign: TextAlign.center,
                        //                 style: TextStyle(
                        //                   color: (selected_Area.length == 0)
                        //                       ? Colors.red[300]
                        //                       : PeopleChaoScreen_Color
                        //                           .Colors_Text2_,
                        //                   // fontWeight: FontWeight.bold,
                        //                   fontFamily: Font_.Fonts_T,
                        //                   fontSize: (selected_Area.length == 0)
                        //                       ? 12
                        //                       : null,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       if (selected_Area.length != 0)
                        //         Expanded(
                        //           flex: 1,
                        //           child: Padding(
                        //             padding: const EdgeInsets.all(2.0),
                        //             child: Container(
                        //               // decoration: BoxDecoration(
                        //               //   // color: Colors.red[100]!.withOpacity(0.5),
                        //               //   borderRadius: BorderRadius.only(
                        //               //     topLeft: Radius.circular(10),
                        //               //     topRight: Radius.circular(10),
                        //               //     bottomLeft: Radius.circular(10),
                        //               //     bottomRight: Radius.circular(10),
                        //               //   ),
                        //               //   border: Border.all(color: Colors.grey, width: 1),
                        //               // ),
                        //               padding: const EdgeInsets.all(2.0),
                        //               child: Center(
                        //                 child: InkWell(
                        //                   onTap: () async {
                        //                     setState(() {
                        //                       ser_data_Detail =
                        //                           (ser_data_Detail == 1)
                        //                               ? 0
                        //                               : 1;
                        //                     });
                        //                   },
                        //                   child: Text(
                        //                     (ser_data_Detail == 1)
                        //                         ? 'ปิด X '
                        //                         : 'แสดงเพิ่มเติม >> ',
                        //                     textAlign: TextAlign.center,
                        //                     style: TextStyle(
                        //                       color: (ser_data_Detail == 1)
                        //                           ? Colors.red
                        //                           : Colors.blue,
                        //                       // fontWeight: FontWeight.bold,
                        //                       fontFamily: Font_.Fonts_T,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //     ],
                        //   ),
                        // ),
                        // if (ser_data_Detail == 1)
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(
                        //       children: [
                        //         Container(
                        //           padding: const EdgeInsets.all(2.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: SizedBox(),
                        //               ),
                        //               Expanded(
                        //                 flex: 2,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.start,
                        //                   children: [
                        //                     Text(
                        //                       'รายการ',
                        //                       textAlign: TextAlign.start,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           fontWeight: FontWeight.w500,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       'ราคา',
                        //                       textAlign: TextAlign.end,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       'จำนวนพื้นที่',
                        //                       textAlign: TextAlign.end,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       'ราคารวม',
                        //                       textAlign: TextAlign.end,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         for (int index = 0;
                        //             index < selected_Area.length;
                        //             index++)
                        //           Container(
                        //             padding: const EdgeInsets.all(2.0),
                        //             child: Row(
                        //               children: [
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: SizedBox(),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 2,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.start,
                        //                     children: [
                        //                       Text(
                        //                         '${index + 1}. พื้นที่ : ${selected_Area[index].type.toString().trim()}',
                        //                         textAlign: TextAlign.start,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             fontWeight: FontWeight.w500,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '${nFormat.format(double.parse('${selected_Area[index].rent}'))} ',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '1',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '${nFormat.format(double.parse('${selected_Area[index].rent}'))} ฿',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         for (int indexexp = 0;
                        //             indexexp < expModels.length;
                        //             indexexp++)
                        //           Container(
                        //             padding: const EdgeInsets.all(2.0),
                        //             child: Row(
                        //               children: [
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: SizedBox(),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 2,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.start,
                        //                     children: [
                        //                       Text(
                        //                         '${(selected_Area.length) + (indexexp + 1)}. ${expModels[indexexp].expname}',
                        //                         textAlign: TextAlign.start,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             fontWeight: FontWeight.w500,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '${expModels[indexexp].pri_book}',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '${selected_Area.length}',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                   flex: 1,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.end,
                        //                     children: [
                        //                       Text(
                        //                         '${nFormat.format(double.parse('${expModels[indexexp].pri_book}') * selected_Area.length)} ฿',
                        //                         textAlign: TextAlign.end,
                        //                         style: TextStyle(
                        //                             color: Colors.grey[700],
                        //                             // fontWeight: FontWeight.bold,
                        //                             fontFamily: Font_.Fonts_T,
                        //                             fontSize: 12),
                        //                       ),
                        //                       Divider(
                        //                         height: 2,
                        //                       )
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         Container(
                        //           padding: const EdgeInsets.all(2.0),
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 flex: 3,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       '',
                        //                       textAlign: TextAlign.end,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       'ทั้งหมด',
                        //                       textAlign: TextAlign.end,
                        //                       maxLines: 1,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //               Expanded(
                        //                 flex: 1,
                        //                 child: Column(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.end,
                        //                   children: [
                        //                     Text(
                        //                       (selected_Area.length == 0)
                        //                           ? '0.00'
                        //                           :
                        //                           //  '${(selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())))}',
                        //                           '${nFormat.format(double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString()))))} บาท',
                        //                       textAlign: TextAlign.end,
                        //                       maxLines: 1,
                        //                       style: TextStyle(
                        //                           color: Colors.grey[700],
                        //                           // fontWeight: FontWeight.bold,
                        //                           fontFamily: Font_.Fonts_T,
                        //                           fontSize: 12),
                        //                     ),
                        //                     Divider(
                        //                       height: 2,
                        //                     )
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         flex: 1,
                        //         child: Text(
                        //           (Date_list_selected.length < 2)
                        //               ? 'จำนวนเงิน'
                        //               : 'จำนวนเงิน (x${Date_list_selected.length}วัน)',
                        //           textAlign: TextAlign.start,
                        //           maxLines: 1,
                        //           style: TextStyle(
                        //             color: Colors.grey[800],
                        //             fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T,
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         flex: 3,
                        //         child: Container(
                        //           decoration: BoxDecoration(
                        //             color: Colors.red[100]!.withOpacity(0.5),
                        //             borderRadius: const BorderRadius.only(
                        //               topLeft: Radius.circular(10),
                        //               topRight: Radius.circular(10),
                        //               bottomLeft: Radius.circular(10),
                        //               bottomRight: Radius.circular(10),
                        //             ),
                        //             border: Border.all(
                        //                 color: Colors.grey, width: 1),
                        //           ),
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Center(
                        //             child: Text(
                        //               (selected_Area.length == 0)
                        //                   ? '0.00'
                        //                   : '${nFormat.format((Date_list_selected.length) * (double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())))))} บาท',

                        //               //'${nFormat.format((Date_list_selected.length) * (double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString()))))} บาท',
                        //               // '${nFormat.format(double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0) * selected_Area.length).toString())) + double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0) * selected_Area.length).toString())))} บาท',
                        //               textAlign: TextAlign.center, maxLines: 1,
                        //               style: const TextStyle(
                        //                 color: Colors.black,
                        //                 fontWeight: FontWeight.w800,
                        //                 fontFamily: Font_.Fonts_T,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 1),
                        // const Padding(
                        //   padding: EdgeInsets.all(8.0),
                        //   child: Divider(),
                        // ),
                        // const SizedBox(height: 1),
                        // if (TextForm_name.text.toString().trim() == '' ||
                        //     TextForm_tel.text.toString().trim() == '' ||
                        //     TextForm_tel.text.toString().trim().length < 9 ||
                        //     SDatex_total1_ == null ||
                        //     double.parse((selected_Area
                        //             .fold(
                        //                 0.0,
                        //                 (previousValue, element) =>
                        //                     previousValue +
                        //                     (element.rent != null
                        //                         ? double.parse(element.rent!)
                        //                         : 0))
                        //             .toString())) ==
                        //         0.00 ||
                        //     selected_Area.length == 0 ||
                        //     paymentName1 == null ||
                        //     paymentName1.toString().trim() == '')
                        //   const Center(
                        //     child: Text(
                        //       '*** กรุณาใส่ข้อมูลให้ครบถ้วน',
                        //       style: TextStyle(
                        //         color: Colors.red,
                        //         // fontWeight: FontWeight.bold,
                        //         fontFamily: Font_.Fonts_T,
                        //       ),
                        //     ),
                        //   ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       // (base64_Slip == null ||
                        //       //         TextForm_time.text.toString().trim() == '' ||
                        //       //         TextForm_name.text.toString().trim() == '' ||
                        //       //         TextForm_tel.text.toString().trim() == '' ||
                        //       //         datex_selected == null ||
                        //       //         double.parse((selected_Area
                        //       //                 .fold(
                        //       //                     0.0,
                        //       //                     (previousValue, element) =>
                        //       //                         previousValue +
                        //       //                         (element.rent != null
                        //       //                             ? double.parse(
                        //       //                                 element.rent!)
                        //       //                             : 0))
                        //       //                 .toString())) ==
                        //       //             0.00 ||
                        //       //         selected_Area.length == 0 ||
                        //       //         paymentName1 == null ||
                        //       //         paymentName1.toString().trim() == '' ||
                        //       //         TextForm_time.text == '00.00.00')

                        //       (TextForm_tax.text.toString().trim().length <
                        //                   13 ||
                        //               TextForm_tax.text.toString().trim() ==
                        //                   '' ||
                        //               TextForm_name.text.toString().trim() ==
                        //                   '' ||
                        //               TextForm_tel.text.toString().trim() ==
                        //                   '' ||
                        //               TextForm_tel.text
                        //                       .toString()
                        //                       .trim()
                        //                       .length <
                        //                   9 ||
                        //               SDatex_total1_ == null ||
                        //               double.parse((selected_Area
                        //                       .fold(
                        //                           0.0,
                        //                           (previousValue, element) =>
                        //                               previousValue +
                        //                               (element.rent != null
                        //                                   ? double.parse(
                        //                                       element.rent!)
                        //                                   : 0))
                        //                       .toString())) ==
                        //                   0.00 ||
                        //               selected_Area.length == 0 ||
                        //               paymentName1 == null ||
                        //               paymentName1.toString().trim() == '')
                        //           ? Container(
                        //               width: 300,
                        //               decoration: BoxDecoration(
                        //                 color: Colors.grey[300],
                        //                 borderRadius: const BorderRadius.only(
                        //                   topLeft: Radius.circular(10),
                        //                   topRight: Radius.circular(10),
                        //                   bottomLeft: Radius.circular(10),
                        //                   bottomRight: Radius.circular(10),
                        //                 ),
                        //                 border: Border.all(
                        //                     color: const Color.fromARGB(
                        //                         255, 204, 203, 203),
                        //                     width: 1),
                        //               ),
                        //               padding: const EdgeInsets.all(8.0),
                        //               child: Center(
                        //                 child: Text(
                        //                   (payment_Ptser.toString() == '5')
                        //                       ? 'ยืนยัน ดำเนินการต่อ'
                        //                       : 'ยืนยัน การจองพื้นที่',
                        //                   style: TextStyle(
                        //                     color: Colors.grey,
                        //                     fontWeight: FontWeight.bold,
                        //                     fontFamily: FontWeight_.Fonts_T,
                        //                   ),
                        //                 ),
                        //               ))
                        //           : OtpTimerButton(
                        //               height: 50,
                        //               text: Text(
                        //                 'ยืนยัน ดำเนินการต่อ',
                        //                 style: TextStyle(
                        //                   color: Colors.black,
                        //                   fontWeight: FontWeight.bold,
                        //                   fontFamily: FontWeight_.Fonts_T,
                        //                 ),
                        //               ),
                        //               duration: 3,
                        //               radius: 8,
                        //               backgroundColor: Colors.green[300],
                        //               textColor: Colors.black,
                        //               buttonType: ButtonType.elevated_button,
                        //               loadingIndicator:
                        //                   CircularProgressIndicator(
                        //                 strokeWidth: 2,
                        //                 color: Colors.red,
                        //               ),
                        //               loadingIndicatorColor: Colors.red,
                        //               onPressed: () async {
                        //                 SharedPreferences preferences =
                        //                     await SharedPreferences
                        //                         .getInstance();
                        //                 var ren =
                        //                     preferences.getString('renTalSer');
                        //                 String Area_Ser1 =
                        //                     (selected_Area.length > 0)
                        //                         ? selected_Area[0]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser2 =
                        //                     (selected_Area.length > 1)
                        //                         ? selected_Area[1]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser3 =
                        //                     (selected_Area.length > 2)
                        //                         ? selected_Area[2]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser4 =
                        //                     (selected_Area.length > 3)
                        //                         ? selected_Area[3]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser5 =
                        //                     (selected_Area.length > 4)
                        //                         ? selected_Area[4]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser6 =
                        //                     (selected_Area.length > 5)
                        //                         ? selected_Area[5]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser7 =
                        //                     (selected_Area.length > 6)
                        //                         ? selected_Area[6]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser8 =
                        //                     (selected_Area.length > 7)
                        //                         ? selected_Area[7]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser9 =
                        //                     (selected_Area.length > 8)
                        //                         ? selected_Area[8]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser10 =
                        //                     (selected_Area.length > 9)
                        //                         ? selected_Area[9]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser11 =
                        //                     (selected_Area.length > 10)
                        //                         ? selected_Area[10]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser12 =
                        //                     (selected_Area.length > 11)
                        //                         ? selected_Area[11]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser13 =
                        //                     (selected_Area.length > 12)
                        //                         ? selected_Area[12]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser14 =
                        //                     (selected_Area.length > 13)
                        //                         ? selected_Area[13]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser15 =
                        //                     (selected_Area.length > 14)
                        //                         ? selected_Area[14]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser16 =
                        //                     (selected_Area.length > 15)
                        //                         ? selected_Area[15]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser17 =
                        //                     (selected_Area.length > 16)
                        //                         ? selected_Area[16]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';
                        //                 String Area_Ser18 =
                        //                     (selected_Area.length > 17)
                        //                         ? selected_Area[17]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser19 =
                        //                     (selected_Area.length > 18)
                        //                         ? selected_Area[18]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String Area_Ser20 =
                        //                     (selected_Area.length > 19)
                        //                         ? selected_Area[19]
                        //                             .ser
                        //                             .toString()
                        //                         : '0';

                        //                 String url =
                        //                     '${MyConstant().domain}/GC_UsercheckLock_Market.php?isAdd=true&ren=$ren';
                        //                 // String url =
                        //                 //     '${MyConstant().domain}/GC_UsercheckLock_Market.php?isAdd=true&ren=$ren&pdatex=$SDatex_total1_&aser1=$Area_Ser1&aser2=$Area_Ser2&aser3=$Area_Ser3&Arealength=${selected_Area.length}';

                        //                 //--------------------> random_1
                        //                 int randomMilliseconds =
                        //                     Random().nextInt(401) + 200;
                        //                 Duration randomDuration = Duration(
                        //                     milliseconds: randomMilliseconds);

                        //                 int formattedMilliseconds =
                        //                     randomDuration.inMilliseconds %
                        //                         1000;
                        //                 //--------------------> random_2

                        //                 int randomMilliseconds2 =
                        //                     Random().nextInt(901) + 100;
                        //                 Duration randomDuration2 = Duration(
                        //                     milliseconds: randomMilliseconds2);

                        //                 int formattedMilliseconds2 =
                        //                     randomDuration2.inMilliseconds %
                        //                         1000;
                        //                 Dia_log(formattedMilliseconds);
                        //                 Future.delayed(
                        //                     Duration(
                        //                         milliseconds:
                        //                             formattedMilliseconds),
                        //                     () async {
                        //                   //print(
                        //                       ' random1 : ${formattedMilliseconds}');

                        //                   Future.delayed(
                        //                       Duration(
                        //                           milliseconds:
                        //                               formattedMilliseconds2),
                        //                       () async {
                        //                     try {
                        //                       var response = await http.post(
                        //                         Uri.parse(url),
                        //                         body: {
                        //                           'pdatex':
                        //                               SDatex_total1_.toString(),
                        //                           'aser1': Area_Ser1.toString(),
                        //                           'aser2': Area_Ser2.toString(),
                        //                           'aser3': Area_Ser3.toString(),
                        //                           'aser4': Area_Ser4.toString(),
                        //                           'aser5': Area_Ser5.toString(),
                        //                           'aser6': Area_Ser6.toString(),
                        //                           'aser7': Area_Ser7.toString(),
                        //                           'aser8': Area_Ser8.toString(),
                        //                           'aser9': Area_Ser9.toString(),
                        //                           'aser10':
                        //                               Area_Ser10.toString(),
                        //                           'aser11':
                        //                               Area_Ser11.toString(),
                        //                           'aser12':
                        //                               Area_Ser12.toString(),
                        //                           'aser13':
                        //                               Area_Ser13.toString(),
                        //                           'aser14':
                        //                               Area_Ser14.toString(),
                        //                           'aser15':
                        //                               Area_Ser15.toString(),
                        //                           'aser16':
                        //                               Area_Ser16.toString(),
                        //                           'aser17':
                        //                               Area_Ser17.toString(),
                        //                           'aser18':
                        //                               Area_Ser18.toString(),
                        //                           'aser19':
                        //                               Area_Ser19.toString(),
                        //                           'aser20':
                        //                               Area_Ser20.toString(),
                        //                           'Arealength': selected_Area
                        //                               .length
                        //                               .toString(),
                        //                         },
                        //                       ).then((response) {
                        //                         var result =
                        //                             json.decode(response.body);
                        //                         // //print(result);
                        //                         if (result == null) {
                        //                           //print(
                        //                               ' Y random2 : ${formattedMilliseconds2}');
                        //                           setState(() {
                        //                             TextForm_time.text =
                        //                                 '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                        //                           });
                        //                           in_Trans_select();
                        //                         } else {
                        //                           Dialog_error();
                        //                           //print(
                        //                               ' N random2 : ${formattedMilliseconds2}');
                        //                         }
                        //                       }).catchError((e) {
                        //                         Dialog_error();
                        //                         print(
                        //                             ' N random2 : ${formattedMilliseconds2}');
                        //                       });
                        //                       // http
                        //                       //     .get(Uri.parse(url))
                        //                       //     .then((response) {
                        //                       //   var result =
                        //                       //       json.decode(response.body);
                        //                       //   // print(result);
                        //                       //   if (result == null) {
                        //                       //     print(
                        //                       //         ' Y random2 : ${formattedMilliseconds2}');
                        //                       //     setState(() {
                        //                       //       TextForm_time.text =
                        //                       //           '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                        //                       //     });
                        //                       //     in_Trans_select();
                        //                       //   } else {
                        //                       //     Dialog_error();
                        //                       //     print(
                        //                       //         ' N random2 : ${formattedMilliseconds2}');
                        //                       //   }
                        //                       // }).catchError((e) {
                        //                       //   Dialog_error();
                        //                       //   print(
                        //                       //       ' N random2 : ${formattedMilliseconds2}');
                        //                       // });
                        //                     } catch (e) {
                        //                       Dialog_error();
                        //                       print(
                        //                           ' N random2 : ${formattedMilliseconds2}');
                        //                     }
                        //                   });
                        //                 });
                        //               })
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 50,
                        // ),
                      ],
                    ),
                  ),
                ),
              )
            ])));
  }

  Column _stap3() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดการชำระ',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: [
                            (payment_Ptser.toString() != '7')
                                ? Dia_PayQR(cFinn, vts)
                                : Center(
                                    child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'BeamCheck..',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ))
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.deepPurple[100],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 40,
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'ใบเสร็จ',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text1_,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T
                                    //fontSize: 10.0
                                    ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 40,
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField2(
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
                                hint: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    '${Default_Receipt_[Default_Receipt_type]}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),

                                isExpanded: false,
                                // value: Default_Receipt_type == 0 ?''
                                // :'',
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
                                items: Default_Receipt_.map(
                                    (item) => DropdownMenuItem<String>(
                                          value: '${item}',
                                          child: Text(
                                            '${item}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                // fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        )).toList(),

                                onChanged: (value) async {
                                  int selectedIndex =
                                      Default_Receipt_.indexWhere(
                                          (item) => item == value);

                                  setState(() {
                                    Default_Receipt_type = selectedIndex;
                                    TitleType_Default_Receipt = 0;
                                  });

                                  // print(
                                  //     '${selectedIndex}////$value  ////----> $Default_Receipt_type');
                                },
                              ),
                            ),
                          ),
                          if (Default_Receipt_[Default_Receipt_type]
                                  .toString() ==
                              'ออกใบเสร็จ')
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  'หัวบิล',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
                            ),
                          if (Default_Receipt_[Default_Receipt_type]
                                  .toString() ==
                              'ออกใบเสร็จ')
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButtonFormField2(
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
                                        color:
                                            Color.fromARGB(255, 231, 227, 227),
                                      ),
                                    ),
                                  ),
                                  hint: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),

                                  isExpanded: false,
                                  // value: Default_Receipt_type == 0 ?''
                                  // :'',
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
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  items: TitleType_Default_Receipt_.map(
                                      (item) => DropdownMenuItem<String>(
                                            value: '${item}',
                                            child: Text(
                                              '${item}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          )).toList(),

                                  onChanged: (value) async {
                                    int selectedIndex =
                                        TitleType_Default_Receipt_.indexWhere(
                                            (item) => item == value);

                                    setState(() {
                                      TitleType_Default_Receipt = selectedIndex;
                                    });

                                    // print(
                                    //     '${selectedIndex}////$value  ////----> $TitleType_Default_Receipt');
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF102456), width: 1),
                      ),
                      child: InkWell(
                        onTap: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          var ren = preferences.getString('renTalSer');
                          var ser_user = preferences.getString('ser');
                          setState(() {
                            _Stap = 1;
                            base64_Slip = null;
                          });

                          var numin = cFinn;
                          var Formbecause = 'ยกเลิกจอง_Market';

                          String url_1 =
                              '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$ser_user&numin=$numin&because=$Formbecause';
                          try {
                            var response = await http.get(Uri.parse(url_1));

                            var result = json.decode(response.body);
                            // print(result);
                            if (result.toString() == 'true') {
                              Dialog_cancellock();
                            }
                          } catch (e) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chevron_left,
                                // color: textPrimary,
                                size: 10,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'ยกเลิกการจอง',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF102456),
                                  fontFamily: Font_.Fonts_T,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OtpTimerButton(
                          height: 50,
                          text: Text(
                            'ยืนยัน >',
                            style: TextStyle(
                                color: Colors.white,
                                // color: PeopleChaoScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          ),
                          duration: 3,
                          radius: 8,
                          backgroundColor: Colors.orange.shade900,
                          textColor: Colors.black,
                          buttonType: ButtonType.elevated_button,
                          loadingIndicator: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                          loadingIndicatorColor: Colors.red,
                          onPressed: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            var ren = preferences.getString('renTalSer');
                            if (base64_Slip.toString() == '' ||
                                base64_Slip == null) {
                              OKuploadName_Slip(cFinn);
                            } else {
                              if (base64_Slip != null) {
                                OKuploadFile_Slip();
                              }
                            }
                          }),
                    ),
                    // Material(
                    //   color: Colors.orange.shade900,
                    //   shape: const RoundedRectangleBorder(
                    //     side: BorderSide(color: Colors.white, width: 1),
                    //   ),
                    //   child: InkWell(
                    //     onTap: () async {
                    //       SharedPreferences preferences =
                    //           await SharedPreferences.getInstance();
                    //       var ren = preferences.getString('renTalSer');
                    //       if (base64_Slip.toString() == '' ||
                    //           base64_Slip == null) {
                    //         OKuploadName_Slip(cFinn);
                    //       } else {
                    //         if (base64_Slip != null) {
                    //           OKuploadFile_Slip();
                    //         }
                    //       }
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16),
                    //       child: Row(
                    //         children: [
                    //           Text(
                    //             'ยืนยัน',
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               color: Colors.white,
                    //               fontFamily: Font_.Fonts_T,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           SizedBox(width: 12),
                    //           Icon(
                    //             Icons.chevron_right,
                    //             color: Colors.white,
                    //             size: 10,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _stap2() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดพื้นที่',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.35,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'ชื่อผู้เช่า',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF102456),
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Material(
                                        color: Colors.transparent,
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xFF102456),
                                              width: 0.5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: TextForm_name,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white
                                                    .withOpacity(0.3),
                                                filled: true,
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                // labelText: 'ชื่อผู้เช่า...',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'ประเภทสินค้า',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF102456),
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppbackgroundColor
                                                      .Sub_Abg_Colors,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                width: 230,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton2<String>(
                                                    isExpanded: true,
                                                    searchController:
                                                        Dropdown_Controller,
                                                    searchInnerWidget:
                                                        Container(
                                                      width: 230,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red[100]!
                                                            .withOpacity(0.5),
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    8),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: TextFormField(
                                                        expands: true,
                                                        maxLines: null,
                                                        controller:
                                                            Dropdown_Controller,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 10,
                                                            vertical: 8,
                                                          ),
                                                          hintText: 'Search...',
                                                          // fillColor: Colors.red[300],
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    hint: Translate
                                                        .TranslateAndSetText(
                                                            'ค้นหา',
                                                            ChaoAreaScreen_Color
                                                                .Colors_Text2_,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            11,
                                                            2),
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: TextHome_Color
                                                          .TextHome_Colors,
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.green,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                    iconSize: 30,
                                                    buttonHeight: 35,
                                                    dropdownDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    items: [
                                                      for (int index = 0;
                                                          index <
                                                              Customer_stype
                                                                  .length;
                                                          index++)
                                                        DropdownMenuItem<
                                                            String>(
                                                          value:
                                                              '${Customer_stype[index]}',
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${index + 1}. ${Customer_stype[index]}',
                                                                maxLines: 2,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                              ),
                                                              Divider(
                                                                color: Colors
                                                                    .grey[300],
                                                                height: 4.0,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                    ],
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        TextForm_nametype.text =
                                                            value.toString();
                                                      });
                                                    },
                                                    // searchMatchFn:
                                                    //     (item, searchValue) {
                                                    //   return item.value
                                                    //       .toString()
                                                    //       .contains(
                                                    //           searchValue);
                                                    // },
                                                    // onMenuStateChange:
                                                    //     (isOpen) {
                                                    //   if (!isOpen) {
                                                    //     Dropdown_Controller
                                                    //         .clear();
                                                    //   }
                                                    // }
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Material(
                                        color: Colors.transparent,
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xFF102456),
                                              width: 0.5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: TextForm_nametype,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white
                                                    .withOpacity(0.3),
                                                filled: true,
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                // labelText:
                                                //     'กรอกประเภทสินค้า...',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'เลขบัตรประชาชน',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF102456),
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Material(
                                        color: Colors.transparent,
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xFF102456),
                                              width: 0.5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: TextForm_tax,
                                            maxLength: 13,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white
                                                    .withOpacity(0.3),
                                                filled: true,
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                // labelText: 'กรอกเลขบัตรประชาชน',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                )),
                                            inputFormatters: <TextInputFormatter>[
                                              // for below version 2 use this
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              // for version 2 and greater youcan also use this
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'เบอร์โทร',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF102456),
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Material(
                                        color: Colors.transparent,
                                        shape: const RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xFF102456),
                                              width: 0.5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            maxLength: 10,
                                            keyboardType: TextInputType.number,
                                            controller: TextForm_tel,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white
                                                    .withOpacity(0.3),
                                                filled: true,
                                                // prefixIcon:
                                                //     const Icon(Icons.person, color: Colors.black),
                                                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                // labelText: 'ระบุเบอร์โทร',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                )),
                                            inputFormatters: <TextInputFormatter>[
                                              // for below version 2 use this
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              // for version 2 and greater youcan also use this
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF102456), width: 1),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _Stap = 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chevron_left,
                                // color: textPrimary,
                                size: 10,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'กลับ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF102456),
                                  fontFamily: Font_.Fonts_T,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OtpTimerButton(
                          height: 50,
                          text: Text(
                            'ยืนยัน >',
                            style: TextStyle(
                                color: Colors.white,
                                // color: PeopleChaoScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          ),
                          duration: 3,
                          radius: 8,
                          backgroundColor: Colors.orange.shade900,
                          textColor: Colors.black,
                          buttonType: ButtonType.elevated_button,
                          loadingIndicator: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                          loadingIndicatorColor: Colors.red,
                          onPressed: () async {
                            if (TextForm_tax.text.toString().trim().length <
                                    13 ||
                                TextForm_tax.text.toString().trim() == '' ||
                                TextForm_name.text.toString().trim() == '' ||
                                TextForm_tel.text.toString().trim() == '' ||
                                TextForm_tel.text.toString().trim().length <
                                    9 ||
                                LDatex_total1_ == null ||
                                double.parse((selected_Area
                                        .fold(
                                            0.0,
                                            (previousValue, element) =>
                                                previousValue +
                                                (element.rent != null
                                                    ? double.parse(
                                                        element.rent!)
                                                    : 0))
                                        .toString())) ==
                                    0.00 ||
                                selected_Area.length == 0 ||
                                paymentName1 == null ||
                                paymentName1.toString().trim() == '' ||
                                TextForm_nametype.text.toString().trim() ==
                                    '') {
                              if (paymentName1 == null) {
                                Dialog_payoff();
                              } else {
                                Dialog_Form();
                              }
                            } else {
                              //print('  _Stap = 3');

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var ren = preferences.getString('renTalSer');
                              String Area_Ser1 = (selected_Area.length > 0)
                                  ? selected_Area[0].ser.toString()
                                  : '0';
                              String Area_Ser2 = (selected_Area.length > 1)
                                  ? selected_Area[1].ser.toString()
                                  : '0';
                              String Area_Ser3 = (selected_Area.length > 2)
                                  ? selected_Area[2].ser.toString()
                                  : '0';
                              String Area_Ser4 = (selected_Area.length > 3)
                                  ? selected_Area[3].ser.toString()
                                  : '0';
                              String Area_Ser5 = (selected_Area.length > 4)
                                  ? selected_Area[4].ser.toString()
                                  : '0';
                              String Area_Ser6 = (selected_Area.length > 5)
                                  ? selected_Area[5].ser.toString()
                                  : '0';
                              String Area_Ser7 = (selected_Area.length > 6)
                                  ? selected_Area[6].ser.toString()
                                  : '0';
                              String Area_Ser8 = (selected_Area.length > 7)
                                  ? selected_Area[7].ser.toString()
                                  : '0';
                              String Area_Ser9 = (selected_Area.length > 8)
                                  ? selected_Area[8].ser.toString()
                                  : '0';

                              String Area_Ser10 = (selected_Area.length > 9)
                                  ? selected_Area[9].ser.toString()
                                  : '0';

                              String Area_Ser11 = (selected_Area.length > 10)
                                  ? selected_Area[10].ser.toString()
                                  : '0';
                              String Area_Ser12 = (selected_Area.length > 11)
                                  ? selected_Area[11].ser.toString()
                                  : '0';
                              String Area_Ser13 = (selected_Area.length > 12)
                                  ? selected_Area[12].ser.toString()
                                  : '0';

                              String Area_Ser14 = (selected_Area.length > 13)
                                  ? selected_Area[13].ser.toString()
                                  : '0';

                              String Area_Ser15 = (selected_Area.length > 14)
                                  ? selected_Area[14].ser.toString()
                                  : '0';

                              String Area_Ser16 = (selected_Area.length > 15)
                                  ? selected_Area[15].ser.toString()
                                  : '0';

                              String Area_Ser17 = (selected_Area.length > 16)
                                  ? selected_Area[16].ser.toString()
                                  : '0';
                              String Area_Ser18 = (selected_Area.length > 17)
                                  ? selected_Area[17].ser.toString()
                                  : '0';

                              String Area_Ser19 = (selected_Area.length > 18)
                                  ? selected_Area[18].ser.toString()
                                  : '0';

                              String Area_Ser20 = (selected_Area.length > 19)
                                  ? selected_Area[19].ser.toString()
                                  : '0';

                              // print('Area_Ser1');
                              // print(Area_Ser1);
                              // print(Area_Ser2);
                              // print(Area_Ser3);
                              //--------------------> random_1
                              int randomMilliseconds =
                                  Random().nextInt(401) + 200;
                              Duration randomDuration =
                                  Duration(milliseconds: randomMilliseconds);

                              int formattedMilliseconds =
                                  randomDuration.inMilliseconds % 1000;
                              //--------------------> random_2

                              int randomMilliseconds2 =
                                  Random().nextInt(901) + 100;
                              Duration randomDuration2 =
                                  Duration(milliseconds: randomMilliseconds2);

                              int formattedMilliseconds2 =
                                  randomDuration2.inMilliseconds % 1000;
                              Dia_log(formattedMilliseconds);
                              Future.delayed(
                                  Duration(milliseconds: formattedMilliseconds),
                                  () async {
                                // print(
                                //     ' random1 : ${formattedMilliseconds}');

                                Future.delayed(
                                    Duration(
                                        milliseconds: formattedMilliseconds2),
                                    () async {
                                  try {
                                    String url =
                                        '${MyConstant().domain}/GC_UsercheckLock_Market.php?isAdd=true&ren=$ren';
                                    //print('  _Stap = 3 $url');
                                    var response = await http.post(
                                      Uri.parse(url),
                                      body: {
                                        'pdatex': SDatex_total1_.toString(),
                                        'aser1': Area_Ser1.toString(),
                                        'aser2': Area_Ser2.toString(),
                                        'aser3': Area_Ser3.toString(),
                                        'aser4': Area_Ser4.toString(),
                                        'aser5': Area_Ser5.toString(),
                                        'aser6': Area_Ser6.toString(),
                                        'aser7': Area_Ser7.toString(),
                                        'aser8': Area_Ser8.toString(),
                                        'aser9': Area_Ser9.toString(),
                                        'aser10': Area_Ser10.toString(),
                                        'aser11': Area_Ser11.toString(),
                                        'aser12': Area_Ser12.toString(),
                                        'aser13': Area_Ser13.toString(),
                                        'aser14': Area_Ser14.toString(),
                                        'aser15': Area_Ser15.toString(),
                                        'aser16': Area_Ser16.toString(),
                                        'aser17': Area_Ser17.toString(),
                                        'aser18': Area_Ser18.toString(),
                                        'aser19': Area_Ser19.toString(),
                                        'aser20': Area_Ser20.toString(),
                                        'Arealength':
                                            selected_Area.length.toString(),
                                      },
                                    ).then((response) {
                                      var result = json.decode(response.body);
                                      // //print(result);
                                      //print('  _Stap = 3 response $result');
                                      if (result.toString() == 'null' ||
                                          result == null) {
                                        // print(
                                        //     ' Y random2 : ${formattedMilliseconds2}');
                                        setState(() {
                                          TextForm_time.text =
                                              '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                                          _Stap = 3;
                                        });

                                        in_Trans_select();
                                      } else {
                                        Dialog_error();
                                        // print(
                                        //     ' N random2 : ${formattedMilliseconds2}');
                                      }
                                    }).catchError((e) {
                                      Dialog_error();
                                      // print(
                                      //     ' N random2 : ${formattedMilliseconds2}');
                                    });
                                    // var result = json.decode(response.body);
                                    // // print(result);
                                    // print('  _Stap = 3 response $result');
                                    // if (result.toString() == 'null' ||
                                    //     result == null) {
                                    //   print(
                                    //       ' Y random2 : ${result}');
                                    //   setState(() {
                                    //     TextForm_time.text =
                                    //         '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                                    //   });
                                    //   in_Trans_select();
                                    // } else {
                                    //   Dialog_error();
                                    //   // print(
                                    //   //     ' N random2 : ${formattedMilliseconds2}');
                                    // }
                                  } catch (e) {
                                    Dialog_error();
                                    // print(
                                    //     ' N random2 : ${formattedMilliseconds2}');
                                  }
                                });
                              });
                            }
                          }),
                    ),
                    // Material(
                    //   color: Colors.orange.shade900,
                    //   shape: const RoundedRectangleBorder(
                    //     side: BorderSide(color: Colors.white, width: 1),
                    //   ),
                    //   child: InkWell(
                    //     onTap: () async {
                    //       if (TextForm_tax.text.toString().trim().length < 13 ||
                    //           TextForm_tax.text.toString().trim() == '' ||
                    //           TextForm_name.text.toString().trim() == '' ||
                    //           TextForm_tel.text.toString().trim() == '' ||
                    //           TextForm_tel.text.toString().trim().length < 9 ||
                    //           LDatex_total1_ == null ||
                    //           double.parse((selected_Area
                    //                   .fold(
                    //                       0.0,
                    //                       (previousValue, element) =>
                    //                           previousValue +
                    //                           (element.rent != null
                    //                               ? double.parse(element.rent!)
                    //                               : 0))
                    //                   .toString())) ==
                    //               0.00 ||
                    //           selected_Area.length == 0 ||
                    //           paymentName1 == null ||
                    //           paymentName1.toString().trim() == '' ||
                    //           TextForm_nametype.text.toString().trim() == '') {
                    //         if (paymentName1 == null) {
                    //           Dialog_payoff();
                    //         } else {
                    //           Dialog_Form();
                    //         }
                    //       } else {
                    //         print('  _Stap = 3');

                    //         SharedPreferences preferences =
                    //             await SharedPreferences.getInstance();
                    //         var ren = preferences.getString('renTalSer');
                    //         String Area_Ser1 = (selected_Area.length > 0)
                    //             ? selected_Area[0].ser.toString()
                    //             : '0';
                    //         String Area_Ser2 = (selected_Area.length > 1)
                    //             ? selected_Area[1].ser.toString()
                    //             : '0';
                    //         String Area_Ser3 = (selected_Area.length > 2)
                    //             ? selected_Area[2].ser.toString()
                    //             : '0';
                    //         String Area_Ser4 = (selected_Area.length > 3)
                    //             ? selected_Area[3].ser.toString()
                    //             : '0';
                    //         String Area_Ser5 = (selected_Area.length > 4)
                    //             ? selected_Area[4].ser.toString()
                    //             : '0';
                    //         String Area_Ser6 = (selected_Area.length > 5)
                    //             ? selected_Area[5].ser.toString()
                    //             : '0';
                    //         String Area_Ser7 = (selected_Area.length > 6)
                    //             ? selected_Area[6].ser.toString()
                    //             : '0';
                    //         String Area_Ser8 = (selected_Area.length > 7)
                    //             ? selected_Area[7].ser.toString()
                    //             : '0';
                    //         String Area_Ser9 = (selected_Area.length > 8)
                    //             ? selected_Area[8].ser.toString()
                    //             : '0';

                    //         String Area_Ser10 = (selected_Area.length > 9)
                    //             ? selected_Area[9].ser.toString()
                    //             : '0';

                    //         String Area_Ser11 = (selected_Area.length > 10)
                    //             ? selected_Area[10].ser.toString()
                    //             : '0';
                    //         String Area_Ser12 = (selected_Area.length > 11)
                    //             ? selected_Area[11].ser.toString()
                    //             : '0';
                    //         String Area_Ser13 = (selected_Area.length > 12)
                    //             ? selected_Area[12].ser.toString()
                    //             : '0';

                    //         String Area_Ser14 = (selected_Area.length > 13)
                    //             ? selected_Area[13].ser.toString()
                    //             : '0';

                    //         String Area_Ser15 = (selected_Area.length > 14)
                    //             ? selected_Area[14].ser.toString()
                    //             : '0';

                    //         String Area_Ser16 = (selected_Area.length > 15)
                    //             ? selected_Area[15].ser.toString()
                    //             : '0';

                    //         String Area_Ser17 = (selected_Area.length > 16)
                    //             ? selected_Area[16].ser.toString()
                    //             : '0';
                    //         String Area_Ser18 = (selected_Area.length > 17)
                    //             ? selected_Area[17].ser.toString()
                    //             : '0';

                    //         String Area_Ser19 = (selected_Area.length > 18)
                    //             ? selected_Area[18].ser.toString()
                    //             : '0';

                    //         String Area_Ser20 = (selected_Area.length > 19)
                    //             ? selected_Area[19].ser.toString()
                    //             : '0';

                    //         // print('Area_Ser1');
                    //         // print(Area_Ser1);
                    //         // print(Area_Ser2);
                    //         // print(Area_Ser3);
                    //         //--------------------> random_1
                    //         int randomMilliseconds =
                    //             Random().nextInt(401) + 200;
                    //         Duration randomDuration =
                    //             Duration(milliseconds: randomMilliseconds);

                    //         int formattedMilliseconds =
                    //             randomDuration.inMilliseconds % 1000;
                    //         //--------------------> random_2

                    //         int randomMilliseconds2 =
                    //             Random().nextInt(901) + 100;
                    //         Duration randomDuration2 =
                    //             Duration(milliseconds: randomMilliseconds2);

                    //         int formattedMilliseconds2 =
                    //             randomDuration2.inMilliseconds % 1000;
                    //         Dia_log(formattedMilliseconds);
                    //         Future.delayed(
                    //             Duration(milliseconds: formattedMilliseconds),
                    //             () async {
                    //           // print(
                    //           //     ' random1 : ${formattedMilliseconds}');

                    //           Future.delayed(
                    //               Duration(
                    //                   milliseconds: formattedMilliseconds2),
                    //               () async {
                    //             try {
                    //               String url =
                    //                   '${MyConstant().domain}/GC_UsercheckLock_Market.php?isAdd=true&ren=$ren';
                    //               print('  _Stap = 3 $url');
                    //               var response = await http.post(
                    //                 Uri.parse(url),
                    //                 body: {
                    //                   'pdatex': SDatex_total1_.toString(),
                    //                   'aser1': Area_Ser1.toString(),
                    //                   'aser2': Area_Ser2.toString(),
                    //                   'aser3': Area_Ser3.toString(),
                    //                   'aser4': Area_Ser4.toString(),
                    //                   'aser5': Area_Ser5.toString(),
                    //                   'aser6': Area_Ser6.toString(),
                    //                   'aser7': Area_Ser7.toString(),
                    //                   'aser8': Area_Ser8.toString(),
                    //                   'aser9': Area_Ser9.toString(),
                    //                   'aser10': Area_Ser10.toString(),
                    //                   'aser11': Area_Ser11.toString(),
                    //                   'aser12': Area_Ser12.toString(),
                    //                   'aser13': Area_Ser13.toString(),
                    //                   'aser14': Area_Ser14.toString(),
                    //                   'aser15': Area_Ser15.toString(),
                    //                   'aser16': Area_Ser16.toString(),
                    //                   'aser17': Area_Ser17.toString(),
                    //                   'aser18': Area_Ser18.toString(),
                    //                   'aser19': Area_Ser19.toString(),
                    //                   'aser20': Area_Ser20.toString(),
                    //                   'Arealength':
                    //                       selected_Area.length.toString(),
                    //                 },
                    //               ).then((response) {
                    //                 var result = json.decode(response.body);
                    //                 // print(result);
                    //                 print('  _Stap = 3 response $result');
                    //                 if (result.toString() == 'null' ||
                    //                     result == null) {
                    //                   print(
                    //                       ' Y random2 : ${formattedMilliseconds2}');
                    //                   setState(() {
                    //                     TextForm_time.text =
                    //                         '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                    //                     _Stap = 3;
                    //                   });

                    //                   in_Trans_select();
                    //                 } else {
                    //                   Dialog_error();
                    //                   // print(
                    //                   //     ' N random2 : ${formattedMilliseconds2}');
                    //                 }
                    //               }).catchError((e) {
                    //                 Dialog_error();
                    //                 // print(
                    //                 //     ' N random2 : ${formattedMilliseconds2}');
                    //               });
                    //               // var result = json.decode(response.body);
                    //               // // print(result);
                    //               // print('  _Stap = 3 response $result');
                    //               // if (result.toString() == 'null' ||
                    //               //     result == null) {
                    //               //   print(
                    //               //       ' Y random2 : ${result}');
                    //               //   setState(() {
                    //               //     TextForm_time.text =
                    //               //         '${TextForm_time_hr.text}:${TextForm_time_min.text}:${TextForm_time_sec.text}';
                    //               //   });
                    //               //   in_Trans_select();
                    //               // } else {
                    //               //   Dialog_error();
                    //               //   // print(
                    //               //   //     ' N random2 : ${formattedMilliseconds2}');
                    //               // }
                    //             } catch (e) {
                    //               Dialog_error();
                    //               // print(
                    //               //     ' N random2 : ${formattedMilliseconds2}');
                    //             }
                    //           });
                    //         });
                    //       }
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16),
                    //       child: Row(
                    //         children: [
                    //           Text(
                    //             'ยืนยัน',
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               color: Colors.white,
                    //               fontFamily: Font_.Fonts_T,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           SizedBox(width: 12),
                    //           Icon(
                    //             Icons.chevron_right,
                    //             color: Colors.white,
                    //             size: 10,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _stap1() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            height: MediaQuery.of(context).size.width * 0.35,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดพื้นที่',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'เริ่ม-จองวันที่ : ',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Material(
                            color: Colors.transparent,
                            // shape: const RoundedRectangleBorder(
                            //   side: BorderSide(
                            //       color:
                            //           AppBarColors.ABar_Sub_Main,
                            //       width: 1),
                            // ),
                            child: InkWell(
                              onTap: () {
                                DateTime date1 = DateTime(
                                    DateTime.parse(SDatex_total1_.toString())
                                        .year,
                                    DateTime.parse(SDatex_total1_.toString())
                                        .month,
                                    DateTime.parse(SDatex_total1_.toString())
                                        .day);
                                // DateTime date2 = DateTime(
                                //     DateTime.parse(
                                //             prebook_bdate
                                //                 .toString())
                                //         .year,
                                //     DateTime.parse(
                                //             prebook_bdate
                                //                 .toString())
                                //         .month,
                                //     DateTime.parse(
                                //             prebook_bdate
                                //                 .toString())
                                //         .day);

                                CG_Prebook().then((result) {
                                  _select_financial_StartDate(context);
                                });

                                // CG_Prebook()
                                //     .then((result) {
                                //   _select_Date(context);
                                // });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Text(
                                      '${DateFormat('dd-MM-').format(DateTime.parse(SDatex_total1_.toString()))}${DateTime.parse(SDatex_total1_.toString()).year + 543}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF102456),
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'ถึง-วันที่ : ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFF102456), width: 1),
                            ),
                            child: InkWell(
                              onTap: () {
                                read_GC_rental_data_All();
                                CG_Prebook().then((result) {
                                  _select_financial_LtartDate(context);
                                });

                                // CG_Prebook()
                                //     .then((result) {
                                //   _select_LDate(context);
                                // });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Text(
                                      '${DateFormat('dd-MM-').format(DateTime.parse(LDatex_total1_.toString()))}${DateTime.parse(LDatex_total1_.toString()).year + 543}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF102456),
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (Date_list_selected.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'จำนวนวันที่ ท่านเลือกทั้งหมด : ${Date_list_selected.length} วัน',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF102456),
                                fontFamily: Font_.Fonts_T,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (Date_list_selected.isNotEmpty)
                              PopupMenuButton(
                                // color: Colors.green[50]!
                                //     .withOpacity(0.9),
                                child: const Center(
                                    child:
                                        Icon(Icons.info, color: Colors.grey)),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.green,
                                      child: Text(
                                        'จำนวนวันที่ ท่านเลือกทั้งหมด  ${Date_list_selected.length} วัน',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: Font_.Fonts_T,
                                          // fontWeight:
                                          //     FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (int index = 0;
                                      index < Date_list_selected.length;
                                      index++)
                                    PopupMenuItem(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                          '${index + 1}. วันที่ : ${DateFormat('dd-MM-').format(DateTime.parse(Date_list_selected[index].toString()))}${DateTime.parse(Date_list_selected[index].toString()).year + 543}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontFamily: Font_.Fonts_T,
                                            // fontWeight:
                                            //     FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'พื้นที่ เลือก',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF102456),
                              fontFamily: Font_.Fonts_T,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          (selected_Area.length == 0)
                              ? SizedBox()
                              : Text(
                                  '${selected_Area.map((data) => data.type.toString()).join(', ')}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF102456),
                                    fontFamily: Font_.Fonts_T,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.red[100]!.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            (selected_Area.length == 0)
                                ? Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.16,
                                    child: Center(
                                      child: Text(
                                        // (selected_Area.length == 0)
                                        //     ?
                                        'กรุณาเลือกพื้นที่',
                                        // : '${selected_Area.map((data) => data.type.toString()).join(', ')}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: (selected_Area.length == 0)
                                              ? Colors.red[300]
                                              : Colors.black,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T,
                                          fontSize: (selected_Area.length == 0)
                                              ? 12
                                              : null,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.16,
                                    padding: const EdgeInsets.all(5.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'รายการ',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'ราคา',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'จำนวนพื้นที่',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'ราคารวม',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          for (int index = 0;
                                              index < selected_Area.length;
                                              index++)
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${index + 1}. พื้นที่ : ${selected_Area[index].type.toString().trim()}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${nFormat.format(double.parse('${selected_Area[index].rent}'))} ',
                                                          textAlign:
                                                              TextAlign.end,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '1',
                                                          textAlign:
                                                              TextAlign.end,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${nFormat.format(double.parse('${selected_Area[index].rent}'))} ฿',
                                                          textAlign:
                                                              TextAlign.end,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          for (int indexexp = 0;
                                              indexexp < expModels.length;
                                              indexexp++)
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${(selected_Area.length) + (indexexp + 1)}. ${expModels[indexexp].expname}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${expModels[indexexp].pri_book}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${selected_Area.length}',
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${nFormat.format(double.parse('${expModels[indexexp].pri_book}') * selected_Area.length)} ฿',
                                                          textAlign:
                                                              TextAlign.end,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                        Divider(
                                                          height: 2,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'ทั้งหมด',
                                                        textAlign:
                                                            TextAlign.end,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        (selected_Area.length ==
                                                                0)
                                                            ? '0.00'
                                                            :
                                                            //  '${(selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())))}',
                                                            '${nFormat.format(double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString()))))} บาท',
                                                        textAlign:
                                                            TextAlign.end,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 12),
                                                      ),
                                                      Divider(
                                                        height: 2,
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
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      (selected_Area.length == 0)
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (Date_list_selected.length < 2)
                                    ? Text(
                                        'จำนวนเงิน',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : Text(
                                        'จำนวนเงิน (x${Date_list_selected.length}วัน)',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                Text(
                                  '${nFormat.format((Date_list_selected.length) * (double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + ((element.rent != null) ? double.parse(element.rent!) : 0)).toString())) + (selected_Area.length * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())))))} บาท',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: Font_.Fonts_T,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius:
            //       const BorderRadius.only(
            //     topLeft: Radius.circular(10),
            //     topRight: Radius.circular(10),
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(0),
            //   ),
            //   border: Border.all(
            //       color:
            //           AppBarColors.ABar_Sub_Main,
            //       width: 0.5),
            // ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (selected_Area.length == 0)
                        ? SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OtpTimerButton(
                                height: 50,
                                text: Text(
                                  'ชำระเงิน >',
                                  style: TextStyle(
                                      color: Colors.white,
                                      // color: PeopleChaoScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                                duration: 3,
                                radius: 8,
                                backgroundColor: Colors.orange.shade900,
                                textColor: Colors.black,
                                buttonType: ButtonType.elevated_button,
                                loadingIndicator: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                                loadingIndicatorColor: Colors.red,
                                onPressed: () async {
                                  if (selected_Area.length != 0) {
                                    setState(() {
                                      _Stap = 2;
                                      red_payMent();
                                    });
                                  } else {
                                    Dialog_Area();
                                  }
                                }),
                          ),
                    // Material(
                    //   color: Colors.orange.shade900,
                    //   shape: const RoundedRectangleBorder(
                    //     side: BorderSide(color: Colors.white, width: 1),
                    //   ),
                    //   child: InkWell(
                    //     onTap: () {
                    //       if (selected_Area.length != 0) {
                    //         setState(() {
                    //           _Stap = 2;
                    //           red_payMent();
                    //         });
                    //       } else {
                    //         Dialog_Area();
                    //       }
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(16),
                    //       child: Row(
                    //         children: [
                    //           Text(
                    //             'ชำระเงิน',
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               color: Colors.white,
                    //               fontFamily: Font_.Fonts_T,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           SizedBox(width: 12),
                    //           Icon(
                    //             Icons.chevron_right,
                    //             color: Colors.white,
                    //             size: 10,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Dialog_Form() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: 'กรุณากรอกข้อมูลให้ครบถ้วน...!!!',
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_areak();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_payoff() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: 'ขออภัย ทาง $renname ยังไม่เปิดให้จองพื้นที่...',
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_areak();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_Area() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: 'กรุณาเลือกพื้นที่จอง...!!!',
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_error() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message:
          "เกิดข้อผิดพลาดไม่สามารถจองได้ หรือมีคนจองพื้นที่ไปก่อนหน้าท่านแล้ว..",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        _Stap = 1;
        read_GC_area();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dia_log(milli_seconds) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(milliseconds: milli_seconds), () {
            Navigator.of(context).pop();
          });
          return Dialog(
            child: SizedBox(
                height: 40,
                width: 40,
                child: Center(
                    child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator()))
                // FittedBox(
                //   fit: BoxFit.cover,
                //   child: Image.asset(
                //     "images/gif-LOGOchao.gif",
                //     fit: BoxFit.cover,
                //     height: 20,
                //     width: 80,
                //   ),
                // ),
                ),
          );
        });
  }

  _searchBar() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 22.0, color: Colors.grey[700]),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
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
        //print(text);
        text = text.toLowerCase();
        setState(() {
          areaModels = _areaModels.where((areaModelss) {
            var notTitle = areaModelss.ln.toString().toLowerCase();
            var notTitle2 = areaModelss.lncode.toString().toLowerCase();
            // var notTitle3 = areaModelss.area.toString().toLowerCase();
            // var notTitle4 = areaModelss.rent.toString().toLowerCase();
            // var notTitle5 = areaModels.cname.toString().toLowerCase();
            return notTitle.contains(text) || notTitle2.contains(text);
          }).toList();
        });
      },
    );
  }

  Padding area_showbook2(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            padding: const EdgeInsets.all(16),
            width: (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.54
                : 800,
            // width: MediaQuery.of(context).size.width * 0.54,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              // color: Color(0xFFA8BFDB),
            ),
            child: areaModels.length == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              'เลือกวันที่',
                              minFontSize: 8,
                              maxFontSize: 20,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: Font_.Fonts_T,
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: InkWell(
                              onTap: () {
                                CG_Prebook().then((result) {
                                  _select_financial_StartDate(context);
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  height: 100,
                                  width: 200,
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(
                                    child: Text(
                                      (SDatex_total1_ == null)
                                          ? 'เลือก'
                                          : '$SDatex_total1_',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: ReportScreen_Color.Colors_Text2_,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: _viewmap == 0
                                          ? Colors.orange.shade900
                                          : AppbackgroundColor.Abg_Colors,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                      // border: Border.all(
                                      //     color: Colors.white, width: 0.5),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _viewmap = 0;
                                          move = 0;
                                          move_Area.clear();
                                          read_GC_area();
                                        });
                                        // _showMyDialogImg();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Grid View',
                                            style: TextStyle(
                                              // fontSize: 20,
                                              color: _viewmap == 0
                                                  ? Colors.white
                                                  : Colors.black,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: _viewmap == 1
                                          ? Colors.orange.shade900
                                          : AppbackgroundColor.Abg_Colors,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                      // border: Border.all(
                                      //     color: Colors.white, width: 0.5),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _viewmap = 1;
                                          move_Area.clear();
                                          move = 0;
                                          read_GC_area();
                                        });
                                        // _showMyDialogImg();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Map View',
                                            style: TextStyle(
                                              // fontSize: 20,
                                              color: _viewmap == 1
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(7),
                                    //   color: Colors.blue[700],
                                    // ),
                                    child: _searchBar(),
                                  ),
                                )
                              ]),
                          SizedBox(
                            height: 5,
                          ),
                          _viewmap == 0
                              ? Row(
                                  children: [
                                    (name_img == null ||
                                            name_img.toString() == '')
                                        ? SizedBox()
                                        : Expanded(
                                            child: Container(
                                                width: (Responsive.isDesktop(
                                                        context))
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.54
                                                    : 800,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.73,
                                                child: _showimg()
                                                //  (zone_img == null ||
                                                //         zone_img.toString() == '')
                                                //     ? const Center(
                                                //         child: Icon(
                                                //           Icons.image_not_supported,
                                                //           color: Colors.black,
                                                //         ),
                                                //       )
                                                //     : Image.network(
                                                //         '$zone_img',
                                                //         fit: BoxFit.contain,
                                                //       ),
                                                ),
                                          ),
                                    Expanded(
                                      child: Container(
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.54
                                            : 800,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.73,
                                        child: GridView.count(
                                          crossAxisCount: (name_img == null ||
                                                  name_img.toString() == '')
                                              ? (MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1200)
                                                  ? 8
                                                  : 6
                                              : (MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1200)
                                                  ? 4
                                                  : 3,
                                          children: [
                                            for (int i = 0;
                                                i < areaModels.length;
                                                i++)
                                              createCard(i, context),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.54
                                            : 800,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.73,
                                        child: _detelMap(),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                      _Stap == 1
                          ? SizedBox()
                          : Positioned(
                              // top: 5,
                              // right: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(117, 189, 189, 189),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No Touch',
                                      style: TextStyle(
                                        // fontSize: 20,
                                        color: Colors.black,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ],
                  )));
  }

  Offset _startOffset = Offset.zero;
  Offset _startOffset2 = Offset.zero;

  Padding _detelMap() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          nodeDatas.length == 0
              ? Center(
                  child: Text(
                    'No Map View',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      // fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                      //fontSize: 10.0
                    ),
                  ),
                )
              : zone_ser == 0
                  ? Center(
                      child: Text(
                        'Select Zone',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                          //fontSize: 10.0
                        ),
                      ),
                    )
                  : Listener(
                      onPointerDown: (details) {
                        controller.mouseDown = true;
                        controller.checkSelection(details.localPosition);
                        _startOffset = details.localPosition;
                      },
                      onPointerMove: (details) {
                        if (controller.mouseDown) {
                          controller.pan(details.delta);
                          _startOffset2 = details.delta;
                        }
                      },
                      onPointerUp: (details) {
                        controller.mouseDown = false;
                      },
                      onPointerCancel: (details) {
                        controller.mouseDown = false;
                      },
                      child: InfiniteCanvas(
                        menuVisible: false,
                        drawVisibleOnly: false,
                        canAddEdges: false,
                        controller: controller,
                        backgroundBuilder: (context, rect) {
                          return Container(
                            // width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.width * 0.32,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                              image: (name_img == null)
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage('$zone_img'),
                                      // "${MyConstant().domain}//${Imge_zone}"),
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            // child: CustomPaint(
                            //   size: rect.size,
                            //   painter: GridPainter(gridSize: gridSize),
                            // ),
                          );
                        },
                        // gridSize: gridSize,
                      ),
                    ),
          Positioned(
            top: 5,
            right: 10,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.zoom_in,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.zoomIn();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.zoom_out,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.zoomOut();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  TransformationController _controllergride = TransformationController();
  void _zoomInSVG() {
    _controllergride.value *= Matrix4.identity()..scale(1.2);
  }

  void _zoomOutSVG() {
    _controllergride.value *= Matrix4.identity()..scale(0.8);
  }

  Stack _showimg() {
    double _scaleFactor = 1.0; // define the initial scale factor

    return Stack(
      children: [
        SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              InteractiveViewer(
                child: Container(
                    height: MediaQuery.of(context).size.width * 0.32,
                    decoration: BoxDecoration(
                      // color: Colors.brown[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      // 'https://chaoperties.com/chao_api/files/kad_taii/zone/zoneBeam_Checkout_24042024_143948.png',
                      '$zone_img',
                      // fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.width * 0.32,
                      // width: 200,
                    )),
                alignment: Alignment.center,
                scaleEnabled: false,
                trackpadScrollCausesScale: false,
                transformationController: _controllergride,
                minScale: 0.8,
                maxScale: 2.0,
                constrained: true,
                boundaryMargin: const EdgeInsets.all(150.0),
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 10,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.zoom_in,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: _zoomInSVG,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.zoom_out,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: _zoomOutSVG,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Dialog_errorMax() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "จองได้สูงสุด 3 พื้นที่/ต่อครั้ง",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_area();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_errormove() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "จำนวนล็อคที่จะย้ายไม่ถูกต้อง!!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_area();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Widget createCard(int index, context) {
    return (areaModels.length == 0)
        ? SizedBox()
        : Card(
            color: areaModels[index].quantity == '' ||
                    areaModels[index].quantity == null
                ? Colors.green.shade200
                : areaModels[index].quantity == '4'
                    ? Colors.red.shade200
                    : Colors.grey.shade100,
            elevation:
                (selected_Area.any((area) => area.ser == areaModels[index].ser))
                    ? 30
                    : null,
            child: InkWell(
              onTap: (type_book_look.toString() == 'Look' &&
                      (areaModels[index].quantity == '' ||
                          areaModels[index].quantity == null))
                  ? null
                  : (type_book_look.toString() == 'Book' &&
                          areaModels[index].quantity == '4')
                      ? null
                      : () {
                          setState(() {
                            zone_ser = int.parse(areaModels[index].zser!);
                          });
                          if (areaModels[index].quantity == '4') {
                            if (move == 0) {
                              setState(() {
                                var doccid = areaModels[index].docno_book;
                                conbook =
                                    int.parse(areaModels[index].con_book!);
                                read_GC_contractBook(doccid);
                                selected_Area.clear();
                                // contractBookModels.clear();
                                // sum_total_book = 0;
                              });
                            } else {
                              PanaraInfoDialog.showAnimatedGrow(
                                context,
                                title: "Oops",
                                message: "พื้นที่ถูกจองแล้วกรุณาพื้นที่ว่าง!!!",
                                buttonText: "รับทราบ",
                                onTapDismiss: () async {
                                  Navigator.pop(context);
                                },
                                panaraDialogType: PanaraDialogType.error,
                                barrierDismissible:
                                    false, // optional parameter (default is true)
                              );
                            }
                          } else if (areaModels[index].quantity == '' ||
                              areaModels[index].quantity == null) {
                            if (move == 0) {
                              setState(() {
                                contractBookModels.clear();
                                sum_total_book = 0;
                                conbook = -1;
                                // read_GC_contractBook(0);
                              });
                              if (selected_Area.length >= 18) {
                                /////---------------->
                                setState(() {
                                  selected_Area.removeWhere((area) =>
                                      area.ser == areaModels[index].ser);
                                });
                                /////---------------->
                                if ((selected_Area.length >= 18)) {
                                  Dialog_errorMax();
                                } else {}
                                /////---------------->
                              } else {
                                // print(areakModels[index].aserQout);
                                Map<String, dynamic> map = Map();
                                map['ser'] = '${areaModels[index].ser}';
                                map['datex'] = '${areaModels[index].datex}';
                                map['timex'] = '${areaModels[index].timex}';
                                map['cser'] = '${areaModels[index].cser}';
                                map['aser'] = '${areaModels[index].aser}';
                                map['aserQout'] =
                                    '${areaModels[index].aserQout}';
                                map['type'] = '${areaModels[index].lncode}';
                                map['sdate'] = '${areaModels[index].sdate}';
                                map['ldate'] = '${areaModels[index].ldate}';
                                map['dataUpdate'] =
                                    '${areaModels[index].dataUpdate}';
                                map['rent'] = '${areaModels[index].rent}';
                                map['area'] = '${areaModels[index].area}';
                                map['zn'] = '${areaModels[index].zn}';

                                AreakModel areakModel_add =
                                    AreakModel.fromJson(map);
                                // print(areakModel_add.type);

                                bool exists = selected_Area.any(
                                    (area) => area.ser == areakModel_add.ser);
                                if (!exists) {
                                  setState(() {
                                    selected_Area.add(areakModel_add);
                                  });
                                } else {
                                  setState(() {
                                    selected_Area.removeWhere((area) =>
                                        area.ser == areaModels[index].ser);
                                  });
                                }
                              }
                            } else {
                              if (move_Area.length >=
                                  contractBookModels[0].ln!.split(',').length) {
                                /////---------------->
                                setState(() {
                                  move_Area.removeWhere((area) =>
                                      area.ser == areaModels[index].ser);
                                });
                                /////---------------->
                                if ((move_Area.length >=
                                    contractBookModels[0]
                                        .ln!
                                        .split(',')
                                        .length)) {
                                  Dialog_errormove();
                                } else {}
                                /////---------------->
                              } else {
                                // print(areakModels[index].aserQout);
                                Map<String, dynamic> map = Map();
                                map['ser'] = '${areaModels[index].ser}';
                                map['datex'] = '${areaModels[index].datex}';
                                map['timex'] = '${areaModels[index].timex}';
                                map['cser'] = '${areaModels[index].cser}';
                                map['aser'] = '${areaModels[index].aser}';
                                map['aserQout'] =
                                    '${areaModels[index].aserQout}';
                                map['type'] = '${areaModels[index].lncode}';
                                map['sdate'] = '${areaModels[index].sdate}';
                                map['ldate'] = '${areaModels[index].ldate}';
                                map['dataUpdate'] =
                                    '${areaModels[index].dataUpdate}';
                                map['rent'] = '${areaModels[index].rent}';
                                map['area'] = '${areaModels[index].area}';
                                map['zn'] = '${areaModels[index].zn}';

                                AreakModel areakModel_add =
                                    AreakModel.fromJson(map);
                                // print(areakModel_add.type);

                                bool exists = move_Area.any(
                                    (area) => area.ser == areakModel_add.ser);
                                if (!exists) {
                                  setState(() {
                                    move_Area.add(areakModel_add);
                                  });
                                } else {
                                  setState(() {
                                    move_Area.removeWhere((area) =>
                                        area.ser == areaModels[index].ser);
                                  });
                                }
                              }
                            }
                          } else {
                            if (move == 0) {
                              setState(() {
                                selected_Area.clear();
                                contractBookModels.clear();
                                sum_total_book = 0;
                                conbook = -1;
                                // read_GC_contractBook(0);
                              });
                            } else {
                              setState(() {
                                move_Area.clear();
                              });
                            }
                          }
                        },
              child: Container(
                  color: move_Area.length == 0
                      ? (selected_Area
                              .any((area) => area.ser == areaModels[index].ser))
                          ? Colors.yellow.shade600
                          : areaModels[index].quantity == '' ||
                                  areaModels[index].quantity == null
                              ? Colors.green.shade200
                              : areaModels[index].quantity == '4'
                                  ? areaModels[index].con_book == '0'
                                      ? Colors.blue.shade900
                                      : areaModels[index].con_book == '1'
                                          ? Colors.red.shade900
                                          : Colors.green.shade200
                                  : Colors.grey.shade100
                      : (move_Area
                              .any((area) => area.ser == areaModels[index].ser))
                          ? Colors.yellow.shade600
                          : areaModels[index].quantity == '' ||
                                  areaModels[index].quantity == null
                              ? Colors.green.shade200
                              : areaModels[index].quantity == '4'
                                  ? areaModels[index].con_book == '0'
                                      ? Colors.blue.shade900
                                      : areaModels[index].con_book == '1'
                                          ? Colors.red.shade900
                                          : Colors.green.shade200
                                  : Colors.grey.shade100,
                  width: MediaQuery.of(context).size.width * 0.1,
                  padding: EdgeInsets.all(8),
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: AutoSizeText(
                        '${areaModels[index].lncode}',
                        minFontSize: 8,
                        maxFontSize: (Responsive.isDesktop(context)) ? 18 : 12,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontSize: 20,
                          fontFamily: Font_.Fonts_T,
                          color: areaModels[index].quantity == '4'
                              ? areaModels[index].con_book == '0'
                                  ? Colors.white
                                  : areaModels[index].con_book == '1'
                                      ? Colors.white
                                      : PeopleChaoScreen_Color.Colors_Text2_
                              : PeopleChaoScreen_Color.Colors_Text2_,
                        ),
                        maxLines: (Responsive.isDesktop(context)) ? 4 : 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      AutoSizeText(
                        areaModels[index].quantity == '1'
                            ? (areaModels[index].ldate == null)
                                ? 'หมดสัญญา'
                                : now.isAfter(DateTime.parse(
                                                '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(now) : areaModels[index].ldate} 00:00:00.000')
                                            .subtract(
                                                const Duration(days: 0))) ==
                                        true
                                    ? 'หมดสัญญา'
                                    : now.isAfter(DateTime.parse(
                                                    '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(now) : areaModels[index].ldate} 00:00:00.000')
                                                .subtract(Duration(
                                                    days: open_set_date))) ==
                                            true
                                        ? 'ใกล้หมดสัญญา'
                                        : 'เช่าอยู่'
                            : areaModels[index].quantity == '2'
                                ? 'เสนอราคา'
                                : areaModels[index].quantity == '3'
                                    ? 'เสนอราคา(มัดจำ)'
                                    : areaModels[index].quantity == '4'
                                        ? areaModels[index].con_book == '0'
                                            ? 'จองแล้ว'
                                            : areaModels[index].con_book == '1'
                                                ? 'ยืนยันการจอง'
                                                : 'ว่าง'
                                        : 'ว่าง',
                        minFontSize: 8,
                        maxFontSize: 12,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontSize: 20,
                          fontFamily: Font_.Fonts_T,
                          color: areaModels[index].quantity == '4'
                              ? areaModels[index].con_book == '0'
                                  ? Colors.white
                                  : areaModels[index].con_book == '1'
                                      ? Colors.white
                                      : PeopleChaoScreen_Color.Colors_Text2_
                              : PeopleChaoScreen_Color.Colors_Text2_,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Center(
                          child: AutoSizeText(
                        areaModels[index].quantity == '4'
                            ? '${areaModels[index].stype}'
                            : '${areaModels[index].rent}',
                        minFontSize: 8,
                        maxFontSize: 12,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontSize: 20,
                          fontFamily: Font_.Fonts_T,
                          color: areaModels[index].quantity == '4'
                              ? areaModels[index].con_book == '0'
                                  ? Colors.white
                                  : areaModels[index].con_book == '1'
                                      ? Colors.white
                                      : PeopleChaoScreen_Color.Colors_Text2_
                              : PeopleChaoScreen_Color.Colors_Text2_,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  )),
            ));
  }

  Future<void> _showMyDialogImg() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(
              child: Text(
            'รูปฝัง',
            style: const TextStyle(
              // fontSize: 15,
              color: Colors.black,
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.bold,
            ),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InteractiveViewer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: (zone_img == null || zone_img.toString() == '')
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.black,
                            ),
                          )
                        : Image.network(
                            '$zone_img',
                            fit: BoxFit.contain,
                          ),
                  ),
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 5.0,
                  transformationController: TransformationController()
                    ..value =
                        Matrix4.diagonal3Values(_scaleFactor, _scaleFactor, 1),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              child: Container(
                width: 150,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: const Center(
                  child: Text(
                    'ปิด',
                    style: TextStyle(
                      // fontSize: 15,
                      color: Colors.white,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> read_GC_Pos() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/print_pos.php?isAdd=true&ser=50&type=MS';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      // for (var map in result) {
      //   SubZoneModel subzoneModel = SubZoneModel.fromJson(map);
      //   setState(() {
      //     subzoneModels.add(subzoneModel);
      //   });
      // }
    } catch (e) {}
  }

  // Future<Null> in_Trans_select() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   // var ren = '${widget.Ser_}';
  //   var user = '${DateTime.now()}';
  //   var zoneser = '$zone_ser';
  //   var selecte = selected_Area.length;
  //   ////datex_selected
  //   DateTime newDatetimex = DateTime.now();
  //   var day = DateFormat('dd').format(newDatetimex);
  //   var timex = DateFormat('HHmmss').format(newDatetimex);
  //   var vts = day.toString() + timex.toString();
  //   String selecte_ln =
  //       '${selected_Area.map((data) => data.type.toString()).join(',')}';
  //   var ciddoc =
  //       'L$day$timex-${selected_Area.map((data) => data.type.toString()).join(',')}'; //In_c_paynew
  //   // var area_rent_sum = expModels[index].cal_auto == '1'
  //   //     ? expModels[index].pri_auto
  //   //     : _area_rent_sum; //ราคาพื้นที่

  //   for (int index = 0; index < selected_Area.length; index++) {
  //     var tser = selected_Area[index].aser;
  //     var area_rent_sum = selected_Area[index].rent;
  //     print(tser);
  //     String url =
  //         '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$vts&ciddoc=$ciddoc&zone=$zoneser&serinsert=1&tax=${TextForm_tax.text.toString()}&date_lock=$SDatex_total1_';
  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // print(tser);
  //     } catch (e) {}
  //   }

  //   for (int index = 0; index < expModels.length; index++) {
  //     var tser = expModels[index].ser;
  //     var area_rent_sum = expModels[index].pri_book;
  //     String url =
  //         '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$vts&ciddoc=$ciddoc&zone=$zoneser&serinsert=2&tax=${TextForm_tax.text.toString()}&date_lock=$SDatex_total1_';
  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // print(result);
  //     } catch (e) {}
  //   }
  //   // setState(() {
  //   //   selected_Area.clear();
  //   // });
  //   await in_Trans(vts, day, timex, ciddoc);
  // }
///////////////////////////-------------------------------------->

  var vtsmove;
  Future<Null> in_Trans_moveselect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser'); // user_book;
    var zoneser = '$zone_ser';
    var selecte = move_Area.length;
    int index_datex = 0;
    ////datex_selected
    DateTime newDatetimex = DateTime.now();
    var day = await DateFormat('dd').format(newDatetimex);
    var timex = await DateFormat('HHmmss').format(newDatetimex);
    setState(() {
      vtsmove = day.toString() + timex.toString();
    });
    String selecte_ln =
        await '${move_Area.map((data) => data.type.toString()).join(',')}';
    var ciddoc =
        await 'L$day$timex-${move_Area.map((data) => data.type.toString()).join(',')}'; //In_c_paynew
    // var area_rent_sum = expModels[index].cal_auto == '1'
    //     ? expModels[index].pri_auto
    //     : _area_rent_sum; //ราคาพื้นที่
    for (int index_date = 0;
        index_date < Date_list_selectedmove.length;
        index_date++) {
      var date_lock = Date_list_selectedmove[index_date];
      for (int index = 0; index < move_Area.length; index++) {
        var tser = move_Area[index].aser;
        var area_rent_sum = move_Area[index].rent;

        //print('in1 $tser');
        String url =
            '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$ser_user&ciddoc=$ciddoc&zone=$zoneser&serinsert=1&tax=$tax_book&date_lock=$date_lock';

        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);
          // print('in2 ${result.toString()}');
        } catch (e) {}
      }

      for (int index = 0; index < expModels.length; index++) {
        var tser = expModels[index].ser;
        var area_rent_sum = expModels[index].pri_book;
        String url =
            '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$ser_user&ciddoc=$ciddoc&zone=$zoneser&serinsert=2&tax=$tax_book&date_lock=$date_lock';
        try {
          var response = await http.get(Uri.parse(url));
          //print('in3 $tser');
          var result = json.decode(response.body);
          //print('in3.1 ${result.toString()}');
        } catch (e) {}
      }
      setState(() {
        index_datex++;
      });
      // print('index_datex---${index_date}----${Date_list_selected[index_date]}');
      // print(index_datex);
      if ((index_date + 1) == Date_list_selectedmove.length) {
        // print('await in_Trans');
        //print('in4 $index_date');
        await in_moveTrans(vtsmove, day, timex, ciddoc, index_datex);
      } else {}
      // await in_Trans(vts, day, timex, ciddoc, index_date);
    }
////------------------>

    // setState(() {
    //   selected_Area.clear();
    // });
  }

  /////---------------------------------------------------------->
  Future<Null> in_moveTrans(vtsmove, day, timex, ciddoc, index_date) async {
    var datex_TransNow = DateFormat('yyyy-MM-dd').format(newDatetime);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser'); //user_book;
    // var ren = '${widget.Ser_}';
    var zoneser = zone_ser;
    // if (base64_Slip != null) {
    //   // print('base64_Slip>>>  $ciddoc');
    //   OKuploadFile_Slip(vts);
    // }

    ///------------------>
    String name_book = naem_book.toString().trim();
    String Tel_book = tel_book.toString().trim();
    String name_type = type_book.toString().trim();
    String datex_book = SDatex_total1_.toString().trim();
    String Area_selecte =
        '${move_Area.map((data) => data.type.toString()).join(',')}';
    String Area_Ser =
        '${move_Area.map((data) => data.ser.toString()).join(',')}';
    String PriArea_Book = (move_Area.length == 0)
        ? '0.00'
        : '${double.parse(Date_list_selectedmove.length.toString()) * double.parse((move_Area.fold(0.0, (previousValue, element) => previousValue + (element.rent != null ? double.parse(element.rent!) : 0)).toString()))}';
    String PriExp_Book = (move_Area.length == 0)
        ? '0.00'
        : '${double.parse(Date_list_selectedmove.length.toString()) * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())) * move_Area.length}';

    String TimePay_Book = TextForm_time.text;
    String? fileNameSlip_ =
        (fileName_Slip == null || fileName_Slip.toString() == 'null')
            ? ''
            : fileName_Slip.toString().trim();
    var summove = sum_total_book -
        (Date_list_selectedmove.length) *
            (double.parse((move_Area
                    .fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue +
                            ((element.rent != null)
                                ? double.parse(element.rent!)
                                : 0))
                    .toString())) +
                (move_Area.length *
                    double.parse((expModels
                        .fold(
                            0.0,
                            (previousValue, element) =>
                                previousValue +
                                ((element.pri_book != null)
                                    ? double.parse(element.pri_book!)
                                    : 0))
                        .toString()))));

    ////////-------------------------------------------------------->
    var qutser = move_Area.length.toString();
    var bill = 'P';
    var payment1 = '0';
    var payment2 = '0';

    String url =
        // 'https://dzentric.com/chao_perty/chao_api/In_tran_financet_webmaket.php?isAdd=true&ren=$ren';
        '${MyConstant().domain}/In_movepayMent.php?isAdd=true&ren=$ren';

    try {
      var response = await http.post(Uri.parse(url), body: {
        'ciddoc': docno_book.toString(),
        'fiddoc': ciddoc.toString(),
        'qutser': qutser.toString(),
        'user': ser_user.toString(),
        'sumdis': '0.00',
        'sumdisp': '0.00',
        'dateY': '',
        'dateY1': '',
        'payby': 'LP',
        // 'dateY': SDatex_total1_,
        // 'dateY1': LDatex_total1_,
        'time': TimePay_Book,
        'payment1': '${double.parse(PriArea_Book) + double.parse(PriExp_Book)}',
        'payment2': '0.00',
        'pSer1': payserby.toString(),
        'pSer2': '0',
        'sum_whta': '0.00',
        'bill': 'P',
        'fileNameSlip': slip_book.toString(),
        'areaSer': '$Area_Ser',
        'typeModels': '',
        'typeshop': name_type.toString(),
        'nameshop': name_book.toString(),
        'bussshop': name_book.toString(),
        'bussscontact': name_book.toString(),
        'address': '',
        'tel': Tel_book.toString(),
        'tax': tax_book.toString(),
        'email': '',
        'Serbool': '',
        'area_rent_sum': summove.toString(),
        'comment': 'ย้ายมาจากพื้นที่ ${contractBookModels[0].ln}',
        'zser': zoneser.toString(),
        'namearea': Area_selecte,
      }).then((value) async {
        // print('*1111**********$value');
        var result = json.decode(value.body);
        // print('*222**********$result ');
        //print('in7 ${result.toString()}');
        if (result.toString() != 'No') {
          PanaraInfoDialog.showAnimatedGrow(
            context,
            title: "Oops",
            message: "ทำการย้ายพื้นที่เสร็จสิ้น !!!",
            buttonText: "รับทราบ",
            onTapDismiss: () async {
              setState(() {
                move_Area.clear();
                contractBookModels.clear();
                move = 0;
                count_book = 0;
                docno_book = null;
                Date_list_selectedmove.clear();
                contractBookModels.clear();
                sum_total_book = 0;
                read_GC_area();
              });

              Navigator.pop(context);
            },
            panaraDialogType: PanaraDialogType.success,
            barrierDismissible: false, // optional parameter (default is true)
          );
        } else {
          PanaraInfoDialog.showAnimatedGrow(
            context,
            title: "Oops",
            message: "ไม่สามารถการย้ายพื้นที่ได้ !!!",
            buttonText: "รับทราบ",
            onTapDismiss: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              var ren = preferences.getString('renTalSer');
              var ser_user = preferences.getString('ser');

              var numin = docno_book;
              var Formbecause = '';

              String url_1 =
                  '${MyConstant().domain}/UPC_finant_bill_move.php?isAdd=true&ren=$ren&user=$ser_user&numin=$numin&because=$Formbecause&stap=E';
              try {
                var response = await http.get(Uri.parse(url_1));

                var result = json.decode(response.body);
                // print(result);
                if (result.toString() == 'true') {
                  setState(() {
                    move_Area.clear();
                    move = 0;
                    contractBookModels.clear();
                    count_book = 0;
                    docno_book = null;
                    Date_list_selectedmove.clear();
                    sum_total_book = 0;
                    read_GC_area();
                  });
                  Navigator.pop(context);
                }
              } catch (e) {}
            },
            panaraDialogType: PanaraDialogType.error,
            barrierDismissible: false, // optional parameter (default is true)
          );
        }
      });
    } catch (e) {}
  }

  var vts;
  Future<Null> in_Trans_select() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser');
    var zoneser = '$zone_ser';
    var selecte = selected_Area.length;
    int index_datex = 0;
    ////datex_selected
    DateTime newDatetimex = DateTime.now();
    var day = await DateFormat('dd').format(newDatetimex);
    var timex = await DateFormat('HHmmss').format(newDatetimex);
    setState(() {
      vts = day.toString() + timex.toString();
    });
    String selecte_ln =
        await '${selected_Area.map((data) => data.type.toString()).join(',')}';
    var ciddoc =
        await 'L$day$timex-${selected_Area.map((data) => data.type.toString()).join(',')}'; //In_c_paynew
    // var area_rent_sum = expModels[index].cal_auto == '1'
    //     ? expModels[index].pri_auto
    //     : _area_rent_sum; //ราคาพื้นที่
    for (int index_date = 0;
        index_date < Date_list_selected.length;
        index_date++) {
      for (int index = 0; index < selected_Area.length; index++) {
        var tser = selected_Area[index].aser;
        var area_rent_sum = selected_Area[index].rent;
        //print('in1 $tser');
        String url =
            '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$ser_user&ciddoc=$ciddoc&zone=$zoneser&serinsert=1&tax=${TextForm_tax.text.toString()}&date_lock=${Date_list_selected[index_date]}';

        try {
          var response = await http.get(Uri.parse(url));

          var result = json.decode(response.body);
         //  print('in2 ${result.toString()}');
        } catch (e) {}
      }

      for (int index = 0; index < expModels.length; index++) {
        var tser = expModels[index].ser;
        var area_rent_sum = expModels[index].pri_book;
        String url =
            '${MyConstant().domain}/In_c_paynewMarket.php?isAdd=true&ren=$ren&tser=$tser&selecte=$selecte&selecte_ln=$selecte_ln&_area_rent_sum=$area_rent_sum&user=$ser_user&ciddoc=$ciddoc&zone=$zoneser&serinsert=2&tax=${TextForm_tax.text.toString()}&date_lock=${Date_list_selected[index_date]}';
        try {
          var response = await http.get(Uri.parse(url));
          //print('in3 $tser');
          var result = json.decode(response.body);
          //print('in3.1 ${result.toString()}');
        } catch (e) {}
      }
      setState(() {
        index_datex++;
      });
      // print('index_datex---${index_date}----${Date_list_selected[index_date]}');
      // print(index_datex);
      if ((index_date + 1) == Date_list_selected.length) {
        // print('await in_Trans');
        //print('in4 $index_date');
        await in_Trans(vts, day, timex, ciddoc, index_datex);
      } else {}
      // await in_Trans(vts, day, timex, ciddoc, index_date);
    }
////------------------>

    // setState(() {
    //   selected_Area.clear();
    // });
  }

  /////---------------------------------------------------------->
  Future<Null> in_Trans(vts, day, timex, ciddoc, index_date) async {
    var datex_TransNow = DateFormat('yyyy-MM-dd').format(newDatetime);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ser_user = preferences.getString('ser');
    // var ren = '${widget.Ser_}';
    var zoneser = zone_ser;
    // if (base64_Slip != null) {
    //   // print('base64_Slip>>>  $ciddoc');
    //   OKuploadFile_Slip(vts);
    // }

    ///------------------>
    String name_book = TextForm_name.text.toString().trim();
    String Tel_book = TextForm_tel.text.toString().trim();
    String name_type = TextForm_nametype.text.toString().trim();
    String datex_book = SDatex_total1_.toString().trim();
    String Area_selecte =
        '${selected_Area.map((data) => data.type.toString()).join(',')}';
    String Area_Ser =
        '${selected_Area.map((data) => data.ser.toString()).join(',')}';
    String PriArea_Book = (selected_Area.length == 0)
        ? '0.00'
        : '${double.parse(Date_list_selected.length.toString()) * double.parse((selected_Area.fold(0.0, (previousValue, element) => previousValue + (element.rent != null ? double.parse(element.rent!) : 0)).toString()))}';
    String PriExp_Book = (selected_Area.length == 0)
        ? '0.00'
        : '${double.parse(Date_list_selected.length.toString()) * double.parse((expModels.fold(0.0, (previousValue, element) => previousValue + ((element.pri_book != null) ? double.parse(element.pri_book!) : 0)).toString())) * selected_Area.length}';

    String TimePay_Book = TextForm_time.text;
    String? fileNameSlip_ =
        (fileName_Slip == null || fileName_Slip.toString() == 'null')
            ? ''
            : fileName_Slip.toString().trim();

    ////////----------------------------------------------->
    // print('--------->');
    // print('ชื่อผู้เช่า : ${name_book}');
    //print('เบอร์ : ${Tel_book}');
    //print('วันที่จอง : ${datex_book}');
    //print('พื้นที่จอง : ${Area_selecte}');
    //print('ราคาพื้นที่ : ${PriArea_Book}');
    //print('ราคาอื่นๆที่เก็บเพิ่ม : ${PriExp_Book}');
    //print('รูปแบบชำระ : ${paymentName1}');
    //print('Serแบบชำระ : ${paymentSer1}');
    // //print('วันที่ทำรายการ : ${datex_selected}');
    // //print('วันที่ชำระ : ${datex_selected}');
    //print('เวลาหลักฐาน : ${TimePay_Book}');
    //print('หลักฐานชำระ : ${fileNameSlip_}');
    //print('Ser พื้นที่จอง : ${Area_Ser}');
    // print('--------->');
    // print('ren : ${ren}');
    // print('user : ${vts}');
    // print('zoneser : ${zoneser}');
    // print('--------->');
    ////////-------------------------------------------------------->
    var qutser = selected_Area.length.toString();
    var bill = 'P';
    var payment1 = '0';
    var payment2 = '0';

    String url =
        // 'https://dzentric.com/chao_perty/chao_api/In_tran_financet_webmaket.php?isAdd=true&ren=$ren';
        '${MyConstant().domain}/In_tran_financet_webmaket.php?isAdd=true&ren=$ren';

    //print('in6 $url');
    try {
      var response = await http.post(Uri.parse(url), body: {
        'ciddoc': ciddoc.toString(),
        'qutser': qutser.toString(),
        'user': ser_user.toString(),
        'sumdis': '0.00',
        'sumdisp': '0.00',
        'dateY': '',
        'dateY1': '',
        'payby': 'LP',
        // 'dateY': SDatex_total1_,
        // 'dateY1': LDatex_total1_,
        'time': TimePay_Book,
        'payment1': '${double.parse(PriArea_Book) + double.parse(PriExp_Book)}',
        'payment2': '0.00',
        'pSer1': '$paymentSer1',
        'pSer2': '0',
        'sum_whta': '0.00',
        'bill': 'P',
        'fileNameSlip': fileNameSlip_.toString(),
        'areaSer': '$Area_Ser',
        'typeModels': '',
        'typeshop': name_type.toString(),
        'nameshop': name_book.toString(),
        'bussshop': name_book.toString(),
        'bussscontact': name_book.toString(),
        'address': '',
        'tel': Tel_book.toString(),
        'tax': TextForm_tax.text.toString(),
        'email': '',
        'Serbool': '',
        'area_rent_sum': '',
        'comment': '',
        'zser': zoneser.toString(),
        'namearea': Area_selecte,
      }).then((value) async {
        // print('*1111**********$value');
        var result = json.decode(value.body);
        // print('*222**********$result ');
        //print('in7 ${result.toString()}');
        if (result.toString() != 'No') {
          for (var map in result) {
            CFinnancetransModel cFinnancetransModel =
                CFinnancetransModel.fromJson(map);
            setState(() {
              cFinn = cFinnancetransModel.docno;
            });
            // print('in_Trans_invoice///zzzzasaaa123454>>>>  $cFinn');
            // print(
            //     'in_Trans_invoice///bnobnobnobno123454>>>>  ${cFinnancetransModel.bno}');
          }
          Future.delayed(Duration(milliseconds: 100), () async {
            if (cFinn == null ||
                cFinn.toString() == '' ||
                cFinn.toString() == 'null') {
            } else {
              // if (payment_Ptser.toString() == '5') {
              //   Dia_PayQR(cFinn, vts);
              // }
              if (payment_Ptser.toString() == '7') {
                read_GC_beamcheckout(
                    cFinn,
                    selected_Area,
                    '${double.parse(PriArea_Book) + double.parse(PriExp_Book)}',
                    name_book);
              }
            }

            // ManPay_Receipt_PDF.ManPayReceipt_PDF(context, widget.Ser_, '$cFinn',
            //     bill_addr, bill_email, bill_tel, bill_tax, bill_name);
          });
        }
      });
    } catch (e) {}
  }

///////--------------------------------------------------------->(Stap-1)
  Future<Null> read_GC_beamcheckout(
      cFinn, selected_Area, PriArea, name_book) async {
    /////////--------------->
    String decodedPassword = retrieveDecodedPassword(Pay_Ke.toString());
    String basicAuth = generateBasicAuth(decodedPassword);
    /////////--------->
    DateTime datexnow = DateTime.now();
    final moonLanding = DateTime.utc(datexnow.year, datexnow.month,
        datexnow.day, datexnow.hour, datexnow.minute + 10, 00);
    final isoDate2 = moonLanding.toIso8601String();

    String Area_selecte =
        '${selected_Area.map((data) => data.type.toString()).join(',')}';
    String datex_book = SDatex_total1_.toString().trim();
    /////////-------------->
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '$basicAuth'
    };
    var request = https_Request();
    /////////------------->
    request.body = json.encode({
      "channel": "qrThb",
      "expiry": "$isoDate2",

      ///"2024-04-06T15:00:00Z",
      "order": {
        "currencyCode": "THB",
        "description": (Date_list_selected.length == 0)
            ? '-'
            : (Date_list_selected.length == 1)
                ? 'คุณ :$name_book จองพื้นที่ x${selected_Area.length} ,${Date_list_selected.map((model) => '${DateFormat('dd-MM').format(DateTime.parse('${model} 00:00:00'))}-${DateTime.parse('${model} 00:00:00').year + 543}').join('')}'
                : 'คุณ :$name_book จองพื้นที่ x${selected_Area.length} ,${Date_list_selected.map((model) => '${DateFormat('dd-MM').format(DateTime.parse('${model} 00:00:00'))}-${DateTime.parse('${model} 00:00:00').year + 543}').join(', ')}',
        // "[${renTal_user}]:$renTal_name, คุณ :$name_book จองพื้นที่ ${Area_selecte} ,วันที่จอง : ${datex_book}",
        "merchantReference": "คุณ:$name_book,ระบบหลักแอดมิน(W)",
        "merchantReferenceId": "$cFinn",
        "netAmount": double.parse(PriArea.toString()),
        "orderItems": [
          for (int index = 0; index < selected_Area.length; index++)
            {
              "product": {
                "description": "พื้นที่ : ${selected_Area[index].type}",
                "imageUrl":
                    "https://www.shutterstock.com/image-vector/map-icon-red-marker-pin-260nw-1962656155.jpg",
                "name": "${selected_Area[index].type}",
                "price": double.parse(selected_Area[index].rent.toString()),
                "sku": "string"
              },
              "quantity": 1 * Date_list_selected.length,
            },
          for (int index2 = 0; index2 < expModels.length; index2++)
            {
              "product": {
                "description":
                    "(${expModels[index2].expname}*${selected_Area.length}พื้นที่)",
                "imageUrl":
                    "https://cdn-icons-png.freepik.com/512/9727/9727444.png",
                "name": "${expModels[index2].expname}",
                "price": double.parse('${expModels[index2].pri_book}') *
                    selected_Area.length,
                "sku": "string"
              },
              "quantity": 1 * Date_list_selected.length,
            },
        ],
        "totalAmount": double.parse(PriArea.toString()),
        "totalDiscount": 0
      },
      "redirectUrl": "",
      "requiredFieldsFormId": "",
      "supportedPaymentMethods": ["qrThb", "eWallet", "creditCard"]
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      String jsonString = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(jsonString);
      String purchaseId = data['purchaseId'];
      String paymentLink = data['paymentLink'];

      // print('Purchase ID: $purchaseId');
      // print('Payment Link: $paymentLink'); ////UP_PurchaseID_Beamcheck
      if (purchaseId == null ||
          paymentLink == null ||
          purchaseId.toString() == '' ||
          paymentLink.toString() == '' ||
          cFinn == null ||
          cFinn.toString() == '') {
      } else {
        Beamcheckout_Dialog(cFinn, purchaseId, paymentLink);
      }
    } else {
      // print(response.reasonPhrase);
    }

    setState(() {
      read_GC_area();
    });
  }

  int cahek = 0;
  late Timer _timer;

  void startUpdates(cFinn, purchaseId) {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (cahek == 1) {
        _timer.cancel(); // Stop the timer if cahek is 1
        return;
      }

      await read_Recheck_beamcheckout(cFinn, purchaseId);
      // print('read_Recheck_beamcheckout ');
    });
  }

  Future<Null> read_Recheck_beamcheckout(cFinn, purchaseId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    /////////------------------------------------------------>
    String decodedPassword = retrieveDecodedPassword(Pay_Ke.toString());
    String basicAuth = generateBasicAuth(decodedPassword);
    /////////------------------------------------------------>
    var headers = {'Authorization': '$basicAuth'};
    var request = https_Request_check(purchaseId);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    /////////------------------------------------------------>
    if (response.statusCode == 200) {
      String jsonString = await response.stream.bytesToString();
      Map<String, dynamic> jsonData = json.decode(jsonString);
      var DateTimePay = jsonData['timePaid'].toString().trim();
      var urlIdpaycomplete = jsonData['paymentLink'].toString().trim();

      //print('State: ${jsonData['state']}');
      if (jsonData['state'].toString().trim() == 'complete') {
        setState(() {
          cahek = 1;
        });
        Future.delayed(Duration(milliseconds: 200), () async {
          Beamcheckout_Complete(
                  context,
                  '$ren',
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  cFinn,
                  purchaseId,
                  DateTimePay,
                  urlIdpaycomplete)
              .then((value) => {
                    if (value == 'true')
                      {
                        setState(() {
                          base64_Slip = null;
                        }),

                        read_GC_rental(),
                        read_GC_zone(),
                        // read_GC_area();
                        read_GC_rental_data_All(),
                        read_GC_Exp(),
                        red_payMent(),
                        ManPay_ReceiptMarket_PDF.ManPayReceiptMarket_PDF(
                          context,
                          ren,
                          foder,
                          cFinn,
                          bill_addr,
                          bill_email,
                          bill_tel,
                          bill_tax,
                          bill_name,
                        ),
                      }
                    else
                      {
                        setState(() {
                          base64_Slip = null;
                        }),

                        read_GC_rental(),
                        read_GC_zone(),
                        // read_GC_area();
                        read_GC_rental_data_All(),
                        read_GC_Exp(),
                        red_payMent(),
                      }
                  });
        });
      } else {}
      // print(await response.stream.bytesToString());
    } else {
      // print(response.reasonPhrase);
    }
  }

///////----------------------------------------------------------->(Stap-2)
  Future<Null> Beamcheckout_Dialog(cFinn, purchaseId, paymentLink) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ren = '${widget.Ser_}';
    var cFinnc_s = cFinn;
    var purchaseId_s = purchaseId;
    var paymentLink_s = paymentLink;
    String url =
        await '${MyConstant().domain}/UP_PurchaseID_Beamcheck.php?isAdd=true&serren=$ren&iddocno=$cFinnc_s&beamid=$purchaseId_s&url_s=$paymentLink_s';
    if (purchaseId != null && cFinn != null) {
      Future.delayed(Duration(microseconds: 2), () {
        // read_Recheck_beamcheckout('$purchaseId');
        startUpdates(cFinn, '$purchaseId');
      });

      try {
        var response = await http.get(Uri.parse(url));

        var result = await json.decode(response.body);

        if (result.toString() == 'true') {
          await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                insetPadding: EdgeInsets.all(5),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 0)),
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Chaoperty X Beam Checkout - Payment System",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                          if (cahek != 1)
                            InkWell(
                              onTap: () async {
                                Dia_log(200);
                                // Navigator.pop(context);
                                // Dialog_cancellock(purchaseId_s);

                                Beam_purchase_disabled(
                                        purchaseId, Pay_Ke, ren, cFinnc_s, '')
                                    .then((value) => {
                                          Navigator.pop(context),
                                          Future.delayed(
                                              Duration(milliseconds: 600),
                                              () async {
                                            Dialog_cancellock();
                                          }),
                                        });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 30,
                              ),
                            )
                        ],
                      );
                    }),
                content: StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 0)),
                    builder: (context, snapshot) {
                      return SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Container(
                              // height: 600,
                              width: MediaQuery.of(context).size.width,
                              child:
                                  WebViewX2Pagebeamcheck(id_ser: paymentLink_s),
                            ),
                          ],
                        ),
                      );
                    }),
              );
            },
          );
        } else {}
      } catch (e) {
        //print(e);
      }
    }
  }

  Dialog_Datelock() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: 'วันที่เลือก ไม่เปิดให้จอง...!! (วันหยุดพิเศษ/วันนักขัตฤกษ์)',
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_areak();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_DateMax() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: 'เลือกจองได้สูงสุด 16 วัน ...!!!!',
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        // read_GC_areak();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_cancellock() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ยกเลิกการจองพื้นที่ เสร็จสิ้น ...!!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        read_GC_area();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  /////////////------------------------------------------------------>
  Dia_Qr(total) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          // Timer(Duration(milliseconds: milli_seconds), () {
          //   Navigator.of(context).pop();
          // });
          return AlertDialog(
            // backgroundColor: Colors.grey[100],
            insetPadding: EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 30,
                  ),
                )
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    // color:
                    //     Colors.red, 1639900314983 // 0612949719
                    child: WebViewX2Page(
                        id_ser: selectedValue,
                        amt_ser: total,
                        name_ser: '${bname1}'),
                  ),
                ],
              ),
            ),
          );
        });
  }

/////////////------------------------------------------------------>
  Dia_PayQR(cFinn, vts) {
    var total = (selected_Area.length == 0)
        ? 0.00
        : ((Date_list_selected.length) *
            (double.parse((selected_Area
                    .fold(
                        0.0,
                        (previousValue, element) =>
                            previousValue +
                            ((element.rent != null)
                                ? double.parse(element.rent!)
                                : 0))
                    .toString())) +
                (selected_Area.length *
                    double.parse((expModels
                        .fold(
                            0.0,
                            (previousValue, element) =>
                                previousValue +
                                ((element.pri_book != null)
                                    ? double.parse(element.pri_book!)
                                    : 0))
                        .toString())))));
    //

    return Container(
      height: MediaQuery.of(context).size.width * 0.25,
      child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.start,
          child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'วิธีการชำระเงิน',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Font_.Fonts_T,
                              fontSize: 14),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 28, 43, 133),
                                      width: 2.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Color.fromARGB(255, 28, 43, 133),
                                    ),
                                    Expanded(
                                        child: AutoSizeText(
                                      minFontSize: 9,
                                      maxFontSize: 14,
                                      '$paymentName1',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // _PayMentModels
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (_) {
                                            // Timer(Duration(milliseconds: milli_seconds), () {
                                            //   Navigator.of(context).pop();
                                            // });
                                            return AlertDialog(
                                              // backgroundColor: Colors.grey[100],
                                              insetPadding: EdgeInsets.all(0),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0))),
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'เลือกช่องทางการชำระ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                      size: 30,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    for (int index = 0;
                                                        index <
                                                            _PayMentModels
                                                                .length;
                                                        index++)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              topRight: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            border: Border.all(
                                                                color: _PayMentModels[
                                                                                index]
                                                                            .ser ==
                                                                        paymentSer1
                                                                    ? Colors
                                                                        .orange
                                                                        .shade900
                                                                    : Color
                                                                        .fromARGB(
                                                                            255,
                                                                            28,
                                                                            43,
                                                                            133),
                                                                width: 2.0),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 2,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                    0,
                                                                    3), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              // print(
                                                              //     _PayMentModels[
                                                              //             index]
                                                              //         .ser);
                                                              setState(() {
                                                                Pay_Ke = _PayMentModels[
                                                                        index]
                                                                    .key_b
                                                                    .toString();
                                                                paymentSer1 =
                                                                    _PayMentModels[
                                                                            index]
                                                                        .ser
                                                                        .toString();
                                                                paymentName1 =
                                                                    _PayMentModels[
                                                                            index]
                                                                        .ptname
                                                                        .toString();
                                                                selectedValue =
                                                                    _PayMentModels[
                                                                            index]
                                                                        .bno
                                                                        .toString();
                                                                payment_Ptser =
                                                                    _PayMentModels[
                                                                            index]
                                                                        .ptser
                                                                        .toString();
                                                                bname1 = _PayMentModels[
                                                                        index]
                                                                    .bname
                                                                    .toString();
                                                                paymentBank =
                                                                    _PayMentModels[
                                                                            index]
                                                                        .bank
                                                                        .toString();
                                                                // Form_payment1.text =
                                                                //     (sum_amt - sum_disamt).toStringAsFixed(2).toString();
                                                                // }
                                                                newValuePDFimg_QR = (_PayMentModels[index].img ==
                                                                            null ||
                                                                        _PayMentModels[index].img.toString() ==
                                                                            '')
                                                                    ? '${MyConstant().domain}/Awaitdownload/imagenot.png'
                                                                    : '${MyConstant().domain}/files/$foder/payment/${_PayMentModels[index].img}';
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .account_balance,
                                                                  color: _PayMentModels[index]
                                                                              .ser ==
                                                                          paymentSer1
                                                                      ? Colors
                                                                          .orange
                                                                          .shade900
                                                                      : Color.fromARGB(
                                                                          255,
                                                                          28,
                                                                          43,
                                                                          133),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '${_PayMentModels[index].ptname}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '${_PayMentModels[index].bno}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _PayMentModels[index]
                                                                            .ser ==
                                                                        paymentSer1
                                                                    ? Icon(
                                                                        Icons
                                                                            .check_box,
                                                                        color: Colors
                                                                            .orange
                                                                            .shade900,
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .check_box_outline_blank,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            28,
                                                                            43,
                                                                            133),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 28, 43, 133),
                                              width: 2.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            // Icon(
                                            //   Icons.qr_code,
                                            //   color: Color.fromARGB(
                                            //       255, 28, 43, 133),
                                            // ),
                                            Expanded(
                                              child: Text(
                                                '${paymentName1}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.check_box,
                                              color: Color.fromARGB(
                                                  255, 28, 43, 133),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    payment_Ptser == '2' || payment_Ptser == '5'
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(children: [
                                        (newValuePDFimg_QR == null &&
                                                newValuePDFimg_QR.toString() ==
                                                    '')
                                            ? GestureDetector(
                                                onTap: () {
                                                  Dia_Qr_Online_Payment(total);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: ScrollConfiguration(
                                                    behavior:
                                                        ScrollConfiguration.of(
                                                                context)
                                                            .copyWith(
                                                                dragDevices: {
                                                          PointerDeviceKind
                                                              .touch,
                                                          PointerDeviceKind
                                                              .mouse,
                                                        }),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          WebViewX2Page(
                                                              id_ser:
                                                                  selectedValue,
                                                              amt_ser: total,
                                                              name_ser:
                                                                  '${bname1}')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Image.network(
                                                '$newValuePDFimg_QR',
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                              )
                                      ]))),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      // crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (payment_Ptser.toString() == '2')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ธนาคาร : $paymentBank',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (payment_Ptser.toString() == '2')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'บัญชี : $selectedValue',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (payment_Ptser.toString() == '2')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'จำนวนเงิน : ${nFormat.format(total)} ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 1)),
                                            builder: (context, snapshot) {
                                              return Container(
                                                width: 130,
                                                height: 130,
                                                decoration: (base64_Slip
                                                                .toString() ==
                                                            '' ||
                                                        base64_Slip == null)
                                                    ? BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                      )
                                                    : BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  8),
                                                          topRight:
                                                              Radius.circular(
                                                                  8),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  8),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  8),
                                                        ),
                                                        image: DecorationImage(
                                                            // fit: BoxFit.cover,
                                                            image: MemoryImage(
                                                          base64Decode(
                                                              base64_Slip
                                                                  .toString()),
                                                        ))),
                                                child: IconButton(
                                                    onPressed: () async {
                                                      uploadFile_Slip();
                                                    },
                                                    icon: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.upload_file,
                                                          color: Colors.red,
                                                        ),
                                                        Text(
                                                          ' กดเพื่อแนบสลิป',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    )),
                                              );
                                            }),
                                        Text(
                                          ' หลักฐาน/สลิป',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          // width: 35,
                                                          height: 35,
                                                          // decoration: const BoxDecoration(
                                                          //   color: AppbackgroundColor
                                                          //       .Abg_Sub_Main,
                                                          //   borderRadius: BorderRadius.only(
                                                          //     topLeft: Radius.circular(6),
                                                          //     topRight: Radius.circular(6),
                                                          //     bottomLeft:
                                                          //         Radius.circular(0),
                                                          //     bottomRight:
                                                          //         Radius.circular(0),
                                                          //   ),
                                                          //   // border: Border.all(color: Colors.grey, width: 1),
                                                          // ),

                                                          child: TextFormField(
                                                            controller:
                                                                TextForm_time_hr, //editing controller of this TextField

                                                            readOnly:
                                                                false, //set it true, so that user will not able to edit text
                                                            onChanged: (value) {
                                                              //print(value);
                                                              if (value
                                                                      .toString()
                                                                      .length >=
                                                                  2) {
                                                                setState(() {
                                                                  TextForm_time_hr
                                                                          .text =
                                                                      value.substring(
                                                                          0, 2);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  TextForm_time_hr
                                                                          .text =
                                                                      value;
                                                                });
                                                              }
                                                            },
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
                                                                    // prefixIcon:
                                                                    //     const Icon(Icons.person, color: Colors.black),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
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
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    )),
                                                            inputFormatters: <TextInputFormatter>[
                                                              // for below version 2 use this
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'[0-9]')),
                                                              // for version 2 and greater youcan also use this
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                          )),
                                                    ),
                                                    Text(
                                                      ' : ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          // width: 35,
                                                          height: 35,
                                                          // decoration: const BoxDecoration(
                                                          //   color: AppbackgroundColor
                                                          //       .Abg_Sub_Main,
                                                          //   borderRadius: BorderRadius.only(
                                                          //     topLeft: Radius.circular(6),
                                                          //     topRight: Radius.circular(6),
                                                          //     bottomLeft:
                                                          //         Radius.circular(0),
                                                          //     bottomRight:
                                                          //         Radius.circular(0),
                                                          //   ),
                                                          //   // border: Border.all(color: Colors.grey, width: 1),
                                                          // ),
                                                          // padding:
                                                          //     const EdgeInsets.all(4.0),
                                                          child: TextField(
                                                            controller:
                                                                TextForm_time_min, //editing controller of this TextField

                                                            readOnly:
                                                                false, //set it true, so that user will not able to edit text

                                                            onChanged: (value) {
                                                              if (value
                                                                      .toString()
                                                                      .length >=
                                                                  2) {
                                                                setState(() {
                                                                  TextForm_time_min
                                                                          .text =
                                                                      value.substring(
                                                                          0, 2);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  TextForm_time_min
                                                                          .text =
                                                                      value;
                                                                });
                                                              }
                                                            },
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
                                                                    // prefixIcon:
                                                                    //     const Icon(Icons.person, color: Colors.black),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
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
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    )),
                                                            inputFormatters: <TextInputFormatter>[
                                                              // for below version 2 use this
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'[0-9]')),
                                                              // for version 2 and greater youcan also use this
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                          )),
                                                    ),
                                                    Text(
                                                      ' : ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          // width: 35,
                                                          height: 35,
                                                          // decoration: const BoxDecoration(
                                                          //   color: AppbackgroundColor
                                                          //       .Abg_Sub_Main,
                                                          //   borderRadius: BorderRadius.only(
                                                          //     topLeft: Radius.circular(6),
                                                          //     topRight: Radius.circular(6),
                                                          //     bottomLeft:
                                                          //         Radius.circular(0),
                                                          //     bottomRight:
                                                          //         Radius.circular(0),
                                                          //   ),
                                                          //   // border: Border.all(color: Colors.grey, width: 1),
                                                          // ),
                                                          // padding:
                                                          //     const EdgeInsets.all(4.0),
                                                          child: TextField(
                                                            controller:
                                                                TextForm_time_sec, //editing controller of this TextField

                                                            readOnly:
                                                                false, //set it true, so that user will not able to edit text
                                                            onChanged: (value) {
                                                              if (value
                                                                      .toString()
                                                                      .length >=
                                                                  2) {
                                                                setState(() {
                                                                  TextForm_time_sec
                                                                          .text =
                                                                      value.substring(
                                                                          0, 2);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  TextForm_time_sec
                                                                          .text =
                                                                      value;
                                                                });
                                                              }
                                                            },
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
                                                                    // prefixIcon:
                                                                    //     const Icon(Icons.person, color: Colors.black),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
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
                                                                      // borderRadius:
                                                                      //     BorderRadius.only(
                                                                      //   topLeft:
                                                                      //       Radius.circular(8),
                                                                      //   topRight:
                                                                      //       Radius.circular(8),
                                                                      //   bottomLeft:
                                                                      //       Radius.circular(8),
                                                                      //   bottomRight:
                                                                      //       Radius.circular(8),
                                                                      // ),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    )),
                                                            inputFormatters: <TextInputFormatter>[
                                                              // for below version 2 use this
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'[0-9]')),
                                                              // for version 2 and greater youcan also use this
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Text(
                                                    ' เวลา/หลักฐาน',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    )),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                  ],
                );
              })),
    );
  }

  Dia_Qr_Online_Payment(total) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          // Timer(Duration(milliseconds: milli_seconds), () {
          //   Navigator.of(context).pop();
          // });
          return AlertDialog(
            // backgroundColor: Colors.grey[100],
            insetPadding: EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 30,
                  ),
                )
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    // color:
                    //     Colors.red, 1639900314983 // 0612949719
                    child: WebViewX2Page(
                        id_ser: selectedValue,
                        amt_ser: total,
                        name_ser: '${bname1}'),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

///1639900314983 /// 0612949719
class NodeData2 {
  String? ser;
  String? user;
  String? datex;
  String? timex;
  String? zser;
  String? aser;
  String? lncode;
  String? ln;
  String? offset;
  String? size;
  String? color;
  String? st;
  String? dx;
  String? dy;
  String? width;
  String? height;
  String? type;
  String? rent;
  String? data_update;
  String? custno;
  String? dtype;
  String? date;
  String? total;
  String? refno;

  String? no;
  String? sname;
  String? zn;

  String? ln_c;
  String? in_docno;
  String? docno;
  String? ser_docno;
  String? quantity;
  String? id;
  String? path;

  String? name;
  String? ser_area;
  String? cid;
  String? ldate;
  String? cc_date;
  String? stype;
  String? cidx;
  String? con_book;

  NodeData2({
    this.ser,
    this.user,
    this.datex,
    this.timex,
    this.zser,
    this.aser,
    this.lncode,
    this.ln,
    this.offset,
    this.size,
    this.color,
    this.st,
    this.dx,
    this.dy,
    this.width,
    this.height,
    this.type,
    this.rent,
    this.data_update,
    this.custno,
    this.dtype,
    this.date,
    this.total,
    this.refno,
    this.no,
    this.sname,
    this.zn,
    this.ln_c,
    this.in_docno,
    this.docno,
    this.ser_docno,
    this.quantity,
    this.id,
    this.path,
    this.name,
    this.ser_area,
    this.cid,
    this.ldate,
    this.cc_date,
    this.stype,
    this.cidx,
    this.con_book,
  });

  NodeData2.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    user = json['user'];
    datex = json['datex'];
    timex = json['timex'];
    zser = json['zser'];
    aser = json['aser'];
    lncode = json['lncode'];
    ln = json['ln'];
    offset = json['offset'];
    size = json['size'];
    color = json['color'];
    st = json['st'];
    dx = json['dx'];
    dy = json['dy'];
    width = json['width'];
    height = json['height'];
    type = json['type'];
    rent = json['rent'];
    data_update = json['data_update'];

    custno = json['custno'];
    dtype = json['dtype'];
    date = json['date'];
    total = json['total'];
    refno = json['refno'];

    no = json['no'];
    sname = json['sname'];
    zn = json['zn'];

    ln_c = json['ln_c'];
    in_docno = json['in_docno'];
    docno = json['docno'];
    ser_docno = json['ser_docno'];
    quantity = json['quantity'];
    id = json['id'];
    path = json['path'];

    name = json['name'];
    ser_area = json['ser_area'];
    cid = json['cid'];
    ldate = json['ldate'];
    cc_date = json['cc_date'];
    stype = json['stype'];
    cidx = json['cidx'];
    con_book = json['con_book'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['user'] = this.user;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['zser'] = this.zser;
    data['aser'] = this.aser;
    data['lncode'] = this.lncode;
    data['ln'] = this.ln;
    data['offset'] = this.offset;
    data['size'] = this.size;
    data['color'] = this.color;
    data['st'] = this.st;
    data['dx'] = this.dx;
    data['dy'] = this.dy;
    data['width'] = this.width;
    data['height'] = this.height;
    data['type'] = this.type;
    data['rent'] = this.rent;

    data['data_update'] = this.data_update;
    data['custno'] = this.custno;
    data['dtype'] = this.dtype;
    data['date'] = this.date;
    data['total'] = this.total;
    data['refno'] = this.refno;

    data['no'] = this.no;
    data['sname'] = this.sname;
    data['zn'] = this.zn;

    data['ln_c'] = this.ln_c;
    data['in_docno'] = this.in_docno;
    data['docno'] = this.docno;
    data['ser_docno'] = this.ser_docno;
    data['quantity'] = this.quantity;
    data['id'] = this.id;
    data['path'] = this.path;

    data['name'] = this.name;
    data['ser_area'] = this.ser_area;
    data['cid'] = this.cid;
    data['ldate'] = this.ldate;
    data['cc_date'] = this.cc_date;
    data['stype'] = this.stype;
    data['cidx'] = this.cidx;
    data['con_book'] = this.con_book;
    return data;
  }
}
