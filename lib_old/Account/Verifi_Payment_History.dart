import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:simple_barcode_scanner/screens/io_device.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Beam/Beam_apiPassw.dart';
import '../Beam/Beam_api_disabled.dart';
import '../Beam/webviewPay_beamcheckout.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../Man_PDF/Man_Receipt_Market_PDF.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/Get_ExcReceivable_Model.dart';
import '../Model/Get_easyslip_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Model/trans_re_chack_bill_model.dart';
import '../PDF_Market/pdf_hisbill_Market.dart';
import '../PeopleChao/UP_Slip_Again.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/downloadImage.dart';
import 'Ac_List/Ac_List_Title.dart';
import 'Ac_Sub/Account_BillPayVerifi.dart';
import 'Verifi_Exc_pay.dart';

class Verifi_Payment_History extends StatefulWidget {
  final Texts;
  const Verifi_Payment_History({super.key, this.Texts});

  @override
  State<Verifi_Payment_History> createState() => _Verifi_Payment_HistoryState();
}

class _Verifi_Payment_HistoryState extends State<Verifi_Payment_History> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  TextEditingController Text_searchBar_main1 = TextEditingController();
  TextEditingController Text_searchBar_main2 = TextEditingController();
  //-------------------------------------->
  TextEditingController Text_searchBar1 = TextEditingController();
  TextEditingController Text_searchBar2 = TextEditingController();
  //-------------------------------------->
  DateTime datex = DateTime.now();
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  List<BankExcBilling_Model> limitedList_bankExcBilling = [];

  List<TransReBillModel> limitedList_TransReBillModels_ = [];
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<TransReBillModel> _TransReBillModels = [];
  List<TransReBillModel> TransReBillModels_ = <TransReBillModel>[];
  List<TransReBillModel> _TransReBillModelsTest = [];
  List<easyslipModel> easyslipModels_ = [];
  String tappedIndex_ = '';
  ScrollController _scrollController2 = ScrollController();
  List<TransModel> _TransModels = [];
  List<RenTalModel> renTalModels = [];
  List<BankExcBilling_Model> bankExcBilling = [];
  List<TransReChackBillModel> transReChackBillModels = [];
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  int Ser_Tap = 0, _ChacpExcel = 0;
  String? ser_payby;
  String? cid_Name, name_Name;
  String? base64_Slip, fileName_Slip, Slip_history;
  String? ref_1, ref_2, ref_3;
  final Formbecause_ = TextEditingController();
  String? renTal_user,
      renTal_Ser,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      fname_,
      pdate;
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
  int limit_excel = 200;
  int offset_excel = 0;
  int endIndex_excel = 0;
  int renTal_lavel = 0;
  String? numinvoice,
      paymentSer1,
      paymentName1,
      paymentSer2,
      paymentName2,
      cFinn,
      Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';
  String? Slip_status, resultqr;
  final sum_disamtx = TextEditingController();
  final sum_dispx = TextEditingController();
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  final Form_time = TextEditingController();
  final Form_note = TextEditingController();
  final Pincontroller = TextEditingController();
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
      api_key,
      time_check,
      Auto_cancel;
  int Count_time_check = 0;
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

  ///------------------------>
  List<String> YE_Th = [];
  late Timer _timer;
  String? MONTH_Now, YEAR_Now, Pay_Ke;
  String? indexTest;
  int? index_Test;
  ///////////--------------------------------------------->
  List<String> TransReBill_select = [];
  List<String> transReBill_loade_Success = [];
  ///////////--------------------------------------------->
  List<String> transReBill_select_delete = [];
  List<String> transReBill_loade_Success_delete = [];
  List<Map<String, String>> ac5 = [];
////////////----------------------------------->
  String? email_login;
  String? seremail_login;

  String randomString = '';
////////////----------------------------------->
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
      ac5.addAll(
          AcListTitle().ac_5); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_ac5(String ser) {
    if (ac5
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  ////////////----------------------------------->

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

  Future<Null> checkPreferance() async {
    int currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 10; i--) {
      YE_Th.add(i.toString());
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (MONTH_Now == null || YEAR_Now == null) {
        MONTH_Now = DateFormat('MM').format(DateTime.parse('${datex}'));
        YEAR_Now = DateFormat('yyyy').format(DateTime.parse('${datex}'));
      }
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      Auto_cancel = preferences.getString('Auto_cancel');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
      fname_ = preferences.getString('fname');
      email_login = preferences.getString('email');
      seremail_login = preferences.getString('ser');
    });
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
          red_Trans_bill();
          read_GC_rental();
        } else {
          read_CheckBeamAll_true(ren, Pay_Ke, context);
        }
        // RecheckAuto(ren, Pay_Ke);
      }
    } catch (e) {}
  }

  Future<void> read_CheckBeamAll_true(Ser_, Pay_Ke, context) async {
    var ren = Ser_;

    try {
      /////////------------------------------------------------>
      String decodedPassword = retrieveDecodedPassword(Pay_Ke.toString());
      String basicAuth = generateBasicAuth(decodedPassword);
      // print(basicAuth);
      /////////------------------------------------------------>

      String url =
          '${MyConstant().domain}/UP_Beam_CompleteAll.php?isAdd=true&serren=$ren';
      var response = await http.post(
        Uri.parse(url),
        body: {'Basic_pass': basicAuth.toString()},
      );

      if (response.statusCode == 200) {
        // Request was successful
        // print('Response: successful');
        return PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "ตรวจเช็คการรับชำระ เสร็จสิ้น ...!!",
          buttonText: "รับทราบ",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            red_Trans_bill();
            read_GC_rental();
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.success,
          barrierDismissible: false, // optional parameter (default is true)
        );
        // print('Response: ${response.body}');
      } else {
        // print('Response: failed');
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "ตรวจเช็คการรับชำระ ล้มเหลว ...!!",
          buttonText: "ลองอีกครั้งภายหลัง",
          onTapDismiss: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            red_Trans_bill();
            read_GC_rental();
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false, // optional parameter (default is true)
        );
        // Request failed
        // print('Failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // print('Response: error');
      PanaraInfoDialog.showAnimatedGrow(
        context,
        title: "Oops",
        message: "ตรวจเช็คการรับชำระ ล้มเหลว ...!!",
        buttonText: "ลองอีกครั้งภายหลัง",
        onTapDismiss: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          Navigator.pop(context);
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false, // optional parameter (default is true)
      );
      // Error occurred during the request
      // print('Error: $error');
    }
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
    // print('name>>>>>  $renname');
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  Future<Null> red_Trans_bill() async {
    if (limitedList_TransReBillModels_.length != 0) {
      setState(() {
        _TransReBillModels.clear();
        limitedList_TransReBillModels_.clear();
      });
    }

    var sertype = (ser_payby == '0' || ser_payby == null)
        ? '0'
        : (ser_payby == '1')
            ? 'W'
            : (ser_payby == '2')
                ? 'U'
                : (ser_payby == '3')
                    ? 'LP'
                    : (ser_payby == '4')
                        ? 'H'
                        : '0';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype';
    try {
      var response = await http.get(Uri.parse(url));
      //print('GC_bill_pay_BC_Verifi $url');
      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            limitedList_TransReBillModels_.add(transReBillModel);
          });
        }
        setState(() {
          TransReBillModels_ = limitedList_TransReBillModels_;
        });
        // print('result ${_TransReBillModels.length}');
      }
      read_TransReBill_limit();
    } catch (e) {}
  }

  Future<Null> read_TransReBill_limit() async {
    setState(() {
      endIndex = offset + limit;
      _TransReBillModels = limitedList_TransReBillModels_.sublist(
          offset, // Start index
          (endIndex <= limitedList_TransReBillModels_.length)
              ? endIndex
              : limitedList_TransReBillModels_.length // End index
          );
    });
  }

  Future<Null> red_Chack_Trans_bill() async {
    if (transReChackBillModels.length != 0) {
      setState(() {
        transReChackBillModels.clear();
      });
    }

    var sertype = (ser_payby == '0' || ser_payby == null)
        ? '0'
        : (ser_payby == '1')
            ? 'W'
            : (ser_payby == '2')
                ? 'U'
                : (ser_payby == '3')
                    ? 'LP'
                    : (ser_payby == '4')
                        ? 'H'
                        : '0';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_chack.php?isAdd=true&ren=$ren&user=$user&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype';
    // print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReChackBillModel transReChackBillModel =
              TransReChackBillModel.fromJson(map);
          setState(() {
            transReChackBillModels.add(transReChackBillModel);
          });
        }
      }
      // print('result ${transReChackBillModels.map((e) => e)}');
    } catch (e) {}
  }

  Future<Null> red_Chack_Trans_bill_excel() async {
    if (transReChackBillModels.length != 0) {
      setState(() {
        transReChackBillModels.clear();
      });
    }

    var sertype = (ser_payby == '0' || ser_payby == null)
        ? '0'
        : (ser_payby == '1')
            ? 'W'
            : (ser_payby == '2')
                ? 'U'
                : (ser_payby == '3')
                    ? 'LP'
                    : (ser_payby == '4')
                        ? 'H'
                        : '0';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/GC_bill_pay_BC_Verifi_chack_excel.php?isAdd=true&ren=$ren&user=$user&excel_list=${limitedList_bankExcBilling.toList()}';
    // print('result $url $limitedList_bankExcBilling');
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'mont_h': MONTH_Now.toString(),
          'yea_r': YEAR_Now.toString(),
          'serpang': sertype.toString(),
          'excel_list': limitedList_bankExcBilling.toList(),
        },
      ).then((response) {
        var result = json.decode(response.body);
        // print('result $result');
        if (result.toString() != 'null') {
          for (var map in result) {
            TransReChackBillModel transReChackBillModel =
                TransReChackBillModel.fromJson(map);
            setState(() {
              transReChackBillModels.add(transReChackBillModel);
            });
          }
        }
        // print('result ${transReChackBillModels.map((e) => e)}');
      }).catchError((e) {
        // Dialog_error();
        // print(' N random2 : ${formattedMilliseconds2}');
      });
    } catch (e) {}
  }

  ////////--------------------------------------------------------------->
  _searchBarMain1() {
    return TextField(
      textAlign: TextAlign.start,
      controller: Text_searchBar_main1,
      autofocus: false,
      cursorHeight: 20,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100]!.withOpacity(0.5),
        hintText: ' Search...',
        hintStyle: const TextStyle(
            // fontSize: 12,
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontFamily: Font_.Fonts_T),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        // var Text_searchBar2_ = Text_searchBar_main1.text.toLowerCase();

        setState(() {
          _TransReBillModels = TransReBillModels_.where((transReBill) {
            var notTitle = transReBill.cid.toString();
            var notTitle2 = transReBill.docno.toString();
            var notTitle3 = transReBill.ln.toString();
            var notTitle4 = transReBill.room_number.toString();
            var notTitle5 = transReBill.sname.toString();
            var notTitle6 = transReBill.cname.toString();
            // var notTitle7 = transReBill.expname.toString();
            var notTitle8 = transReBill.date.toString();
            // var notTitle9 = transReBill.remark.toString();

            return notTitle.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text) ||
                notTitle5.contains(text) ||
                notTitle6.contains(text) ||
                // notTitle7.contains(text) ||
                notTitle8.contains(text);
            // ||
            // notTitle9.contains(text);
          }).toList();
        });
        if (text.isEmpty) {
          read_TransReBill_limit();
        } else {}
      },
    );
  }

//////////////----------------------------->
  Future<Null> red_Trans_select(index) async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var ren = preferences.getString('renTalSer');
    // var user = preferences.getString('ser');
    // var ciddoc = _TransReBillModels[index].ser;
    // var qutser = _TransReBillModels[index].ser_in;
    // var docnoin = _TransReBillModels[index].docno;
    // String url =
    //     '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _TransReBillModels[index].cid;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno;
    String url =
        '${MyConstant().domain}/GC_bill_payVerifi_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // print('GC_bill_payVerifi_history>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);

          var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          // var sumPvatx = double.parse(_TransReBillHistoryModel.dis!) != 0
          //     ? double.parse(_TransReBillHistoryModel.pvat!) -
          //         double.parse(_TransReBillHistoryModel.dis!)
          //     : double.parse(_TransReBillHistoryModel.pvat!);

          var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          var sumAmtx = double.parse(_TransReBillHistoryModel.total!);
          //  var sumAmtx = double.parse(_TransReBillHistoryModel.dis!) != 0
          //         ? double.parse(_TransReBillHistoryModel.pvat!) +
          //             double.parse(_TransReBillHistoryModel.vat!) -
          //             double.parse(_TransReBillHistoryModel.wht!) -
          //             double.parse(_TransReBillHistoryModel.disendbill!)
          //         : double.parse(_TransReBillHistoryModel.total!)
          //     ;
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var numinvoiceent = _TransReBillHistoryModel.docno;
          setState(() {
            sum_pvat = sum_pvat + sumPvatx;
            sum_vat = sum_vat + sumVatx;
            sum_wht = sum_wht + sumWhtx;
            sum_amt = sum_amt + sumAmtx;
            // sum_disamt = sum_disamtx;
            // sum_disp = sum_dispx;
            numinvoice = _TransReBillHistoryModel.docno;
            _TransReBillHistoryModels.add(_TransReBillHistoryModel);
          });
        }
      }
      // setState(() {
      //   red_Invoice(index);
      // });
    } catch (e) {}
  }

  Future<Null> red_Trans_select2() async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = cid_Name;
    var qutser = name_Name;

    String url =
        '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);

          var sumPvatx = double.parse(_TransModel.pvat!);
          var sumVatx = double.parse(_TransModel.vat!);
          var sumWhtx = double.parse(_TransModel.wht!);
          var sumAmtx = double.parse(_TransModel.total!);
          setState(() {
            sum_pvat = sum_pvat + sumPvatx;
            sum_vat = sum_vat + sumVatx;
            sum_wht = sum_wht + sumWhtx;
            sum_amt = sum_amt + sumAmtx;
            _TransModels.add(_TransModel);
          });
        }
      }

      // setState(() {
      //   Form_payment1.text =
      //       (sum_amt - sum_disamt).toStringAsFixed(2).toString();
      // });
    } catch (e) {}
  }

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno; //.toString().trim()
    // print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            Slip_history = finnancetransModel.slip.toString();
            ref_1 = finnancetransModel.ref1.toString();
            ref_2 = finnancetransModel.ref2.toString();
            ref_3 = finnancetransModel.ref3.toString();

            if (int.parse(finnancetransModel.receiptSer!) != 0) {
              finnancetransModels.add(finnancetransModel);
              pdate = pdatex;
            } else {
              if (finnancetransModel.type!.trim() == 'DISCOUNT') {
                sum_disamt = sidamt;
                sum_disp = siddisper;
              }
            }
          });
          // print(
          //     '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  Future<Null> pPC_finantIbill(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    // print(url); //ทดพลาดทดสอบระบบยอดเงินไม่ตรง
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          // _InvoiceModels.clear();
          // _InvoiceHistoryModels.clear();
          _TransReBillHistoryModels.clear();
          // numinvoice = null;
          // sum_disamtx.text = '0.00';
          // sum_dispx.text = '0.00';
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;
          // select_page = 0;
          red_Trans_bill();
          finnancetransModels.clear();
          Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> pPC_finantIbill_TimeCheck(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    // print(url); //ทดพลาดทดสอบระบบยอดเงินไม่ตรง
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          // _InvoiceModels.clear();
          // _InvoiceHistoryModels.clear();
          // _TransReBillHistoryModels.clear();
          // numinvoice = null;
          // sum_disamtx.text = '0.00';
          // sum_dispx.text = '0.00';
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;
          // select_page = 0;
          // red_Trans_bill();
          // finnancetransModels.clear();
          // Navigator.pop(context);
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///----------------------->
  Widget Next_page() {
    return Row(
      children: [
        const Expanded(child: Text('')),
        StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 300)),
            builder: (context, snapshot) {
              return Container(
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
                  children: [
                    InkWell(
                      onTap: (renTal_user.toString() != '50')
                          ? null
                          : () async {
                              // red_easyslip_data();
                              red_Trans_billTest();
                              _easyslipDialog();
                            },
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    InkWell(
                        onTap: (offset == 0)
                            ? null
                            : () async {
                                if (offset == 0) {
                                } else {
                                  setState(() {
                                    offset = offset - limit;

                                    read_TransReBill_limit();
                                    tappedIndex_ = '';
                                  });
                                  _scrollController2.animateTo(
                                    0,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                        child: Icon(
                          Icons.arrow_left,
                          color:
                              (offset == 0) ? Colors.grey[200] : Colors.black,
                          size: 25,
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        /// '*//$endIndex /${limitedList_teNantModels.length} ///${(endIndex / limit)}/${(limitedList_teNantModels.length / limit).ceil()}',
                        '${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                          //fontSize: 10.0
                        ),
                      ),
                    ),
                    InkWell(
                        onTap:
                            (endIndex >= limitedList_TransReBillModels_.length)
                                ? null
                                : () async {
                                    setState(() {
                                      offset = offset + limit;
                                      tappedIndex_ = '';
                                      read_TransReBill_limit();
                                    });
                                    _scrollController2.animateTo(
                                      0,
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeOut,
                                    );
                                  },
                        child: Icon(
                          Icons.arrow_right,
                          color: (endIndex >=
                                  limitedList_TransReBillModels_.length)
                              ? Colors.grey[200]
                              : Colors.black,
                          size: 25,
                        )),
                  ],
                ),
              );
            }),
      ],
    );
  }

////////--------------------------------------------->

////////--------------------------------------------->
  Future<Null> red_Trans_billTest() async {
    if (_TransReBillModelsTest.length != 0) {
      setState(() {
        _TransReBillModelsTest.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_finance_testSlip.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            _TransReBillModelsTest.add(transReBillModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> Select_Trans_billTest(cid_doc) async {
    if (easyslipModels_.length != 0) {
      setState(() {
        easyslipModels_.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_easyslip.php?isAdd=true&ren=$ren&ciddoc=$cid_doc';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          easyslipModel easyslipModelss = easyslipModel.fromJson(map);
          setState(() {
            easyslipModels_.add(easyslipModelss);
          });
        }
      }
    } catch (e) {}
  }

  Widget ResultChackSlip() {
    // print('**************************');
    // print('transRef: $transRef');
    // print('วันที่สลิป: $date');
    // print('จำนวนเงินในสลิป: $amountValue');
    // print('**************************');
    // print('ชื่อธนาคารผู้ส่ง: $sender_bank');
    // print('ชื่อย่อธนาคารผู้ส่ง: $sender_banknameshort');
    // print('เลขบช.ธนาคารผู้ส่ง: $sender_bankaccount');
    // print('**************************');
    // print('ชื่อธนาคารผู้รับ: $receiver_bank');
    // print('ชื่อย่อธนาคารผู้รับ: $receiver_banknameshort');
    // print('ชื่อผู้รับTH: $receiver_bankACNameTH');
    // print('ชื่อผู้รับEN: $receiver_bankACNameEN');
    // print('เลขบช.ธนาคารผู้รับ: $receiver_bankaccount');
    // print('**************************');

    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              width: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.85
                  : 1200,
              color: Colors.green[50],
              // padding: EdgeInsets.all(6.0),
              child: Column(
                children: [
                  const Text(
                    'ผลการตรวจสอบสลิป',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AccountScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.w600,
                      fontFamily: Font_.Fonts_T,
                      //fontSize: 10.0
                    ),
                  ),
                  Text(
                    (easyslipModels_.length == 0)
                        ? 'วันที่สลิป: ??  (จำนวนเงินในสลิป: ?? '
                        : 'วันที่สลิป: ${easyslipModels_[0].slip_date}  (จำนวนเงินในสลิป: ${easyslipModels_[0].amount}) ',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AccountScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.w600,
                      fontFamily: Font_.Fonts_T,
                      //fontSize: 10.0
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          'ประเภทข้อมูลจากสลิป',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          'ชื่อธนาคาร',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          'เลขบช.ธนาคาร',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          'ชื่อ TH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          'ชื่อ EN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                            right: BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: const Text(
                          '...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,

                            fontWeight: FontWeight.w600,
                            fontFamily: Font_.Fonts_T,
                            //fontSize: 10.0
                          ),
                        ),
                      ),
                    ),
                  ]),

                  ///easyslipModels_
                  for (int index = 0; index < easyslipModels_.length; index++)
                    SizedBox(
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: const Text(
                                      'ข้อมูลผู้ส่ง/ผู้โอน',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].sen_bankname !=
                                              null)
                                          ? '${easyslipModels_[index].sen_bankname} (${easyslipModels_[index].sen_bankshort})'
                                          : '',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].sen_accnumber !=
                                              null)
                                          ? '${easyslipModels_[index].sen_accnumber}'
                                          : '${easyslipModels_[index].sen_proxy_accnumber}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      '${easyslipModels_[index].sen_accnameTh}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      '${easyslipModels_[index].sen_accnameEn}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        right: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].sen_banktype !=
                                              null)
                                          ? '${easyslipModels_[index].sen_banktype}'
                                          : '${easyslipModels_[index].sen_proxy_type}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: const Text(
                                      'ข้อมูลผู้รับ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].recei_bankname ==
                                                  null ||
                                              easyslipModels_[index]
                                                      .recei_bankname ==
                                                  '')
                                          ? ''
                                          : '${easyslipModels_[index].recei_bankname} (${easyslipModels_[index].recei_bankshort})',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].recei_accnumber ==
                                                  null ||
                                              easyslipModels_[index]
                                                      .recei_accnumber ==
                                                  '')
                                          ? '${easyslipModels_[index].recei_proxy_accnumber}'
                                          : '${easyslipModels_[index].recei_accnumber}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      '${easyslipModels_[index].recei_accnameTh}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      '${easyslipModels_[index].recei_accnameEn}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        right: BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      (easyslipModels_[index].recei_banktype ==
                                                  null ||
                                              easyslipModels_[index]
                                                      .recei_banktype ==
                                                  '')
                                          ? '${easyslipModels_[index].recei_proxy_type}'
                                          : '${easyslipModels_[index].recei_banktype}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,

                                        fontFamily: Font_.Fonts_T,
                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }

