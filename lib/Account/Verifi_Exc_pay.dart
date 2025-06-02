import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/Get_ExcReceivable_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

class Verifi_Exc_Pay extends StatefulWidget {
  final transReChackBillModels;
  final MONTH_Now;
  final YEAR_Now;
  const Verifi_Exc_Pay(
      {super.key, this.transReChackBillModels, this.MONTH_Now, this.YEAR_Now});

  @override
  State<Verifi_Exc_Pay> createState() => _Verifi_Exc_PayState();
}

class _Verifi_Exc_PayState extends State<Verifi_Exc_Pay> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  DateTime datex = DateTime.now();
  int Ser_Tap = 0;

  ///------------------------>
  List<PayMentModel> _PayMentModels = [];
  List<BankExcBilling_Model> limitedList_bankExcBilling = [];

  ///------------------------>
  List Default_ = [
    'บิลธรรมดา',
  ];
  List Default2_ = [
    'บิลธรรมดา',
    'ใบกำกับภาษี',
  ];
  String? renTal_user, renTal_name, zone_ser, zone_name;
  String? renTal_Ser, Value_cid, fname_, pdate;
  String? cFinn,
      doctax,
      paymentSer1,
      paymentSer2,
      paymentName1,
      selectedValue,
      bname1,
      bills_name_,
      bill_tser;
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
      foder,
      api_key,
      time_check,
      Auto_cancel;

  ///------------------------>
  List<String> YE_Th = [];

  String? MONTH_Now, YEAR_Now;
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
    // TODO: implement initState
    super.initState();
    checkPreferance();
    read_GC_rental();
    red_payMent();
    ;
  }

  System_New_Update() async {
    // String accept_ = showst_update_!;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Translate.TranslateAndSetText('📢ขออภัย !!!!', Colors.red,
            TextAlign.end, null, Font_.Fonts_T, 14, 1),
        //  const Text(
        //   '📢ขออภัย !!!!',
        //   textAlign: TextAlign.end,
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: Colors.red,
        //     fontFamily: Font_.Fonts_T,
        //   ),
        // ),
        content: Container(
          width: 300,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/pngegg.png"),
              // fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Translate.TranslateAndSetText(
                      'ฟังก์ชั่นก์ ตรวจสอบการชำระ-Excel อยู่ในช่วงปรับปรุงพัฒนา...',
                      Colors.red,
                      TextAlign.center,
                      null,
                      Font_.Fonts_T,
                      16,
                      4),
                  //  Text(
                  //   'ฟังก์ชั่นก์ ตรวจสอบการชำระวางบิล ใช้ได้เฉพาะบัญชีธนาคารที่มี Online Standard QR กับทางธนาคารเท่านั้น ..!!!!!!',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Colors.red,
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: FontWeight_.Fonts_T,
                  //   ),
                  // ),
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
                        child: Translate.TranslateAndSetText(
                            'รับทราบ',
                            Colors.white,
                            TextAlign.start,
                            null,
                            Font_.Fonts_T,
                            14,
                            1),
                        // const Text(
                        //   'รับทราบ',
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
          )
        ],
      ),
    );
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
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
  }

  ///////////--------------------------------------------->
  Future<Null> read_GC_rental() async {
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

            if (billDefaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    System_New_Update();
    // print('name>>>>>  $renname');
  }

  ///////////--------------------------------------------->
  Future<Null> red_payMent() async {
    // if (_PayMentModels.length != 0) {
    //   setState(() {
    //     _PayMentModels.clear();
    //   });
    // }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['datex'] = '';
      map['timex'] = '';
      map['ptser'] = '';
      map['ptname'] = 'เลือก';
      map['bser'] = '';
      map['bank'] = '';
      map['bno'] = '';
      map['bname'] = '';
      map['bsaka'] = '';
      map['btser'] = '';
      map['btype'] = '';
      map['st'] = '1';
      map['rser'] = '';
      map['accode'] = '';
      map['co'] = '';
      map['data_update'] = '';
      map['auto'] = '0';
      map['fine'] = '0';
      map['fine_a'] = '0';
      map['fine_c'] = '0';

      PayMentModel _PayMentModel = PayMentModel.fromJson(map);

      setState(() {
        _PayMentModels.add(_PayMentModel);
      });
      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);

          setState(() {
            if (_PayMentModel.ptser == '6') {
              _PayMentModels.add(_PayMentModel);
              // paymentSer1 = serx.toString();
              // paymentName1 = ptnamex.toString();
              // selectedValue = _PayMentModel.bno.toString();
              // bname1 = _PayMentModel.bname.toString();
              // fine_total = fine_amt;
            }
          });
        }
      }
    } catch (e) {}
  }

  List<String> listchack = [];

  ///------------------------------------------------------------->
  Future<void> selectFileAndReadExcel() async {
    int index = 0;

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
                print(
                    '$EX_No /$PAY_TIME /$CUSTOMER_NO /$CUSTOMER_NAME /$PAY_DATE /$REFERENCE_NO /$AMOUNT');
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
                  print(map);
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
          // setState(() {
          //   limitedList_bankExcBilling
          //       .sort((a, b) => b.ref1!.compareTo(a.ref1!));
          // });
          // // read_Excel_limit();
          // bool hasDuplicate = hasDuplicateRef1InList();
          // if (hasDuplicate == true) {
          //   // showDialog_hasDuplicateRef1();
          // }
        } else {}
      } else {
        // User canceled the file selection.
        print('File selection canceled.');
      }
    } catch (e) {
      print(limitedList_bankExcBilling.length);
      print('Error selecting or reading the file: $e');
    }
  }

  ///////////--------------------------------------------->

  ScrollController _scrollController2 = ScrollController();
  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(children: [
          Container(
              decoration: const BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              width: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.88
                  : 1200,
              child: Column(children: [
                ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        dragStartBehavior: DragStartBehavior.start,
                        child: Row(children: [
                          SizedBox(
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.88
                                  : 1200,
                              child: Column(children: [
                                Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width * 0.88
                                      : 1200,
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
                                      const Divider(
                                        height: 2,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 0, 4, 0),
                                        child: Container(
                                          color: (Ser_Tap == 0)
                                              ? Colors.green[100]!
                                                  .withOpacity(0.5)
                                              : Colors.orange[100]!
                                                  .withOpacity(0.5),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(),
                                                Translate.TranslateAndSetText(
                                                    (Ser_Tap == 0)
                                                        ? 'ข้อมูลที่ได้จาก Excel ( ${limitedList_bankExcBilling.length} ) && ข้อมูลชำระรอตรวจสอบ (${widget.transReChackBillModels.length})'
                                                        : 'ผลการเปรียบเทียบ',
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.start,
                                                    null,
                                                    Font_.Fonts_T,
                                                    14,
                                                    1),
                                                if (api_key == 'Y')
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 40, 0),
                                                    child: Container(
                                                      // color: Colors.green,
                                                      decoration: BoxDecoration(
                                                        color: Colors.purple,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                        // border: Border.all(color: Colors.white, width: 1),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            // red_Chack_Trans_bill();
                                                            selectFileAndReadExcel();
                                                          },
                                                          child: const Text(
                                                            "Check Payment Excel",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ]),
                                        ),
                                      ),
                                      const Divider(
                                        height: 2,
                                      ),
                                      if (widget.MONTH_Now != null &&
                                          widget.YEAR_Now != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Translate.TranslateAndSetText(
                                                'เดือน : ${widget.MONTH_Now} ปี :  ${widget.YEAR_Now}',
                                                AccountScreen_Color
                                                    .Colors_Text1_,
                                                TextAlign.start,
                                                null,
                                                Font_.Fonts_T,
                                                14,
                                                1),
                                          ],
                                        ),
                                      const Divider(
                                        height: 2,
                                      ),
                                      const Divider(
                                        height: 2,
                                      ),
                                      if (Ser_Tap == 0 &&
                                          !limitedList_bankExcBilling.isEmpty)
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'No.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'PAY.TIME',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'CUSTOMER NO.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'CUSTOMER NAME',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'PAY.DATE',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'REFERENCE NO.',
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'REFERENCE NO.3',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'FR BR.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'AMOUNT',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'BY',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'CHQ.NO.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'BC.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                'RC.',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
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
                                                '...',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ManageScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (Ser_Tap == 1)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                '...',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'เลขสัญญา',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'เลขสัญญา',
                                                //   textAlign: TextAlign.center,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'เลขที่ใบแจ้งหนี้',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'เลขที่ใบแจ้งหนี้',
                                                //   textAlign: TextAlign.start,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'วันที่ออกใบแจ้งหนี้',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'วันที่ออกใบแจ้งหนี้',
                                                //   textAlign: TextAlign.start,
                                                //   maxLines: 1,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'วันที่ครบกำหนดชำระ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'วันที่ครบกำหนดชำระ',
                                                //   textAlign: TextAlign.start,
                                                //   maxLines: 1,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'วันที่ครบกำหนดชำระ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),

                                                // Text(
                                                //   'ชื่อร้านค้า',
                                                //   textAlign: TextAlign.center,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              // Expanded(
                                              //   flex: 1,
                                              //   child: Text(
                                              //     'โซน',
                                              //     textAlign: TextAlign.start,
                                              //     style: TextStyle(
                                              //       color: ManageScreen_Color
                                              //           .Colors_Text1_,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontFamily:
                                              //           FontWeight_.Fonts_T,
                                              //     ),
                                              //   ),
                                              // ),
                                              // Expanded(
                                              //   flex: 1,
                                              //   child: Text(
                                              //     'รหัสพื้นที่',
                                              //     textAlign: TextAlign.start,
                                              //     style: TextStyle(
                                              //       color: ManageScreen_Color
                                              //           .Colors_Text1_,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontFamily:
                                              //           FontWeight_.Fonts_T,
                                              //     ),
                                              //   ),
                                              // ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ช่องทางชำระ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),

                                                // Text(
                                                //   'ช่องทางชำระ',
                                                //   textAlign: TextAlign.center,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'บัญชี',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                                // Text(
                                                //   'บัญชี',
                                                //   textAlign: TextAlign.center,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              // Expanded(
                                              //   flex: 1,
                                              //   child: Text(
                                              //     'ส่วนลด',
                                              //     textAlign: TextAlign.end,
                                              //     style: TextStyle(
                                              //       color: ManageScreen_Color
                                              //           .Colors_Text1_,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontFamily:
                                              //           FontWeight_.Fonts_T,
                                              //     ),
                                              //   ),
                                              // ),
                                              // Expanded(
                                              //   flex: 1,
                                              //   child: Text(
                                              //     'ยอดรวม',
                                              //     textAlign: TextAlign.center,
                                              //     style: TextStyle(
                                              //       color: ManageScreen_Color
                                              //           .Colors_Text1_,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontFamily:
                                              //           FontWeight_.Fonts_T,
                                              //     ),
                                              //   ),
                                              // ),
                                              Expanded(
                                                flex: 1,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ยอดรวมสุทธิ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.end,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),

                                                // Text(
                                                //   'ยอดรวมสุทธิ',
                                                //   textAlign: TextAlign.end,
                                                //   style: TextStyle(
                                                //     color: ManageScreen_Color
                                                //         .Colors_Text1_,
                                                //     fontWeight: FontWeight.bold,
                                                //     fontFamily:
                                                //         FontWeight_.Fonts_T,
                                                //   ),
                                                // ),
                                              ),
                                              const Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  // onTap: () {
                                                  //   for (var index = 0;
                                                  //       index <
                                                  //           _TransModels.length;
                                                  //       index++) {
                                                  //     de_Trans_item_inv(index);
                                                  //   }
                                                  // },
                                                  child: Text(
                                                    '...',
                                                    // 'ยอดชำระรวม ${nFormat.format(sum_amt + sum_fine + (fine_total * _TransModels.length))}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
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
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.63,
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.88
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
                                    child: (Ser_Tap == 1)
                                        ? SizedBox()
                                        : limitedList_bankExcBilling.isEmpty
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red[100],
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(10),
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Translate
                                                          .TranslateAndSetText(
                                                              'กรุณาอัพโหลด : Excel.. !!!',
                                                              AccountScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.end,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                      //  const Text(
                                                      //   'กรุณาอัพโหลด : Excel.. !!!',
                                                      //   style: TextStyle(
                                                      //     color:
                                                      //         AccountScreen_Color
                                                      //             .Colors_Text1_,
                                                      //     // fontWeight: FontWeight.bold,
                                                      //     fontFamily:
                                                      //         Font_.Fonts_T,
                                                      //     //fontSize: 10.0
                                                      //   ),
                                                      // ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ListView.builder(
                                                controller: _scrollController2,
                                                // itemExtent: 50,
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    limitedList_bankExcBilling
                                                        .length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Column(
                                                    children: [
                                                      Material(
                                                        child: Container(
                                                          child: ListTile(
                                                              // onTap:
                                                              //     () async {
                                                              //   setState(() {
                                                              //     tappedIndex_ =
                                                              //         '${index}';
                                                              //   });
                                                              // },
                                                              title: Container(
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
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].ex_no}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].pay_time}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
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
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].customer_no}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
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
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].customer_name}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].pay_date}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
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
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].referenceno}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      // fontSize: 12.0
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].referenceno3}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      //fontSize: 12.0
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].frbr}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].amount}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].by}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].chqno}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].bc}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${limitedList_bankExcBilling[index].rc}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight:
                                                                      //     FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                })),
                                Container(
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width * 88
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    _scrollController2
                                                        .animateTo(
                                                      0,
                                                      duration: const Duration(
                                                          seconds: 1),
                                                      curve: Curves.easeOut,
                                                    );
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        // color: AppbackgroundColor
                                                        //     .TiTile_Colors,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(6),
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
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      child: const Text(
                                                        'Top',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_scrollController2
                                                      .hasClients) {
                                                    final position =
                                                        _scrollController2
                                                            .position
                                                            .maxScrollExtent;
                                                    _scrollController2
                                                        .animateTo(
                                                      position,
                                                      duration: const Duration(
                                                          seconds: 1),
                                                      curve: Curves.easeOut,
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      // color: AppbackgroundColor
                                                      //     .TiTile_Colors,
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: const Text(
                                                      'Down',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
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
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: const Text(
                                                    'Scroll',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                              InkWell(
                                                onTap: _moveDown2,
                                                child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
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
                                const SizedBox(
                                  height: 20,
                                )
                              ])),
                        ])))
              ]))
        ]));
  }
}