////////-------------------------------------->
  int ser_adddata = 0;

  final _formKey = GlobalKey<FormState>();
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  final myController4 = TextEditingController();
  final myController5 = TextEditingController();
  final myController6 = TextEditingController();
  /////////////------------------------------------>
  Future<Null> _select_Date_Daily(BuildContext context, ser) async {
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

        var formatter = DateFormat('yyyy-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          if (ser == 2) {
            myController2.text = "${formatter.format(result)}";
          } else {
            myController3.text = "${formatter.format(result)}";
          }
        });
      }
    });
  }

  //////////////////------------------------->
  // String? base64_Slip, fileName_Slip; In_finance_testSlip
  var extension_;
  var file_;
  Future<void> uploadFile_Slip() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // print('User canceled image selection');
      return print(pickedFile);
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
      });
      // print(base64_Slip);
      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // print(extension_);
      // print(extension_);
    }
    OKuploadFile_Slip();
    // OKuploadFile_Slip();
    // OKuploadFile_Slip(extension, file);
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
      var fileName_Slip_ = 'PaymentQR_${date.toString()}_$Time_';
      setState(() {
        fileName_Slip = 'Testeasyslip_${date.toString()}_$Time_.$extension_';
      });
      final url =
          '${MyConstant().domain}/Test_Upeasyslip.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Slip,
          'Foder': foder,
          'name': fileName_Slip,
          'ex': extension_.toString()
        }, // Send the image as a form field named 'image'
      );
    }
  }

  Future<void> _easyslipDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // user must tap button! **https://dzentric.com/chao_perty/chao_api/easyslip.php
      builder: (BuildContext context) {
        return StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 0)),
            builder: (context, snapshot) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(10.0),
                actionsPadding: const EdgeInsets.all(6.0),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            setState(() {
                              fileName_Slip = null;
                              ser_adddata = 0;
                              index_Test = null;
                              myController1.clear();
                              myController2.clear();
                              myController3.clear();
                              myController4.clear();
                              myController5.clear();
                              myController6.clear();
                            });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                fileName_Slip = null;

                                myController1.clear();
                                myController2.clear();
                                myController3.clear();
                                myController4.clear();
                                myController5.clear();
                                myController6.clear();
                              });
                              setState(() {
                                if (ser_adddata == 1) {
                                  ser_adddata = 0;
                                } else {
                                  ser_adddata = 1;
                                }
                              });
                            },
                            child: Container(
                              color: (ser_adddata == 1)
                                  ? Colors.red[100]
                                  : Colors.green[100],
                              width: 180,
                              padding: EdgeInsets.all(2.0),
                              child: Center(
                                child: Text(
                                  (ser_adddata == 1)
                                      ? 'ยกเลิกทดสอบเพิ่ม X'
                                      : 'ทดสอบเพิ่ม +',
                                  style: TextStyle(
                                    color: ReportScreen_Color.Colors_Text2_,
                                    // fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // title:
                // Text(
                //     'Easyslip Check Test ${_TransReBillModelsTest.length}'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      if (ser_adddata == 1)
                        Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            width: 500,
                            padding: EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController1,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'เลขที่สัญญา',
                                      ),
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please เลขที่สัญญา';
                                        }
                                        return null;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController2,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'วันที่ทำรายการ',
                                      ),
                                      readOnly: true,
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      onTap: () {
                                        _select_Date_Daily(context, 2);
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please วันที่ทำรายการ';
                                        }
                                        return null;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController3,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'วันที่รับชำระ',
                                      ),
                                      readOnly: true,
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      onTap: () {
                                        _select_Date_Daily(context, 3);
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please วันที่รับชำระ';
                                        }
                                        return null;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController4,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'เลขที่ใบเสร็จ',
                                      ),
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please เลขที่ใบเสร็จ';
                                        }
                                        return null;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController5,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'ชื่อร้าน',
                                      ),
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please ชื่อร้าน';
                                        }
                                        return null;
                                      },
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: myController6,
                                      decoration: const InputDecoration(
                                        // icon: Icon(Icons.person),
                                        labelText: 'จำนวนเงิน',
                                      ),
                                      onSaved: (String? value) {
                                        // This optional block of code can be used to run
                                        // code when the user saves the form.
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please จำนวนเงิน';
                                        }
                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter(
                                            RegExp("[0-9.]"),
                                            allow: true),
                                        // for below version 2 use this
                                        // FilteringTextInputFormatter.allow(
                                        //     RegExp(r'[0-9.]')),
                                        // // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter.digitsOnly
                                      ],
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async {
                                        if (fileName_Slip != null) {
                                          setState(() {
                                            fileName_Slip = null;
                                          });
                                        } else {
                                          uploadFile_Slip();
                                        }
                                      },
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 25,
                                        maxLines: 1,
                                        (fileName_Slip != null)
                                            ? 'ลบสลิป X'
                                            : 'กรุณาอัพสลิป ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: (fileName_Slip != null)
                                                ? Colors.blue
                                                : Colors.red,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: (fileName_Slip == null)
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                red_easyslip_data();
                                              }
                                            },
                                      child: Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: (fileName_Slip != null)
                                              ? Colors.green
                                              : Colors.green[50],
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          'ยืนยัน',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: AccountScreen_Color
                                                  .Colors_Text2_,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            'Easyslip Check Test ${_TransReBillModelsTest.length}',
                            style: const TextStyle(
                              color: AccountScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                              //fontSize: 10.0
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: (Responsive.isDesktop(context))
                            ? MediaQuery.of(context).size.width * 0.85
                            : 1200,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.TiTile_Colors,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                        ),
                        // padding: const EdgeInsets.all(8.0),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'เลขที่สัญญา',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    'วันที่รับชำระ',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    'เลขที่ใบเสร็จ',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    'ชื่อร้าน',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    'จำนวนเงิน',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    'Slip',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
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
                                    '....',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AccountScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.85
                              : 1200,
                          decoration: const BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: _TransReBillModelsTest.isEmpty
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
                                            child: (elapsed > 8.00)
                                                ? const Text(
                                                    'ไม่พบข้อมูล',
                                                    style: TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        ),
                                                  )
                                                : Text(
                                                    'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                    // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  // controller: _scrollController2,
                                  // itemExtent: 50,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _TransReBillModelsTest.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Material(
                                          color:
                                              (indexTest == index.toString() ||
                                                      index_Test == index)
                                                  ? tappedIndex_Color
                                                      .tappedIndex_Colors
                                                  : AppbackgroundColor
                                                      .Sub_Abg_Colors,
                                          child: Container(
                                            color: (indexTest ==
                                                        index.toString() ||
                                                    index_Test == index)
                                                ? tappedIndex_Color
                                                    .tappedIndex_Colors
                                                : null,
                                            child: ListTile(
                                                // onTap: () async {
                                                //   // setState(() {
                                                //   //   indexTest = '${index}';
                                                //   // });
                                                // },
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        '${_TransReBillModelsTest[index].refno}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        (_TransReBillModelsTest[
                                                                        index]
                                                                    .daterec ==
                                                                null)
                                                            ? '${_TransReBillModelsTest[index].daterec}'
                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModelsTest[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModelsTest[index].daterec} 00:00:00').year + 543}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        (_TransReBillModelsTest[
                                                                        index]
                                                                    .pdate ==
                                                                null)
                                                            ? '${_TransReBillModelsTest[index].pdate}'
                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModelsTest[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModelsTest[index].pdate} 00:00:00').year + 543}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        '${_TransReBillModelsTest[index].docno}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        '${_TransReBillModelsTest[index].remark}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Tooltip(
                                                      richMessage:
                                                          const TextSpan(
                                                        text: '',
                                                        style: TextStyle(
                                                          color: HomeScreen_Color
                                                              .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          //fontSize: 10.0
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.grey[200],
                                                      ),
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        (_TransReBillModelsTest[
                                                                        index]
                                                                    .total ==
                                                                null)
                                                            ? '${_TransReBillModelsTest[index].total}'
                                                            : '${nFormat.format(double.parse(_TransReBillModelsTest[index].total!))}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          String url =
                                                              await '${MyConstant().domain}/Awaitdownload/payment/${_TransReBillModelsTest[index].slip}';
                                                          await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (_) => Dialog(
                                                                        // backgroundColor: Colors.transparent,
                                                                        // elevation: 0,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              320,
                                                                          // height:
                                                                          //     400,
                                                                          child:
                                                                              Column(
                                                                            // mainAxisAlignment:
                                                                            //     MainAxisAlignment.spaceBetween,
                                                                            // mainAxisSize:
                                                                            //     MainAxisSize.s,
                                                                            // crossAxisAlignment:
                                                                            //     CrossAxisAlignment.stretch,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 0),
                                                                                child: Container(
                                                                                  color: Colors.grey[100],
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                        '${_TransReBillModelsTest[index].docno}',
                                                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () async {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        icon: Icon(Icons.close_rounded),
                                                                                        color: Colors.redAccent,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Container(
                                                                                    child: Image.network(
                                                                                      '${url}',
                                                                                      //  'https://dzentric.com/chao_perty/chao_api/Awaitdownload/payment/${_TransReBillModelsTest[index].slip}',
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ));
                                                        },
                                                        child:
                                                            const AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 25,
                                                          maxLines: 1,
                                                          'ดู',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          //https://dzentric.com/chao_perty/chao_api/easyslip.php
                                                          if (index_Test ==
                                                              index) {
                                                            setState(() {
                                                              index_Test = null;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              index_Test =
                                                                  index;
                                                            });
                                                          }
                                                          Select_Trans_billTest(
                                                              '${_TransReBillModelsTest[index].docno}');
                                                          // red_set_data(index);
                                                        },
                                                        child: Container(
                                                          width: 100,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                (index_Test ==
                                                                        index)
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .orange,
                                                            borderRadius: const BorderRadius
                                                                    .only(
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
                                                                color: Colors
                                                                    .white,
                                                                width: 1),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 25,
                                                            maxLines: 1,
                                                            (index_Test ==
                                                                    index)
                                                                ? 'X'
                                                                : 'ตรวจสอบ',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ),
                                        ),
                                        if (index_Test == index)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 8),
                                            child: ResultChackSlip(),
                                          ),
                                        if (index_Test == index)
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                        if (index_Test == index)
                                          const Divider(
                                            color: Colors.grey,
                                            height: 1.5,
                                          ),
                                        if (index_Test == index)
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                      ],
                                    );
                                  })),
                    ],
                  ),
                ),
              );
            });
      },
    );
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

  ///////////--------------------------------------------------------->
  Widget buidImageCard(int index) => Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: (_TransReBillModels[index].st.toString() == '0')
                    ? null
                    : DecorationImage(
                        image: (_TransReBillModels[index].slip == null ||
                                _TransReBillModels[index].slip.toString() ==
                                    'null' ||
                                _TransReBillModels[index].slip.toString() == '')
                            ? NetworkImage(
                                '${MyConstant().domain}/Awaitdownload/imagenot.png',
                              )
                            : NetworkImage(
                                '${MyConstant().domain}/files/$foder/slip/${_TransReBillModels[index].slip}',
                              ),
                        fit: BoxFit.fitWidth,
                      ),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (_TransReBillModels[index].slip == null ||
                          _TransReBillModels[index].slip.toString() == 'null' ||
                          _TransReBillModels[index].slip.toString() == '')
                      ? SizedBox()
                      : Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(2),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: AppbackgroundColor.TiTile_Colors,
                                        borderRadius:
                                            (Responsive.isDesktop(context))
                                                ? BorderRadius.circular(20)
                                                : BorderRadius.circular(14)),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          dropdownWidth: 200,
                                          // searchController:
                                          //     Dropdown_Controller,
                                          // searchInnerWidget:
                                          //     Container(
                                          //   width:
                                          //       230,
                                          //   height:
                                          //       30,
                                          //   decoration:
                                          //       BoxDecoration(
                                          //     color: Colors
                                          //         .red[100]!
                                          //         .withOpacity(0.5),
                                          //     borderRadius: const BorderRadius.only(
                                          //         topLeft: Radius.circular(8),
                                          //         topRight: Radius.circular(8),
                                          //         bottomLeft: Radius.circular(8),
                                          //         bottomRight: Radius.circular(8)),
                                          //     border: Border.all(
                                          //         color: Colors.grey,
                                          //         width: 1),
                                          //   ),
                                          //   child:
                                          //       TextFormField(
                                          //     expands:
                                          //         true,
                                          //     maxLines:
                                          //         null,
                                          //     controller:
                                          //         Dropdown_Controller,
                                          //     decoration:
                                          //         InputDecoration(
                                          //       isDense:
                                          //           true,
                                          //       contentPadding:
                                          //           const EdgeInsets.symmetric(
                                          //         horizontal: 10,
                                          //         vertical: 8,
                                          //       ),
                                          //       hintText:
                                          //           'Search...',
                                          //       // fillColor: Colors.red[300],
                                          //       hintStyle:
                                          //           const TextStyle(fontSize: 12),
                                          //       border:
                                          //           OutlineInputBorder(
                                          //         borderRadius: BorderRadius.circular(8),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          customButton: const Icon(
                                            Icons.menu,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                          items: [
                                            DropdownMenuItem<String>(
                                              value: '0',
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'รายละเอียดบิล',
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey[300],
                                                    height: 4.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem<String>(
                                              value: '1',
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'ข้อมูลการจอง',
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey[300],
                                                    height: 4.0,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                          onChanged: (value) async {
                                            if (value.toString() == '1') {
                                              // Navigator.pop(context, 'OK');
                                              setState(() {
                                                _TransReBillModels[index].st =
                                                    '0';
                                              });
                                            } else {
                                              // Navigator.pop(context, 'OK');
                                              generateRandomString();
                                              setState(() {
                                                red_Trans_select(index);
                                                red_Invoice(index);
                                              });
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 300),
                                                  () async {
                                                checkshowDialog(
                                                  index,
                                                );
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  (renTal_Ser.toString() == '106')
                                      ? SizedBox()
                                      : (checkTimeDifference(
                                                  '${_TransReBillModels[index].dateacc}',
                                                  '${_TransReBillModels[index].timex}') ==
                                              false)
                                          ? SizedBox(width: 25)
                                          : SizedBox(
                                              width: 25,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Center(
                                                    child: Icon(
                                                  Icons.lock_clock,
                                                  size: 18,
                                                  color: Colors.blueGrey,
                                                )),
                                              ),
                                            ),
                                  Expanded(
                                    // flex: 1,
                                    child: (_TransReBillModels[index]
                                                .st
                                                .toString() ==
                                            '0')
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (_TransReBillModels[index]
                                                      .pay_by
                                                      .toString() ==
                                                  'LP')
                                                Translate.TranslateAndSetText(
                                                    'ล็อกเสียบ',
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.start,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    12,
                                                    1),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _TransReBillModels[index]
                                                          .st = '1';
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .TiTile_Colors,
                                                        borderRadius: (Responsive
                                                                .isDesktop(
                                                                    context))
                                                            ? BorderRadius
                                                                .circular(20)
                                                            : BorderRadius
                                                                .circular(14)),
                                                    child: Icon(
                                                        Icons.highlight_off,
                                                        size: 20,
                                                        color: Colors.red[700]),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: AppbackgroundColor
                                                      .TiTile_Colors
                                                  .withOpacity(0.8),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  topRight: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(0)),
                                            ),
                                            child: AutoSizeText(
                                              minFontSize: 8,
                                              maxFontSize: 13,
                                              _TransReBillModels[index].ln ==
                                                      null
                                                  ? 'พื้นที่ : ${_TransReBillModels[index].room_number}'
                                                  : 'พื้นที่ : ${_TransReBillModels[index].ln}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              if (_TransReBillModels[index].st.toString() ==
                                  '1')
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () async {
                                      setState(() {
                                        transReBill_select_delete.clear();
                                      });
                                      if (TransReBill_select.length >= 50) {
                                        setState(() {
                                          TransReBill_select.remove(
                                              '${_TransReBillModels[index].docno}');
                                        });
                                        // Dialog_notimax(50);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  'เลือกได้สูงสุด 50 รายการ...!!',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: FontWeight_
                                                          .Fonts_T))),
                                        );
                                      } else {
                                        setState(() {
                                          if (TransReBill_select.contains(
                                                  '${_TransReBillModels[index].docno}') ==
                                              true) {
                                            TransReBill_select.remove(
                                                '${_TransReBillModels[index].docno}');
                                          } else {
                                            TransReBill_select.add(
                                                '${_TransReBillModels[index].docno}');
                                          }
                                        });
                                      }
                                    },
                                    child: (TransReBill_select.contains(
                                                '${_TransReBillModels[index].docno}') ==
                                            true)
                                        ? const Icon(Icons.check_box,
                                            color: AppBarColors.ABar_Colors)
                                        : const Icon(
                                            Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                  (_TransReBillModels[index].st.toString() == '0')
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            child: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 13,
                                    'เลขที่ใบเสร็จ : ${_TransReBillModels[index].docno}',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'สัญญา :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          '${_TransReBillModels[index].cid}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'โซนพื้นที่ :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          _TransReBillModels[index].zn == null
                                              ? '${_TransReBillModels[index].znn}'
                                              : '${_TransReBillModels[index].zn}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'รหัสพื้นที่ :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          _TransReBillModels[index].ln == null
                                              ? '${_TransReBillModels[index].room_number}'
                                              : '${_TransReBillModels[index].ln}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'ชื่อร้านค้า :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          _TransReBillModels[index].sname ==
                                                  null
                                              ? '${_TransReBillModels[index].remark}'
                                              : '${_TransReBillModels[index].sname}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'วันที่ทำรายการ :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          '${_TransReBillModels[index].daterec}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'วันที่รับชำระ :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          '${_TransReBillModels[index].pdate}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          'จำนวนเงิน :',
                                          AccountScreen_Color.Colors_Text1_,
                                          TextAlign.start,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          12,
                                          1),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          _TransReBillModels[index].total_dis ==
                                                  null
                                              ? (_TransReBillModels[index]
                                                          .total_bill ==
                                                      null)
                                                  ? ''
                                                  : '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                                              : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 5,
                                  ),
                                  if (_TransReBillModels[index]
                                          .pay_by
                                          .toString() ==
                                      'LP')
                                    Translate.TranslateAndSetText(
                                        'วันที่จอง-ล็อกเสียบ',
                                        AccountScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        12,
                                        1),
                                  if (_TransReBillModels[index]
                                          .pay_by
                                          .toString() ==
                                      'LP')
                                    AutoSizeText(
                                      minFontSize: 8,
                                      maxFontSize: 13,
                                      (_TransReBillModels[index]
                                                  .pay_by
                                                  .toString() ==
                                              'LP')
                                          ? (_TransReBillModels[index]
                                                      .date_book ==
                                                  null)
                                              ? ''
                                              : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date_book} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date_book} 00:00:00').year + 0}'
                                          : '',
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  if (_TransReBillModels[index]
                                          .pay_by
                                          .toString() ==
                                      'LP')
                                    const Divider(
                                      height: 5,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            children: [
                              Expanded(
                                // flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Colors
                                        .withOpacity(0.8),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Copy_Text(
                                          context,
                                          _TransReBillModels[index].doctax == ''
                                              ? '${_TransReBillModels[index].docno}'
                                              : '${_TransReBillModels[index].doctax}'),
                                      Expanded(
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 13,
                                          _TransReBillModels[index].doctax == ''
                                              ? '${_TransReBillModels[index].docno}'
                                              : '${_TransReBillModels[index].doctax}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              (_TransReBillModels[index].slip == null ||
                                      _TransReBillModels[index]
                                              .slip
                                              .toString() ==
                                          'null' ||
                                      _TransReBillModels[index]
                                              .slip
                                              .toString() ==
                                          '')
                                  ? SizedBox()
                                  : Container(
                                      margin: const EdgeInsets.all(2),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
                                          borderRadius:
                                              (Responsive.isDesktop(context))
                                                  ? BorderRadius.circular(20)
                                                  : BorderRadius.circular(14)),
                                      child: InkWell(
                                        onTap: () => downloadImage_slip(
                                            '${MyConstant().domain}/files/$foder/slip/${_TransReBillModels[index].slip}',
                                            '${_TransReBillModels[index].docno}'),
                                        child: Icon(
                                          Icons.download,
                                          color: Colors.blue,
                                          size: 20,
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
        ),
      );

  Widget Image_GridView(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Container(
      width: (Responsive.isDesktop(context))
          ? MediaQuery.of(context).size.width * 0.88
          : 1400,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Container(
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
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Translate.TranslateAndSetText(
                            'ค้นหา :',
                            AccountScreen_Color.Colors_Text1_,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                      Expanded(
                        // flex: 1,
                        child: Container(
                          height: 35, //Date_ser
                          // width: 150,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: _searchBarMain1(),
                        ),
                      ),

                      Container(width: 150, child: Next_page())
                      // Container(
                      //     width: 150,
                      //     child: Next_page())
                      // Expanded(
                      //     child:
                      //         Next_page_billCancel())
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
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
                            decoration: BoxDecoration(
                              color:
                                  AppbackgroundColor.Sub_Abg_Colors.withOpacity(
                                      0.5),
                              borderRadius: const BorderRadius.only(
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
                                      'เดือน :',
                                      AccountScreen_Color.Colors_Text1_,
                                      TextAlign.start,
                                      null,
                                      Font_.Fonts_T,
                                      14,
                                      1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
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
                                        focusedBorder: const OutlineInputBorder(
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
                                              ? 'เลือก-Select'
                                              : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                          Colors.grey,
                                          TextAlign.start,
                                          null,
                                          Font_.Fonts_T,
                                          12,
                                          1),
                                      //  Text(
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
                                        borderRadius: BorderRadius.circular(10),
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
                                            // Text(
                                            //   '${monthsInThai[item - 1]}',
                                            //   // '${item}',
                                            //   textAlign:
                                            //       TextAlign
                                            //           .center,
                                            //   style:
                                            //       const TextStyle(
                                            //     overflow:
                                            //         TextOverflow
                                            //             .ellipsis,
                                            //     fontSize:
                                            //         14,
                                            //     color: Colors
                                            //         .grey,
                                            //   ),
                                            // ),
                                          )
                                      ],

                                      onChanged: (value) async {
                                        MONTH_Now = value;
                                        red_Trans_bill();
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
                                      'ปี :',
                                      AccountScreen_Color.Colors_Text1_,
                                      TextAlign.start,
                                      null,
                                      Font_.Fonts_T,
                                      12,
                                      1),
                                  // Text(
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
                                      color: AppbackgroundColor.Sub_Abg_Colors,
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
                                        focusedBorder: const OutlineInputBorder(
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
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      items: YE_Th.map((item) =>
                                          DropdownMenuItem<String>(
                                            value: '${item}',
                                            child: Text(
                                              '${item}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )).toList(),

                                      onChanged: (value) async {
                                        YEAR_Now = value;
                                        red_Trans_bill();
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
                                      'ระบบ :',
                                      AccountScreen_Color.Colors_Text1_,
                                      TextAlign.start,
                                      null,
                                      Font_.Fonts_T,
                                      12,
                                      1),

                                  // Text(
                                  //   'ระบบ :',
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
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      // border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    width: 200,
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
                                        focusedBorder: const OutlineInputBorder(
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
                                          'ทั้งหมด',
                                          Colors.grey,
                                          TextAlign.start,
                                          null,
                                          Font_.Fonts_T,
                                          12,
                                          1),
                                      // Text(
                                      //   (ser_payby ==
                                      //               null ||
                                      //           ser_payby ==
                                      //               '0')
                                      //       ? 'ทั้งหมด-All'
                                      //       : '$ser_payby',
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
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: '0',
                                          child: Translate.TranslateAndSetText(
                                              'ทั้งหมด',
                                              Colors.grey,
                                              TextAlign.start,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          //  Text(
                                          //   'ทั้งหมด',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '1',
                                          child: Translate.TranslateAndSetText(
                                              'Web Admin(W)',
                                              Colors.grey,
                                              TextAlign.start,
                                              null,
                                              Font_.Fonts_T,
                                              12,
                                              1),
                                          // Text(
                                          //   'เว็ป หลักแอดมิน(W)',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '2',
                                          child: Translate.TranslateAndSetText(
                                              'Web User(U)',
                                              Colors.grey,
                                              TextAlign.start,
                                              null,
                                              Font_.Fonts_T,
                                              12,
                                              1),
                                          //  Text(
                                          //   'เว็ป User(U)',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '3',
                                          child: Translate.TranslateAndSetText(
                                              'Web Market(LP)',
                                              Colors.grey,
                                              TextAlign.start,
                                              null,
                                              Font_.Fonts_T,
                                              12,
                                              1),
                                          //  Text(
                                          //   'เว็ป Market(LP)',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '4',
                                          child: Translate.TranslateAndSetText(
                                              'Handheld(H)',
                                              Colors.grey,
                                              TextAlign.start,
                                              null,
                                              Font_.Fonts_T,
                                              12,
                                              1),
                                          // Text(
                                          //   'เครื่อง Handheld(H)',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        )
                                      ],

                                      onChanged: (value) async {
                                        setState(() {
                                          ser_payby = value;
                                        });

                                        // print(value);
                                        red_Trans_bill();
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
                                      'เรียงจาก :',
                                      AccountScreen_Color.Colors_Text1_,
                                      TextAlign.start,
                                      null,
                                      Font_.Fonts_T,
                                      14,
                                      1),
                                  // Text(
                                  //   'เรียงจาก :',
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
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      // border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    width: 160,
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
                                        focusedBorder: const OutlineInputBorder(
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
                                          'เลขที่ใบเสร็จ',
                                          Colors.grey,
                                          TextAlign.center,
                                          null,
                                          Font_.Fonts_T,
                                          14,
                                          1),
                                      // Text(
                                      //   'เลขที่ใบเสร็จ',
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
                                        // Icons.sort_rounded,
                                        color: Colors.black,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      iconSize: 20,
                                      buttonHeight: 30,
                                      buttonWidth: 160,
                                      // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                      dropdownDecoration: BoxDecoration(
                                        // color: Colors
                                        //     .amber,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: '0',
                                          child: Translate.TranslateAndSetText(
                                              'เลขที่ใบเสร็จ',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          //  Text(
                                          //   'เลขที่ใบเสร็จ',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       const TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '1',
                                          child: Translate.TranslateAndSetText(
                                              'เลขที่สัญญา',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          // Text(
                                          //   'เลขที่สัญญา',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       const TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '2',
                                          child: Translate.TranslateAndSetText(
                                              'วันที่ทำรายการ',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          //  Text(
                                          //   'วันที่ทำรายการ',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       const TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '3',
                                          child: Translate.TranslateAndSetText(
                                              'วันที่จอง-ล็อกเสียบ',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          // Text(
                                          //   'วันที่จอง-ล็อกเสียบ',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       const TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: '4',
                                          child: Translate.TranslateAndSetText(
                                              'วันที่รับชำระ',
                                              Colors.grey,
                                              TextAlign.center,
                                              null,
                                              Font_.Fonts_T,
                                              14,
                                              1),
                                          //  Text(
                                          //   'วันที่รับชำระ',
                                          //   textAlign:
                                          //       TextAlign
                                          //           .center,
                                          //   style:
                                          //       const TextStyle(
                                          //     overflow:
                                          //         TextOverflow
                                          //             .ellipsis,
                                          //     fontSize:
                                          //         14,
                                          //     color: Colors
                                          //         .grey,
                                          //   ),
                                          // ),
                                        ),
                                      ],

                                      onChanged: (value) async {
                                        if (value.toString() == '0') {
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) =>
                                                  b.docno!.compareTo(a.docno!));
                                        } else if (value.toString() == '1') {
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) =>
                                                  b.cid!.compareTo(a.cid!));
                                        } else if (value.toString() == '2') {
                                          //DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) =>
                                                  DateTime.parse(b.daterec!)
                                                      .compareTo(DateTime.parse(
                                                          a.daterec!)));
                                          // InvoiceModels.sort((a, b) => b.daterec!.compareTo(a.daterec!));
                                        } else if (value.toString() == '3') {
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) => DateTime.parse(b.date!)
                                                  .compareTo(
                                                      DateTime.parse(a.date!)));
                                          // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
                                        } else if (value.toString() == '4') {
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) => DateTime.parse(b.pdate!)
                                                  .compareTo(DateTime.parse(
                                                      a.pdate!)));
                                          // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
                                        } else {
                                          limitedList_TransReBillModels_.sort(
                                              (a, b) =>
                                                  b.docno!.compareTo(a.docno!));
                                        }
                                        setState(() {
                                          // _TransReBillModels = limitedList_TransReBillModels_
                                          _TransReBillModels =
                                              limitedList_TransReBillModels_;
                                        });
                                        read_TransReBill_limit();
                                      },
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
                ),
                const Divider(),
                Row(
                  children: [
                    (TransReBill_select.length != 0 &&
                            _TransReBillModels.length != 0)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(0)),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    'Save ( ${TransReBill_select.length} )',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(8)),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  itemBuilder: (BuildContext context) => [
                                    // PopupMenuItem(
                                    //     onTap: () async {
                                    //       Future.delayed(
                                    //           const Duration(microseconds: 800),
                                    //           () async {
                                    //         List newValuePDFimg = [];

                                    //         for (int index = 0;
                                    //             index < 1;
                                    //             index++) {
                                    //           if (renTalModels[0]
                                    //                   .imglogo!
                                    //                   .trim() ==
                                    //               '') {
                                    //             // newValuePDFimg.add(
                                    //             //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                    //           } else {
                                    //             newValuePDFimg.add(
                                    //                 '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                    //           }
                                    //         }

                                    //         _showMyDialog_SAVE_All(
                                    //             newValuePDFimg, 'Folder');
                                    //       });
                                    //     },
                                    //     child: Container(
                                    //       decoration: const BoxDecoration(
                                    //         // color: Colors.green[100]!
                                    //         //     .withOpacity(0.5),
                                    //         border: Border(
                                    //           bottom: BorderSide(
                                    //             color: Colors.black12,
                                    //             width: 1,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       padding: const EdgeInsets.all(2.0),
                                    //       // width: 200,
                                    //       child: Row(
                                    //         children: [
                                    //           Text(
                                    //             'Save( ${TransReBill_select.length} ) : Folder ',
                                    //             style: const TextStyle(
                                    //               fontSize: 14,
                                    //               color: ReportScreen_Color
                                    //                   .Colors_Text2_,
                                    //               // fontWeight: FontWeight.bold,
                                    //               fontFamily: Font_.Fonts_T,
                                    //             ),
                                    //           ),
                                    //           Icon(Icons.folder,
                                    //               color: Colors.amber[600])
                                    //         ],
                                    //       ),
                                    //     )),
                                    PopupMenuItem(
                                        onTap: () async {
                                          Future.delayed(
                                              const Duration(microseconds: 800),
                                              () async {
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

                                            _showMyDialog_SAVE_All(
                                                newValuePDFimg, 'File');
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
                                          child: Row(
                                            children: [
                                              Text(
                                                'Save( ${TransReBill_select.length} ) : File ',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ReportScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                              const Icon(Icons.file_copy,
                                                  color:
                                                      AppBarColors.ABar_Colors)
                                            ],
                                          ),
                                        )),
                                    PopupMenuItem(
                                        onTap: () async {
                                          setState(() {
                                            TransReBill_select.clear();
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
                                          child: Row(
                                            children: [
                                              Translate.TranslateAndSetText(
                                                  'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                                  AccountScreen_Color
                                                      .Colors_Text2_,
                                                  TextAlign.start,
                                                  null,
                                                  Font_.Fonts_T,
                                                  13,
                                                  1),
                                              // Text(
                                              //   'ยกเลิกทั้งหมด( ${TransReBill_select.length} ) : ',
                                              //   style:
                                              //       const TextStyle(
                                              //     fontSize: 14,
                                              //     color: ReportScreen_Color.Colors_Text2_,
                                              //     // fontWeight: FontWeight.bold,
                                              //     fontFamily: Font_.Fonts_T,
                                              //   ),
                                              // ),
                                              const Icon(
                                                Icons.check_box_outline_blank,
                                                color: Colors.red,
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
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            width: 80,
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  //  TransReBill_select_delete
                                  //       .clear();
                                  TransReBill_select.clear();
                                });
                                // print(InvoiceModels
                                //     .length);
                                for (int index = 0;
                                    index < _TransReBillModels.length;
                                    index++) {
                                  if (_TransReBillModels[index].slip == null ||
                                      _TransReBillModels[index]
                                              .slip
                                              .toString() ==
                                          '' ||
                                      _TransReBillModels[index]
                                              .slip
                                              .toString() ==
                                          'null') {
                                  } else {
                                    setState(() {
                                      TransReBill_select.add(
                                          '${_TransReBillModels[index].docno}');
                                    });
                                  }
                                }
                              },
                              child: Text(
                                'All: ${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()} [✔]',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  // fontWeight:
                                  //     FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _TransReBillModels.isEmpty
                ? SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        StreamBuilder(
                          stream: Stream.periodic(
                              const Duration(milliseconds: 25), (i) => i),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Text('');
                            double elapsed =
                                double.parse(snapshot.data.toString()) * 0.05;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (elapsed > 8.00)
                                  ? const Text(
                                      'No Data',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    )
                                  : Text(
                                      'Download : ${elapsed.toStringAsFixed(2)} s.',
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
                : GridView.builder(
                    controller: _scrollController2,
                    // controller: new ScrollController(keepScrollOffset: false),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _TransReBillModels.length,
                    itemBuilder: (context, index) => buidImageCard(index),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 8,
                      crossAxisCount: (MediaQuery.of(context).size.width < 300)
                          ? 2
                          : (MediaQuery.of(context).size.width < 500)
                              ? 3
                              : (MediaQuery.of(context).size.width < 1200)
                                  ? 6
                                  : (Responsive.isDesktop(context))
                                      ? 7
                                      : Responsive.isTablet(context)
                                          ? 3
                                          : 4,
                      mainAxisExtent: (MediaQuery.of(context).size.width < 300)
                          ? 100
                          : (MediaQuery.of(context).size.width < 500)
                              ? 200
                              : (MediaQuery.of(context).size.width < 700)
                                  ? 200
                                  : (MediaQuery.of(context).size.width < 1200)
                                      ? 250
                                      : 300, // itemHeight,
                    ),
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisCount: (MediaQuery.of(context).size.width < 300)
                    //       ? 3
                    //       : (Responsive.isDesktop(context))
                    //           ? 7
                    //           : 4,
                    //   mainAxisSpacing: 8,
                    //   crossAxisSpacing: 8,
                    // ),
                  ),
          ),
        ],
      ),
    );
  }

  ////////////------------------------------------------------------>(Export file)
  Future<void> _showMyDialog_SAVE_All(newValuePDFimg, Folder_File) async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    // String? TitleType_Default_Receipt_Name;
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
                                      TransReBill_select.clear();
                                    });

                                    Future.delayed(const Duration(seconds: 2));
                                    // Deleted_foder(context).then((value) {
                                    //   Future.delayed(
                                    //       const Duration(seconds: 2));
                                    //   Navigator.pop(context, 'OK');
                                    // });
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
                              child: Text(
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
                            Text(
                              'ดำเนินการ ทั้งหมด : ${TransReBill_select.length} รายการ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
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
                                        index < TransReBill_select.length;
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
                                          // print('stop/break ');
                                          setState(() {
                                            preferences.setString('name_page',
                                                '${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()}');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   Navigator.pop(context, 'OK');
                                          // });
                                          break innerloop_for;
                                        }
                                        var docno = TransReBill_select[index]
                                            .toString();
                                        setState(() {
                                          numinvoice =
                                              TransReBill_select[index];
                                          invoice_Now =
                                              'กำลังดำเนินการ (${index + 1} / ${TransReBill_select.length}) : ${TransReBill_select[index]}';
                                        });
                                        // var namenew = '';

                                        // String sname = _TransReBillModels[index]
                                        //             .sname ==
                                        //         null
                                        //     ? '${_TransReBillModels[index].remark}'
                                        //     : '${_TransReBillModels[index].sname}';
                                        // String cname =
                                        //     '${_TransReBillModels[index].cname}';
                                        // String addr =
                                        //     '${_TransReBillModels[index].addr}';
                                        // String tax =
                                        //     '${_TransReBillModels[index].tax}';
                                        // String room_number_BillHistory =
                                        //     '${_TransReBillModels[index].room_number}';
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (Folder_File == 'File') {
                                          await downloadImage_slip(
                                              '${MyConstant().domain}/files/$foder/slip/${_TransReBillModels[index].slip}',
                                              '${_TransReBillModels[index].docno}');
                                        } else {}

                                        setState(() {
                                          transReBill_loade_Success.add(
                                              TransReBill_select[index]
                                                  .toString());
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (index + 1 ==
                                            TransReBill_select.length) {
                                          await Future.delayed(const Duration(
                                              milliseconds: 400));
                                          setState(() {
                                            preferences.setString('name_page',
                                                'ใบเสร็จ_${(endIndex / limit)}of${(limitedList_TransReBillModels_.length / limit).ceil()}($MONTH_Now-$YEAR_Now)');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            TransReBill_select.clear();
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            // print('')

                                            Navigator.pop(context, 'OK');
                                            if (Folder_File! == 'Folder') {
                                              // Dialog_Download_Foder(context);
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
                                  child: const Center(
                                    child: Text(
                                      'ปิด',
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

  ///////////------------------------>
  @override
  Widget build(BuildContext context) {
    double calculatedWidth =
        (ac5.where((item) => item["st"] == '1').toList().length <= 9)
            ? MediaQuery.of(context).size.width * 0.89
            : MediaQuery.of(context).size.width * 0.89 +
                ((ac5.where((item) => item["st"] == '1').toList().length - 9) *
                    60);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context)) ? calculatedWidth : 1400,
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
                Container(
                    width: (Responsive.isDesktop(context))
                        ? calculatedWidth
                        : 1400,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Ser_Tap = 0;
                                    tappedIndex_ = '';
                                  });
                                  // select_coutumer();
                                },
                                child: Container(
                                  // width: 130,
                                  decoration: BoxDecoration(
                                    color: (Ser_Tap == 0)
                                        ? Colors.orange[600]
                                        : Colors.orange[200],
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSetText(
                                      "รายการ",
                                      (Ser_Tap == 0)
                                          ? Colors.white
                                          : Colors.black,
                                      TextAlign.start,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      12,
                                      1),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Ser_Tap = 1;
                                    tappedIndex_ = '';
                                  });
                                  // select_coutumer();
                                },
                                child: Container(
                                  // width: 130,
                                  decoration: BoxDecoration(
                                    color: (Ser_Tap == 1)
                                        ? Colors.orange[600]
                                        : Colors.orange[200],
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSetText(
                                      "หลักฐานการชำระ",
                                      (Ser_Tap == 1)
                                          ? Colors.white
                                          : Colors.black,
                                      TextAlign.start,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      12,
                                      1),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Ser_Tap = 2;
                                    tappedIndex_ = '';
                                  });
                                  // select_coutumer();
                                },
                                child: Container(
                                  // width: 130,
                                  decoration: BoxDecoration(
                                    color: (Ser_Tap == 2)
                                        ? Colors.orange[600]
                                        : Colors.orange[200],
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSetText(
                                      "ตรวจสอบ-Excel",
                                      (Ser_Tap == 2)
                                          ? Colors.white
                                          : Colors.black,
                                      TextAlign.start,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      12,
                                      1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        (Ser_Tap == 2)
                            ? Verifi_Exc_Pay(
                                transReChackBillModels:
                                    limitedList_TransReBillModels_,
                                MONTH_Now: MONTH_Now,
                                YEAR_Now: YEAR_Now)
                            : (Ser_Tap == 1)
                                ? Image_GridView(context)
                                : (Ser_Tap == 0)
                                    ? Account_BillPayVerifi()
                                    : SizedBox(),

                        // ScrollConfiguration(
                        //         behavior: ScrollConfiguration.of(context)
                        //             .copyWith(dragDevices: {
                        //           PointerDeviceKind.touch,
                        //           PointerDeviceKind.mouse,
                        //         }),
                        //         child: SingleChildScrollView(
                        //           scrollDirection: Axis.horizontal,
                        //           dragStartBehavior:
                        //               DragStartBehavior.start,
                        //           child: Row(
                        //             children: [
                        //               SizedBox(
                        //                 child: Column(
                        //                   children: [
                        //                     Container(
                        //                       width: (Responsive.isDesktop(
                        //                               context))
                        //                           ? calculatedWidth
                        //                           : 1200,
                        //                       decoration: BoxDecoration(
                        //                         color: AppbackgroundColor
                        //                             .TiTile_Colors,
                        //                         borderRadius:
                        //                             BorderRadius.only(
                        //                                 topLeft:
                        //                                     Radius.circular(
                        //                                         10),
                        //                                 topRight:
                        //                                     Radius.circular(
                        //                                         10),
                        //                                 bottomLeft:
                        //                                     Radius.circular(
                        //                                         0),
                        //                                 bottomRight:
                        //                                     Radius.circular(
                        //                                         0)),
                        //                       ),
                        //                       padding:
                        //                           const EdgeInsets.all(8.0),
                        //                       child: Column(
                        //                         children: [
                        //                           Padding(
                        //                             padding:
                        //                                 const EdgeInsets
                        //                                     .all(2.0),
                        //                             child: Row(
                        //                               children: [
                        //                                 Padding(
                        //                                   padding:
                        //                                       EdgeInsets
                        //                                           .all(2.0),
                        //                                   child: Translate.TranslateAndSetText(
                        //                                       'ค้นหา :',
                        //                                       AccountScreen_Color
                        //                                           .Colors_Text1_,
                        //                                       TextAlign
                        //                                           .start,
                        //                                       FontWeight
                        //                                           .bold,
                        //                                       FontWeight_
                        //                                           .Fonts_T,
                        //                                       14,
                        //                                       1),
                        //                                 ),
                        //                                 Expanded(
                        //                                   // flex: 1,
                        //                                   child: Container(
                        //                                     height:
                        //                                         35, //Date_ser
                        //                                     // width: 150,
                        //                                     decoration: (time_check.toString() ==
                        //                                                 '0' ||
                        //                                             time_check ==
                        //                                                 null)
                        //                                         ? BoxDecoration(
                        //                                             color: AppbackgroundColor
                        //                                                 .Sub_Abg_Colors,
                        //                                             borderRadius: const BorderRadius.only(
                        //                                                 topLeft:
                        //                                                     Radius.circular(8),
                        //                                                 topRight: Radius.circular(0),
                        //                                                 bottomLeft: Radius.circular(8),
                        //                                                 bottomRight: Radius.circular(0)),
                        //                                             border: Border.all(
                        //                                                 color:
                        //                                                     Colors.grey,
                        //                                                 width: 1),
                        //                                           )
                        //                                         : BoxDecoration(
                        //                                             color: AppbackgroundColor
                        //                                                 .Sub_Abg_Colors,
                        //                                             borderRadius: const BorderRadius.only(
                        //                                                 topLeft:
                        //                                                     Radius.circular(8),
                        //                                                 topRight: Radius.circular(0),
                        //                                                 bottomLeft: Radius.circular(8),
                        //                                                 bottomRight: Radius.circular(0)),
                        //                                             border: Border.all(
                        //                                                 color:
                        //                                                     Colors.grey,
                        //                                                 width: 1),
                        //                                           ),
                        //                                     child:
                        //                                         _searchBarMain1(),
                        //                                   ),
                        //                                 ),
                        //                                 Padding(
                        //                                   padding:
                        //                                       const EdgeInsets
                        //                                               .fromLTRB(
                        //                                           0,
                        //                                           2,
                        //                                           0,
                        //                                           2),
                        //                                   child: Container(
                        //                                     height: 35,
                        //                                     decoration:
                        //                                         BoxDecoration(
                        //                                       color: AppbackgroundColor
                        //                                           .Sub_Abg_Colors,
                        //                                       // .withOpacity(0.5),
                        //                                       borderRadius: BorderRadius.only(
                        //                                           topLeft: Radius
                        //                                               .circular(
                        //                                                   0),
                        //                                           topRight:
                        //                                               Radius.circular(
                        //                                                   6),
                        //                                           bottomLeft:
                        //                                               Radius.circular(
                        //                                                   0),
                        //                                           bottomRight:
                        //                                               Radius.circular(
                        //                                                   6)),
                        //                                       // border: Border.all(
                        //                                       //     color:
                        //                                       //         Colors.grey,
                        //                                       //     width: 1),
                        //                                     ),
                        //                                     width: 130,
                        //                                     // height: 30,
                        //                                     padding:
                        //                                         const EdgeInsets
                        //                                                 .all(
                        //                                             2.0),
                        //                                     child:
                        //                                         DropdownButtonHideUnderline(
                        //                                       child:
                        //                                           DropdownButton2<
                        //                                               String>(
                        //                                         isExpanded:
                        //                                             true,
                        //                                         hint:
                        //                                             Center(
                        //                                           child:
                        //                                               Text(
                        //                                             'หัวข้อ',
                        //                                             style:
                        //                                                 const TextStyle(
                        //                                               fontSize:
                        //                                                   14,
                        //                                               color:
                        //                                                   AccountScreen_Color.Colors_Text1_,
                        //                                               fontWeight:
                        //                                                   FontWeight.bold,
                        //                                               fontFamily:
                        //                                                   Font_.Fonts_T,
                        //                                             ),
                        //                                           ),
                        //                                         ),

                        //                                         items: ac5
                        //                                             .asMap()
                        //                                             .entries
                        //                                             .map(
                        //                                                 (entry) {
                        //                                           int index =
                        //                                               entry
                        //                                                   .key; // Get the index
                        //                                           var item =
                        //                                               entry
                        //                                                   .value;
                        //                                           return DropdownMenuItem<
                        //                                               String>(
                        //                                             value: item[
                        //                                                 "ser"], // Use "ser" as the value
                        //                                             enabled:
                        //                                                 false, // Set to true to allow selection
                        //                                             child:
                        //                                                 StatefulBuilder(
                        //                                               builder:
                        //                                                   (context, menuSetState) {
                        //                                                 // final isSelected = selectedItems.contains(item);
                        //                                                 return InkWell(
                        //                                                   onTap: () {
                        //                                                     int selectedIndex = ac5.indexWhere((items) => items["ser"] == item["ser"]);
                        //                                                     // print(ac1[selectedIndex]
                        //                                                     //     [
                        //                                                     //     "pn"]);
                        //                                                     // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                        //                                                     //This rebuilds the StatefulWidget to update the button's text
                        //                                                     setState(() {
                        //                                                       if (item["st"]! == '1') {
                        //                                                         ac5[selectedIndex]["st"] = '0';
                        //                                                       } else {
                        //                                                         ac5[selectedIndex]["st"] = '1';
                        //                                                       }
                        //                                                     });
                        //                                                     //This rebuilds the dropdownMenu Widget to update the check mark
                        //                                                     menuSetState(() {});
                        //                                                   },
                        //                                                   child: Container(
                        //                                                     height: double.infinity,
                        //                                                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        //                                                     child: Row(
                        //                                                       children: [
                        //                                                         if (item["st"]! == '1')
                        //                                                           Icon(
                        //                                                             Icons.check_box_outlined,
                        //                                                             color: Colors.green[400],
                        //                                                           )
                        //                                                         else
                        //                                                           const Icon(Icons.check_box_outline_blank),
                        //                                                         Expanded(
                        //                                                           child: Text(
                        //                                                             item["pn"]!,
                        //                                                             maxLines: 2,
                        //                                                             style: const TextStyle(
                        //                                                               fontSize: 12,
                        //                                                               color: AccountScreen_Color.Colors_Text1_,
                        //                                                               fontWeight: FontWeight.w600,
                        //                                                               fontFamily: Font_.Fonts_T,
                        //                                                             ),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ],
                        //                                                     ),
                        //                                                   ),
                        //                                                 );
                        //                                               },
                        //                                             ),
                        //                                           );
                        //                                         }).toList(),
                        //                                         //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                        //                                         // value: selectedItems.isEmpty ? null : selectedItems.last,
                        //                                         onChanged:
                        //                                             (value) {},
                        //                                       ),
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                                 Row(
                        //                                   mainAxisAlignment:
                        //                                       MainAxisAlignment
                        //                                           .end,
                        //                                   children: [
                        //                                     if (time_check
                        //                                                 .toString() !=
                        //                                             '0' &&
                        //                                         time_check !=
                        //                                             null)
                        //                                       if (renTal_Ser
                        //                                               .toString() !=
                        //                                           '106')
                        //                                         Padding(
                        //                                           padding:
                        //                                               const EdgeInsets.fromLTRB(
                        //                                                   0,
                        //                                                   4,
                        //                                                   4,
                        //                                                   4),
                        //                                           child:
                        //                                               Container(
                        //                                             decoration:
                        //                                                 BoxDecoration(
                        //                                               color:
                        //                                                   Colors.deepOrange[100],
                        //                                               borderRadius: const BorderRadius.only(
                        //                                                   topLeft: Radius.circular(0),
                        //                                                   topRight: Radius.circular(8),
                        //                                                   bottomLeft: Radius.circular(0),
                        //                                                   bottomRight: Radius.circular(8)),
                        //                                               // border: Border.all(
                        //                                               //     color: Colors
                        //                                               //         .grey,
                        //                                               //     width:
                        //                                               //         1),
                        //                                             ),
                        //                                             padding:
                        //                                                 EdgeInsets.all(2.0),
                        //                                             child:
                        //                                                 Row(
                        //                                               children: [
                        //                                                 Padding(
                        //                                                   padding: EdgeInsets.all(2.0),
                        //                                                   child: Text(
                        //                                                     'Check Auto',
                        //                                                     style: TextStyle(
                        //                                                       fontSize: 12,
                        //                                                       color: ReportScreen_Color.Colors_Text2_,
                        //                                                       // fontWeight: FontWeight.bold,
                        //                                                       fontFamily: Font_.Fonts_T,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 InkWell(
                        //                                                   onTap: () async {
                        //                                                     SharedPreferences preferences = await SharedPreferences.getInstance();
                        //                                                     if (Auto_cancel.toString() == 'Yes') {
                        //                                                       preferences.setString('Auto_cancel', 'No');
                        //                                                     } else {
                        //                                                       preferences.setString('Auto_cancel', 'Yes');
                        //                                                     }
                        //                                                     String? _route = preferences.getString('route');
                        //                                                     MaterialPageRoute materialPageRoute = MaterialPageRoute(builder: (BuildContext context) => AdminScafScreen(route: _route));
                        //                                                     Navigator.pushAndRemoveUntil(context, materialPageRoute, (route) => false);
                        //                                                   },
                        //                                                   child: (Auto_cancel.toString() == 'Yes')
                        //                                                       ? Icon(
                        //                                                           Icons.toggle_on,
                        //                                                           color: Colors.green,
                        //                                                           size: 25,
                        //                                                         )
                        //                                                       : Icon(
                        //                                                           Icons.toggle_off,
                        //                                                           color: Colors.black87,
                        //                                                           size: 30,
                        //                                                         ),
                        //                                                 ),
                        //                                                 // Icon(
                        //                                                 //   Icons.toggle_on,
                        //                                                 //   color: Colors
                        //                                                 //       .green,
                        //                                                 //   size: 25,
                        //                                                 // ),
                        //                                               ],
                        //                                             ),
                        //                                           ),
                        //                                         ),
                        //                                     Container(
                        //                                         width: 150,
                        //                                         child:
                        //                                             Next_page())
                        //                                   ],
                        //                                 ),
                        //                                 // Container(
                        //                                 //     width: 150,
                        //                                 //     child: Next_page())
                        //                                 // Expanded(
                        //                                 //     child:
                        //                                 //         Next_page_billCancel())
                        //                               ],
                        //                             ),
                        //                           ),
                        //                           const Divider(),
                        //                           SizedBox(
                        //                             width: (Responsive
                        //                                     .isDesktop(
                        //                                         context))
                        //                                 ? calculatedWidth
                        //                                 : 1200,
                        //                             child: Row(
                        //                               children: [
                        //                                 // if (api_key == 'Y' &&
                        //                                 //     renTal_Ser
                        //                                 //             .toString() ==
                        //                                 //         '106')
                        //                                 //   Expanded(
                        //                                 //     flex: 4,
                        //                                 //     child: SizedBox(),
                        //                                 //   ),
                        //                                 Expanded(
                        //                                   flex: 6,
                        //                                   // color: Colors.red,
                        //                                   // width: 300,
                        //                                   // height: 50,
                        //                                   child:
                        //                                       ScrollConfiguration(
                        //                                     behavior: ScrollConfiguration.of(
                        //                                             context)
                        //                                         .copyWith(
                        //                                             dragDevices: {
                        //                                           PointerDeviceKind
                        //                                               .touch,
                        //                                           PointerDeviceKind
                        //                                               .mouse,
                        //                                         }),
                        //                                     child:
                        //                                         SingleChildScrollView(
                        //                                       scrollDirection:
                        //                                           Axis.horizontal,
                        //                                       dragStartBehavior:
                        //                                           DragStartBehavior
                        //                                               .start,
                        //                                       child: Row(
                        //                                         children: [
                        //                                           Container(
                        //                                             decoration:
                        //                                                 BoxDecoration(
                        //                                               color:
                        //                                                   AppbackgroundColor.Sub_Abg_Colors.withOpacity(0.5),
                        //                                               borderRadius: const BorderRadius.only(
                        //                                                   topLeft: Radius.circular(10),
                        //                                                   topRight: Radius.circular(10),
                        //                                                   bottomLeft: Radius.circular(10),
                        //                                                   bottomRight: Radius.circular(10)),
                        //                                               // border: Border.all(color: Colors.white, width: 1),
                        //                                             ),
                        //                                             child:
                        //                                                 Row(
                        //                                               children: [
                        //                                                 Padding(
                        //                                                   padding: EdgeInsets.all(2.0),
                        //                                                   child: Translate.TranslateAndSetText('เดือน :', AccountScreen_Color.Colors_Text1_, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: const EdgeInsets.all(2.0),
                        //                                                   child: Container(
                        //                                                     decoration: const BoxDecoration(
                        //                                                       color: AppbackgroundColor.Sub_Abg_Colors,
                        //                                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                       // border: Border.all(color: Colors.grey, width: 1),
                        //                                                     ),
                        //                                                     width: 120,
                        //                                                     padding: const EdgeInsets.all(2.0),
                        //                                                     child: DropdownButtonFormField2(
                        //                                                       alignment: Alignment.center,
                        //                                                       focusColor: Colors.white,
                        //                                                       autofocus: false,
                        //                                                       decoration: InputDecoration(
                        //                                                         floatingLabelAlignment: FloatingLabelAlignment.center,
                        //                                                         enabled: true,
                        //                                                         hoverColor: Colors.brown,
                        //                                                         prefixIconColor: Colors.blue,
                        //                                                         fillColor: Colors.white.withOpacity(0.05),
                        //                                                         filled: false,
                        //                                                         isDense: true,
                        //                                                         contentPadding: EdgeInsets.zero,
                        //                                                         border: OutlineInputBorder(
                        //                                                           borderSide: const BorderSide(color: Colors.red),
                        //                                                           borderRadius: BorderRadius.circular(10),
                        //                                                         ),
                        //                                                         focusedBorder: const OutlineInputBorder(
                        //                                                           borderRadius: BorderRadius.only(
                        //                                                             topRight: Radius.circular(10),
                        //                                                             topLeft: Radius.circular(10),
                        //                                                             bottomRight: Radius.circular(10),
                        //                                                             bottomLeft: Radius.circular(10),
                        //                                                           ),
                        //                                                           borderSide: BorderSide(
                        //                                                             width: 1,
                        //                                                             color: Color.fromARGB(255, 231, 227, 227),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ),
                        //                                                       isExpanded: false,
                        //                                                       //value: MONTH_Now,
                        //                                                       hint: Translate.TranslateAndSetText(MONTH_Now == null ? 'เลือก-Select' : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                       //  Text(
                        //                                                       //   MONTH_Now == null
                        //                                                       //       ? 'เลือก'
                        //                                                       //       : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                        //                                                       //   maxLines: 2,
                        //                                                       //   textAlign:
                        //                                                       //       TextAlign
                        //                                                       //           .center,
                        //                                                       //   style:
                        //                                                       //       const TextStyle(
                        //                                                       //     overflow:
                        //                                                       //         TextOverflow
                        //                                                       //             .ellipsis,
                        //                                                       //     fontSize: 12,
                        //                                                       //     color:
                        //                                                       //         Colors.grey,
                        //                                                       //   ),
                        //                                                       // ),
                        //                                                       icon: const Icon(
                        //                                                         Icons.arrow_drop_down,
                        //                                                         color: Colors.black,
                        //                                                       ),
                        //                                                       style: const TextStyle(
                        //                                                         color: Colors.grey,
                        //                                                       ),
                        //                                                       iconSize: 20,
                        //                                                       buttonHeight: 30,
                        //                                                       buttonWidth: 200,
                        //                                                       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                        //                                                       dropdownDecoration: BoxDecoration(
                        //                                                         // color: Colors
                        //                                                         //     .amber,
                        //                                                         borderRadius: BorderRadius.circular(10),
                        //                                                         border: Border.all(color: Colors.white, width: 1),
                        //                                                       ),
                        //                                                       items: [
                        //                                                         for (int item = 1; item < 13; item++)
                        //                                                           DropdownMenuItem<String>(
                        //                                                             value: '${item}',
                        //                                                             child: Translate.TranslateAndSetText('${monthsInThai[item - 1]}', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                             // Text(
                        //                                                             //   '${monthsInThai[item - 1]}',
                        //                                                             //   // '${item}',
                        //                                                             //   textAlign:
                        //                                                             //       TextAlign
                        //                                                             //           .center,
                        //                                                             //   style:
                        //                                                             //       const TextStyle(
                        //                                                             //     overflow:
                        //                                                             //         TextOverflow
                        //                                                             //             .ellipsis,
                        //                                                             //     fontSize:
                        //                                                             //         14,
                        //                                                             //     color: Colors
                        //                                                             //         .grey,
                        //                                                             //   ),
                        //                                                             // ),
                        //                                                           )
                        //                                                       ],

                        //                                                       onChanged: (value) async {
                        //                                                         MONTH_Now = value;
                        //                                                         red_Trans_bill();
                        //                                                         // if (Value_Chang_Zone_Income !=
                        //                                                         //     null) {
                        //                                                         //   red_Trans_billIncome();
                        //                                                         //   red_Trans_billMovemen();
                        //                                                         // }
                        //                                                       },
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: EdgeInsets.all(2.0),
                        //                                                   child: Translate.TranslateAndSetText('ปี :', AccountScreen_Color.Colors_Text1_, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                   // Text(
                        //                                                   //   'ปี :',
                        //                                                   //   style: TextStyle(
                        //                                                   //     color: ReportScreen_Color
                        //                                                   //         .Colors_Text2_,
                        //                                                   //     // fontWeight: FontWeight.bold,
                        //                                                   //     fontFamily:
                        //                                                   //         Font_.Fonts_T,
                        //                                                   //   ),
                        //                                                   // ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: const EdgeInsets.all(2.0),
                        //                                                   child: Container(
                        //                                                     decoration: const BoxDecoration(
                        //                                                       color: AppbackgroundColor.Sub_Abg_Colors,
                        //                                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                       // border: Border.all(color: Colors.grey, width: 1),
                        //                                                     ),
                        //                                                     width: 120,
                        //                                                     padding: const EdgeInsets.all(2.0),
                        //                                                     child: DropdownButtonFormField2(
                        //                                                       alignment: Alignment.center,
                        //                                                       focusColor: Colors.white,
                        //                                                       autofocus: false,
                        //                                                       decoration: InputDecoration(
                        //                                                         floatingLabelAlignment: FloatingLabelAlignment.center,
                        //                                                         enabled: true,
                        //                                                         hoverColor: Colors.brown,
                        //                                                         prefixIconColor: Colors.blue,
                        //                                                         fillColor: Colors.white.withOpacity(0.05),
                        //                                                         filled: false,
                        //                                                         isDense: true,
                        //                                                         contentPadding: EdgeInsets.zero,
                        //                                                         border: OutlineInputBorder(
                        //                                                           borderSide: const BorderSide(color: Colors.red),
                        //                                                           borderRadius: BorderRadius.circular(10),
                        //                                                         ),
                        //                                                         focusedBorder: const OutlineInputBorder(
                        //                                                           borderRadius: BorderRadius.only(
                        //                                                             topRight: Radius.circular(10),
                        //                                                             topLeft: Radius.circular(10),
                        //                                                             bottomRight: Radius.circular(10),
                        //                                                             bottomLeft: Radius.circular(10),
                        //                                                           ),
                        //                                                           borderSide: BorderSide(
                        //                                                             width: 1,
                        //                                                             color: Color.fromARGB(255, 231, 227, 227),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ),
                        //                                                       isExpanded: false,
                        //                                                       // value: YEAR_Now,
                        //                                                       hint: Text(
                        //                                                         YEAR_Now == null ? 'เลือก-Select' : '$YEAR_Now',
                        //                                                         maxLines: 2,
                        //                                                         textAlign: TextAlign.center,
                        //                                                         style: const TextStyle(
                        //                                                           overflow: TextOverflow.ellipsis,
                        //                                                           fontSize: 12,
                        //                                                           color: Colors.grey,
                        //                                                         ),
                        //                                                       ),
                        //                                                       icon: const Icon(
                        //                                                         Icons.arrow_drop_down,
                        //                                                         color: Colors.black,
                        //                                                       ),
                        //                                                       style: const TextStyle(
                        //                                                         color: Colors.grey,
                        //                                                       ),
                        //                                                       iconSize: 20,
                        //                                                       buttonHeight: 30,
                        //                                                       buttonWidth: 200,
                        //                                                       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                        //                                                       dropdownDecoration: BoxDecoration(
                        //                                                         // color: Colors
                        //                                                         //     .amber,
                        //                                                         borderRadius: BorderRadius.circular(10),
                        //                                                         border: Border.all(color: Colors.white, width: 1),
                        //                                                       ),
                        //                                                       items: YE_Th.map((item) => DropdownMenuItem<String>(
                        //                                                             value: '${item}',
                        //                                                             child: Text(
                        //                                                               '${item}',
                        //                                                               textAlign: TextAlign.center,
                        //                                                               style: const TextStyle(
                        //                                                                 overflow: TextOverflow.ellipsis,
                        //                                                                 fontSize: 14,
                        //                                                                 color: Colors.grey,
                        //                                                               ),
                        //                                                             ),
                        //                                                           )).toList(),

                        //                                                       onChanged: (value) async {
                        //                                                         YEAR_Now = value;
                        //                                                         red_Trans_bill();
                        //                                                         // if (Value_Chang_Zone_Income !=
                        //                                                         //     null) {
                        //                                                         //   red_Trans_billIncome();
                        //                                                         //   red_Trans_billMovemen();
                        //                                                         // }
                        //                                                       },
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: EdgeInsets.all(2.0),
                        //                                                   child: Translate.TranslateAndSetText('ระบบ :', AccountScreen_Color.Colors_Text1_, TextAlign.start, null, Font_.Fonts_T, 12, 1),

                        //                                                   // Text(
                        //                                                   //   'ระบบ :',
                        //                                                   //   style: TextStyle(
                        //                                                   //     color: ReportScreen_Color
                        //                                                   //         .Colors_Text2_,
                        //                                                   //     // fontWeight: FontWeight.bold,
                        //                                                   //     fontFamily:
                        //                                                   //         Font_.Fonts_T,
                        //                                                   //   ),
                        //                                                   // ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: const EdgeInsets.all(2.0),
                        //                                                   child: Container(
                        //                                                     decoration: const BoxDecoration(
                        //                                                       color: AppbackgroundColor.Sub_Abg_Colors,
                        //                                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                       // border: Border.all(color: Colors.grey, width: 1),
                        //                                                     ),
                        //                                                     width: 200,
                        //                                                     padding: const EdgeInsets.all(2.0),
                        //                                                     child: DropdownButtonFormField2(
                        //                                                       alignment: Alignment.center,
                        //                                                       focusColor: Colors.white,
                        //                                                       autofocus: false,
                        //                                                       decoration: InputDecoration(
                        //                                                         floatingLabelAlignment: FloatingLabelAlignment.center,
                        //                                                         enabled: true,
                        //                                                         hoverColor: Colors.brown,
                        //                                                         prefixIconColor: Colors.blue,
                        //                                                         fillColor: Colors.white.withOpacity(0.05),
                        //                                                         filled: false,
                        //                                                         isDense: true,
                        //                                                         contentPadding: EdgeInsets.zero,
                        //                                                         border: OutlineInputBorder(
                        //                                                           borderSide: const BorderSide(color: Colors.red),
                        //                                                           borderRadius: BorderRadius.circular(10),
                        //                                                         ),
                        //                                                         focusedBorder: const OutlineInputBorder(
                        //                                                           borderRadius: BorderRadius.only(
                        //                                                             topRight: Radius.circular(10),
                        //                                                             topLeft: Radius.circular(10),
                        //                                                             bottomRight: Radius.circular(10),
                        //                                                             bottomLeft: Radius.circular(10),
                        //                                                           ),
                        //                                                           borderSide: BorderSide(
                        //                                                             width: 1,
                        //                                                             color: Color.fromARGB(255, 231, 227, 227),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ),
                        //                                                       isExpanded: false,
                        //                                                       // value: YEAR_Now,
                        //                                                       hint: Translate.TranslateAndSetText('ทั้งหมด', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                       // Text(
                        //                                                       //   (ser_payby ==
                        //                                                       //               null ||
                        //                                                       //           ser_payby ==
                        //                                                       //               '0')
                        //                                                       //       ? 'ทั้งหมด-All'
                        //                                                       //       : '$ser_payby',
                        //                                                       //   maxLines: 2,
                        //                                                       //   textAlign:
                        //                                                       //       TextAlign
                        //                                                       //           .center,
                        //                                                       //   style:
                        //                                                       //       const TextStyle(
                        //                                                       //     overflow:
                        //                                                       //         TextOverflow
                        //                                                       //             .ellipsis,
                        //                                                       //     fontSize: 12,
                        //                                                       //     color:
                        //                                                       //         Colors.grey,
                        //                                                       //   ),
                        //                                                       // ),
                        //                                                       icon: const Icon(
                        //                                                         Icons.arrow_drop_down,
                        //                                                         color: Colors.black,
                        //                                                       ),
                        //                                                       style: const TextStyle(
                        //                                                         color: Colors.grey,
                        //                                                       ),
                        //                                                       iconSize: 20,
                        //                                                       buttonHeight: 30,
                        //                                                       buttonWidth: 200,
                        //                                                       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                        //                                                       dropdownDecoration: BoxDecoration(
                        //                                                         // color: Colors
                        //                                                         //     .amber,
                        //                                                         borderRadius: BorderRadius.circular(10),
                        //                                                         border: Border.all(color: Colors.white, width: 1),
                        //                                                       ),
                        //                                                       items: [
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '0',
                        //                                                           child: Translate.TranslateAndSetText('ทั้งหมด', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                        //                                                           //  Text(
                        //                                                           //   'ทั้งหมด',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '1',
                        //                                                           child: Translate.TranslateAndSetText('Web Admin(W)', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                           // Text(
                        //                                                           //   'เว็ป หลักแอดมิน(W)',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '2',
                        //                                                           child: Translate.TranslateAndSetText('Web User(U)', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                           //  Text(
                        //                                                           //   'เว็ป User(U)',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '3',
                        //                                                           child: Translate.TranslateAndSetText('Web Market(LP)', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                           //  Text(
                        //                                                           //   'เว็ป Market(LP)',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '4',
                        //                                                           child: Translate.TranslateAndSetText('Handheld(H)', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                        //                                                           // Text(
                        //                                                           //   'เครื่อง Handheld(H)',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         )
                        //                                                       ],

                        //                                                       onChanged: (value) async {
                        //                                                         setState(() {
                        //                                                           ser_payby = value;
                        //                                                         });

                        //                                                         // print(value);
                        //                                                         red_Trans_bill();
                        //                                                         // if (Value_Chang_Zone_Income !=
                        //                                                         //     null) {
                        //                                                         //   red_Trans_billIncome();
                        //                                                         //   red_Trans_billMovemen();
                        //                                                         // }
                        //                                                       },
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: EdgeInsets.all(2.0),
                        //                                                   child: Translate.TranslateAndSetText('เรียงจาก :', AccountScreen_Color.Colors_Text1_, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                        //                                                   // Text(
                        //                                                   //   'เรียงจาก :',
                        //                                                   //   style: TextStyle(
                        //                                                   //     color: ReportScreen_Color
                        //                                                   //         .Colors_Text2_,
                        //                                                   //     // fontWeight: FontWeight.bold,
                        //                                                   //     fontFamily:
                        //                                                   //         Font_.Fonts_T,
                        //                                                   //   ),
                        //                                                   // ),
                        //                                                 ),
                        //                                                 Padding(
                        //                                                   padding: const EdgeInsets.all(2.0),
                        //                                                   child: Container(
                        //                                                     decoration: const BoxDecoration(
                        //                                                       color: AppbackgroundColor.Sub_Abg_Colors,
                        //                                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                       // border: Border.all(color: Colors.grey, width: 1),
                        //                                                     ),
                        //                                                     width: 160,
                        //                                                     padding: const EdgeInsets.all(2.0),
                        //                                                     child: DropdownButtonFormField2(
                        //                                                       alignment: Alignment.center,
                        //                                                       focusColor: Colors.white,
                        //                                                       autofocus: false,
                        //                                                       decoration: InputDecoration(
                        //                                                         floatingLabelAlignment: FloatingLabelAlignment.center,
                        //                                                         enabled: true,
                        //                                                         hoverColor: Colors.brown,
                        //                                                         prefixIconColor: Colors.blue,
                        //                                                         fillColor: Colors.white.withOpacity(0.05),
                        //                                                         filled: false,
                        //                                                         isDense: true,
                        //                                                         contentPadding: EdgeInsets.zero,
                        //                                                         border: OutlineInputBorder(
                        //                                                           borderSide: const BorderSide(color: Colors.red),
                        //                                                           borderRadius: BorderRadius.circular(10),
                        //                                                         ),
                        //                                                         focusedBorder: const OutlineInputBorder(
                        //                                                           borderRadius: BorderRadius.only(
                        //                                                             topRight: Radius.circular(10),
                        //                                                             topLeft: Radius.circular(10),
                        //                                                             bottomRight: Radius.circular(10),
                        //                                                             bottomLeft: Radius.circular(10),
                        //                                                           ),
                        //                                                           borderSide: BorderSide(
                        //                                                             width: 1,
                        //                                                             color: Color.fromARGB(255, 231, 227, 227),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ),
                        //                                                       isExpanded: false,
                        //                                                       // value: YEAR_Now,
                        //                                                       hint: Translate.TranslateAndSetText('เลขที่ใบเสร็จ', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                       // Text(
                        //                                                       //   'เลขที่ใบเสร็จ',
                        //                                                       //   maxLines: 2,
                        //                                                       //   textAlign:
                        //                                                       //       TextAlign
                        //                                                       //           .center,
                        //                                                       //   style:
                        //                                                       //       const TextStyle(
                        //                                                       //     overflow:
                        //                                                       //         TextOverflow
                        //                                                       //             .ellipsis,
                        //                                                       //     fontSize: 12,
                        //                                                       //     color:
                        //                                                       //         Colors.grey,
                        //                                                       //   ),
                        //                                                       // ),
                        //                                                       icon: const Icon(
                        //                                                         Icons.arrow_drop_down,
                        //                                                         // Icons.sort_rounded,
                        //                                                         color: Colors.black,
                        //                                                       ),
                        //                                                       style: const TextStyle(
                        //                                                         color: Colors.grey,
                        //                                                       ),
                        //                                                       iconSize: 20,
                        //                                                       buttonHeight: 30,
                        //                                                       buttonWidth: 160,
                        //                                                       // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                        //                                                       dropdownDecoration: BoxDecoration(
                        //                                                         // color: Colors
                        //                                                         //     .amber,
                        //                                                         borderRadius: BorderRadius.circular(10),
                        //                                                         border: Border.all(color: Colors.white, width: 1),
                        //                                                       ),
                        //                                                       items: [
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '0',
                        //                                                           child: Translate.TranslateAndSetText('เลขที่ใบเสร็จ', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                           //  Text(
                        //                                                           //   'เลขที่ใบเสร็จ',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       const TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '1',
                        //                                                           child: Translate.TranslateAndSetText('เลขที่สัญญา', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                           // Text(
                        //                                                           //   'เลขที่สัญญา',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       const TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '2',
                        //                                                           child: Translate.TranslateAndSetText('วันที่ทำรายการ', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                           //  Text(
                        //                                                           //   'วันที่ทำรายการ',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       const TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '3',
                        //                                                           child: Translate.TranslateAndSetText('วันที่จอง-ล็อกเสียบ', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                           // Text(
                        //                                                           //   'วันที่จอง-ล็อกเสียบ',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       const TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                         DropdownMenuItem<String>(
                        //                                                           value: '4',
                        //                                                           child: Translate.TranslateAndSetText('วันที่รับชำระ', Colors.grey, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                           //  Text(
                        //                                                           //   'วันที่รับชำระ',
                        //                                                           //   textAlign:
                        //                                                           //       TextAlign
                        //                                                           //           .center,
                        //                                                           //   style:
                        //                                                           //       const TextStyle(
                        //                                                           //     overflow:
                        //                                                           //         TextOverflow
                        //                                                           //             .ellipsis,
                        //                                                           //     fontSize:
                        //                                                           //         14,
                        //                                                           //     color: Colors
                        //                                                           //         .grey,
                        //                                                           //   ),
                        //                                                           // ),
                        //                                                         ),
                        //                                                       ],

                        //                                                       onChanged: (value) async {
                        //                                                         if (value.toString() == '0') {
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => b.docno!.compareTo(a.docno!));
                        //                                                         } else if (value.toString() == '1') {
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => b.cid!.compareTo(a.cid!));
                        //                                                         } else if (value.toString() == '2') {
                        //                                                           //DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => DateTime.parse(b.daterec!).compareTo(DateTime.parse(a.daterec!)));
                        //                                                           // InvoiceModels.sort((a, b) => b.daterec!.compareTo(a.daterec!));
                        //                                                         } else if (value.toString() == '3') {
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => DateTime.parse(b.date!).compareTo(DateTime.parse(a.date!)));
                        //                                                           // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
                        //                                                         } else if (value.toString() == '4') {
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => DateTime.parse(b.pdate!).compareTo(DateTime.parse(a.pdate!)));
                        //                                                           // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
                        //                                                         } else {
                        //                                                           limitedList_TransReBillModels_.sort((a, b) => b.docno!.compareTo(a.docno!));
                        //                                                         }
                        //                                                         setState(() {
                        //                                                           // _TransReBillModels = limitedList_TransReBillModels_
                        //                                                           _TransReBillModels = limitedList_TransReBillModels_;
                        //                                                         });
                        //                                                         read_TransReBill_limit();
                        //                                                       },
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                               ],
                        //                                             ),
                        //                                           ),
                        //                                         ],
                        //                                       ),
                        //                                     ),
                        //                                   ),
                        //                                 ),

                        //                                 Expanded(
                        //                                   flex: 4,
                        //                                   child:
                        //                                       ScrollConfiguration(
                        //                                     behavior: ScrollConfiguration.of(
                        //                                             context)
                        //                                         .copyWith(
                        //                                             dragDevices: {
                        //                                           PointerDeviceKind
                        //                                               .touch,
                        //                                           PointerDeviceKind
                        //                                               .mouse,
                        //                                         }),
                        //                                     child: Row(
                        //                                       mainAxisAlignment:
                        //                                           MainAxisAlignment
                        //                                               .end,
                        //                                       crossAxisAlignment:
                        //                                           CrossAxisAlignment
                        //                                               .end,
                        //                                       children: [
                        //                                         if (time_check.toString() != '0' &&
                        //                                             time_check.toString() !=
                        //                                                 '' &&
                        //                                             time_check !=
                        //                                                 null &&
                        //                                             renTal_Ser.toString() !=
                        //                                                 '106')
                        //                                           Padding(
                        //                                             padding: const EdgeInsets.fromLTRB(
                        //                                                 4,
                        //                                                 2,
                        //                                                 4,
                        //                                                 2),
                        //                                             child:
                        //                                                 Align(
                        //                                               alignment:
                        //                                                   Alignment.centerRight,
                        //                                               child:
                        //                                                   Row(
                        //                                                 mainAxisAlignment:
                        //                                                     MainAxisAlignment.end,
                        //                                                 children: [
                        //                                                   // Spacer(),
                        //                                                   // Container(
                        //                                                   //   // width: 150,
                        //                                                   //   // color: Colors.green,
                        //                                                   //   decoration: BoxDecoration(
                        //                                                   //     color: Colors.deepOrange[400],
                        //                                                   //     borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(0), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(0)),
                        //                                                   //     // border: Border.all(
                        //                                                   //     //     color: Colors
                        //                                                   //     //         .grey,
                        //                                                   //     //     width: 1),
                        //                                                   //   ),
                        //                                                   //   child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.lock_clock)),
                        //                                                   // ),
                        //                                                   Container(
                        //                                                     // width:
                        //                                                     //     300,
                        //                                                     // color: Colors.green,
                        //                                                     decoration: BoxDecoration(
                        //                                                       color: Colors.deepOrange[400],
                        //                                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                       // border: Border.all(
                        //                                                       //     color: Colors
                        //                                                       //         .grey,
                        //                                                       //     width: 1),
                        //                                                     ),
                        //                                                     child: Row(
                        //                                                       children: [
                        //                                                         Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.lock_clock)),
                        //                                                         Padding(
                        //                                                           padding: const EdgeInsets.all(4.0),
                        //                                                           child: TextButton(
                        //                                                             onPressed: () async {
                        //                                                               setState(() {
                        //                                                                 Count_time_check = 0;
                        //                                                               });
                        //                                                               for (int index1 = 0; index1 < limitedList_TransReBillModels_.length; index1++) {
                        //                                                                 var date_x = '${limitedList_TransReBillModels_[index1].dateacc}';
                        //                                                                 var time_x = '${limitedList_TransReBillModels_[index1].timex}';
                        //                                                                 if (limitedList_TransReBillModels_[index1].slip == null || limitedList_TransReBillModels_[index1].slip.toString() == 'null' || limitedList_TransReBillModels_[index1].slip.toString() == '') {
                        //                                                                   // checkTimeDifference(
                        //                                                                   //     date_x,
                        //                                                                   //     time_x);
                        //                                                                   if (checkTimeDifference(date_x, time_x) == true) {
                        //                                                                     setState(() {
                        //                                                                       Count_time_check = Count_time_check + 1;
                        //                                                                     });
                        //                                                                   }
                        //                                                                 }
                        //                                                               }
                        //                                                               generateRandomString();
                        //                                                               showDialog<String>(
                        //                                                                   context: context,
                        //                                                                   builder: (BuildContext context) => AlertDialog(
                        //                                                                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                        //                                                                         backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                        //                                                                         titlePadding: const EdgeInsets.all(0.0),
                        //                                                                         contentPadding: const EdgeInsets.all(10.0),
                        //                                                                         actionsPadding: const EdgeInsets.all(6.0),
                        //                                                                         title: Column(
                        //                                                                           mainAxisAlignment: MainAxisAlignment.center,
                        //                                                                           crossAxisAlignment: CrossAxisAlignment.center,
                        //                                                                           children: [
                        //                                                                             Row(
                        //                                                                               mainAxisAlignment: MainAxisAlignment.end,
                        //                                                                               children: [
                        //                                                                                 InkWell(
                        //                                                                                   onTap: () {
                        //                                                                                     setState(() {
                        //                                                                                       Formbecause_.clear();
                        //                                                                                     });
                        //                                                                                     Navigator.pop(context, 'OK');
                        //                                                                                   },
                        //                                                                                   child: Padding(
                        //                                                                                     padding: const EdgeInsets.all(4.0),
                        //                                                                                     child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                        //                                                                                   ),
                        //                                                                                 ),
                        //                                                                               ],
                        //                                                                             ),
                        //                                                                             Translate.TranslateAndSetText('ยกเลิกรายการ ที่เกิน ${time_check} นาที', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                        //                                                                             Translate.TranslateAndSetText('( รายการ ที่ไม่พบ Slip )', Colors.grey, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                        //                                                                             Translate.TranslateAndSetText('# พบทั้งหมด ${Count_time_check} จาก ${limitedList_TransReBillModels_.length} รายการ', Colors.deepOrange[400], TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                        //                                                                             const Divider(),
                        //                                                                             Padding(
                        //                                                                               padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                        //                                                                               child: Translate.TranslateAndSetText('ผู้ตรวจสอบ/ยกเลิก ', AccountScreen_Color.Colors_Text1_, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                        //                                                                               // Text(
                        //                                                                               //   'ผู้ตรวจสอบ/ยกเลิก ',
                        //                                                                               //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                        //                                                                               // ),
                        //                                                                             ),
                        //                                                                           ],
                        //                                                                         ),
                        //                                                                         content: StreamBuilder(
                        //                                                                             stream: Stream.periodic(const Duration(seconds: 1)),
                        //                                                                             builder: (context, snapshot) {
                        //                                                                               return SingleChildScrollView(
                        //                                                                                 child: ListBody(
                        //                                                                                   children: <Widget>[
                        //                                                                                     Text(
                        //                                                                                       '- ${email_login}($seremail_login)',
                        //                                                                                       style: const TextStyle(
                        //                                                                                           fontSize: 14,
                        //                                                                                           color: AccountScreen_Color.Colors_Text2_,
                        //                                                                                           // fontWeight:
                        //                                                                                           //     FontWeight.bold,
                        //                                                                                           fontFamily: Font_.Fonts_T),
                        //                                                                                     ),
                        //                                                                                     Padding(
                        //                                                                                       padding: const EdgeInsets.all(8.0),
                        //                                                                                       child: Container(
                        //                                                                                         child: Row(
                        //                                                                                           mainAxisAlignment: MainAxisAlignment.center,
                        //                                                                                           children: [
                        //                                                                                             const Text(
                        //                                                                                               'CODE : ',
                        //                                                                                               style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                        //                                                                                             ),
                        //                                                                                             Padding(
                        //                                                                                               padding: const EdgeInsets.all(2),
                        //                                                                                               child: Container(
                        //                                                                                                 decoration: const BoxDecoration(
                        //                                                                                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                                                                   color: Color.fromARGB(255, 179, 177, 170),
                        //                                                                                                   // image:
                        //                                                                                                   //     const DecorationImage(
                        //                                                                                                   //   image: AssetImage(
                        //                                                                                                   //       "assets/pngegg2.png"),
                        //                                                                                                   //   fit: BoxFit
                        //                                                                                                   //       .cover,
                        //                                                                                                   // ),
                        //                                                                                                 ),
                        //                                                                                                 width: 65,
                        //                                                                                                 // color: Colors.black,
                        //                                                                                                 padding: const EdgeInsets.all(2.0),
                        //                                                                                                 child: Center(
                        //                                                                                                   child: Text(
                        //                                                                                                     '${randomString}',
                        //                                                                                                     style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                        //                                                                                                   ),
                        //                                                                                                 ),
                        //                                                                                               ),
                        //                                                                                             ),
                        //                                                                                           ],
                        //                                                                                         ),
                        //                                                                                       ),
                        //                                                                                     ),
                        //                                                                                     Padding(
                        //                                                                                       padding: const EdgeInsets.all(4.0),
                        //                                                                                       child: Center(
                        //                                                                                         child: Container(
                        //                                                                                           height: 40,
                        //                                                                                           width: 90,
                        //                                                                                           child: PinCode(
                        //                                                                                             keyboardType: TextInputType.number,
                        //                                                                                             numberOfFields: 2,
                        //                                                                                             fieldWidth: 40.0,
                        //                                                                                             style: const TextStyle(
                        //                                                                                               fontFamily: Font_.Fonts_T,
                        //                                                                                               color: Colors.black,
                        //                                                                                             ),
                        //                                                                                             fieldStyle: PinCodeStyle.box,
                        //                                                                                             onChanged: (value) {
                        //                                                                                               setState(() {
                        //                                                                                                 Pincontroller.text = value.trim();
                        //                                                                                               });
                        //                                                                                             },
                        //                                                                                             onCompleted: (text) {
                        //                                                                                               setState(() {
                        //                                                                                                 Pincontroller.text = text.trim();
                        //                                                                                               });
                        //                                                                                             },
                        //                                                                                           ),
                        //                                                                                         ),
                        //                                                                                       ),
                        //                                                                                     ),
                        //                                                                                   ],
                        //                                                                                 ),
                        //                                                                               );
                        //                                                                             }),
                        //                                                                         actions: <Widget>[
                        //                                                                           Column(
                        //                                                                             children: [
                        //                                                                               Translate.TranslateAndSetText('** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนยกเลิก', Colors.red[800], TextAlign.start, null, Font_.Fonts_T, 14, 1),
                        //                                                                               StreamBuilder(
                        //                                                                                   stream: Stream.periodic(const Duration(seconds: 1)),
                        //                                                                                   builder: (context, snapshot) {
                        //                                                                                     return Column(
                        //                                                                                       crossAxisAlignment: CrossAxisAlignment.center,
                        //                                                                                       children: [
                        //                                                                                         const SizedBox(
                        //                                                                                           height: 5.0,
                        //                                                                                         ),
                        //                                                                                         const Divider(
                        //                                                                                           color: Colors.grey,
                        //                                                                                           height: 1.0,
                        //                                                                                         ),
                        //                                                                                         const SizedBox(
                        //                                                                                           height: 5.0,
                        //                                                                                         ),
                        //                                                                                         Row(
                        //                                                                                           mainAxisAlignment: MainAxisAlignment.center,
                        //                                                                                           children: [
                        //                                                                                             Padding(
                        //                                                                                               padding: const EdgeInsets.all(8.0),
                        //                                                                                               child: Container(
                        //                                                                                                 width: 150,
                        //                                                                                                 height: 40,
                        //                                                                                                 // ignore: deprecated_member_use
                        //                                                                                                 child: ElevatedButton(
                        //                                                                                                   style: ElevatedButton.styleFrom(
                        //                                                                                                     backgroundColor: (Pincontroller.text != "$randomString") ? Colors.grey : Colors.green,
                        //                                                                                                   ),
                        //                                                                                                   onPressed: (Pincontroller.text != "$randomString" || Count_time_check == 0)
                        //                                                                                                       ? null
                        //                                                                                                       : () async {
                        //                                                                                                           showDialog(
                        //                                                                                                               barrierDismissible: false,
                        //                                                                                                               context: context,
                        //                                                                                                               builder: (_) {
                        //                                                                                                                 // Timer(Duration(milliseconds: 3600), () {
                        //                                                                                                                 //   Navigator.of(context).pop();
                        //                                                                                                                 // });
                        //                                                                                                                 return Dialog(
                        //                                                                                                                   child: SizedBox(
                        //                                                                                                                     height: 20,
                        //                                                                                                                     width: 80,
                        //                                                                                                                     child: FittedBox(
                        //                                                                                                                       fit: BoxFit.cover,
                        //                                                                                                                       child: Image.asset(
                        //                                                                                                                         "images/gif-LOGOchao.gif",
                        //                                                                                                                         fit: BoxFit.cover,
                        //                                                                                                                         height: 20,
                        //                                                                                                                         width: 80,
                        //                                                                                                                       ),
                        //                                                                                                                     ),
                        //                                                                                                                   ),
                        //                                                                                                                 );
                        //                                                                                                               });
                        //                                                                                                           for (int index1 = 0; index1 < limitedList_TransReBillModels_.length; index1++) {
                        //                                                                                                             var date_x = '${limitedList_TransReBillModels_[index1].dateacc}';
                        //                                                                                                             var time_x = '${limitedList_TransReBillModels_[index1].timex}';
                        //                                                                                                             if (limitedList_TransReBillModels_[index1].slip == null || limitedList_TransReBillModels_[index1].slip.toString() == 'null' || limitedList_TransReBillModels_[index1].slip.toString() == '') {
                        //                                                                                                               // checkTimeDifference(
                        //                                                                                                               //     date_x,
                        //                                                                                                               //     time_x);
                        //                                                                                                               if (checkTimeDifference(date_x, time_x) == true) {
                        //                                                                                                                 setState(() {
                        //                                                                                                                   numinvoice = limitedList_TransReBillModels_[index1].docno!;
                        //                                                                                                                 });
                        //                                                                                                                 String Formbe_cause = (int.parse('${time_check}') < 60)
                        //                                                                                                                     ? 'ยกเลิก: $numinvoice เกินกำหนด $time_check นาที(ไม่แนบสลิป)'
                        //                                                                                                                     : (int.parse('${time_check}') == 60)
                        //                                                                                                                         ? 'ยกเลิก: $numinvoice เกินกำหนด 1 ชั่วโมง(ไม่แนบสลิป)'
                        //                                                                                                                         : (int.parse('${time_check}') == 90)
                        //                                                                                                                             ? 'ยกเลิก: $numinvoice เกินกำหนด 1.3 ชั่วโมง(ไม่แนบสลิป)'
                        //                                                                                                                             : (int.parse('${time_check}') == 120)
                        //                                                                                                                                 ? 'ยกเลิก: $numinvoice เกินกำหนด 2 ชั่วโมง(ไม่แนบสลิป)'
                        //                                                                                                                                 : (int.parse('${time_check}') == 1440)
                        //                                                                                                                                     ? 'ยกเลิก: $numinvoice เกินกำหนด 1 วัน(ไม่แนบสลิป)'
                        //                                                                                                                                     : (int.parse('${time_check}') == 2880)
                        //                                                                                                                                         ? 'ยกเลิก: $numinvoice เกินกำหนด 2 วัน(ไม่แนบสลิป)'
                        //                                                                                                                                         : 'ยกเลิก: $numinvoice เกินกำหนด $time_check นาที(ไม่แนบสลิป)';
                        //                                                                                                                 // print(Formbe_cause);
                        //                                                                                                                 // 'ยกเลิกรับชำระ : $numinvoice  เกินกำหนด(ไม่แนบสลิป)';
                        //                                                                                                                 await pPC_finantIbill_TimeCheck(Formbe_cause).then((value) => {
                        //                                                                                                                       // print('index1 + 1'),
                        //                                                                                                                       // print(index1 + 1),
                        //                                                                                                                     });
                        //                                                                                                               }
                        //                                                                                                             }
                        //                                                                                                             Future.delayed(const Duration(milliseconds: 800));
                        //                                                                                                             if (index1 + 1 == limitedList_TransReBillModels_.length) {
                        //                                                                                                               Future.delayed(const Duration(seconds: 1));
                        //                                                                                                               // print('+++index1 + 1');
                        //                                                                                                               // print(index1 + 1);
                        //                                                                                                               Navigator.of(context).pop();
                        //                                                                                                               Future.delayed(const Duration(milliseconds: 200));
                        //                                                                                                               Navigator.pop(context);
                        //                                                                                                               Future.delayed(const Duration(milliseconds: 600), () async {
                        //                                                                                                                 Dialog_cancellock();
                        //                                                                                                               });
                        //                                                                                                             }
                        //                                                                                                           }
                        //                                                                                                         },
                        //                                                                                                   child: Text(
                        //                                                                                                     'ยืนยัน-Confirm',
                        //                                                                                                     style: TextStyle(
                        //                                                                                                       // fontSize: 20.0,
                        //                                                                                                       // fontWeight: FontWeight.bold,
                        //                                                                                                       color: Colors.white,
                        //                                                                                                     ),
                        //                                                                                                   ),
                        //                                                                                                   // color: Colors.black,
                        //                                                                                                 ),
                        //                                                                                               ),
                        //                                                                                             ),
                        //                                                                                           ],
                        //                                                                                         ),
                        //                                                                                       ],
                        //                                                                                     );
                        //                                                                                   }),
                        //                                                                             ],
                        //                                                                           ),
                        //                                                                         ],
                        //                                                                       ));
                        //                                                             },
                        //                                                             child: Text(
                        //                                                               "Check Payment ",
                        //                                                               maxLines: 1,
                        //                                                               style: TextStyle(
                        //                                                                 color: Colors.white,
                        //                                                                 fontFamily: Font_.Fonts_T,
                        //                                                                 fontWeight: FontWeight.bold,
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         ),
                        //                                                       ],
                        //                                                     ),
                        //                                                   ),
                        //                                                 ],
                        //                                               ),
                        //                                             ),
                        //                                           ),
                        //                                         // if (api_key ==
                        //                                         //     'Y')
                        //                                         //   Container(
                        //                                         //     // color: Colors.green,
                        //                                         //     decoration:
                        //                                         //         BoxDecoration(
                        //                                         //       color: Colors
                        //                                         //           .purple,
                        //                                         //       borderRadius: const BorderRadius
                        //                                         //               .only(
                        //                                         //           topLeft: Radius.circular(
                        //                                         //               10),
                        //                                         //           topRight: Radius.circular(
                        //                                         //               10),
                        //                                         //           bottomLeft: Radius.circular(
                        //                                         //               10),
                        //                                         //           bottomRight:
                        //                                         //               Radius.circular(10)),
                        //                                         //       // border: Border.all(color: Colors.white, width: 1),
                        //                                         //     ),
                        //                                         //     child:
                        //                                         //         Padding(
                        //                                         //       padding:
                        //                                         //           const EdgeInsets.all(
                        //                                         //               4.0),
                        //                                         //       child:
                        //                                         //           TextButton(
                        //                                         //         onPressed:
                        //                                         //             () async {
                        //                                         //           // PanaraInfoDialog
                        //                                         //           //     .showAnimatedGrow(
                        //                                         //           //   context,
                        //                                         //           //   title:
                        //                                         //           //       "Oops",
                        //                                         //           //   message:
                        //                                         //           //       "Coming soon...",
                        //                                         //           //   buttonText:
                        //                                         //           //       "รับทราบ",
                        //                                         //           //   onTapDismiss:
                        //                                         //           //       () async {
                        //                                         //           //     Navigator.pop(context);
                        //                                         //           //   },
                        //                                         //           //   panaraDialogType:
                        //                                         //           //       PanaraDialogType.error,
                        //                                         //           //   barrierDismissible:
                        //                                         //           //       false,
                        //                                         //           // );
                        //                                         //           // red_Chack_Trans_bill();
                        //                                         //           // selectFileAndReadExcel();
                        //                                         //           setState(
                        //                                         //               () {
                        //                                         //             if (_ChacpExcel ==
                        //                                         //                 1) {
                        //                                         //               _ChacpExcel = 0;
                        //                                         //             } else {
                        //                                         //               _ChacpExcel = 1;
                        //                                         //             }
                        //                                         //           });
                        //                                         //         },
                        //                                         //         child:
                        //                                         //             const Text(
                        //                                         //           "Check Payment Excel",
                        //                                         //           maxLines:
                        //                                         //               1,
                        //                                         //           style:
                        //                                         //               TextStyle(
                        //                                         //             color:
                        //                                         //                 Colors.white,
                        //                                         //             fontFamily:
                        //                                         //                 Font_.Fonts_T,
                        //                                         //             fontWeight:
                        //                                         //                 FontWeight.bold,
                        //                                         //           ),
                        //                                         //         ),
                        //                                         //       ),
                        //                                         //     ),
                        //                                         //   ),
                        //                                         if (api_key ==
                        //                                             'Y')
                        //                                           SizedBox(
                        //                                             width:
                        //                                                 15,
                        //                                           ),
                        //                                         if (api_key ==
                        //                                             'Y')
                        //                                           Container(
                        //                                             // color: Colors.green,
                        //                                             decoration:
                        //                                                 BoxDecoration(
                        //                                               color:
                        //                                                   Colors.green,
                        //                                               borderRadius: const BorderRadius.only(
                        //                                                   topLeft: Radius.circular(10),
                        //                                                   topRight: Radius.circular(10),
                        //                                                   bottomLeft: Radius.circular(10),
                        //                                                   bottomRight: Radius.circular(10)),
                        //                                               // border: Border.all(color: Colors.white, width: 1),
                        //                                             ),
                        //                                             child:
                        //                                                 Padding(
                        //                                               padding:
                        //                                                   const EdgeInsets.all(4.0),
                        //                                               child:
                        //                                                   TextButton(
                        //                                                 onPressed:
                        //                                                     () async {
                        //                                                   PanaraConfirmDialog.showAnimatedGrow(
                        //                                                     context,
                        //                                                     title: "Check Payment",
                        //                                                     message: "เช็คการชำระเงิน",
                        //                                                     confirmButtonText: "Confirm",
                        //                                                     cancelButtonText: "Cancel",
                        //                                                     onTapConfirm: () async {
                        //                                                       Dia_log();
                        //                                                       red_Trans_bill();
                        //                                                       red_Chack_Trans_bill().then((value) {
                        //                                                         Navigator.pop(context);
                        //                                                         Navigator.pop(context);
                        //                                                       });
                        //                                                     },
                        //                                                     onTapCancel: () {
                        //                                                       Navigator.pop(context);
                        //                                                     },
                        //                                                     panaraDialogType: PanaraDialogType.success,
                        //                                                   );
                        //                                                   // red_Trans_bill();
                        //                                                   // red_Chack_Trans_bill();
                        //                                                 },
                        //                                                 child:
                        //                                                     const Text(
                        //                                                   "Check Payment ",
                        //                                                   maxLines: 1,
                        //                                                   style: TextStyle(
                        //                                                     color: Colors.white,
                        //                                                     fontFamily: Font_.Fonts_T,
                        //                                                     fontWeight: FontWeight.bold,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                           ),
                        //                                       ],
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                           ),
                        //                           const Divider(),
                        //                           _ChacpExcel == 1
                        //                               ? SizedBox(
                        //                                   child: Container(
                        //                                       child: Row(
                        //                                     children: [
                        //                                       Expanded(
                        //                                         flex: 6,
                        //                                         child:
                        //                                             Container(
                        //                                           color: Colors
                        //                                               .white,
                        //                                           child: Row(
                        //                                               mainAxisAlignment:
                        //                                                   MainAxisAlignment.center,
                        //                                               children: [
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "วันที่รับชำระ",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "เวลา",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "ชื่อผู้โอน",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "จำนวน",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "Ref 1",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                                 Expanded(
                        //                                                   flex: 1,
                        //                                                   child: Padding(
                        //                                                     padding: EdgeInsets.all(0.0),
                        //                                                     child: Translate.TranslateAndSetText(
                        //                                                       "Ref 2",
                        //                                                       AccountScreen_Color.Colors_Text1_,
                        //                                                       TextAlign.start,
                        //                                                       FontWeight.bold,
                        //                                                       FontWeight_.Fonts_T,
                        //                                                       14,
                        //                                                       1,
                        //                                                     ),
                        //                                                   ),
                        //                                                 ),
                        //                                               ]),
                        //                                         ),
                        //                                       ),
                        //                                       Expanded(
                        //                                         flex: 6,
                        //                                         child: Row(
                        //                                             mainAxisAlignment:
                        //                                                 MainAxisAlignment.center,
                        //                                             children: [
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "วันที่ทำรายการ",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "เลขที่สัญญา",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "เลขที่ใบเสร็จ",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "ชื่อผู้เช่า",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "จำนวนเงิน",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "Ref 1",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "Ref 2",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                               Expanded(
                        //                                                 flex:
                        //                                                     1,
                        //                                                 child:
                        //                                                     Padding(
                        //                                                   padding: EdgeInsets.all(0.0),
                        //                                                   child: Translate.TranslateAndSetText(
                        //                                                     "",
                        //                                                     AccountScreen_Color.Colors_Text1_,
                        //                                                     TextAlign.start,
                        //                                                     FontWeight.bold,
                        //                                                     FontWeight_.Fonts_T,
                        //                                                     14,
                        //                                                     1,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                             ]),
                        //                                       ),
                        //                                     ],
                        //                                   )),
                        //                                 )
                        //                               : Row(
                        //                                   children: [
                        //                                     (renTal_Ser.toString() ==
                        //                                             '106')
                        //                                         ? SizedBox()
                        //                                         : SizedBox(
                        //                                             width:
                        //                                                 30,
                        //                                           ),
                        //                                     Expanded(
                        //                                       flex: 15,
                        //                                       child: Row(
                        //                                         mainAxisAlignment:
                        //                                             MainAxisAlignment
                        //                                                 .center,
                        //                                         children: ac5
                        //                                             .where((item) => item["st"] == '1') // Filter items
                        //                                             .toList() // Convert to a list
                        //                                             .asMap()
                        //                                             .entries
                        //                                             .map((entry) {
                        //                                           int index =
                        //                                               entry
                        //                                                   .key; // Get the index
                        //                                           var item =
                        //                                               entry
                        //                                                   .value; // Get the item

                        //                                           return Expanded(
                        //                                             flex: 1,
                        //                                             child:
                        //                                                 Padding(
                        //                                               padding:
                        //                                                   EdgeInsets.all(0.0),
                        //                                               child:
                        //                                                   Translate.TranslateAndSetText(
                        //                                                 item["pn"] ??
                        //                                                     "", // Use "pn" or an empty string if null
                        //                                                 AccountScreen_Color.Colors_Text1_,
                        //                                                 (item["ser"] == '11' || item["ser"] == '12' || item["ser"] == '13')
                        //                                                     ? TextAlign.center
                        //                                                     : (item["ser"] == '10')
                        //                                                         ? TextAlign.right
                        //                                                         : TextAlign.start,
                        //                                                 FontWeight.bold,
                        //                                                 FontWeight_.Fonts_T,
                        //                                                 14,
                        //                                                 1,
                        //                                               ),
                        //                                             ),
                        //                                           );
                        //                                         }).toList(),
                        //                                       ),
                        //                                     ),
                        //                                     const Expanded(
                        //                                       flex: 2,
                        //                                       child:
                        //                                           Padding(
                        //                                         padding:
                        //                                             EdgeInsets.all(
                        //                                                 8.0),
                        //                                         child: Text(
                        //                                           '...',
                        //                                           textAlign:
                        //                                               TextAlign
                        //                                                   .center,
                        //                                           style:
                        //                                               TextStyle(
                        //                                             color: AccountScreen_Color
                        //                                                 .Colors_Text1_,
                        //                                             fontWeight:
                        //                                                 FontWeight.bold,
                        //                                             fontFamily:
                        //                                                 FontWeight_.Fonts_T,
                        //                                           ),
                        //                                         ),
                        //                                       ),
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                           // Row(
                        //                           //   mainAxisAlignment:
                        //                           //       MainAxisAlignment
                        //                           //           .center,
                        //                           //   children: [
                        //                           //     SizedBox(
                        //                           //       width: 30,
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             const EdgeInsets
                        //                           //                 .all(8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'เลขที่สัญญา',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .start,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'วันที่ทำรายการ',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate.TranslateAndSetText(
                        //                           //             'วันที่จอง-ล็อกเสียบ(วันแรก)',
                        //                           //             AccountScreen_Color
                        //                           //                 .Colors_Text1_,
                        //                           //             TextAlign.center,
                        //                           //             FontWeight.bold,
                        //                           //             FontWeight_
                        //                           //                 .Fonts_T,
                        //                           //             14,
                        //                           //             1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'วันที่รับชำระ',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'เลขที่ใบเสร็จ',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .left,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     // Expanded(
                        //                           //     //   flex: 1,
                        //                           //     //   child: Padding(
                        //                           //     //     padding: EdgeInsets.all(8.0),
                        //                           //     //     child: Text(
                        //                           //     //       'เลขที่ใบวางบิล',
                        //                           //     //       textAlign: TextAlign.center,
                        //                           //     //       style: TextStyle(
                        //                           //     //         color: AccountScreen_Color
                        //                           //     //             .Colors_Text1_,
                        //                           //     //         fontWeight: FontWeight.bold,
                        //                           //     //         fontFamily:
                        //                           //     //             FontWeight_.Fonts_T,
                        //                           //     //         //fontSize: 10.0
                        //                           //     //       ),
                        //                           //     //     ),
                        //                           //     //   ),
                        //                           //     // ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'รหัสพื้นที่',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .left,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'ชื่อร้านค้า',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .left,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'จำนวนเงิน',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .right,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'รูปแบบชำระ',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'รหัสอ้างอิง',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 2,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'Ref1',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 2,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'Ref2',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'ทำรายการ',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Translate
                        //                           //             .TranslateAndSetText(
                        //                           //                 'ประเภท',
                        //                           //                 AccountScreen_Color
                        //                           //                     .Colors_Text1_,
                        //                           //                 TextAlign
                        //                           //                     .center,
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //                 14,
                        //                           //                 1),
                        //                           //       ),
                        //                           //     ),
                        //                           //     // Container(
                        //                           //     //   width: 100,
                        //                           //     //   child: Padding(
                        //                           //     //     padding:
                        //                           //     //         EdgeInsets.all(8.0),
                        //                           //     //     child: Text(
                        //                           //     //       'เอกสาร',
                        //                           //     //       textAlign:
                        //                           //     //           TextAlign.center,
                        //                           //     //       style: TextStyle(
                        //                           //     //         color:
                        //                           //     //             AccountScreen_Color
                        //                           //     //                 .Colors_Text1_,
                        //                           //     //         fontWeight:
                        //                           //     //             FontWeight.bold,
                        //                           //     //         fontFamily:
                        //                           //     //             FontWeight_.Fonts_T,
                        //                           //     //       ),
                        //                           //     //     ),
                        //                           //     //   ),
                        //                           //     // ),
                        //                           //     const Expanded(
                        //                           //       flex: 1,
                        //                           //       child: Padding(
                        //                           //         padding:
                        //                           //             EdgeInsets.all(
                        //                           //                 8.0),
                        //                           //         child: Text(
                        //                           //           '...',
                        //                           //           textAlign: TextAlign
                        //                           //               .center,
                        //                           //           style: TextStyle(
                        //                           //             color: AccountScreen_Color
                        //                           //                 .Colors_Text1_,
                        //                           //             fontWeight:
                        //                           //                 FontWeight
                        //                           //                     .bold,
                        //                           //             fontFamily:
                        //                           //                 FontWeight_
                        //                           //                     .Fonts_T,
                        //                           //           ),
                        //                           //         ),
                        //                           //       ),
                        //                           //     ),
                        //                           //   ],
                        //                           // ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                     _ChacpExcel == 1
                        //                         ? SizedBox()
                        //                         : Container(
                        //                             height: MediaQuery.of(
                        //                                         context)
                        //                                     .size
                        //                                     .height *
                        //                                 0.6,
                        //                             width: Responsive
                        //                                     .isDesktop(
                        //                                         context)
                        //                                 ? calculatedWidth
                        //                                 : 1200,
                        //                             decoration:
                        //                                 const BoxDecoration(
                        //                               color:
                        //                                   AppbackgroundColor
                        //                                       .Sub_Abg_Colors,
                        //                               borderRadius: BorderRadius.only(
                        //                                   topLeft: Radius
                        //                                       .circular(0),
                        //                                   topRight: Radius
                        //                                       .circular(0),
                        //                                   bottomLeft: Radius
                        //                                       .circular(0),
                        //                                   bottomRight:
                        //                                       Radius
                        //                                           .circular(
                        //                                               0)),
                        //                               // border: Border.all(color: Colors.grey, width: 1),
                        //                             ),
                        //                             child: _TransReBillModels
                        //                                     .isEmpty
                        //                                 ? SizedBox(
                        //                                     child: Column(
                        //                                       mainAxisAlignment:
                        //                                           MainAxisAlignment
                        //                                               .center,
                        //                                       children: [
                        //                                         const CircularProgressIndicator(),
                        //                                         StreamBuilder(
                        //                                           stream: Stream.periodic(
                        //                                               const Duration(
                        //                                                   milliseconds:
                        //                                                       25),
                        //                                               (i) =>
                        //                                                   i),
                        //                                           builder:
                        //                                               (context,
                        //                                                   snapshot) {
                        //                                             if (!snapshot
                        //                                                 .hasData)
                        //                                               return const Text(
                        //                                                   '');
                        //                                             double
                        //                                                 elapsed =
                        //                                                 double.parse(snapshot.data.toString()) *
                        //                                                     0.05;
                        //                                             return Padding(
                        //                                               padding:
                        //                                                   const EdgeInsets.all(8.0),
                        //                                               child: (elapsed > 8.00)
                        //                                                   ? const Text(
                        //                                                       'No Data',
                        //                                                       style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
                        //                                                           //fontSize: 10.0
                        //                                                           ),
                        //                                                     )
                        //                                                   : Text(
                        //                                                       'Download : ${elapsed.toStringAsFixed(2)} s.',
                        //                                                       // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                        //                                                       style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
                        //                                                           //fontSize: 10.0
                        //                                                           ),
                        //                                                     ),
                        //                                             );
                        //                                           },
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   )
                        //                                 : ListView.builder(
                        //                                     controller:
                        //                                         _scrollController2,
                        //                                     // itemExtent: 50,
                        //                                     physics:
                        //                                         const AlwaysScrollableScrollPhysics(),
                        //                                     shrinkWrap:
                        //                                         true,
                        //                                     itemCount:
                        //                                         _TransReBillModels
                        //                                             .length,
                        //                                     itemBuilder:
                        //                                         (BuildContext
                        //                                                 context,
                        //                                             int index) {
                        //                                       return Column(
                        //                                         children: [
                        //                                           Material(
                        //                                             color: tappedIndex_ ==
                        //                                                     index.toString()
                        //                                                 ? tappedIndex_Color.tappedIndex_Colors
                        //                                                 : AppbackgroundColor.Sub_Abg_Colors,
                        //                                             child:
                        //                                                 Container(
                        //                                               // decoration:
                        //                                               //     BoxDecoration(
                        //                                               //   color: Colors.orange,
                        //                                               //   borderRadius: const BorderRadius
                        //                                               //           .only(
                        //                                               //       topLeft: Radius
                        //                                               //           .circular(10),
                        //                                               //       topRight: Radius
                        //                                               //           .circular(10),
                        //                                               //       bottomLeft: Radius
                        //                                               //           .circular(10),
                        //                                               //       bottomRight:
                        //                                               //           Radius
                        //                                               //               .circular(
                        //                                               //                   10)),
                        //                                               //   border: Border.all(
                        //                                               //       color:
                        //                                               //           Colors.white,
                        //                                               //       width: 1),
                        //                                               // ),
                        //                                               // color: tappedIndex_ ==
                        //                                               //         index.toString()
                        //                                               //     ? tappedIndex_Color
                        //                                               //         .tappedIndex_Colors
                        //                                               //         .withOpacity(0.5)
                        //                                               //     : null,
                        //                                               child:
                        //                                                   Column(
                        //                                                 children: [
                        //                                                   ListTile(
                        //                                                       // onTap:
                        //                                                       //     () async {
                        //                                                       //   setState(
                        //                                                       //       () {
                        //                                                       //     tappedIndex_ =
                        //                                                       //         '${index}';
                        //                                                       //   });
                        //                                                       // },
                        //                                                       title: Container(
                        //                                                     decoration: BoxDecoration(
                        //                                                       color: (renTal_Ser.toString() == '106')
                        //                                                           ? null
                        //                                                           : (_TransReBillModels[index].slip == null || _TransReBillModels[index].slip.toString() == 'null' || _TransReBillModels[index].slip.toString() == '')
                        //                                                               ? Colors.deepOrange[300]!.withOpacity(0.3)
                        //                                                               : null,
                        //                                                       border: Border(
                        //                                                         bottom: BorderSide(
                        //                                                           color: Colors.black12,
                        //                                                           width: 1,
                        //                                                         ),
                        //                                                       ),
                        //                                                     ),
                        //                                                     child: Row(
                        //                                                       mainAxisAlignment: MainAxisAlignment.center,
                        //                                                       children: [
                        //                                                         (renTal_Ser.toString() == '106')
                        //                                                             ? SizedBox()
                        //                                                             : (checkTimeDifference('${_TransReBillModels[index].dateacc}', '${_TransReBillModels[index].timex}') == false)
                        //                                                                 ? SizedBox(width: 25)
                        //                                                                 : SizedBox(
                        //                                                                     width: 25,
                        //                                                                     child: Padding(
                        //                                                                       padding: const EdgeInsets.all(2.0),
                        //                                                                       child: Center(
                        //                                                                           child: Icon(
                        //                                                                         Icons.lock_clock,
                        //                                                                         size: 18,
                        //                                                                         color: Colors.blueGrey,
                        //                                                                       )),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                         if (where_ac5("0") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: TextSpan(
                        //                                                                 text: '${_TransReBillModels[index].cid}',
                        //                                                                 style: const TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].cid == null ? '-' : '${_TransReBillModels[index].cid}',
                        //                                                                 textAlign: TextAlign.start,
                        //                                                                 overflow: TextOverflow.ellipsis,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("1") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: AutoSizeText(
                        //                                                               minFontSize: 10,
                        //                                                               maxFontSize: 16,
                        //                                                               maxLines: 1,
                        //                                                               (_TransReBillModels[index].daterec == null) ? '-' : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00').year + 0}',
                        //                                                               textAlign: TextAlign.start,
                        //                                                               overflow: TextOverflow.ellipsis,
                        //                                                               style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                             ),
                        //                                                           ),

                        //                                                         if (where_ac5("2") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: AutoSizeText(
                        //                                                               minFontSize: 10,
                        //                                                               maxFontSize: 16,
                        //                                                               maxLines: 1,
                        //                                                               (_TransReBillModels[index].pay_by.toString() == 'LP')
                        //                                                                   ? (_TransReBillModels[index].date == null)
                        //                                                                       ? '-'
                        //                                                                       : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 0}'
                        //                                                                   : '-',
                        //                                                               textAlign: TextAlign.start,
                        //                                                               overflow: TextOverflow.ellipsis,
                        //                                                               style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("3") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: AutoSizeText(
                        //                                                               minFontSize: 10,
                        //                                                               maxFontSize: 16,
                        //                                                               maxLines: 1,
                        //                                                               (_TransReBillModels[index].pdate == null) ? '-' : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 0}',
                        //                                                               textAlign: TextAlign.start,
                        //                                                               overflow: TextOverflow.ellipsis,
                        //                                                               style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("4") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Row(
                        //                                                               children: [
                        //                                                                 Copy_Text(context, _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}'),
                        //                                                                 Expanded(
                        //                                                                   child: Tooltip(
                        //                                                                     richMessage: TextSpan(
                        //                                                                       text: _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}',
                        //                                                                       style: const TextStyle(
                        //                                                                         color: HomeScreen_Color.Colors_Text1_,
                        //                                                                         fontWeight: FontWeight.bold,
                        //                                                                         fontFamily: FontWeight_.Fonts_T,
                        //                                                                         //fontSize: 10.0
                        //                                                                       ),
                        //                                                                     ),
                        //                                                                     decoration: BoxDecoration(
                        //                                                                       borderRadius: BorderRadius.circular(5),
                        //                                                                       color: Colors.grey[200],
                        //                                                                     ),
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 16,
                        //                                                                       maxLines: 1,
                        //                                                                       _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}',
                        //                                                                       textAlign: TextAlign.left,
                        //                                                                       overflow: TextOverflow.ellipsis,
                        //                                                                       style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                 ),
                        //                                                               ],
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("5") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        //                                                               Copy_Text(
                        //                                                                 context,
                        //                                                                 _TransReBillModels[index].inv == null ? '' : '${_TransReBillModels[index].inv}',
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 1,
                        //                                                                 child: Tooltip(
                        //                                                                   richMessage: TextSpan(
                        //                                                                     text: _TransReBillModels[index].inv2 == null ? '' : '${_TransReBillModels[index].inv2}',
                        //                                                                     style: const TextStyle(
                        //                                                                       color: HomeScreen_Color.Colors_Text1_,
                        //                                                                       fontWeight: FontWeight.bold,
                        //                                                                       fontFamily: FontWeight_.Fonts_T,
                        //                                                                       //fontSize: 10.0
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   decoration: BoxDecoration(
                        //                                                                     borderRadius: BorderRadius.circular(5),
                        //                                                                     color: Colors.grey[200],
                        //                                                                   ),
                        //                                                                   child: AutoSizeText(
                        //                                                                     minFontSize: 10,
                        //                                                                     maxFontSize: 16,
                        //                                                                     maxLines: 1,
                        //                                                                     _TransReBillModels[index].inv2 == null ? '' : '${_TransReBillModels[index].inv2}',
                        //                                                                     textAlign: TextAlign.left,
                        //                                                                     overflow: TextOverflow.ellipsis,
                        //                                                                     style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                   ),
                        //                                                                 ),
                        //                                                               ),
                        //                                                             ]),
                        //                                                           ),

                        //                                                         if (where_ac5("6") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: AutoSizeText(
                        //                                                               minFontSize: 10,
                        //                                                               maxFontSize: 16,
                        //                                                               maxLines: 1,
                        //                                                               _TransReBillModels[index].zn == null ? '${_TransReBillModels[index].znn}' : '${_TransReBillModels[index].zn}',
                        //                                                               textAlign: TextAlign.left,
                        //                                                               overflow: TextOverflow.ellipsis,
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("7") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: TextSpan(
                        //                                                                 text: _TransReBillModels[index].ln == null ? '${_TransReBillModels[index].room_number}' : '${_TransReBillModels[index].ln}',
                        //                                                                 style: const TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].ln == null ? '${_TransReBillModels[index].room_number}' : '${_TransReBillModels[index].ln}',
                        //                                                                 textAlign: TextAlign.left,
                        //                                                                 overflow: TextOverflow.ellipsis,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("8") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: TextSpan(
                        //                                                                 text: _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}',
                        //                                                                 style: const TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}',
                        //                                                                 textAlign: TextAlign.left,
                        //                                                                 overflow: TextOverflow.ellipsis,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("9") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: AutoSizeText(
                        //                                                               minFontSize: 10,
                        //                                                               maxFontSize: 16,
                        //                                                               maxLines: 1,
                        //                                                               _TransReBillModels[index].cname == null ? '-' : '${_TransReBillModels[index].cname}',
                        //                                                               textAlign: TextAlign.left,
                        //                                                               overflow: TextOverflow.ellipsis,
                        //                                                               style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("10") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: const TextSpan(
                        //                                                                 text: '',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].total_dis == null
                        //                                                                     ? (_TransReBillModels[index].total_bill == null)
                        //                                                                         ? ''
                        //                                                                         : '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                        //                                                                     : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                        //                                                                 textAlign: TextAlign.right,
                        //                                                                 overflow: TextOverflow.ellipsis,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("11") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: const TextSpan(
                        //                                                                 text: '',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].type == null ? '-' : '${_TransReBillModels[index].type}',
                        //                                                                 textAlign: TextAlign.center,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("12") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: const TextSpan(
                        //                                                                 text: '',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].ref1 == null ? '-' : '${_TransReBillModels[index].ref1}',
                        //                                                                 textAlign: TextAlign.center,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("13") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: TextSpan(
                        //                                                                 text: '${_TransReBillModels[index].ref2}',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].ref2 == null ? '-' : '${_TransReBillModels[index].ref2}',
                        //                                                                 textAlign: TextAlign.center,
                        //                                                                 style: TextStyle(color: Colors.amber.shade900, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("14") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: TextSpan(
                        //                                                                 text: '${_TransReBillModels[index].ref4}',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 10,
                        //                                                                 maxFontSize: 16,
                        //                                                                 maxLines: 1,
                        //                                                                 _TransReBillModels[index].ref4 == null ? '-' : '${_TransReBillModels[index].ref4}',
                        //                                                                 textAlign: TextAlign.center,
                        //                                                                 style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("15") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: const TextSpan(
                        //                                                                 text: '',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: AutoSizeText(
                        //                                                                 minFontSize: 8,
                        //                                                                 maxFontSize: 12,
                        //                                                                 maxLines: 1,
                        //                                                                 (_TransReBillModels[index].pay_by.toString() == 'W')
                        //                                                                     ? 'Web Admin (${_TransReBillModels[index].pay_by})'
                        //                                                                     : (_TransReBillModels[index].pay_by.toString() == 'U')
                        //                                                                         ? 'Web User (${_TransReBillModels[index].pay_by})'
                        //                                                                         : (_TransReBillModels[index].pay_by.toString() == 'LP')
                        //                                                                             ? 'Web Market (${_TransReBillModels[index].pay_by})'
                        //                                                                             : (_TransReBillModels[index].pay_by.toString() == 'LP')
                        //                                                                                 ? 'Handheld (${_TransReBillModels[index].pay_by})'
                        //                                                                                 : 'Unknow ?? (${_TransReBillModels[index].pay_by})',
                        //                                                                 textAlign: TextAlign.center,
                        //                                                                 style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         if (where_ac5("16") == false)
                        //                                                           Expanded(
                        //                                                             flex: 1,
                        //                                                             child: Tooltip(
                        //                                                               richMessage: const TextSpan(
                        //                                                                 text: '',
                        //                                                                 style: TextStyle(
                        //                                                                   color: HomeScreen_Color.Colors_Text1_,
                        //                                                                   fontWeight: FontWeight.bold,
                        //                                                                   fontFamily: FontWeight_.Fonts_T,
                        //                                                                   //fontSize: 10.0
                        //                                                                 ),
                        //                                                               ),
                        //                                                               decoration: BoxDecoration(
                        //                                                                 borderRadius: BorderRadius.circular(5),
                        //                                                                 color: Colors.grey[200],
                        //                                                               ),
                        //                                                               child: Translate.TranslateAndSetText(
                        //                                                                   (_TransReBillModels[index].pay_by.toString() == 'W')
                        //                                                                       ? 'ชำระค่าบริการ'
                        //                                                                       : (_TransReBillModels[index].pay_by.toString() == 'U')
                        //                                                                           ? 'ชำระค่าบริการ'
                        //                                                                           : (_TransReBillModels[index].pay_by.toString() == 'LP')
                        //                                                                               ? 'จองล็อกเสียบ'
                        //                                                                               : (_TransReBillModels[index].pay_by.toString() == 'LP')
                        //                                                                                   ? 'ชำระค่าบริการ'
                        //                                                                                   : 'ไม่ทราบ ??',
                        //                                                                   AccountScreen_Color.Colors_Text1_,
                        //                                                                   TextAlign.right,
                        //                                                                   null,
                        //                                                                   Font_.Fonts_T,
                        //                                                                   14,
                        //                                                                   1),
                        //                                                             ),
                        //                                                           ),

                        //                                                         Expanded(
                        //                                                           flex: 1,
                        //                                                           child: Center(
                        //                                                             child: InkWell(
                        //                                                               onTap: () async {
                        //                                                                 generateRandomString();
                        //                                                                 setState(() {
                        //                                                                   red_Trans_select(index);
                        //                                                                   red_Invoice(index);
                        //                                                                 });
                        //                                                                 Future.delayed(const Duration(milliseconds: 300), () async {
                        //                                                                   checkshowDialog(
                        //                                                                     index,
                        //                                                                   );
                        //                                                                 });
                        //                                                               },
                        //                                                               child: Container(
                        //                                                                 width: 100,
                        //                                                                 decoration: BoxDecoration(
                        //                                                                   color: Colors.orange,
                        //                                                                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                                   border: Border.all(color: Colors.white, width: 1),
                        //                                                                 ),
                        //                                                                 padding: const EdgeInsets.all(4.0),
                        //                                                                 child: Row(
                        //                                                                   mainAxisAlignment: MainAxisAlignment.center,
                        //                                                                   children: [
                        //                                                                     if (_TransReBillModels[index].slip == null || _TransReBillModels[index].slip.toString() == 'null' || _TransReBillModels[index].slip.toString() == '') Icon(Icons.image_not_supported),
                        //                                                                     Translate.TranslateAndSetText('ตรวจสอบ', AccountScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                        //                                                                     // AutoSizeText(
                        //                                                                     //   minFontSize: 10,
                        //                                                                     //   maxFontSize: 25,
                        //                                                                     //   maxLines: 1,
                        //                                                                     //   'ตรวจสอบ',
                        //                                                                     //   textAlign: TextAlign.center,
                        //                                                                     //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     // ),
                        //                                                                   ],
                        //                                                                 ),
                        //                                                               ),
                        //                                                             ),
                        //                                                           ),
                        //                                                         ),
                        //                                                         // Expanded(
                        //                                                         //   flex:
                        //                                                         //       1,
                        //                                                         //   child:
                        //                                                         //       Center(
                        //                                                         //     child: InkWell(
                        //                                                         //       onTap: () async {
                        //                                                         //         generateRandomString();
                        //                                                         //         setState(() {
                        //                                                         //           red_Trans_select(index);
                        //                                                         //           red_Invoice(index);
                        //                                                         //         });
                        //                                                         //         Future.delayed(const Duration(milliseconds: 300), () async {
                        //                                                         //           checkshowDialog(
                        //                                                         //             index,
                        //                                                         //           );
                        //                                                         //         });
                        //                                                         //       },
                        //                                                         //       child: Container(
                        //                                                         //         width: 100,
                        //                                                         //         decoration: BoxDecoration(
                        //                                                         //           color: Colors.orange,
                        //                                                         //           borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                         //           border: Border.all(color: Colors.white, width: 1),
                        //                                                         //         ),
                        //                                                         //         padding: const EdgeInsets.all(4.0),
                        //                                                         //         child: const AutoSizeText(
                        //                                                         //           minFontSize: 10,
                        //                                                         //           maxFontSize: 25,
                        //                                                         //           maxLines: 1,
                        //                                                         //           'ตรวจสอบ',
                        //                                                         //           textAlign: TextAlign.center,
                        //                                                         //           style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                         //         ),
                        //                                                         //       ),
                        //                                                         //     ),
                        //                                                         //   ),
                        //                                                         // ),
                        //                                                       ],
                        //                                                     ),
                        //                                                   )),
                        //                                                   if (limitedList_bankExcBilling.length != 0)
                        //                                                     for (int indexbank = 0; indexbank < limitedList_bankExcBilling.length; indexbank++)
                        //                                                       if (limitedList_bankExcBilling[indexbank].ref1 == _TransReBillModels[index].ref1)
                        //                                                         ListTile(
                        //                                                             title: Container(
                        //                                                           color: Colors.grey.shade100,
                        //                                                           // decoration:
                        //                                                           //     BoxDecoration(
                        //                                                           //   color:  Colors.grey.shade100,
                        //                                                           //   borderRadius: const BorderRadius.only(
                        //                                                           //       topLeft: Radius.circular(10),
                        //                                                           //       topRight: Radius.circular(10),
                        //                                                           //       bottomLeft: Radius.circular(10),
                        //                                                           //       bottomRight: Radius.circular(10)),
                        //                                                           //   border: Border.all(
                        //                                                           //       color: Colors.white,
                        //                                                           //       width: 1),
                        //                                                           // ),
                        //                                                           child: Row(
                        //                                                             children: [
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: Translate.TranslateAndSetText(
                        //                                                                     'เลขที่บัญชี : ${limitedList_bankExcBilling[indexbank].company_account}',
                        //                                                                     limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                             (_TransReBillModels[index].total_dis == null
                        //                                                                                 ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                     ? 0
                        //                                                                                     : _TransReBillModels[index].total_bill
                        //                                                                                 : _TransReBillModels[index].total_dis)
                        //                                                                         ? Colors.red
                        //                                                                         : Colors.green,
                        //                                                                     TextAlign.start,
                        //                                                                     null,
                        //                                                                     Font_.Fonts_T,
                        //                                                                     14,
                        //                                                                     1),
                        //                                                                 // AutoSizeText(
                        //                                                                 //   minFontSize: 10,
                        //                                                                 //   maxFontSize: 25,
                        //                                                                 //   maxLines: 1,
                        //                                                                 //   'เลขที่บัญชี : ${limitedList_bankExcBilling[indexbank].company_account}', //transReChackBillModels[index].cid
                        //                                                                 //   textAlign: TextAlign.left,
                        //                                                                 //   style: TextStyle(
                        //                                                                 //       color:
                        //                                                                 // limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                 //               (_TransReBillModels[index].total_dis == null
                        //                                                                 //                   ? (_TransReBillModels[index].total_bill == null)
                        //                                                                 //                       ? 0
                        //                                                                 //                       : _TransReBillModels[index].total_bill
                        //                                                                 //                   : _TransReBillModels[index].total_dis)
                        //                                                                 //           ? Colors.red
                        //                                                                 //           : Colors.green,
                        //                                                                 //       fontFamily: Font_.Fonts_T),
                        //                                                                 // ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '',
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(
                        //                                                                       color: limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                               (_TransReBillModels[index].total_dis == null
                        //                                                                                   ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                       ? 0
                        //                                                                                       : _TransReBillModels[index].total_bill
                        //                                                                                   : _TransReBillModels[index].total_dis)
                        //                                                                           ? Colors.red
                        //                                                                           : Colors.green,
                        //                                                                       fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               // Expanded(
                        //                                                               //   flex: 2,
                        //                                                               //   child: AutoSizeText(
                        //                                                               //     minFontSize: 10,
                        //                                                               //     maxFontSize: 25,
                        //                                                               //     maxLines: 1,
                        //                                                               //     '${limitedList_bankExcBilling[indexbank].payment_time}', //transReChackBillModels[index].cid
                        //                                                               //     textAlign: TextAlign.left,
                        //                                                               //     style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                               //   ),
                        //                                                               // ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '${listchack[indexbank]}', //transReChackBillModels[index].cid
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(
                        //                                                                       color: limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                               (_TransReBillModels[index].total_dis == null
                        //                                                                                   ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                       ? 0
                        //                                                                                       : _TransReBillModels[index].total_bill
                        //                                                                                   : _TransReBillModels[index].total_dis)
                        //                                                                           ? Colors.red
                        //                                                                           : Colors.green,
                        //                                                                       fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '${limitedList_bankExcBilling[indexbank].customer_name}', //transReChackBillModels[index].cid
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(
                        //                                                                       color: limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                               (_TransReBillModels[index].total_dis == null
                        //                                                                                   ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                       ? 0
                        //                                                                                       : _TransReBillModels[index].total_bill
                        //                                                                                   : _TransReBillModels[index].total_dis)
                        //                                                                           ? Colors.red
                        //                                                                           : Colors.green,
                        //                                                                       fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '${nFormat.format(double.parse(limitedList_bankExcBilling[indexbank].amount!))}',
                        //                                                                   textAlign: TextAlign.right,
                        //                                                                   style: TextStyle(
                        //                                                                     color: limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                             (_TransReBillModels[index].total_dis == null
                        //                                                                                 ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                     ? 0
                        //                                                                                     : _TransReBillModels[index].total_bill
                        //                                                                                 : _TransReBillModels[index].total_dis)
                        //                                                                         ? Colors.red
                        //                                                                         : Colors.green,
                        //                                                                     fontFamily: Font_.Fonts_T,
                        //                                                                   ),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '',
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '${limitedList_bankExcBilling[indexbank].ref1}',
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(
                        //                                                                       color: limitedList_bankExcBilling[indexbank].amount !=
                        //                                                                               (_TransReBillModels[index].total_dis == null
                        //                                                                                   ? (_TransReBillModels[index].total_bill == null)
                        //                                                                                       ? 0
                        //                                                                                       : _TransReBillModels[index].total_bill
                        //                                                                                   : _TransReBillModels[index].total_dis)
                        //                                                                           ? Colors.red
                        //                                                                           : Colors.green,
                        //                                                                       fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                               Expanded(
                        //                                                                 flex: 2,
                        //                                                                 child: AutoSizeText(
                        //                                                                   minFontSize: 10,
                        //                                                                   maxFontSize: 25,
                        //                                                                   maxLines: 1,
                        //                                                                   '',
                        //                                                                   textAlign: TextAlign.left,
                        //                                                                   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                 ),
                        //                                                               ),
                        //                                                             ],
                        //                                                           ),
                        //                                                         )),
                        //                                                   if (transReChackBillModels.length != 0)
                        //                                                     if (transReChackBillModels[index].ref1 == _TransReBillModels[index].ref1)
                        //                                                       ListTile(
                        //                                                         title: Container(
                        //                                                           width: 100,
                        //                                                           decoration: BoxDecoration(
                        //                                                             color: transReChackBillModels[index].status == 'payment confirm success'
                        //                                                                 ? Colors.green.shade100
                        //                                                                 : transReChackBillModels[index].status == 'billing_not_found'
                        //                                                                     ? Colors.purple.shade100
                        //                                                                     : Colors.orange.shade100,
                        //                                                             borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        //                                                             border: Border.all(color: Colors.white, width: 1),
                        //                                                           ),
                        //                                                           padding: const EdgeInsets.all(4.0),
                        //                                                           child: Column(
                        //                                                             children: [
                        //                                                               Row(
                        //                                                                 children: [
                        //                                                                   Expanded(
                        //                                                                     flex: 2,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].cid}',
                        //                                                                       textAlign: TextAlign.left,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   transReChackBillModels[index].transDate == null
                        //                                                                       ? SizedBox()
                        //                                                                       : Expanded(
                        //                                                                           flex: 2,
                        //                                                                           child: AutoSizeText(
                        //                                                                             minFontSize: 10,
                        //                                                                             maxFontSize: 25,
                        //                                                                             maxLines: 1,
                        //                                                                             transReChackBillModels[index].transDate == null ? '' : '${transReChackBillModels[index].transDate}',
                        //                                                                             textAlign: TextAlign.center,
                        //                                                                             style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                           ),
                        //                                                                         ),
                        //                                                                   transReChackBillModels[index].transDate == null
                        //                                                                       ? SizedBox()
                        //                                                                       : Expanded(
                        //                                                                           flex: 2,
                        //                                                                           child: AutoSizeText(
                        //                                                                             minFontSize: 10,
                        //                                                                             maxFontSize: 25,
                        //                                                                             maxLines: 1,
                        //                                                                             transReChackBillModels[index].transTime == null ? '' : '${transReChackBillModels[index].transTime}',
                        //                                                                             textAlign: TextAlign.center,
                        //                                                                             style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                           ),
                        //                                                                         ),
                        //                                                                   Expanded(
                        //                                                                     flex: transReChackBillModels[index].transDate == null ? 6 : 2,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].docno}',
                        //                                                                       textAlign: TextAlign.left,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].cname}',
                        //                                                                       textAlign: TextAlign.center,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '',
                        //                                                                       textAlign: TextAlign.center,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].ref1}',
                        //                                                                       textAlign: TextAlign.center,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].ref2}',
                        //                                                                       textAlign: TextAlign.center,
                        //                                                                       style: TextStyle(color: Colors.amber.shade900, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: AutoSizeText(
                        //                                                                       minFontSize: 10,
                        //                                                                       maxFontSize: 25,
                        //                                                                       maxLines: 1,
                        //                                                                       '${transReChackBillModels[index].ref4}',
                        //                                                                       textAlign: TextAlign.center,
                        //                                                                       style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     ),
                        //                                                                   ),
                        //                                                                   transReChackBillModels[index].transDate == null
                        //                                                                       ? SizedBox()
                        //                                                                       : Expanded(
                        //                                                                           flex: 2,
                        //                                                                           child: AutoSizeText(
                        //                                                                             minFontSize: 10,
                        //                                                                             maxFontSize: 25,
                        //                                                                             maxLines: 1,
                        //                                                                             'Pay by',
                        //                                                                             textAlign: TextAlign.center,
                        //                                                                             style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                           ),
                        //                                                                         ),
                        //                                                                   transReChackBillModels[index].transDate == null
                        //                                                                       ? SizedBox()
                        //                                                                       : Expanded(
                        //                                                                           flex: 2,
                        //                                                                           child: AutoSizeText(
                        //                                                                             minFontSize: 10,
                        //                                                                             maxFontSize: 25,
                        //                                                                             maxLines: 1,
                        //                                                                             '${transReChackBillModels[index].fromName}',
                        //                                                                             textAlign: TextAlign.center,
                        //                                                                             style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                           ),
                        //                                                                         ),
                        //                                                                   transReChackBillModels[index].transDate == null
                        //                                                                       ? SizedBox()
                        //                                                                       : Expanded(
                        //                                                                           flex: 2,
                        //                                                                           child: AutoSizeText(
                        //                                                                             minFontSize: 10,
                        //                                                                             maxFontSize: 25,
                        //                                                                             maxLines: 1,
                        //                                                                             transReChackBillModels[index].amount == null ? '' : '${nFormat.format(double.parse(transReChackBillModels[index].amount.toString()))}',
                        //                                                                             textAlign: TextAlign.center,
                        //                                                                             style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                           ),
                        //                                                                         ),
                        //                                                                   Expanded(
                        //                                                                     flex: 4,
                        //                                                                     child: Translate.TranslateAndSetText('', AccountScreen_Color.Colors_Text1_, TextAlign.right, null, Font_.Fonts_T, 14, 1),
                        //                                                                     //  AutoSizeText(
                        //                                                                     //   minFontSize: 10,
                        //                                                                     //   maxFontSize: 25,
                        //                                                                     //   maxLines: 1,
                        //                                                                     //   transReChackBillModels[index].status == 'payment confirm success'
                        //                                                                     //       ? 'Payment confirm success : ชำระเงินสำเร็จ'
                        //                                                                     //       : transReChackBillModels[index].status == 'require data is missing'
                        //                                                                     //           ? 'Require data is missing : ข้อมูลไม่ครบ'
                        //                                                                     //           : transReChackBillModels[index].status == 'billing_not_found'
                        //                                                                     //               ? 'Billing not found : ไม่พบเอกสารการจ่ายเงิน หรือ จำนวนเงินไม่ถูกต้อง'
                        //                                                                     //               : 'Payment confirm not found : จ่ายเงินไม่สำเร็จ',
                        //                                                                     //   textAlign: TextAlign.right,
                        //                                                                     //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                        //                                                                     // ),
                        //                                                                   ),
                        //                                                                 ],
                        //                                                               ),
                        //                                                               Padding(
                        //                                                                 padding: const EdgeInsets.all(8.0),
                        //                                                                 child: Row(
                        //                                                                   mainAxisAlignment: MainAxisAlignment.end,
                        //                                                                   children: [
                        //                                                                     Translate.TranslateAndSetText(
                        //                                                                         transReChackBillModels[index].status == 'payment confirm success'
                        //                                                                             ? 'Payment confirm success : ชำระเงินสำเร็จ'
                        //                                                                             : transReChackBillModels[index].status == 'require data is missing'
                        //                                                                                 ? 'Require data is missing : ข้อมูลไม่ครบ'
                        //                                                                                 : transReChackBillModels[index].status == 'billing_not_found'
                        //                                                                                     ? 'Billing not found : ไม่พบเอกสารการจ่ายเงิน หรือ จำนวนเงินไม่ถูกต้อง'
                        //                                                                                     : 'Payment confirm not found : จ่ายเงินไม่สำเร็จ',
                        //                                                                         AccountScreen_Color.Colors_Text1_,
                        //                                                                         TextAlign.right,
                        //                                                                         null,
                        //                                                                         Font_.Fonts_T,
                        //                                                                         14,
                        //                                                                         1),
                        //                                                                   ],
                        //                                                                 ),
                        //                                                               )
                        //                                                             ],
                        //                                                           ),
                        //                                                         ),
                        //                                                       )
                        //                                                 ],
                        //                                               ),
                        //                                             ),
                        //                                           ),
                        //                                           if (index + 1 ==
                        //                                                   _TransReBillModels
                        //                                                       .length &&
                        //                                               _TransReBillModels.length !=
                        //                                                   0)
                        //                                             Padding(
                        //                                               padding:
                        //                                                   const EdgeInsets.all(8.0),
                        //                                               child:
                        //                                                   Row(
                        //                                                 children: [
                        //                                                   const AutoSizeText(
                        //                                                     minFontSize: 10,
                        //                                                     maxFontSize: 25,
                        //                                                     maxLines: 1,
                        //                                                     '<<- End ',
                        //                                                     textAlign: TextAlign.center,
                        //                                                     style: TextStyle(color: tappedIndex_Color.End_Colors, fontFamily: Font_.Fonts_T),
                        //                                                   ),
                        //                                                   Expanded(
                        //                                                     child: Container(
                        //                                                       decoration: BoxDecoration(
                        //                                                         // color: Colors
                        //                                                         //     .orange,
                        //                                                         border: Border.all(color: tappedIndex_Color.End_Colors, width: 1),
                        //                                                       ),
                        //                                                       height: 1,
                        //                                                     ),
                        //                                                   ),
                        //                                                   const AutoSizeText(
                        //                                                     minFontSize: 10,
                        //                                                     maxFontSize: 25,
                        //                                                     maxLines: 1,
                        //                                                     ' End ->>',
                        //                                                     textAlign: TextAlign.center,
                        //                                                     style: TextStyle(color: tappedIndex_Color.End_Colors, fontFamily: Font_.Fonts_T),
                        //                                                   ),
                        //                                                 ],
                        //                                               ),
                        //                                             ),
                        //                                         ],
                        //                                       );
                        //                                     })),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        if (Ser_Tap != 0 && Ser_Tap != 1 && Ser_Tap != 2)
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                duration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.easeOut,
                                              );
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  // color: AppbackgroundColor
                                                  //     .TiTile_Colors,
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
                                                                  8)),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: const Text(
                                                  'Top',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (_scrollController2.hasClients) {
                                              final position =
                                                  _scrollController2
                                                      .position.maxScrollExtent;
                                              _scrollController2.animateTo(
                                                position,
                                                duration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                // color: AppbackgroundColor
                                                //     .TiTile_Colors,
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
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: const Text(
                                                'Down',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
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
                                            padding: const EdgeInsets.all(3.0),
                                            child: const Text(
                                              'Scroll',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                        InkWell(
                                          onTap: _moveDown2,
                                          child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
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
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
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

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index) async {
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
                title: Column(
                  children: [
                    Row(
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
                    if (_TransReBillModels[index].inv != null &&
                        _TransReBillModels[index].inv.toString() != '')
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Row(
                          children: [
                            Translate.TranslateAndSetText(
                                'อ้างอิงใบวางบิลเลขที่ : ',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                            Text(
                              '${_TransReBillModels[index].inv2}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                  fontSize: 12.0
                                  //fontSize: 10.0
                                  ),
                            ),
                          ],
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
                                              'รายละเอียดบิล',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.center,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              1),
                                          //  AutoSizeText(
                                          //   minFontSize: 8,
                                          //   maxFontSize: 14,
                                          //   'รายละเอียดบิล', //numinvoice
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
                                          child: Row(
                                            children: [
                                              Translate.TranslateAndSetText(
                                                  'บิลเลขที่ : ',
                                                  AccountScreen_Color
                                                      .Colors_Text1_,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  14,
                                                  1),
                                              Center(
                                                child: AutoSizeText(
                                                  minFontSize: 8,
                                                  maxFontSize: 12,
                                                  '${_TransReBillModels[index].docno}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //  Center(
                                          //   child: Translate.TranslateAndSetText(
                                          //       'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                          //       AccountScreen_Color
                                          //           .Colors_Text1_,
                                          //       TextAlign.center,
                                          //       FontWeight.bold,
                                          //       FontWeight_.Fonts_T,
                                          //       14,
                                          //       1),
                                          //   //  AutoSizeText(
                                          //   //   minFontSize: 8,
                                          //   //   maxFontSize: 12,
                                          //   //   'บิลเลขที่ ${_TransReBillModels[index].docno}', //
                                          //   //   textAlign: TextAlign.center,
                                          //   //   style: const TextStyle(
                                          //   //       color: PeopleChaoScreen_Color
                                          //   //           .Colors_Text1_,
                                          //   //       fontWeight: FontWeight.bold,
                                          //   //       fontFamily:
                                          //   //           FontWeight_.Fonts_T
                                          //   //       //fontSize: 10.0
                                          //   //       //fontSize: 10.0
                                          //   //       ),
                                          //   // ),
                                          // ),
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
                                            14,
                                            1),
                                        //  const AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'ลำดับ',
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
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'วันที่ชำระ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        //  AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'วันที่ชำระ',
                                        //   textAlign: TextAlign.start,
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
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'วันที่ชำระ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //  Translate.TranslateAndSetText(
                                        //     'วันที่ชำระ',
                                        //     AccountScreen_Color.Colors_Text1_,
                                        //     TextAlign.start,
                                        //     FontWeight.bold,
                                        //     FontWeight_.Fonts_T,
                                        //     14,
                                        //     1),
                                        //   textAlign: TextAlign.start,
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
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'รหัสพื้นที่',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.start,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
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
                                            14,
                                            1),
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'เลขตั้งหนี้',
                                        //   textAlign: TextAlign.start,
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
                                        // AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'รายการ',
                                        //   textAlign: TextAlign.start,
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
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'VAT(฿)',
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
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'WHT(฿)',
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
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'ส่วนลด',
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
                                            'ยอดสุทธิ',
                                            AccountScreen_Color.Colors_Text1_,
                                            TextAlign.end,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        //  AutoSizeText(
                                        //   minFontSize: 8,
                                        //   maxFontSize: 14,
                                        //   maxLines: 1,
                                        //   'ยอดสุทธิ',
                                        //   textAlign: TextAlign.end,
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
                                              _TransReBillHistoryModels.length,
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
                                                        maxFontSize: 14,
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .dateacc ==
                                                                null)
                                                            ? ''
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].dateacc} 00:00:00'))}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .date ==
                                                                null)
                                                            ? ''
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransReBillHistoryModels[index].date} 00:00:00'))}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        _TransReBillHistoryModels[
                                                                        index]
                                                                    .ln ==
                                                                null
                                                            ? ''
                                                            : '${_TransReBillHistoryModels[index].ln}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .dtype_tex
                                                                    .toString() ==
                                                                'INV')
                                                            ? '${_TransReBillHistoryModels[index].cid}'
                                                            : _TransReBillHistoryModels[
                                                                            index]
                                                                        .refno ==
                                                                    null
                                                                ? '${_TransReBillHistoryModels[index].inv}'
                                                                : '${_TransReBillHistoryModels[index].refno}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        '${_TransReBillHistoryModels[index].expname}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .vat ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .wht ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .dis ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].dis!))}',
                                                        // '${_TransReBillHistoryModels[index].wht}',
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
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .total ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
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
                                  padding: const EdgeInsets.all(2.0),
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
                                          width: 400,
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
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0}',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.end,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
                                                        1),
                                                //  AutoSizeText(
                                                //   minFontSize: 8,
                                                //   maxFontSize: 13,
                                                //   'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 543}',
                                                //   textAlign: TextAlign.end,
                                                //   style: const TextStyle(
                                                //       color:
                                                //           PeopleChaoScreen_Color
                                                //               .Colors_Text1_,
                                                //       // fontWeight:
                                                //       //     FontWeight
                                                //       //         .bold,
                                                //       fontFamily: Font_.Fonts_T
                                                //       //fontSize: 10.0
                                                //       ),
                                                // ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'รูปแบบการชำระ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.end,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
                                                        1),

                                                //  AutoSizeText(
                                                //   minFontSize: 8,
                                                //   maxFontSize: 13,
                                                //   'รูปแบบการชำระ',
                                                //   textAlign: TextAlign.end,
                                                //   style: TextStyle(
                                                //       color:
                                                //           PeopleChaoScreen_Color
                                                //               .Colors_Text1_,
                                                //       // decoration:
                                                //       //     TextDecoration
                                                //       //         .underline,
                                                //       // decorationStyle:
                                                //       //     TextDecorationStyle
                                                //       //         .dashed,
                                                //       // fontWeight:
                                                //       //     FontWeight
                                                //       //         .bold,
                                                //       fontFamily:
                                                //           FontWeight_.Fonts_T
                                                //       //fontSize: 10.0
                                                //       ),
                                                // ),
                                              ),
                                              for (var i = 0;
                                                  i <
                                                      finnancetransModels
                                                          .length;
                                                  i++)
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Translate.TranslateAndSetText(
                                                          '${i + 1}. จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท (${finnancetransModels[i].ptname})',
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.start,
                                                          null,
                                                          Font_.Fonts_T,
                                                          12,
                                                          1),
                                                      // AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 13,
                                                      //   '${i + 1}. จำนวน ${nFormat.format(double.parse(finnancetransModels[i].amt!))} บาท (${finnancetransModels[i].ptname})',
                                                      //   style: const TextStyle(
                                                      //       color: PeopleChaoScreen_Color
                                                      //           .Colors_Text2_,
                                                      //       fontWeight:
                                                      //           FontWeight.w500,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                      if (finnancetransModels[i]
                                                              .type
                                                              .toString() !=
                                                          'CASH')
                                                        Translate
                                                            .TranslateAndSetText(
                                                                '  ** ${i + 1}.1. ธนาคาร : ${finnancetransModels[i].bank} , เลขบช. : ${finnancetransModels[i].bno}',
                                                                Colors
                                                                    .grey[800],
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                11,
                                                                2),
                                                      // AutoSizeText(
                                                      //   minFontSize: 8,
                                                      //   maxFontSize: 11,
                                                      //   '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                                      //   style: TextStyle(
                                                      //       color:
                                                      // Colors
                                                      //           .grey[800],
                                                      //       //fontWeight: FontWeight.bold,
                                                      //       fontFamily: Font_
                                                      //           .Fonts_T),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
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
                                                                    'รวม(บาท)',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
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
                                                                12,
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
                                                                12,
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
                                                                    12,
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
                                                                    12,
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
                                                                    12,
                                                                    1),

                                                            // AutoSizeText(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (finnancetransModels.any((transaction) {
                                  return transaction.ptser.toString().trim() ==
                                      '7';
                                }) ==
                                false)
                              if (transReChackBillModels.length != 0)
                                if (transReChackBillModels[index].status ==
                                    'payment confirm success')
                                  SizedBox()
                                else
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    width: 180,
                                    child: InkWell(
                                      onTap: () {
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
                                                      title: Center(
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ถูกต้อง/อนุมัติ การรับชำระ',
                                                                Colors.orange,
                                                                TextAlign
                                                                    .center,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                              child: ListBody(
                                                                  children: <Widget>[
                                                            const SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Translate.TranslateAndSetText(
                                                                'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // color: Colors.grey,
                                                                  borderRadius: const BorderRadius
                                                                          .only(
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
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Translate.TranslateAndSetText(
                                                                        'ยอดชำระ ',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    // const Text(
                                                                    //   'ยอดชำระ ',
                                                                    //   style: TextStyle(
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       fontWeight: FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                    Text(
                                                                      '- ${nFormat.format(sum_amt - sum_disamt)}',
                                                                      style: const TextStyle(
                                                                          fontSize: 14,
                                                                          color: AccountScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              4,
                                                                              0,
                                                                              0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หลักฐานการชำระ ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text2_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //     Text(
                                                                      //   'หลักฐานการชำระ ',
                                                                      //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                      // ),
                                                                    ),
                                                                    Translate.TranslateAndSetText(
                                                                        (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                                            ? '- ไม่พบหลักฐาน ✖️'
                                                                            : '- พบหลักฐาน ✔️',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        null,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    // Text(
                                                                    //   (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                                    //       ? '- ไม่พบหลักฐาน ✖️'
                                                                    //       : '- พบหลักฐาน ✔️',
                                                                    //   style: const TextStyle(
                                                                    //       fontSize: 14,
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       //(Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? Colors.red : Colors.green,
                                                                    //       // fontWeight:
                                                                    //       //     FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                    Text(
                                                                      (Slip_history.toString() == '' ||
                                                                              Slip_history == null ||
                                                                              Slip_history.toString() == 'null')
                                                                          ? ''
                                                                          : '($Slip_history)',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontFamily:
                                                                              Font_.Fonts_T),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              4,
                                                                              0,
                                                                              0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'ผู้ตรวจสอบ/อนุมัติ ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text2_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //     Text(
                                                                      //   'ผู้ตรวจสอบ/อนุมัติ ',
                                                                      //   style: TextStyle(color: AccountScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                      // ),
                                                                    ),
                                                                    Text(
                                                                      '- ${email_login}($seremail_login)',
                                                                      style: const TextStyle(
                                                                          fontSize: 14,
                                                                          color: AccountScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily: Font_.Fonts_T),
                                                                    ),
                                                                    StreamBuilder(
                                                                        stream: Stream.periodic(const Duration(
                                                                            seconds:
                                                                                0)),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          return Column(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Container(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      const Text(
                                                                                        'CODE : ',
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.all(2),
                                                                                        child: Container(
                                                                                          decoration: const BoxDecoration(
                                                                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            color: Color.fromARGB(255, 179, 177, 170),
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
                                                                                              style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
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
                                                                            ],
                                                                          );
                                                                        }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ])),
                                                      actions: <Widget>[
                                                        Column(
                                                          children: [
                                                            Translate.TranslateAndSetText(
                                                                '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                                Colors.red[800],
                                                                TextAlign
                                                                    .center,
                                                                FontWeight.bold,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            // Text(
                                                            //   '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                            //   style: TextStyle(
                                                            //       color: Colors.red[
                                                            //           800],
                                                            //       fontFamily:
                                                            //           Font_.Fonts_T),
                                                            // ),
                                                            const SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            const Divider(
                                                              color:
                                                                  Colors.grey,
                                                              height: 1.0,
                                                            ),
                                                            const SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                StreamBuilder(
                                                                    stream: Stream.periodic(const Duration(
                                                                        seconds:
                                                                            0)),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              150,
                                                                          height:
                                                                              40,
                                                                          // ignore: deprecated_member_use
                                                                          child:
                                                                              ElevatedButton(
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: (Pincontroller.text != "$randomString") ? Colors.grey : Colors.green,
                                                                            ),
                                                                            onPressed: (Pincontroller.text != "$randomString")
                                                                                ? null
                                                                                : () async {
                                                                                    SharedPreferences preferences = await SharedPreferences.getInstance();

                                                                                    var ren = preferences.getString('renTalSer');
                                                                                    var Remark = _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}';
                                                                                    var ser_userVerifi = '$seremail_login';
                                                                                    // '${email_login}($seremail_login)';
                                                                                    var docno = _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}';

                                                                                    // '${_TransReBillModels[index].docno}';

                                                                                    String url = '${MyConstant().domain}/OK_Verifi_Payment_con.php?isAdd=true&ren=$ren&ciddoc=$docno&Re_mark=$Remark&ser_user=$ser_userVerifi';

                                                                                    try {
                                                                                      var response = await http.get(Uri.parse(url));

                                                                                      var result = json.decode(response.body);
                                                                                      if (result.toString() == 'true') {
                                                                                        Insert_log.Insert_logs('บัญชี', 'ประวัติบิลรอตรวจสอบ>>อนุมัติ($docno,ผู้อนุมัตื:${Remark})');
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(backgroundColor: Colors.green, content: Text('$docno อนุมัติเสร็จสิ้น!', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                        );
                                                                                        Navigator.pop(context, 'OK');
                                                                                        Navigator.pop(context, 'OK');
                                                                                        setState(() {
                                                                                          Pincontroller.clear;
                                                                                          checkPreferance();
                                                                                          red_Trans_bill();
                                                                                          read_GC_rental();
                                                                                        });
                                                                                      }
                                                                                    } catch (e) {
                                                                                      Pincontroller.clear;
                                                                                    }
                                                                                  },
                                                                            child:
                                                                                const Text(
                                                                              'ยืนยัน-Confirm',
                                                                              style: TextStyle(
                                                                                // fontSize: 20.0,
                                                                                // fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            // color: Colors.black,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    width: 150,
                                                                    height: 40,
                                                                    // ignore: deprecated_member_use
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.black,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          Formbecause_
                                                                              .clear();
                                                                        });
                                                                        Navigator.pop(
                                                                            context,
                                                                            'OK');
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'ปิด-Close',
                                                                        style:
                                                                            TextStyle(
                                                                          // fontSize: 20.0,
                                                                          // fontWeight: FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      // color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green[400],
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.check,
                                                    color: Colors.black),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ถูกต้อง/อนุมัติ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        null,
                                                        Font_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'ถูกต้อง/อนุมัติ',
                                                //   style: TextStyle(
                                                //     color: Colors.black,
                                                //     // fontWeight:
                                                //     //     FontWeight.bold,
                                                //     fontFamily: Font_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  )
                              else
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  width: 180,
                                  child: InkWell(
                                    onTap: () {
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
                                                    title: Center(
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ถูกต้อง/อนุมัติ การรับชำระ',
                                                              Colors.orange,
                                                              TextAlign.center,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                    ),
                                                    content:
                                                        SingleChildScrollView(
                                                            child: ListBody(
                                                                children: <Widget>[
                                                          const SizedBox(
                                                            height: 2.0,
                                                          ),
                                                          Translate.TranslateAndSetText(
                                                              'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                              AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: Colors.grey,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            6),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            6),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            6),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            6)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Translate.TranslateAndSetText(
                                                                      'ยอดชำระ ',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .bold,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  // const Text(
                                                                  //   'ยอดชำระ ',
                                                                  //   style: TextStyle(
                                                                  //       color: AccountScreen_Color.Colors_Text2_,
                                                                  //       fontWeight: FontWeight.bold,
                                                                  //       fontFamily: Font_.Fonts_T),
                                                                  // ),
                                                                  Text(
                                                                    '- ${nFormat.format(sum_amt - sum_disamt)}',
                                                                    style: const TextStyle(
                                                                        fontSize: 14,
                                                                        color: AccountScreen_Color.Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                    child: Translate.TranslateAndSetText(
                                                                        'หลักฐานการชำระ ',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    //     Text(
                                                                    //   'หลักฐานการชำระ ',
                                                                    //   style: TextStyle(
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       fontWeight: FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                  ),
                                                                  Translate.TranslateAndSetText(
                                                                      (Slip_history.toString() == '' ||
                                                                              Slip_history ==
                                                                                  null ||
                                                                              Slip_history.toString() ==
                                                                                  'null')
                                                                          ? '- ไม่พบหลักฐาน ✖️'
                                                                          : '- พบหลักฐาน ✔️',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  // Text(
                                                                  //   (Slip_history.toString() == '' || Slip_history == null || Slip_history.toString() == 'null')
                                                                  //       ? '- ไม่พบหลักฐาน ✖️'
                                                                  //       : '- พบหลักฐาน ✔️',
                                                                  //   style: const TextStyle(
                                                                  //       fontSize: 14,
                                                                  //       color: AccountScreen_Color.Colors_Text2_,
                                                                  //       //(Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? Colors.red : Colors.green,
                                                                  //       // fontWeight:
                                                                  //       //     FontWeight.bold,
                                                                  //       fontFamily: Font_.Fonts_T),
                                                                  // ),
                                                                  Text(
                                                                    (Slip_history.toString() == '' ||
                                                                            Slip_history ==
                                                                                null ||
                                                                            Slip_history.toString() ==
                                                                                'null')
                                                                        ? ''
                                                                        : '($Slip_history)',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontFamily:
                                                                            Font_.Fonts_T),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            4,
                                                                            0,
                                                                            0),
                                                                    child: Translate.TranslateAndSetText(
                                                                        'ผู้ตรวจสอบ/อนุมัติ ',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    //     Text(
                                                                    //   'ผู้ตรวจสอบ/อนุมัติ ',
                                                                    //   style: TextStyle(
                                                                    //       color: AccountScreen_Color.Colors_Text2_,
                                                                    //       fontWeight: FontWeight.bold,
                                                                    //       fontFamily: Font_.Fonts_T),
                                                                    // ),
                                                                  ),
                                                                  Text(
                                                                    '- ${email_login}($seremail_login)',
                                                                    style: const TextStyle(
                                                                        fontSize: 14,
                                                                        color: AccountScreen_Color.Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                  StreamBuilder(
                                                                      stream: Stream.periodic(const Duration(
                                                                          seconds:
                                                                              0)),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        return Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Container(
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    const Text(
                                                                                      'CODE : ',
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(2),
                                                                                      child: Container(
                                                                                        decoration: const BoxDecoration(
                                                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                          color: Color.fromARGB(255, 179, 177, 170),
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
                                                                                            style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
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
                                                                          ],
                                                                        );
                                                                      }),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ])),
                                                    actions: <Widget>[
                                                      Column(
                                                        children: [
                                                          Translate
                                                              .TranslateAndSetText(
                                                                  '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                                  Colors
                                                                      .red[800],
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          // Text(
                                                          //   '** โปรดตรวจสอบความถูกต้องทุกครั้งก่อนอนุมัติ',
                                                          //   style: TextStyle(
                                                          //       color: Colors
                                                          //               .red[
                                                          //           800],
                                                          //       fontFamily:
                                                          //           Font_
                                                          //               .Fonts_T),
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
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              StreamBuilder(
                                                                  stream: Stream.periodic(
                                                                      const Duration(
                                                                          seconds:
                                                                              0)),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    return Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            150,
                                                                        height:
                                                                            40,
                                                                        // ignore: deprecated_member_use
                                                                        child:
                                                                            ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor: (Pincontroller.text != "$randomString")
                                                                                ? Colors.grey
                                                                                : Colors.green,
                                                                          ),
                                                                          onPressed: (Pincontroller.text != "$randomString")
                                                                              ? null
                                                                              : () async {
                                                                                  SharedPreferences preferences = await SharedPreferences.getInstance();

                                                                                  var ren = preferences.getString('renTalSer');
                                                                                  var Remark = _TransReBillModels[index].sname == null ? '${_TransReBillModels[index].remark}' : '${_TransReBillModels[index].sname}';
                                                                                  var ser_userVerifi = '$seremail_login';
                                                                                  // '${email_login}($seremail_login)';
                                                                                  var docno = _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}';

                                                                                  // '${_TransReBillModels[index].docno}';

                                                                                  String url = '${MyConstant().domain}/OK_Verifi_Payment_con.php?isAdd=true&ren=$ren&ciddoc=$docno&Re_mark=$Remark&ser_user=$ser_userVerifi';
                                                                                  // print(url);
                                                                                  try {
                                                                                    var response = await http.get(Uri.parse(url));

                                                                                    var result = json.decode(response.body);

                                                                                    // print(result.toString());
                                                                                    if (result.toString() == 'true') {
                                                                                      Navigator.pop(context, 'OK');
                                                                                      Navigator.pop(context, 'OK');
                                                                                      Insert_log.Insert_logs('บัญชี', 'ประวัติบิลรอตรวจสอบ>>อนุมัติ($docno,ผู้อนุมัติ:${Remark})');
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        SnackBar(backgroundColor: Colors.green, content: Text('$docno อนุมัติเสร็จสิ้น!', style: const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                      );
                                                                                      setState(() {
                                                                                        Pincontroller.clear;
                                                                                        checkPreferance();
                                                                                        red_Trans_bill();
                                                                                        read_GC_rental();
                                                                                      });
                                                                                    }
                                                                                  } catch (e) {
                                                                                    Pincontroller.clear;
                                                                                  }
                                                                                },
                                                                          child:
                                                                              const Text(
                                                                            'ยืนยัน-Confirm',
                                                                            style:
                                                                                TextStyle(
                                                                              // fontSize: 20.0,
                                                                              // fontWeight: FontWeight.bold,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          // color: Colors.black,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    Container(
                                                                  width: 150,
                                                                  height: 40,
                                                                  // ignore: deprecated_member_use
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        Formbecause_
                                                                            .clear();
                                                                      });
                                                                      Navigator.pop(
                                                                          context,
                                                                          'OK');
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'ปิด-Close',
                                                                      style:
                                                                          TextStyle(
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
                                                        ],
                                                      ),
                                                    ],
                                                  ));
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.check,
                                                  color: Colors.black),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ถูกต้อง/อนุมัติ',
                                                      AccountScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.center,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                              // Text(
                                              //   'ถูกต้อง/อนุมัติ',
                                              //   style: TextStyle(
                                              //     color: Colors.black,
                                              //     // fontWeight:
                                              //     //     FontWeight.bold,
                                              //     fontFamily: Font_.Fonts_T,
                                              //   ),
                                              // ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                            (Slip_history.toString() == '' ||
                                    Slip_history == null ||
                                    Slip_history.toString() == 'null')
                                ? Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 150,
                                          height: 40,
                                          // ignore: deprecated_member_use
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                            ),
                                            onPressed: () async {
                                              uploadFile_Slip_Again(
                                                  context,
                                                  '${_TransReBillModels[index].docno}',
                                                  '${_TransReBillModels[index].pdate}',
                                                  'รอตรวจสอบ',
                                                  '${_TransReBillModels[index].slip}',
                                                  foder);
                                            },
                                            child:
                                                Translate.TranslateAndSetText(
                                                    ' + เพิ่มหลักฐาน',
                                                    Colors.grey[300],
                                                    // Colors.white,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4.0),
                                        width: 180,
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              numinvoice =
                                                  _TransReBillModels[index]
                                                      .docno!;
                                            });
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                title: Center(
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ยกเลิกการรับชำระ',
                                                          Colors.red,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                content: Container(
                                                  height: 120,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 2.0,
                                                      ),
                                                      Translate.TranslateAndSetText(
                                                          'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          null,
                                                          Font_.Fonts_T,
                                                          14,
                                                          1),
                                                      // Text(
                                                      //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                      //   style: const TextStyle(
                                                      //       color:
                                                      //           AccountScreen_Color
                                                      //               .Colors_Text2_,
                                                      //       // fontWeight:
                                                      //       //     FontWeight.bold,
                                                      //       fontFamily:
                                                      //           Font_.Fonts_T),
                                                      // ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              Formbecause_,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
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
                                                                  filled: true,
                                                                  // prefixIcon: const Icon(Icons.water,
                                                                  //     color: Colors.blue),
                                                                  // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                  focusedBorder:
                                                                      const OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              15),
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                  enabledBorder:
                                                                      const OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              15),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              15),
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                  labelText:
                                                                      'หมายเหตุ-Note',
                                                                  labelStyle:
                                                                      const TextStyle(
                                                                    color: AccountScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight:
                                                                    //     FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width: 150,
                                                      height: 40,
                                                      // ignore: deprecated_member_use
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                        onPressed: () {
                                                          String Formbecause =
                                                              Formbecause_.text
                                                                  .toString();
                                                          if (Formbecause ==
                                                              '') {
                                                            showDialog<String>(
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
                                                                      'กรุณากรอกเหตุผล !!',
                                                                      AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  //     Text(
                                                                  //   'กรุณากรอกเหตุผล !!',
                                                                  //   style: TextStyle(
                                                                  //       color: AdminScafScreen_Color
                                                                  //           .Colors_Text1_,
                                                                  //       fontWeight:
                                                                  //           FontWeight
                                                                  //               .bold,
                                                                  //       fontFamily:
                                                                  //           FontWeight_
                                                                  //               .Fonts_T),
                                                                  // )
                                                                ),
                                                                actions: <Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              100,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.redAccent,
                                                                            borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10)),
                                                                          ),
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context, 'OK'),
                                                                            child: Translate.TranslateAndSetText(
                                                                                'ปิด',
                                                                                Colors.white,
                                                                                TextAlign.center,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            //     const Text(
                                                                            //   'ปิด',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors.white,
                                                                            //       fontWeight: FontWeight.bold,
                                                                            //       fontFamily: FontWeight_.Fonts_T),
                                                                            // ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            if (finnancetransModels
                                                                    .any(
                                                                        (transaction) {
                                                                  return transaction
                                                                          .ptser
                                                                          .toString()
                                                                          .trim() ==
                                                                      '7';
                                                                }) ==
                                                                false) {
                                                              pPC_finantIbill(
                                                                      Formbecause)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Navigator.pop(context),
                                                                            Future.delayed(const Duration(milliseconds: 600),
                                                                                () async {
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
                                                                      ref_1,
                                                                      Pay_Ke,
                                                                      renTal_user,
                                                                      _TransReBillModels[
                                                                              index]
                                                                          .docno,
                                                                      Formbecause)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            // _timer.cancel(),
                                                                            Navigator.pop(context),
                                                                            Navigator.pop(context),
                                                                            Future.delayed(Duration(milliseconds: 600),
                                                                                () async {
                                                                              Dialog_cancellock();
                                                                            }),
                                                                          });
                                                            }
                                                          }
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ยืนยัน',
                                                                Colors.white,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  const Text(
                                                        //   'ยืนยัน',
                                                        //   style: TextStyle(
                                                        //     // fontSize: 20.0,
                                                        //     // fontWeight: FontWeight.bold,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        // color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width: 150,
                                                      height: 40,
                                                      // ignore: deprecated_member_use
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
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
                                                              context, 'OK');
                                                        },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปิด',
                                                                Colors.white,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        //  const Text(
                                                        //   'ปิด',
                                                        //   style: TextStyle(
                                                        //     // fontSize: 20.0,
                                                        //     // fontWeight: FontWeight.bold,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        // color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red[200],
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Icon(
                                                        Icons
                                                            .cancel_presentation,
                                                        color: Colors.black),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยกเลิกการรับชำระ',
                                                            AccountScreen_Color
                                                                .Colors_Text2_,
                                                            TextAlign.center,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                    // Text(
                                                    //   'ยกเลิกการรับชำระ',
                                                    //   style: TextStyle(
                                                    //     color:
                                                    //      AccountScreen_Color
                                                    //         .Colors_Text2_,
                                                    //     // fontWeight:
                                                    //     //     FontWeight.bold,
                                                    //     fontFamily: Font_.Fonts_T,
                                                    //   ),
                                                    // ),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(4.0),
                                    // width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        (Slip_history.toString() == '' ||
                                                Slip_history == null ||
                                                Slip_history.toString() ==
                                                    'null')
                                            ? const SizedBox()
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                // width: 210,
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        bool
                                                            hasNonCashTransaction =
                                                            finnancetransModels
                                                                .any(
                                                                    (transaction) {
                                                          return transaction
                                                                  .ptser
                                                                  .toString()
                                                                  .trim() ==
                                                              '7';
                                                        });

                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
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
                                                                  title: Center(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(4.0),
                                                                                child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Translate.TranslateAndSetText(
                                                                            'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                                                            AccountScreen_Color.Colors_Text1_,
                                                                            TextAlign.start,
                                                                            FontWeight.bold,
                                                                            FontWeight_.Fonts_T,
                                                                            14,
                                                                            1),
                                                                        // Text(
                                                                        //   'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                                                        //   maxLines: 1,
                                                                        //   textAlign:
                                                                        //       TextAlign
                                                                        //           .start,
                                                                        //   style: const TextStyle(
                                                                        //       color: Colors
                                                                        //           .black,
                                                                        //       fontWeight:
                                                                        //           FontWeight
                                                                        //               .bold,
                                                                        //       fontFamily:
                                                                        //           FontWeight_
                                                                        //               .Fonts_T,
                                                                        //       fontSize:
                                                                        //           12.0),
                                                                        // ),
                                                                        (hasNonCashTransaction ==
                                                                                true)
                                                                            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(2.0),
                                                                                  child: Text(
                                                                                    '${Slip_history}',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                  ),
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () async {
                                                                                    final String url = '${ref_2}';
                                                                                    if (await canLaunch(url)) {
                                                                                      await launch(url);
                                                                                    } else {
                                                                                      throw 'Could not launch $url';
                                                                                    }
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.open_in_browser,
                                                                                    color: Colors.blue,
                                                                                    size: 20,
                                                                                  ),
                                                                                ),
                                                                              ])
                                                                            : Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    '${Slip_history}',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () => downloadImage_slip('${MyConstant().domain}/files/$foder/slip/${Slip_history}', '${_TransReBillModels[index].docno}'),
                                                                                    child: Icon(
                                                                                      Icons.download,
                                                                                      color: Colors.blue,
                                                                                      size: 20,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  content: (hasNonCashTransaction ==
                                                                          true)
                                                                      ? StreamBuilder(
                                                                          stream: Stream.periodic(const Duration(seconds: 0)),
                                                                          builder: (context, snapshot) {
                                                                            return SingleChildScrollView(
                                                                              child: ListBody(
                                                                                children: <Widget>[
                                                                                  Container(
                                                                                    // height: 600,
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    child: WebViewX2Pagebeamcheck(id_ser: (Slip_history == '' || Slip_history == null) ? ref_2 : Slip_history),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          })
                                                                      : SingleChildScrollView(
                                                                          child: ListBody(children: <Widget>[
                                                                          SizedBox(
                                                                            width:
                                                                                300,
                                                                            child:
                                                                                Image.network('${MyConstant().domain}/files/$foder/slip/${Slip_history}'),
                                                                          )
                                                                        ])),
                                                                  actions: <Widget>[
                                                                (hasNonCashTransaction ==
                                                                        true)
                                                                    ? SizedBox()
                                                                    : SizedBox(
                                                                        // width: 300,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Translate.TranslateAndSetText(
                                                                                '*** วิธีตรวจสอบ "สลิป" เบื้องต้น',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                FontWeight.bold,
                                                                                FontWeight_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '*** วิธีตรวจสอบ "สลิป" เบื้องต้น',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           13,
                                                                            //       fontWeight:
                                                                            //           FontWeight
                                                                            //               .bold,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '1. สังเกตความละเอียดของ ตัวเลข หรือ ตัวหนังสือ',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '1. สังเกตความละเอียดของ ตัวเลข หรือ ตัวหนังสือ',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '2. เปิดแอปฯ ธนาคารขึ้นมา สแกน QR CODE บนสลิปโอนเงิน',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '2. เปิดแอปฯ ธนาคารขึ้นมา สแกน QR CODE บนสลิปโอนเงิน',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '3. ใช้  Mobile Banking เช็ก ยอดเงิน วัน-เวลาที่โอน ตรงกับในสลิปที่ได้มาหรือไม่',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '3. ใช้  Mobile Banking เช็ก ยอดเงิน วัน-เวลาที่โอน ตรงกับในสลิปที่ได้มาหรือไม่',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
                                                                            Translate.TranslateAndSetText(
                                                                                '4. ควรตรวจสอบสลิปทันทีที่ได้รับมา เพราะ QR code บนสลิปของบางธนาคารจะมีอายุจำกัด ตั้งเเต่ 7 วัน ถึง 60 วัน ',
                                                                                Colors.red,
                                                                                TextAlign.start,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                1),
                                                                            // const Text(
                                                                            //   '4. ควรตรวจสอบสลิปทันทีที่ได้รับมา เพราะ QR code บนสลิปของบางธนาคารจะมีอายุจำกัด ตั้งเเต่ 7 วัน ถึง 60 วัน ',
                                                                            //   style: TextStyle(
                                                                            //       color: Colors
                                                                            //           .red,
                                                                            //       fontSize:
                                                                            //           12,
                                                                            //       fontFamily:
                                                                            //           Font_.Fonts_T),
                                                                            // ),
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
                                                                            // Row(
                                                                            //   mainAxisAlignment:
                                                                            //       MainAxisAlignment.end,
                                                                            //   children: [
                                                                            //     Padding(
                                                                            //       padding: const EdgeInsets.all(8.0),
                                                                            //       child: Container(
                                                                            //         width: 100,
                                                                            //         decoration: const BoxDecoration(
                                                                            //           color: Colors.black,
                                                                            //           borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                            //         ),
                                                                            //         padding: const EdgeInsets.all(8.0),
                                                                            //         child: TextButton(
                                                                            //           onPressed: () => Navigator.pop(context, 'OK'),
                                                                            //           child: const Text(
                                                                            //             'ปิด',
                                                                            //             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            //           ),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ),
                                                                            //   ],
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ]),
                                                        );
                                                      },
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue[200],
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        6),
                                                                topRight: (renTal_lavel <=
                                                                        2)
                                                                    ? Radius.circular(
                                                                        6)
                                                                    : Radius.circular(
                                                                        0),
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                        6),
                                                                bottomRight: (renTal_lavel <=
                                                                        2)
                                                                    ? Radius
                                                                        .circular(
                                                                            6)
                                                                    : Radius
                                                                        .circular(
                                                                            0)),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1),
                                                          ),
                                                          child: (finnancetransModels
                                                                      .any(
                                                                          (transaction) {
                                                                    return transaction
                                                                            .ptser
                                                                            .toString()
                                                                            .trim() ==
                                                                        '7';
                                                                  }) ==
                                                                  false)
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
                                                                              .image,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'หลักฐานการชำระ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          null,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //  Text(
                                                                      //   'หลักฐานการชำระ',
                                                                      //   style: TextStyle(
                                                                      //     color: AccountScreen_Color
                                                                      //         .Colors_Text2_,
                                                                      //     // fontWeight:
                                                                      //     //     FontWeight.bold,
                                                                      //     fontFamily: Font_
                                                                      //         .Fonts_T,
                                                                      //   ),
                                                                      // ),
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
                                                                          const EdgeInsets.fromLTRB(
                                                                              4,
                                                                              0,
                                                                              4,
                                                                              0),
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius:
                                                                            12.0,
                                                                        backgroundImage:
                                                                            AssetImage('images/LogoBank/BEAM.png'),
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4.0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'ชำระ/ตรวจสอบ',
                                                                          AccountScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          null,
                                                                          Font_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                      //  Text(
                                                                      //   'ชำระ/ตรวจสอบ',
                                                                      //   style: TextStyle(
                                                                      //     color: AccountScreen_Color
                                                                      //         .Colors_Text2_,
                                                                      //     // fontWeight:
                                                                      //     //     FontWeight.bold,
                                                                      //     fontFamily: Font_
                                                                      //         .Fonts_T,
                                                                      //   ),
                                                                      // ),
                                                                    ),
                                                                  ],
                                                                )),
                                                    ),
                                                    (renTal_lavel <= 2)
                                                        ? Container()
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blueGrey,
                                                              borderRadius: const BorderRadius
                                                                      .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6)),
                                                              // border: Border.all(
                                                              //     color: Colors.grey,
                                                              //     width: 1),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4.0),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  uploadFile_Slip_Again(
                                                                      context,
                                                                      '${_TransReBillModels[index].docno}',
                                                                      '${_TransReBillModels[index].pdate}',
                                                                      'รอตรวจสอบ',
                                                                      '${_TransReBillModels[index].slip}',
                                                                      foder);
                                                                },
                                                                child: Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                            .grey[
                                                                        300]),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          width: 180,
                                          child: InkWell(
                                            onTap: () async {
                                              setState(() {
                                                numinvoice =
                                                    _TransReBillModels[index]
                                                        .docno!;
                                              });
                                              showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20.0))),
                                                  title: Center(
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ยกเลิกการรับชำระ',
                                                            Colors.red,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                  ),
                                                  content: Container(
                                                    height: 120,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 2.0,
                                                        ),
                                                        Translate.TranslateAndSetText(
                                                            'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                            AccountScreen_Color
                                                                .Colors_Text2_,
                                                            TextAlign.center,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1),
                                                        // Text(
                                                        //   'บิลเลขที่ ${_TransReBillModels[index].docno}',
                                                        //   style: const TextStyle(
                                                        //       color:
                                                        //           AccountScreen_Color
                                                        //               .Colors_Text2_,
                                                        //       // fontWeight:
                                                        //       //     FontWeight.bold,
                                                        //       fontFamily:
                                                        //           Font_.Fonts_T),
                                                        // ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                Formbecause_,
                                                            validator: (value) {
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
                                                                          BorderRadius
                                                                              .only(
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
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
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
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    labelText:
                                                                        'หมายเหตุ-Note',
                                                                    labelStyle:
                                                                        const TextStyle(
                                                                      color: AccountScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        width: 150,
                                                        height: 40,
                                                        // ignore: deprecated_member_use
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                          onPressed: () {
                                                            String Formbecause =
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
                                                                          BorderRadius.all(
                                                                              Radius.circular(20.0))),
                                                                  title: Center(
                                                                    child: Translate.TranslateAndSetText(
                                                                        'กรุณากรอกเหตุผล !!',
                                                                        AccountScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        null,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    //     Text(
                                                                    //   'กรุณากรอกเหตุผล !!',
                                                                    //   style: TextStyle(
                                                                    //       color: AdminScafScreen_Color
                                                                    //           .Colors_Text1_,
                                                                    //       fontWeight:
                                                                    //           FontWeight
                                                                    //               .bold,
                                                                    //       fontFamily:
                                                                    //           FontWeight_
                                                                    //               .Fonts_T),
                                                                    // )
                                                                  ),
                                                                  actions: <Widget>[
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                100,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors.redAccent,
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                            ),
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                TextButton(
                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                              child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                                                                              //     const Text(
                                                                              //   'ปิด',
                                                                              //   style: TextStyle(
                                                                              //       color: Colors.white,
                                                                              //       fontWeight: FontWeight.bold,
                                                                              //       fontFamily: FontWeight_.Fonts_T),
                                                                              // ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            } else {
                                                              if (finnancetransModels
                                                                      .any(
                                                                          (transaction) {
                                                                    return transaction
                                                                            .ptser
                                                                            .toString()
                                                                            .trim() ==
                                                                        '7';
                                                                  }) ==
                                                                  false) {
                                                                pPC_finantIbill(
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
                                                                        ref_1,
                                                                        Pay_Ke,
                                                                        renTal_user,
                                                                        _TransReBillModels[index]
                                                                            .docno,
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
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ยืนยัน',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  const Text(
                                                          //   'ยืนยัน',
                                                          //   style: TextStyle(
                                                          //     // fontSize: 20.0,
                                                          //     // fontWeight: FontWeight.bold,
                                                          //     color: Colors.white,
                                                          //   ),
                                                          // ),
                                                          // color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        width: 150,
                                                        height: 40,
                                                        // ignore: deprecated_member_use
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
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
                                                                context, 'OK');
                                                          },
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ปิด',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  const Text(
                                                          //   'ปิด',
                                                          //   style: TextStyle(
                                                          //     // fontSize: 20.0,
                                                          //     // fontWeight: FontWeight.bold,
                                                          //     color: Colors.white,
                                                          //   ),
                                                          // ),
                                                          // color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red[200],
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
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Icon(
                                                          Icons
                                                              .cancel_presentation,
                                                          color: Colors.black),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'ยกเลิกการรับชำระ',
                                                              AccountScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),
                                                      // Text(
                                                      //   'ยกเลิกการรับชำระ',
                                                      //   style: TextStyle(
                                                      //     color:
                                                      //      AccountScreen_Color
                                                      //         .Colors_Text2_,
                                                      //     // fontWeight:
                                                      //     //     FontWeight.bold,
                                                      //     fontFamily: Font_.Fonts_T,
                                                      //   ),
                                                      // ),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ),
                                        if (_TransReBillModels[index]
                                                .pay_by
                                                .toString() ==
                                            'LP')
                                          Container(
                                            padding: const EdgeInsets.all(4.0),
                                            width: 180,
                                            child: InkWell(
                                              onTap: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                var ren = preferences
                                                    .getString('renTalSer');
                                                var cFinn_now = _TransReBillModels[
                                                                index]
                                                            .doctax ==
                                                        ''
                                                    ? '${_TransReBillModels[index].docno}'
                                                    : '${_TransReBillModels[index].doctax}';
                                                // print(cFinn_now);
                                                ManPay_ReceiptMarket_PDF
                                                    .ManPayReceiptMarket_PDF(
                                                  context,
                                                  ren,
                                                  foder,
                                                  cFinn_now,
                                                  bill_addr,
                                                  bill_email,
                                                  bill_tel,
                                                  bill_tax,
                                                  bill_name,
                                                );
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[200],
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
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(Icons.print,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'พิมพ์(Web Market)',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                13,
                                                                1),
                                                        //  Text(
                                                        //   'พิมพ์',
                                                        //   style: TextStyle(
                                                        //     color: AccountScreen_Color
                                                        //         .Colors_Text2_,
                                                        //     // fontWeight:
                                                        //     //     FontWeight.bold,
                                                        //     fontFamily: Font_.Fonts_T,
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  List<String> listchack = [];

  Future<void> selectFileAndReadExcel() async {
    int index = 0;

    ///------------------------->
    setState(() {
      limitedList_bankExcBilling.clear();
      index = 0;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xlsx',
        'csv'
      ], // Add the file extensions you want to allow
    );
    // print(result);

    ///------------------------->
    try {
      ///------------------------->
      if (result != null) {
        final file = result.files.single;
        // print('Selected file: ${file.name}');
        if (file.extension == 'xlsx') {
          final Uint8List bytes = file.bytes!;
          final excel = Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            // print(index);
            for (var row in excel.tables[table]!.rows) {
              if (index <= 6) {
                index++;
                // print(index);
                // excel.tables[table]!.rows.length;
              } else if (index + 6 >= excel.tables[table]!.rows.length) {
                index++;
                // print(index);
              } else {
                var EX_No = '${row[0]!.value}';
                var PAY_TIME = '${row[1]!.value}';
                var CUSTOMER_NO = '${row[2]!.value}';

                var CUSTOMER_NAME = '${row[3]!.value}';
                var PAY_DATE = '${row[4]!.value}';
                var REFERENCE_NO = '${row[5]!.value}';
                var REFERENCE_NO3 = '${row[6]!.value}';

                var FR_BR = '${row[7]!.value}';
                var AMOUNT = '${row[8]!.value}';
                var BY = '${row[9]!.value}';
                var CHQ_NO = '${row[10]!.value}';
                var BC = '${row[11]!.value}';
                var RC = '${row[12]!.value}';

                Map<String, dynamic> map = Map();

                map['ex_no'] = EX_No.toString().trim();
                map['pay_time'] = PAY_TIME.toString().trim();
                map['customer_no'] = CUSTOMER_NO.toString().trim();
                map['customer_name'] = CUSTOMER_NAME.toString().trim();
                map['pay_date'] = PAY_DATE.toString().trim();
                map['referenceno'] = REFERENCE_NO.toString().trim();
                map['referenceno3'] = REFERENCE_NO3.toString().trim();
                map['frbr'] = FR_BR.toString().trim();
                map['amount'] = AMOUNT.toString().trim();
                map['by'] = BY.toString().trim();
                map['chqno'] = CHQ_NO.toString().trim();
                map['bc'] = BC.toString().trim();
                map['rc'] = RC.toString().trim();
                // print(
                //     '$EX_No /$PAY_TIME /$CUSTOMER_NO /$CUSTOMER_NAME /$PAY_DATE /$REFERENCE_NO /$AMOUNT');
                // BankExcBilling_Model bankExcBillingss =
                //     BankExcBilling_Model.fromJson(map);
                // setState(() {
                //   limitedList_bankExcBilling.add(bankExcBillingss);
                //   // bankExcBilling.add(bankExcBillingss);
                // });
                // print(map);
                // print(limitedList_bankExcBilling.length);
                // limitedList_bankExcBilling.add(map);
                try {
                  BankExcBilling_Model bankExcBillingss =
                      BankExcBilling_Model.fromJson(map);
                  //print(map);
                  setState(() {
                    limitedList_bankExcBilling.add(bankExcBillingss);
                    // bankExcBilling.add(bankExcBillingss);
                  });
                  // for (int i = 0; i < _TransReBillModels.length; i++) {
                  //   if (_TransReBillModels[i].ref1 ==
                  //       REFERENCE_NO.toString().trim()) {
                  //     print(
                  //         'table ---------------- >${_TransReBillModels[i].ref1} ==== ${REFERENCE_NO.toString().trim()}');
                  //     setState(() {
                  //       listchack.add(_TransReBillModels[i].docno.toString());
                  //       limitedList_bankExcBilling.add(bankExcBillingss);
                  //       // bankExcBilling.add(bankExcBillingss);
                  //     });
                  //   }
                  // }
                } catch (e) {}
                // print(map);
                index++;
              }
            }
          }
          setState(() {
            limitedList_bankExcBilling
                .sort((a, b) => b.ref1!.compareTo(a.ref1!));
          });
          // read_Excel_limit();
          bool hasDuplicate = hasDuplicateRef1InList();
          if (hasDuplicate == true) {
            // showDialog_hasDuplicateRef1();
          }
        } else {}
      } else {
        // User canceled the file selection.
        // print('File selection canceled.');
      }
    } catch (e) {
      // print(limitedList_bankExcBilling.length);
      // print('Error selecting or reading the file: $e');
    }
  }
  // Future<Null> read_Excel_limit() async {
  //   setState(() {
  //     endIndex_excel = offset_excel + limit_excel;
  //     bankExcBilling = limitedList_bankExcBilling.sublist(
  //         offset_excel, // Start index
  //         (endIndex_excel <= limitedList_bankExcBilling.length)
  //             ? endIndex_excel
  //             : limitedList_bankExcBilling.length // End index
  //         );
  //   });
  // }

  bool hasDuplicateRef1InList() {
    // Create a Set to keep track of unique ref1 values
    Set<String> uniqueRef1Values = Set<String>();

    // Iterate through the list and check for duplicates
    for (var item in bankExcBilling) {
      if (!uniqueRef1Values.add(item.ref1.toString())) {
        // If add returns false, it means the value is already in the Set
        return true;
      }
    }

    // No duplicates found
    return false;
  }

///////////////////--------------------------------------------------->
  // var daterec;
  // var date;
  // var dateacc;
  // var dtype;
  // var shopno;
  // var pos;
  // var docno;
  // var custno;
  // var supno;
  // var refno;
  // var status;
  // var payload;
  // var trans_ref;
  // var slip_date;
  // var country_code;
  // var amount;
  // var currency;
  // var fee;
  // var ref1;
  // var ref2;
  // var ref3;
  // var sen_bankid;
  // var sen_bankname;
  // var sen_bankshort;
  // var sen_accnameTh;
  // var sen_accnameEn;
  // var sen_banktype;
  // var sen_accnumber;
  // var sen_proxy_type;
  // var sen_proxy_accnumber;
  // var recei_bankid;
  // var recei_bankname;
  // var recei_bankshort;
  // var recei_accnameTh;
  // var recei_accnameEn;
  // var recei_banktype;
  // var recei_accnumber;
  // var recei_proxy_type;
  // var recei_proxy_accnumber;
  // var merchant_Id;
  // var slip_img;
  var datadata = '''
{
  "status": 200,
  "data": {
    "payload": "004600060000010103002022520240116080807230055057085102TH91044463",
    "transRef": "2024011608080723005505708",
    "date": "2024-01-16T08:08:06+07:00",
    "countryCode": "",
    "amount": {
      "amount": 50,
      "local": {
        "amount": 0,
        "currency": ""
      }
    },
    "fee": 0,
    "ref1": "",
    "ref2": "",
    "ref3": "",
    "sender": {
      "bank": {
        "id": "2",
        "name": "ธนาคารกรุงเทพ",
        "short": "BBL"
      },
      "account": {
        "name": [],
        "bank": {
          "type": "BANKAC",
          "account": "399-0-xxx171"
        }
      }
    },
    "receiver": {
      "bank": {
        "id": ""
      },
      "account": {
        "name": {
          "th": "นาง ธนษา ป",
          "en": "THANASA P"
        },
        "proxy": {
          "type": "MSISDN",
          "account": "093-xxx-2295"
        }
      }
    }
  }
}
  ''';

  red_easyslip_data() async {
    //var result = json.decode(datadata);
    var fileName = 'Awaitdownload/payment/$fileName_Slip';
    String url = '${MyConstant().domain}/easyslip.php?file=$fileName';
    var response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    // print(result);
    // print('fileName_Slip');
    // print(fileName_Slip);
    var daterec = '';
    var date = '';
    var dateacc = '';
    var dtype = '';
    var shopno = '';
    var pos = '';
    var docno = '';
    var custno = '';
    var supno = '';
    var refno = '';
    ///////------------------------------------------->
    var status = result?['status'];
    var payload = result?['data']?['payload'];
    var trans_ref = result?['data']?['transRef'];
    var slip_date = result?['data']?['date'];
    var country_code = result?['data']?['countryCode'];
    var amount = result?['data']?['amount']?['amount'];
    var currency = result?['data']?['amount']?['local']?['currency'];
    var fee = result?['data']?['fee'];
    var ref1 = result?['data']?['ref1'];
    var ref2 = result?['data']?['ref2'];
    var ref3 = result?['data']?['ref3'];
    // print('**** 1');
    ///////------------------------------------------->
    var sender = result['data']['sender'];
    var sendername = result['data']['sender']['account']['name'];
    ///////-----------**************----------->
    var sen_bankid = sender?['bank']?['id'];

    var sen_bankname = sender?['bank']?['name'];
    var sen_bankshort = sender?['bank']?['short'];

    var sen_accnameTh = (sendername is List) ? '' : sendername?['th'] ?? '';
    var sen_accnameEn = (sendername is List) ? '' : sendername?['en'] ?? '';

    var sen_banktype = sender?['account']?['bank']?['type'];
    var sen_accnumber = sender?['account']?['bank']?['account'];
    var sen_proxy_type = sender?['account']?['proxy']?['type'];
    var sen_proxy_accnumber = sender?['account']?['proxy']?['account'];

    // print('**** 2');
    ///////------------------------------------------->
    var recei_bankid = result?['data']?['receiver']?['bank']?['id'];
    var recei_bankname = result?['data']?['receiver']?['bank']?['name'];
    var recei_bankshort = result?['data']?['receiver']?['bank']?['short'];
    var recei_accnameTh =
        result?['data']?['receiver']?['account']?['name']?['th'];
    var recei_accnameEn =
        result?['data']?['receiver']?['account']?['name']?['en'];
    var recei_banktype =
        result?['data']?['receiver']?['account']?['bank']?['type'];
    var recei_accnumber =
        result?['data']?['receiver']?['account']?['bank']?['account'];
    var recei_proxy_type =
        result?['data']?['receiver']?['account']?['proxy']?['type'];
    var recei_proxy_accnumber =
        result?['data']?['receiver']?['account']?['proxy']?['account'];
    // print('**** 3');
    ///////------------------------------------------->
    var merchant_Id = result?['data']?['receiver']?['merchantId'];
    var slip_img = '';
    // print('**** ');
    // print('**** $recei_accnameTh');
    await InC_easyslip(
        daterec,
        date,
        dateacc,
        dtype,
        shopno,
        pos,
        docno,
        custno,
        supno,
        refno,
        status,
        payload,
        trans_ref,
        slip_date,
        country_code,
        amount,
        currency,
        fee,
        ref1,
        ref2,
        ref3,
        sen_bankid,
        sen_bankname,
        sen_bankshort,
        sen_accnameTh,
        sen_accnameEn,
        sen_banktype,
        sen_accnumber,
        sen_proxy_type,
        sen_proxy_accnumber,
        recei_bankid,
        recei_bankname,
        recei_bankshort,
        recei_accnameTh,
        recei_accnameEn,
        recei_banktype,
        recei_accnumber,
        recei_proxy_type,
        recei_proxy_accnumber,
        merchant_Id,
        slip_img);
  }

///////////////////--------------------------------------------------->

  Future<void> InC_easyslip(
      daterec,
      date,
      dateacc,
      dtype,
      shopno,
      pos,
      docno,
      custno,
      supno,
      refno,
      status,
      payload,
      trans_ref,
      slip_date,
      country_code,
      amount,
      currency,
      fee,
      ref1,
      ref2,
      ref3,
      sen_bankid,
      sen_bankname,
      sen_bankshort,
      sen_accnameTh,
      sen_accnameEn,
      sen_banktype,
      sen_accnumber,
      sen_proxy_type,
      sen_proxy_accnumber,
      recei_bankid,
      recei_bankname,
      recei_bankshort,
      recei_accnameTh,
      recei_accnameEn,
      recei_banktype,
      recei_accnumber,
      recei_proxy_type,
      recei_proxy_accnumber,
      merchant_Id,
      slip_img) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    String url = '${MyConstant().domain}/In_c_easyslip.php?isAdd=true&ren=$ren';
    String Date_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String Time_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var response = await http.post(Uri.parse(url), body: {
      'isAdd': 'true',
      'ren': '$ren',
      'user': '$user',
      'daterec': Date_now,
      'date': Date_now,
      'dateacc': Date_now,
      'dtype': 'KP',
      'shopno': '1',
      'pos': '1',
      'docno': '',
      'custno': '',
      'supno': '',
      'refno': '',
      'status': (status == null) ? '' : status.toString(),
      'payload': (payload == null) ? '' : payload.toString(),
      'trans_ref': (trans_ref == null) ? '' : trans_ref.toString(),
      'slip_date': (slip_date == null) ? '' : slip_date.toString(),
      'country_code': (country_code == null) ? '' : country_code.toString(),
      'amount': (amount == null) ? '' : amount.toString(),
      'currency': (currency == null) ? '' : currency.toString(),
      'fee': (fee == null) ? '' : fee.toString(),
      'ref1': (ref1 == null) ? '' : ref1.toString(),
      'ref2': (ref2 == null) ? '' : ref2.toString(),
      'ref3': (ref3 == null) ? '' : ref3.toString(),
      'sen_bankname': (sen_bankname == null) ? '' : sen_bankname.toString(),
      'sen_bankshort': (sen_bankshort == null) ? '' : sen_bankshort.toString(),
      'sen_accnameTh': (sen_accnameTh == null) ? '' : sen_accnameTh.toString(),
      'sen_accnameEn': (sen_accnameEn == null) ? '' : sen_accnameEn.toString(),
      'sen_banktype': (sen_banktype == null) ? '' : sen_banktype.toString(),
      'sen_accnumber': (sen_accnumber == null) ? '' : sen_accnumber.toString(),
      'sen_proxy_type':
          (sen_proxy_type == null) ? '' : sen_proxy_type.toString(),
      'sen_proxy_accnumber':
          (sen_proxy_accnumber == null) ? '' : sen_proxy_accnumber.toString(),
      'recei_bankid': (recei_bankid == null) ? '' : recei_bankid.toString(),
      'recei_bankname':
          (recei_bankname == null) ? '' : recei_bankname.toString(),
      'recei_bankshort':
          (recei_bankshort == null) ? '' : recei_bankshort.toString(),
      'recei_accnameTh':
          (recei_accnameTh == null) ? '' : recei_accnameTh.toString(),
      'recei_accnameEn':
          (recei_accnameEn == null) ? '' : recei_accnameEn.toString(),
      'recei_banktype':
          (recei_banktype == null) ? '' : recei_banktype.toString(),
      'recei_accnumber':
          (recei_accnumber == null) ? '' : recei_accnumber.toString(),
      'recei_proxy_type':
          (recei_proxy_type == null) ? '' : recei_proxy_type.toString(),
      'recei_proxy_accnumber': (recei_proxy_accnumber == null)
          ? ''
          : recei_proxy_accnumber.toString(),
      'merchant_Id': (merchant_Id == null) ? '' : merchant_Id.toString(),
      'slip_img': '$fileName_Slip',
      'directions': '1',
    }).then((value) async {
      if (value.toString() != 'No') {
        var result = json.decode(value.body);
        var payload, Sernow;
        for (var map in result) {
          easyslipModel easyslipModelss = easyslipModel.fromJson(map);
          // print(easyslipModelss.payload);
          setState(() {
            payload = easyslipModelss.payload!;
            Sernow = easyslipModelss.ser!;
          });
        }
        await InC_financetestSlip(
          payload,
          Sernow,
        );
      }
    });
  }

  Future<void> InC_financetestSlip(
    payload,
    Sernow,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/In_finance_testSlip.php?isAdd=true&ren=$ren';
    String Date_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String Time_now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // daterec,pdate
    var response = await http.post(Uri.parse(url), body: {
      'isAdd': 'true',
      'ren': '$ren',
      'user': '$user',
      'daterec': '${myController2.text}',
      'pdate': '${myController3.text}',
      'docno': '${myController4.text}',
      'remark': '${myController5.text}',
      'refno': '${myController1.text}',
      'payload': payload.toString(),
      'slip_img': '$fileName_Slip',
      'amount': '${myController6.text}',
      'sernow': '$Sernow',
    }).then((value) async {
      var result = json.decode(value.body);
      // print(result);
      setState(() {
        ser_adddata = 0;
        index_Test = null;
        myController1.clear();
        myController2.clear();
        myController3.clear();
        myController4.clear();
        myController5.clear();
        myController6.clear();
        fileName_Slip = null;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[50],
          content: Translate.TranslateAndSetText(
              'ทำรายการเสร็จสิ้น !!!!',
              AccountScreen_Color.Colors_Text1_,
              TextAlign.start,
              null,
              Font_.Fonts_T,
              14,
              1),
          // Text('ทำรายการเสร็จสิ้น !!!!')
        ),
      );
    });
  }

  /////////////---------------------------------------------------->
  Dialog_cancellock() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ยกเลิกการรับชำระ เสร็จสิ้น ...!!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        Navigator.pop(context);

        red_Trans_bill();

        // String? _route = preferences.getString('route');
        // MaterialPageRoute materialPageRoute = MaterialPageRoute(
        //     builder: (BuildContext context) => AdminScafScreen(route: _route));
        // Navigator.pushAndRemoveUntil(
        //     context, materialPageRoute, (route) => false);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }
}
